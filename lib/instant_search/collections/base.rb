# frozen_string_literal: true

module ::InstantSearch::Collections
  class Base
    def initialize(object)
      @object = object
    end

    def self.model
      self.name.demodulize.constantize
    end

    def create
      if should_index?
        self.class.engine.collections[self.class.collection].documents.upsert(document)
      end
    end

    def delete
      self.class.engine.collections[self.class.collection].documents[@object.id.to_s].delete
    end

    def document
      raise NotImplementedError
    end

    def security
      raise NotImplementedError
    end

    def embeddings
      raise NotImplementedError
    end

    def self.default_sorting_field
      "created_at"
    end

    def self.collection
      self.name.demodulize.underscore.pluralize
    end

    def self.create_collection
      engine.collections.create(schema)
    end

    def self.destroy_collection
      engine.collections[collection].delete
    end

    def self.schema
      { name: collection, fields: fields, default_sorting_field: default_sorting_field }
    end

    def self.fields
      raise NotImplementedError
    end

    def self.engine
      ::InstantSearch::Engines::Typesense.client
    end
  end
end
