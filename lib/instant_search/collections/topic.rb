# frozen_string_literal: true

module ::InstantSearch::Collections
  class Topic < Base
    def self.fields
      fields = [
        { name: "id", type: "string", facet: false },
        { name: "title", type: "string" },
        { name: "user_id", type: "int32" },
        { name: "author_username", type: "string", facet: true, optional: true },
        { name: "blurb", type: "string" },
        { name: "reply_count", type: "int32" },
        { name: "views", type: "int32" },
        { name: "like_count", type: "int32" },
        { name: "participants", type: "string[]", facet: true },
        { name: "created_at", type: "int64" },
        { name: "updated_at", type: "int64" },
        { name: "category_id", type: "int32", optional: true },
        { name: "category", type: "string", facet: true, optional: true },
        { name: "tags", type: "string[]", facet: true },
        { name: "closed", type: "bool", facet: true },
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

    def should_index?
      return false if @object.deleted_at.present?
      return false unless @object.category.present?

      return true if SiteSetting.index_private_content
      return false if @object&.category&.read_restricted?
      return false if @object.archetype == Archetype.private_message
      true
    end

    def document
      doc = {
        id: @object.id.to_s,
        title: @object.title,
        user_id: @object.user_id,
        author_username: @object&.user&.username,
        blurb: @object.first_post.raw.truncate(255),
        reply_count: @object.posts_count - 1,
        views: @object.views,
        like_count: @object.like_count,
        participants: @object.posters_summary.map(&:user).map(&:username),
        created_at: @object.created_at.to_i,
        updated_at: @object.updated_at.to_i,
        category_id: @object&.category&.id,
        category: @object&.category&.name,
        tags: @object.tags.map(&:name),
        closed: @object.closed,
        security: security,
      }

      doc[:embeddings] = embeddings if embeddings.size > 1
      doc
    end

    def security
      if @object.archetype == Archetype.private_message
        group_ids = @object.allowed_groups.pluck(:id).map { "g#{_1}" }
        user_ids = @object.allowed_users.pluck(:id).filter { _1 > 0 }.map { "u#{_1}" }
        group_ids + user_ids
      else
        if @object.category.read_restricted?
          @object.category.secure_group_ids.map { "g#{_1}" }
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
            "SELECT embeddings FROM ai_topic_embeddings_4_1 WHERE topic_id = ? LIMIT 1",
            @object.id,
          )
          .first
          .presence || [],
      )
    end
  end
end
