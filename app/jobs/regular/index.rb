# frozen_string_literal: true

module Jobs
  class Index < ::Jobs::Base
    sidekiq_options queue: "low"

    def execute(args)
      id = args[:id]
      type = args[:type].constantize
      object = type.model.find_by(id: id)

      return if object.blank?

      case args[:action]
      when "upsert"
        type.new(object).create
      when "delete"
        type.new(object).delete
      end
    end
  end
end
