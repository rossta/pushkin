require "pushkin/action_view/helpers"

module Pushkin
  class Engine < Rails::Engine
    # Loads the pushkin.yml file if it exists.
    initializer "pushkin.config" do
      path = Rails.root.join("config/pushkin.yml")
      Pushkin.configure(path[Rails.env]) if path.exist?
    end

    # Adds the ViewHelpers into ActionView::Base
    initializer "private_pub.view_helpers" do
      ActionView::Base.send :include, Pushkin::ActionView::Helpers
    end
  end
end
