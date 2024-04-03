# frozen_string_literal: true

module InstantSearch
  module SiteSettings
    class TypesenseNodesJsonSchema
      def self.schema
        @schema ||= {
          type: "array",
          uniqueItems: true,
          items: {
            type: "object",
            title: "Node",
            properties: {
              host: {
                type: "string",
                description: "Host",
              },
              port: {
                type: "number",
                description: "Port",
              },
              protocol: {
                type: "string",
                description: "Protocol",
                enum: %w[http https],
              },
            },
            required: %w[host port protocol],
          },
        }
      end
    end
  end
end
