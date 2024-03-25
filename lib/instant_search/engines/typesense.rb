# frozen_string_literal: true

module ::InstantSearch
  module Engines
    class Typesense
      def self.client
        @client ||=
          ::Typesense::Client.new(
            api_key: "xyz",
            nodes: [{ host: "localhost", port: "8108", protocol: "http" }],
          )
      end
    end
  end
end
