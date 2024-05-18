require 'yaml'
require 'json'

module StripeHelpers
  def self.construct_webhook_response(vcr_file_name, event_name, checkout_session_id)
    current_time = Time.now.to_i
    pulled_data = YAML.load_stream(File.read("spec/cassettes/#{vcr_file_name}.yml"))
    body = JSON.parse(pulled_data[0]['http_interactions'][0]['response']['body']['string'])
    body["created"] = current_time
    body["id"] = checkout_session_id

    request_body = {
      "id": "evt_XXXXXXXXXXXXXXXXXX",
      "object": "event",
      "api_version": "2022-11-15",
      "created": current_time,
      "data": {
        "object": body
      },
      "livemode": false,
      "pending_webhooks": 2,
      "request": {
        "id": "req_XXXXXXXXXXXX",
        "idempotency_key": "XXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXXX"
      },
      "type": event_name
    }
    return request_body
  end
end
