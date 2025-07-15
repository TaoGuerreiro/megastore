# frozen_string_literal: true

require "rails_helper"

RSpec.describe Instagram::EngagementService do
  let(:user) { create(:user) }
  let(:campagne) { create(:social_campagne, user: user) }
  let(:hashtag_target) { create(:hashtag_target, social_campagne: campagne) }
  let(:account_target) { create(:account_target, social_campagne: campagne) }

  describe ".call" do
    let(:accounts_config) do
      [
        {
          "username" => "test_user",
          "password" => "test_password",
          "hashtags" => [{ "hashtag" => "fashion", "cursor" => "cursor123" }],
          "targeted_accounts" => [{ "account" => "influenceur", "cursor" => "cursor456" }]
        }
      ]
    end

    let(:temp_file) { instance_double(Tempfile) }

    before do
      allow(Tempfile).to receive(:new).and_return(temp_file)
      allow(temp_file).to receive(:write)
      allow(temp_file).to receive(:rewind)
      allow(temp_file).to receive(:path).and_return("/tmp/test_config.json")
      allow(temp_file).to receive(:close)
      allow(temp_file).to receive(:unlink)
      allow(Instagram::BaseService).to receive(:execute_script).and_return({ "success" => true })
    end

    it "exécute le service avec succès" do
      result = described_class.call(accounts_config)

      expect(result).to eq({ "success" => true })
      expect(Instagram::BaseService).to have_received(:execute_script).with("engagement.py", "/tmp/test_config.json")
    end

    it "exécute le service avec campagne_id" do
      result = described_class.call(accounts_config, 123)

      expect(result).to eq({ "success" => true })
      expect(Instagram::BaseService).to have_received(:execute_script).with("engagement.py", "/tmp/test_config.json", "--campagne-id", "123")
    end

    it "nettoie le fichier temporaire même en cas d'erreur" do
      allow(Instagram::BaseService).to receive(:execute_script).and_raise("Erreur test")

      expect { described_class.call(accounts_config) }.to raise_error("Erreur test")
      expect(temp_file).to have_received(:close)
      expect(temp_file).to have_received(:unlink)
    end

    context "validation de la configuration" do
      it "lève une erreur si accounts_config n'est pas un array" do
        expect { described_class.call("invalid") }.to raise_error(ArgumentError, /accounts_config doit être un array/)
      end

      it "lève une erreur si accounts_config est vide" do
        expect { described_class.call([]) }.to raise_error(ArgumentError, /accounts_config ne peut pas être vide/)
      end

      it "lève une erreur si un compte manque de champs requis" do
        invalid_config = [{ "username" => "test" }]
        expect { described_class.call(invalid_config) }.to raise_error(ArgumentError, /champ 'password' manquant/)
      end

      it "lève une erreur si username est vide" do
        invalid_config = [{ "username" => "", "password" => "test", "hashtags" => [], "targeted_accounts" => [] }]
        expect { described_class.call(invalid_config) }.to raise_error(ArgumentError, /username ne peut pas être vide/)
      end

      it "lève une erreur si password est vide" do
        invalid_config = [{ "username" => "test", "password" => "", "hashtags" => [], "targeted_accounts" => [] }]
        expect { described_class.call(invalid_config) }.to raise_error(ArgumentError, /password ne peut pas être vide/)
      end

      it "lève une erreur si hashtags n'est pas un array" do
        invalid_config = [{ "username" => "test", "password" => "test", "hashtags" => "invalid", "targeted_accounts" => [] }]
        expect { described_class.call(invalid_config) }.to raise_error(ArgumentError, /hashtags doit être un array/)
      end

      it "lève une erreur si targeted_accounts n'est pas un array" do
        invalid_config = [{ "username" => "test", "password" => "test", "hashtags" => [], "targeted_accounts" => "invalid" }]
        expect { described_class.call(invalid_config) }.to raise_error(ArgumentError, /targeted_accounts doit être un array/)
      end

      it "lève une erreur si aucun hashtag ni compte cible n'est spécifié" do
        invalid_config = [{ "username" => "test", "password" => "test", "hashtags" => [], "targeted_accounts" => [] }]
        expect { described_class.call(invalid_config) }.to raise_error(ArgumentError, /au moins un hashtag ou un compte cible doit être spécifié/)
      end
    end
  end

  describe ".call_from_user" do
    let(:username) { "test_user" }
    let(:password) { "test_password" }

    before do
      allow(described_class).to receive(:call).and_return({ "success" => true })
      allow(described_class).to receive(:update_cursors_from_result)
      # S'assurer que la campagne existe
      user.create_social_campagne!(status: "active", name: "Campagne principale") unless user.social_campagne
    end

    it "appelle le service avec la configuration de l'utilisateur" do
      result = described_class.call_from_user(user, username, password)

      expect(described_class).to have_received(:call).with(
        [{
          "username" => username,
          "password" => password,
          "hashtags" => [],
          "targeted_accounts" => [],
          "social_campagne_id" => user.social_campagne.id
        }],
        user.social_campagne.id
      )
      expect(result).to eq({ "success" => true })
    end

    it "utilise les hashtags et comptes ciblés fournis" do
      hashtags = [{ "hashtag" => "fashion", "cursor" => "cursor123" }]
      targeted_accounts = [{ "account" => "influenceur", "cursor" => "cursor456" }]

      described_class.call_from_user(user, username, password, hashtags: hashtags, targeted_accounts: targeted_accounts)

      expect(described_class).to have_received(:call).with(
        [{
          "username" => username,
          "password" => password,
          "hashtags" => hashtags,
          "targeted_accounts" => targeted_accounts,
          "social_campagne_id" => user.social_campagne.id
        }],
        user.social_campagne.id
      )
    end

    it "utilise la campagne fournie" do
      custom_campagne = create(:social_campagne, user: user)

      described_class.call_from_user(user, username, password, social_campagne: custom_campagne)

      expect(described_class).to have_received(:call).with(
        [{
          "username" => username,
          "password" => password,
          "hashtags" => [],
          "targeted_accounts" => [],
          "social_campagne_id" => custom_campagne.id
        }],
        custom_campagne.id
      )
    end

    it "met à jour les cursors depuis le résultat" do
      result = { "sessions" => [{ "hashtag_likes" => { "fashion" => { "cursor" => "new_cursor" } } }] }
      allow(described_class).to receive(:call).and_return(result)

      described_class.call_from_user(user, username, password)

      expect(described_class).to have_received(:update_cursors_from_result).with(result, user, user.social_campagne)
    end
  end

  describe ".get_user_config" do
    before do
      create(:hashtag_target, social_campagne: campagne, name: "fashion", cursor: "cursor123")
      create(:account_target, social_campagne: campagne, name: "influenceur", cursor: "cursor456")
    end

    it "retourne la configuration de l'utilisateur" do
      result = described_class.get_user_config(user)

      expect(result["hashtags"]).to contain_exactly(
        {
          "hashtag" => "fashion",
          "cursor" => "cursor123",
          "social_target_id" => campagne.social_targets.find_by(kind: "hashtag", name: "fashion").id,
          "social_campagne_id" => campagne.id
        }
      )

      expect(result["targeted_accounts"]).to contain_exactly(
        {
          "account" => "influenceur",
          "cursor" => "cursor456",
          "social_target_id" => campagne.social_targets.find_by(kind: "account", name: "influenceur").id,
          "social_campagne_id" => campagne.id
        }
      )
    end
  end

  describe ".update_user_targets" do
    it "crée ou met à jour les hashtags" do
      hashtags = [
        { "hashtag" => "fashion", "cursor" => "cursor123" },
        "style"
      ]

      described_class.update_user_targets(user, hashtags: hashtags)

      fashion_target = user.social_campagne.social_targets.find_by(kind: "hashtag", name: "fashion")
      style_target = user.social_campagne.social_targets.find_by(kind: "hashtag", name: "style")

      expect(fashion_target).to be_present
      expect(fashion_target.cursor).to eq("cursor123")
      expect(style_target).to be_present
      expect(style_target.cursor).to be_nil
    end

    it "crée ou met à jour les comptes ciblés" do
      targeted_accounts = [
        { "account" => "influenceur", "cursor" => "cursor456" },
        "celebrity"
      ]

      described_class.update_user_targets(user, targeted_accounts: targeted_accounts)

      influenceur_target = user.social_campagne.social_targets.find_by(kind: "account", name: "influenceur")
      celebrity_target = user.social_campagne.social_targets.find_by(kind: "account", name: "celebrity")

      expect(influenceur_target).to be_present
      expect(influenceur_target.cursor).to eq("cursor456")
      expect(celebrity_target).to be_present
      expect(celebrity_target.cursor).to be_nil
    end
  end

  describe ".update_cursors_from_result" do
    let(:result) do
      {
        "sessions" => [
          {
            "hashtag_likes" => {
              "fashion" => { "cursor" => "new_hashtag_cursor" }
            },
            "follower_likes" => {
              "influenceur" => { "cursor" => "new_account_cursor" }
            }
          }
        ]
      }
    end

    before do
      create(:hashtag_target, social_campagne: campagne, name: "fashion")
      create(:account_target, social_campagne: campagne, name: "influenceur")
    end

    it "met à jour les cursors des hashtags" do
      described_class.update_cursors_from_result(result, user, campagne)

      fashion_target = campagne.social_targets.find_by(kind: "hashtag", name: "fashion")
      expect(fashion_target.cursor).to eq("new_hashtag_cursor")
    end

    it "met à jour les cursors des comptes ciblés" do
      described_class.update_cursors_from_result(result, user, campagne)

      influenceur_target = campagne.social_targets.find_by(kind: "account", name: "influenceur")
      expect(influenceur_target.cursor).to eq("new_account_cursor")
    end

    it "met à jour les statistiques" do
      allow(described_class).to receive(:update_stats_from_result)

      described_class.update_cursors_from_result(result, user, campagne)

      expect(described_class).to have_received(:update_stats_from_result).with(result, user, campagne)
    end
  end

  describe ".update_stats_from_result" do
    let(:result) do
      {
        "sessions" => [
          {
            "hashtag_likes" => {
              "fashion" => {
                "posts_liked" => ["post_123", "post_456"],
                "successful" => 2
              }
            },
            "follower_likes" => {
              "influenceur" => {
                "posts_liked" => ["post_789"],
                "likes" => 1
              }
            }
          }
        ]
      }
    end

    before do
      create(:hashtag_target, social_campagne: campagne, name: "fashion")
      create(:account_target, social_campagne: campagne, name: "influenceur")
    end

    it "met à jour les statistiques des hashtags" do
      described_class.update_stats_from_result(result, user, campagne)

      fashion_target = campagne.social_targets.find_by(kind: "hashtag", name: "fashion")
      expect(fashion_target.total_likes).to eq(2)
      expect(fashion_target.posts_liked).to eq(["post_123", "post_456"])
      expect(fashion_target.last_activity).to be_present
    end

    it "met à jour les statistiques des comptes ciblés" do
      described_class.update_stats_from_result(result, user, campagne)

      influenceur_target = campagne.social_targets.find_by(kind: "account", name: "influenceur")
      expect(influenceur_target.total_likes).to eq(1)
      expect(influenceur_target.posts_liked).to eq(["post_789"])
      expect(influenceur_target.last_activity).to be_present
    end
  end
end
