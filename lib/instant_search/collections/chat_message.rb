# frozen_string_literal: true

module ::InstantSearch::Collections
  class ChatMessage < Base
    def self.model
      Chat::Message
    end

    def self.fields
      [
        { name: "id", type: "string", facet: false },
        { name: "channel_id", type: "int32" },
        { name: "channel_name", type: "string", facet: true, optional: true },
        { name: "user_id", type: "int32" },
        { name: "author_username", type: "string", facet: true },
        { name: "raw", type: "string" },
        { name: "created_at", type: "int64" },
        { name: "updated_at", type: "int64" },
        { name: "thread_id", type: "int32", optional: true },
        { name: "thread_name", type: "string", facet: true, optional: true },
        { name: "security", type: "string[]" },
      ]
    end

    def document
      {
        id: @object.id.to_s,
        channel_id: @object.chat_channel.id,
        channel_name: @object.chat_channel.name,
        user_id: @object.user_id,
        author_username: @object.user.username,
        raw: @object.message,
        created_at: @object.created_at.to_i,
        updated_at: @object.updated_at.to_i,
        thread_id: @object.thread_id,
        thread_name: @object.thread&.name,
        security: security,
      }
    end

    def should_index?
      return false if @object.deleted_at.present?
      return false unless @object.chat_channel.present?
      return true if SiteSetting.index_private_content
      return false if @object.chat_channel.class == Chat::DirectMessageChannel
      return false if @object.chat_channel.chatable.read_restricted?
      true
    end

    def security
      if @object.chat_channel.class == Chat::DirectMessageChannel
        @object
          .chat_channel
          .user_chat_channel_memberships
          .pluck(:user_id)
          .filter { _1 > 0 }
          .map { "u#{_1}" }
      else
        category = @object.chat_channel.chatable

        if category.read_restricted?
          category.group_ids.map { "g#{_1}" }
        else
          ["g0"]
        end
      end
    end
  end
end
