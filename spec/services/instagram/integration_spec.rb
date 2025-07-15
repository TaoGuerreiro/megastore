# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Instagram Services Integration", type: :service do
  let(:user) { create(:user) }
  let(:campagne) { create(:social_campagne, user: user) }
  let(:username) { "test_user" }
  let(:password) { "test_password" }

  describe "EngagementService avec SocialTargets" do
    before do
      # S'assurer que la campagne existe
      user.create_social_campagne!(status: "active", name: "Campagne principale") unless user.social_campagne
      create(:hashtag_target, social_campagne: user.social_campagne, name: "fashion", cursor: "cursor123")
      create(:account_target, social_campagne: user.social_campagne, name: "influenceur", cursor: "cursor456")
    end

    it "récupère la configuration utilisateur correctement" do
      config = Instagram::EngagementService.get_user_config(user)

      expect(config["hashtags"].size).to eq(1)
      expect(config["hashtags"].first["hashtag"]).to eq("fashion")
      expect(config["hashtags"].first["cursor"]).to eq("cursor123")

      expect(config["targeted_accounts"].size).to eq(1)
      expect(config["targeted_accounts"].first["account"]).to eq("influenceur")
      expect(config["targeted_accounts"].first["cursor"]).to eq("cursor456")
    end

    it "met à jour les targets utilisateur" do
      hashtags = [
        { "hashtag" => "style", "cursor" => "new_cursor" },
        "beauty"
      ]
      targeted_accounts = [
        { "account" => "celebrity", "cursor" => "celebrity_cursor" },
        "model"
      ]

      Instagram::EngagementService.update_user_targets(user, hashtags: hashtags, targeted_accounts: targeted_accounts)

      # Vérifier les hashtags
      style_target = user.social_campagne.social_targets.find_by(kind: "hashtag", name: "style")
      beauty_target = user.social_campagne.social_targets.find_by(kind: "hashtag", name: "beauty")

      expect(style_target).to be_present
      expect(style_target.cursor).to eq("new_cursor")
      expect(beauty_target).to be_present
      expect(beauty_target.cursor).to be_nil

      # Vérifier les comptes ciblés
      celebrity_target = user.social_campagne.social_targets.find_by(kind: "account", name: "celebrity")
      model_target = user.social_campagne.social_targets.find_by(kind: "account", name: "model")

      expect(celebrity_target).to be_present
      expect(celebrity_target.cursor).to eq("celebrity_cursor")
      expect(model_target).to be_present
      expect(model_target.cursor).to be_nil
    end

    it "met à jour les cursors depuis un résultat" do
      result = {
        "sessions" => [
          {
            "hashtag_likes" => {
              "fashion" => { "cursor" => "new_fashion_cursor" }
            },
            "follower_likes" => {
              "influenceur" => { "cursor" => "new_influenceur_cursor" }
            }
          }
        ]
      }

      Instagram::EngagementService.update_cursors_from_result(result, user, user.social_campagne)

      fashion_target = user.social_campagne.social_targets.find_by(kind: "hashtag", name: "fashion")
      influenceur_target = user.social_campagne.social_targets.find_by(kind: "account", name: "influenceur")

      expect(fashion_target.cursor).to eq("new_fashion_cursor")
      expect(influenceur_target.cursor).to eq("new_influenceur_cursor")
    end

    it "met à jour les statistiques depuis un résultat" do
      result = {
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

      Instagram::EngagementService.update_stats_from_result(result, user, user.social_campagne)

      fashion_target = user.social_campagne.social_targets.find_by(kind: "hashtag", name: "fashion")
      influenceur_target = user.social_campagne.social_targets.find_by(kind: "account", name: "influenceur")

      expect(fashion_target.total_likes).to eq(2)
      expect(fashion_target.posts_liked).to eq(["post_123", "post_456"])
      expect(fashion_target.last_activity).to be_present

      expect(influenceur_target.total_likes).to eq(1)
      expect(influenceur_target.posts_liked).to eq(["post_789"])
      expect(influenceur_target.last_activity).to be_present
    end
  end

  describe "SocialTarget méthodes" do
    let(:target) { create(:hashtag_target, social_campagne: campagne) }

    it "gère les posts likés correctement" do
      expect(target.has_liked_post?("post_123")).to be false

      target.add_liked_post("post_123")
      expect(target.has_liked_post?("post_123")).to be true
      expect(target.total_likes).to eq(1)

      target.add_liked_post("post_456")
      expect(target.has_liked_post?("post_456")).to be true
      expect(target.total_likes).to eq(2)

      # Ne pas ajouter le même post deux fois
      target.add_liked_post("post_123")
      expect(target.posts_liked).to eq(["post_123", "post_456"])
      expect(target.total_likes).to eq(3) # Mais incrémente quand même
    end

    it "remet à zéro les statistiques" do
      target.add_liked_post("post_123")
      target.add_liked_post("post_456")

      expect(target.total_likes).to eq(2)
      expect(target.posts_liked).to eq(["post_123", "post_456"])
      expect(target.last_activity).to be_present

      target.reset_stats

      expect(target.total_likes).to eq(0)
      expect(target.posts_liked).to eq([])
      expect(target.last_activity).to be_nil
    end
  end

  describe "SocialCampagne associations" do
    it "gère les associations correctement" do
      expect(campagne.user).to eq(user)
      expect(user.social_campagne).to eq(campagne)

      hashtag_target = create(:hashtag_target, social_campagne: campagne)
      account_target = create(:account_target, social_campagne: campagne)

      expect(campagne.social_targets).to include(hashtag_target, account_target)
      expect(campagne.social_targets.where(kind: "hashtag")).to contain_exactly(hashtag_target)
      expect(campagne.social_targets.where(kind: "account")).to contain_exactly(account_target)
    end

    it "supprime les targets quand la campagne est supprimée" do
      hashtag_target = create(:hashtag_target, social_campagne: campagne)
      account_target = create(:account_target, social_campagne: campagne)

      expect { campagne.destroy }.to change { SocialTarget.count }.by(-2)
    end
  end

  describe "Validation des données" do
    it "valide l'unicité des noms par campagne et type" do
      create(:hashtag_target, social_campagne: campagne, name: "fashion")

      duplicate = build(:hashtag_target, social_campagne: campagne, name: "fashion")
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:name]).to include("déjà utilisé pour ce type et cette campagne")
    end

    it "permet le même nom pour des types différents" do
      create(:hashtag_target, social_campagne: campagne, name: "fashion")

      account_target = build(:account_target, social_campagne: campagne, name: "fashion")
      expect(account_target).to be_valid
    end

    it "valide les types de kind" do
      invalid_target = build(:social_target, kind: "invalid")
      expect(invalid_target).not_to be_valid
      expect(invalid_target.errors[:kind]).to include("n'est pas inclus(e) dans la liste")
    end

    it "valide total_likes positif" do
      target = build(:social_target, total_likes: -1)
      expect(target).not_to be_valid
      expect(target.errors[:total_likes]).to include("doit être supérieur ou égal à 0")
    end
  end
end
