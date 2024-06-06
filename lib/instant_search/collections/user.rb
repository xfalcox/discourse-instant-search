# frozen_string_literal: true

module ::InstantSearch::Collections
  class User < Base
    def self.fields
      [
        { name: "id", type: "string", facet: false },
        { name: "username", type: "string" },
        { name: "name", type: "string", optional: true },
        { name: "trust_level", type: "int32", facet: true },
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
      return false if @object.staged?
      return false if @object.anonymous?
      true
    end

    def document
      {
        id: @object.id.to_s,
        username: @object.username,
        name: @object.name,
        trust_level: @object.trust_level,
        bio: @object.user_profile.bio_raw,
        location: @object.user_profile.location,
        website: @object.user_profile.website,
        groups: groups.map(&:name),
        group_ids: groups.map(&:id),
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

    def groups
      @object.groups.where(members_visibility_level: Group.visibility_levels[:public])
    end
  end
end
