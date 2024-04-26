# frozen_string_literal: true

module ::InstantSearch::Collections
  class User < Base
    def self.fields
      [
        { name: "id", type: "string", facet: false },
        { name: "username", type: "string" },
        { name: "name", type: "string", optional: true },
        { name: "bio", type: "string", optional: true },
        { name: "location", type: "string", optional: true },
        { name: "website", type: "string", optional: true },
        { name: "groups", type: "string[]", facet: true },
        { name: "group_ids", type: "int32[]" },
        { name: "likes_given", type: "int32" },
        { name: "likes_received", type: "int32" },
        { name: "topics_created", type: "int32" },
        { name: "posts_created", type: "int32" },
        { name: "badges", type: "string[]" },
        { name: "created_at", type: "int64" },
        { name: "updated_at", type: "int64" },
        { name: "security", type: "string[]" },
      ]
    end

    def should_index?
      true
    end

    def document
      {
        id: @object.id.to_s,
        username: @object.username,
        name: @object.name,
        bio: @object.user_profile.bio_raw,
        location: @object.user_profile.location,
        website: @object.user_profile.website,
        groups: @object.groups.map(&:name),
        group_ids: @object.groups.map(&:id),
        likes_given: @object.user_stat.likes_given,
        likes_received: @object.user_stat.likes_received,
        topics_created: @object.user_stat.topic_count,
        posts_created: @object.user_stat.post_count,
        badges: @object.badges.map(&:name),
        created_at: @object.created_at.to_i,
        updated_at: @object.updated_at.to_i,
        security: ["g0"],
      }
    end
  end
end
