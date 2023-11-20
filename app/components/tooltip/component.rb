class Tooltip::Component < ViewComponent::Base
  def initialize(message:)
    @message = message
  end
end
