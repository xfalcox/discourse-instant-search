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

      def self.search_api_key
        if !SiteSetting.typesense_read_only_key.present?
          SiteSetting.typesense_read_only_key =
            client.keys.create(
              {
                "description" => "Search-only Discourse key.",
                "actions" => ["documents:search"],
                "collections" => ::InstantSearch::Collections::Base.subclasses.map(&:collection),
              },
            )[
              "value"
            ]
        end

        SiteSetting.typesense_read_only_key
      end

      def self.create_scoped_api_key(user, expires_at: Time.now + 11.minutes)
        user_security = []
        if user.present?
          user_security << "u#{user.id}"
          user_security += user.groups.map { "g#{_1.id}" }
          user_security << "g0"
        elsif !SiteSetting.login_required
          user_security << "g0"
        end

        client.keys.generate_scoped_search_key(
          search_api_key,
          { filter_by: "security:=[#{user_security}", expires_at: expires_at.to_i },
        )
      end

      def self.user_scoped_search_key(user)
        Discourse
          .cache
          .fetch("user_scoped_search_key_#{user&.id || 0}", expires_in: 10.minutes) do
            create_scoped_api_key(user)
          end
      end
    end
  end
end
