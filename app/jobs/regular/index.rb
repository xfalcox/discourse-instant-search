# frozen_string_literal: true

module Jobs
  class Index < ::Jobs::Base
    sidekiq_options queue: "low"

    def execute(args)
      id = args[:id]
      type = args[:type]
      object = type.constantize.model.find_by(id: id)

      return unless object.present?

      case args[:action]
      when "upsert"
        type.constantize.new(object).create
      when "delete"
        type.constantize.new(object).delete
      end
    end
  end
end
