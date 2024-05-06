# frozen_string_literal: true

module ::InstantSearch::Collections
  class Post < Base
    def self.fields
      fields = [
        { name: "id", type: "string", facet: false },
        { name: "topic_id", type: "int32" },
        { name: "topic_title", type: "string" },
        { name: "user_id", type: "int32" },
        { name: "author_username", type: "string", facet: true, optional: true },
        { name: "raw", type: "string" },
        { name: "created_at", type: "int64" },
        { name: "updated_at", type: "int64" },
        { name: "category_id", type: "int32", optional: true },
        { name: "category", type: "string", facet: true, optional: true },
        { name: "tags", type: "string[]", facet: true },
        { name: "security", type: "string[]" },
      ]

      if SiteSetting.include_embeddings
        fields << {
          name: "embeddings",
          type: "float[]",
          facet: false,
          num_dim: 1024,
          optional: true,
        }
      end

      fields
    end

    def document
      doc = {
        id: @object.id.to_s,
        topic_id: @object.topic_id,
        topic_title: @object.topic.title,
        user_id: @object.user_id,
        author_username: @object&.user&.username,
        raw: @object.raw,
        created_at: @object.created_at.to_i,
        updated_at: @object.updated_at.to_i,
        category_id: @object.topic&.category&.id,
        category: @object.topic&.category&.name,
        tags: @object.topic.tags.map(&:name),
        security: security,
      }

      doc[:embeddings] = embeddings if embeddings.size > 1
      doc
    end

    def should_index?
      return false if @object.deleted_at.present?
      return false unless @object.topic.present?
      return false unless @object.topic.category.present?
      return true if SiteSetting.index_private_content
      return false if @object&.topic&.category&.read_restricted?
      return false if @object&.topic&.archetype == Archetype.private_message
      return false if @object.whisper?
      true
    end

    def security
      return SiteSetting.whispers_allowed_groups_map.map { "g#{_1}" } if @object.whisper?

      if @object.topic.archetype == Archetype.private_message
        group_ids = @object.topic.allowed_groups.pluck(:id).map { "g#{_1}" }
        user_ids = @object.topic.allowed_users.pluck(:id).filter { _1 > 0 }.map { "u#{_1}" }
        group_ids + user_ids
      else
        if @object.topic.category.read_restricted?
          @object.topic.category.secure_group_ids.map { "g#{_1}" }
        else
          ["g0"]
        end
      end
    end

    def embeddings
      return [] unless SiteSetting.include_embeddings
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
