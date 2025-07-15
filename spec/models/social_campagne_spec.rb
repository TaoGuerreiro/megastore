# frozen_string_literal: true

require "rails_helper"

RSpec.describe SocialCampagne, type: :model do
  describe "associations" do
    it { should belong_to(:user) }
    it { should have_many(:social_targets).dependent(:destroy) }
    it { should have_many(:campagne_logs).dependent(:destroy) }
  end

  describe "validations" do
    it { should validate_presence_of(:status) }
  end

  describe "enums" do
    it "accepte les valeurs 'active' et 'paused' pour status" do
      expect(described_class.statuses.keys).to include("active", "paused")
    end
  end

  describe "factory" do
    it "a une factory valide" do
      expect(build(:social_campagne)).to be_valid
    end

    it "a une factory valide pour une campagne en pause" do
      expect(build(:paused_social_campagne)).to be_valid
    end
  end

  describe "defaults" do
    it "a le statut 'active' par défaut" do
      campagne = SocialCampagne.new
      expect(campagne.status).to eq("active")
    end
  end
end
