# frozen_string_literal: true

module ::InstantSearch
  class EventHandler
    def self.setup(plugin)
      # TODO use meta programming to DRY this mess up
      plugin.on(:post_created) do |target|
        Jobs.enqueue(
          :index,
          id: target.id,
          type: ::InstantSearch::Collections::Post.name,
          action: "upsert",
        )
      end

      plugin.on(:post_edited) do |target|
        Jobs.enqueue(
          :index,
          id: target.id,
          type: ::InstantSearch::Collections::Post.name,
          action: "upsert",
        )
      end

      plugin.on(:post_destroyed) do |target|
        Jobs.enqueue(
          :index,
          id: target.id,
          type: ::InstantSearch::Collections::Post.name,
          action: "delete",
        )
      end

      plugin.on(:user_created) do |target|
        Jobs.enqueue(
          :index,
          id: target.id,
          type: ::InstantSearch::Collections::User.name,
          action: "upsert",
        )
      end

      plugin.on(:user_updated) do |target|
        Jobs.enqueue(
          :index,
          id: target.id,
          type: ::InstantSearch::Collections::User.name,
          action: "upsert",
        )
      end

      plugin.on(:user_destroyed) do |target|
        Jobs.enqueue(
          :index,
          id: target.id,
          type: ::InstantSearch::Collections::User.name,
          action: "delete",
        )
      end

      plugin.on(:topic_created) do |target|
        Jobs.enqueue(
          :index,
          id: target.id,
          type: ::InstantSearch::Collections::Topic.name,
          action: "upsert",
        )
      end

      plugin.on(:topic_updated) do |target|
        Jobs.enqueue(
          :index,
          id: target.id,
          type: ::InstantSearch::Collections::Topic.name,
          action: "upsert",
        )
      end

      plugin.on(:topic_destroyed) do |target|
        Jobs.enqueue(
          :index,
          id: target.id,
          type: ::InstantSearch::Collections::Topic.name,
          action: "delete",
        )
      end

      plugin.on(:chat_message_created) do |target|
        Jobs.enqueue(
          :index,
          id: target.id,
          type: ::InstantSearch::Collections::ChatMessage.name,
          action: "upsert",
        )
      end

      plugin.on(:chat_message_trashed) do |target|
        Jobs.enqueue(
          :index,
          id: target.id,
          type: ::InstantSearch::Collections::ChatMessage.name,
          action: "delete",
        )
      end

      plugin.on(:chat_message_edited) do |target|
        Jobs.enqueue(
          :index,
          id: target.id,
          type: ::InstantSearch::Collections::ChatMessage.name,
          action: "upsert",
        )
      end

      plugin.on(:chat_message_restored) do |target|
        Jobs.enqueue(
          :index,
          id: target.id,
          type: ::InstantSearch::Collections::ChatMessage.name,
          action: "upsert",
        )
      end
    end
  end
end
