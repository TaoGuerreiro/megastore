# frozen_string_literal: true

require "rails_helper"

RSpec.describe SocialTarget, type: :model do
  describe "associations" do
    it { should belong_to(:social_campagne) }
  end

  describe "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:kind) }
    it { should validate_presence_of(:social_campagne_id) }
    it { should validate_inclusion_of(:kind).in_array(%w[hashtag account]) }
    it { should validate_numericality_of(:total_likes).is_greater_than_or_equal_to(0).allow_nil }

    it "valide l'unicité du nom par campagne et type" do
      campagne = create(:social_campagne)
      create(:hashtag_target, social_campagne: campagne, name: "fashion")

      duplicate = build(:hashtag_target, social_campagne: campagne, name: "fashion")
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:name]).to include("déjà utilisé pour ce type et cette campagne")
    end

    it "permet le même nom pour des types différents" do
      campagne = create(:social_campagne)
      create(:hashtag_target, social_campagne: campagne, name: "fashion")

      account_target = build(:account_target, social_campagne: campagne, name: "fashion")
      expect(account_target).to be_valid
    end

    it "permet le même nom pour des campagnes différentes" do
      campagne1 = create(:social_campagne)
      campagne2 = create(:social_campagne)
      create(:hashtag_target, social_campagne: campagne1, name: "fashion")

      duplicate = build(:hashtag_target, social_campagne: campagne2, name: "fashion")
      expect(duplicate).to be_valid
    end
  end

  describe "serialization" do
    it "sérialise posts_liked en JSON" do
      target = create(:social_target)
      target.posts_liked = ["post_123", "post_456"]
      target.save!

      target.reload
      expect(target.posts_liked).to eq(["post_123", "post_456"])
    end
  end

  describe "factory" do
    it "a une factory valide" do
      expect(create(:social_target)).to be_valid
    end

    it "a une factory valide pour hashtag" do
      expect(create(:hashtag_target)).to be_valid
    end

    it "a une factory valide pour account" do
      expect(create(:account_target)).to be_valid
    end

    it "a une factory valide avec statistiques" do
      expect(create(:social_target_with_stats)).to be_valid
    end
  end

  describe "defaults" do
    it "a total_likes à 0 par défaut" do
      target = SocialTarget.new
      expect(target.total_likes).to eq(0)
    end

    it "a posts_liked comme tableau vide par défaut" do
      target = SocialTarget.new
      expect(target.posts_liked).to eq([])
    end
  end

  describe "#add_liked_post" do
    let(:target) { create(:social_target) }

    it "ajoute un post à la liste des posts likés" do
      target.add_liked_post("post_123")

      expect(target.posts_liked).to include("post_123")
      expect(target.total_likes).to eq(1)
      expect(target.last_activity).to be_present
    end

    it "n'ajoute pas le même post deux fois" do
      target.add_liked_post("post_123")
      target.add_liked_post("post_123")

      expect(target.posts_liked).to eq(["post_123"])
      expect(target.total_likes).to eq(2) # Incrémente quand même
    end

    it "incrémente total_likes" do
      expect { target.add_liked_post("post_123") }.to change { target.total_likes }.by(1)
    end

    it "met à jour last_activity" do
      expect { target.add_liked_post("post_123") }.to change { target.last_activity }.from(nil)
    end
  end

  describe "#reset_stats" do
    let(:target) { create(:social_target_with_stats) }

    it "remet à zéro les statistiques" do
      target.reset_stats

      expect(target.total_likes).to eq(0)
      expect(target.posts_liked).to eq([])
      expect(target.last_activity).to be_nil
    end
  end

  describe "#has_liked_post?" do
    let(:target) { create(:social_target) }

    it "retourne true si le post a été liké" do
      target.posts_liked = ["post_123", "post_456"]

      expect(target.has_liked_post?("post_123")).to be true
      expect(target.has_liked_post?("post_456")).to be true
    end

    it "retourne false si le post n'a pas été liké" do
      target.posts_liked = ["post_123"]

      expect(target.has_liked_post?("post_789")).to be false
    end
  end

  describe "scopes" do
    let(:campagne) { create(:social_campagne) }
    let!(:hashtag_target) { create(:hashtag_target, social_campagne: campagne) }
    let!(:account_target) { create(:account_target, social_campagne: campagne) }

    it "filtre par type hashtag" do
      expect(campagne.social_targets.where(kind: "hashtag")).to contain_exactly(hashtag_target)
    end

    it "filtre par type account" do
      expect(campagne.social_targets.where(kind: "account")).to contain_exactly(account_target)
    end
  end
end
