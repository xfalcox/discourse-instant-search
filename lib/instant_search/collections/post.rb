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
        { name: "type", type: "string", facet: true },
        { name: "allowed_users", type: "string[]", facet: true, optional: true },
        { name: "allowed_groups", type: "string[]", facet: true, optional: true },
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
        type: type,
        allowed_users: @object.topic.allowed_users.pluck(:username).compact,
        allowed_groups: @object.topic.allowed_groups.pluck(:name).compact,
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
      return false if @object.topic.deleted_at.present?

      return true if SiteSetting.index_private_content
      return false if @object&.topic&.category&.read_restricted?
      return false if @object&.topic&.archetype == Archetype.private_message
      return false if @object.whisper?
      true
    end

    def security
      return SiteSetting.whispers_allowed_groups_map.map { "g#{_1}" } if @object.whisper?

      # hack
      if @object.topic.tags.present? && @object.topic.tags.any? { |t| t.tag_groups.present? } &&
           @object.topic.tags.any? { |t|
             t.tag_groups.any? { |tg| tg.tag_group_permissions.none? { |tgp| tgp.group_id == 0 } }
           }
        return ["g47"]
      end

      # Handles unlisted topics
      return ["g3"] unless @object.topic.visible

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

    def type
      @object.topic.archetype
    end

    def embeddings
      return [] unless SiteSetting.include_embeddings
      JSON.parse(
        DB
          .query_single(
            "SELECT embeddings FROM ai_post_embeddings_8_1 WHERE post_id = ? LIMIT 1",
            @object.id,
          )
          .first
          .presence || "[]",
      )
    end
  end
end
