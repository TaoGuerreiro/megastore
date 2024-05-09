# frozen_string_literal: true

module Avatar
  class Component < ViewComponent::Base
    AVATAR_CLASSES = <<-TXT
      rounded-full overflow-hidden
      bg-black-200 border-2 border-primary
      flex items-center justify-center w-12 h-12
    TXT

    AVATAR_SIZE = 200

    def initialize(user:, classes: nil)
      super
      @user = user
      @classes = classes
    end
  end
end
