# frozen_string_literal: true

module ::InstantSearch
  module Engines
    class Typesense
      def self.client
        ::Typesense::Client.new(
          api_key: SiteSetting.typesense_api_key,
          nodes: JSON.parse(SiteSetting.typesense_nodes, symbolize_names: true),
        )
      end

      def self.create_search_api_key
        client.keys.create(
          {
            "description" => "Search-only Discourse key.",
            "actions" => ["documents:search"],
            "collections" => ::InstantSearch::Collections::Base.subclasses.map(&:collection),
          },
        )
      end

      def self.create_scoped_api_key(user, expires_at: Time.now + 10.minutes)
        user_security = user.groups.map { "g#{_1.id}" } + ["g0", "u#{user.id}"]
        search_api_key = create_search_api_key
        client.keys.generate_scoped_search_key(
          search_api_key["value"],
          { filter_by: "security:=[#{user_security}", expires_at: expires_at.to_i },
        )
      end
    end
  end
end
