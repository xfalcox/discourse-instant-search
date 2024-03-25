# frozen_string_literal: true

module ::InstantSearch::Collections
  class Post < Base
    def self.fields
      [
        { name: "id", type: "string", facet: false },
        { name: "topic_id", type: "int32" },
        { name: "topic_title", type: "string" },
        { name: "user_id", type: "int32" },
        { name: "author_username", type: "string", facet: true },
        { name: "raw", type: "string" },
        { name: "cooked", type: "string" },
        { name: "created_at", type: "int64" },
        { name: "updated_at", type: "int64" },
        { name: "category", type: "string", facet: true },
        { name: "tags", type: "string[]", facet: true },
        { name: "security", type: "string[]" },
        { name: "embeddings", type: "float[]", facet: false, num_dim: 1024 },
      ]
    end

    def document
      {
        id: @object.id.to_s,
        topic_id: @object.topic_id,
        topic_title: @object.topic.title,
        user_id: @object.user_id,
        author_username: @object.user.username,
        raw: @object.raw,
        cooked: @object.cooked,
        created_at: @object.created_at.to_i,
        updated_at: @object.updated_at.to_i,
        category: @object.topic.category.name,
        tags: @object.topic.tags.map(&:name),
        security: security,
        embeddings: embeddings,
      }
    end

    def security
      if @object.topic.archetype == Archetype.regular
        if @object.topic.category.read_restricted?
          @object.topic.category.secure_group_ids.map { "g#{_1}" }
        else
          ["g0"]
        end
      elsif @object.topic.archetype == Archetype.private_message
        group_ids = @object.topic.allowed_groups.pluck(:id).map { "g#{_1}" }
        user_ids = @object.topic.allowed_users.pluck(:id).map { "u#{_1}" }
        group_ids + user_ids
      end
    end

    def embeddings
      JSON.parse(
        DB
          .query_single(
            "SELECT embeddings FROM ai_post_embeddings_4_1 WHERE post_id = ? LIMIT 1",
            @object.id,
          )
          .first
          .presence || "[]",
      )
    end
  end
end
