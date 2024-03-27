# frozen_string_literal: true

module Jobs
  class Index < ::Jobs::Base
    sidekiq_options queue: "low"

    def execute(args)
      id = args[:id]
      type = args[:type]
      object = type.constantize.find_by(id: id)

      return unless object.present?

      case type
      when "User"
        ::InstantSearch::Collections::User.new(object).create
      when "Topic"
        ::InstantSearch::Collections::Topic.new(object).create
      when "Post"
        ::InstantSearch::Collections::Post.new(object).create
      when "Chat::Message"
        ::InstantSearch::Collections::ChatMessage.new(object).create
      end
    end
  end
end
