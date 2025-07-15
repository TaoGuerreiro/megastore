# frozen_string_literal: true

module InstagramTestHelpers
  def mock_instagram_credentials
    allow(Rails.application).to receive(:credentials).and_return(
      double("credentials",
             instagram: double("instagram_creds",
                              two_captcha_api_key: "test_2captcha_key",
                              email: "test@example.com",
                              email_password: "email_password",
                              sms_phone: "+33123456789"))
    )

    allow(ENV).to receive(:fetch).with("CHALLENGE_SMS_PROVIDER", "twilio").and_return("twilio")
    allow(ENV).to receive(:fetch).with("CHALLENGE_SMS_ACCOUNT_SID", nil).and_return("test_sid")
    allow(ENV).to receive(:fetch).with("CHALLENGE_SMS_AUTH_TOKEN", nil).and_return("test_token")
  end

  def mock_temp_file
    temp_file = instance_double(Tempfile)
    allow(Tempfile).to receive(:new).and_return(temp_file)
    allow(temp_file).to receive(:write)
    allow(temp_file).to receive(:rewind)
    allow(temp_file).to receive(:path).and_return("/tmp/test_config.json")
    allow(temp_file).to receive(:close)
    allow(temp_file).to receive(:unlink)
    temp_file
  end

  def create_instagram_test_data(user = nil)
    user ||= create(:user)
    campagne = create(:social_campagne, user: user)

    hashtag_target = create(:hashtag_target,
                           social_campagne: campagne,
                           name: "fashion",
                           cursor: "cursor123")

    account_target = create(:account_target,
                           social_campagne: campagne,
                           name: "influenceur",
                           cursor: "cursor456")

    { user: user, campagne: campagne, hashtag_target: hashtag_target, account_target: account_target }
  end

  def sample_engagement_result
    {
      "sessions" => [
        {
          "hashtag_likes" => {
            "fashion" => {
              "cursor" => "new_fashion_cursor",
              "posts_liked" => ["post_123", "post_456"],
              "successful" => 2
            }
          },
          "follower_likes" => {
            "influenceur" => {
              "cursor" => "new_influenceur_cursor",
              "posts_liked" => ["post_789"],
              "likes" => 1
            }
          }
        }
      ]
    }
  end

  def sample_accounts_config
    [
      {
        "username" => "test_user",
        "password" => "test_password",
        "hashtags" => [{ "hashtag" => "fashion", "cursor" => "cursor123" }],
        "targeted_accounts" => [{ "account" => "influenceur", "cursor" => "cursor456" }]
      }
    ]
  end
end

RSpec.configure do |config|
  config.include InstagramTestHelpers, type: :service
end
