# frozen_string_literal: true

InstantSearch::Engine.routes.draw do
  get "/examples" => "examples#index"
  # define routes here
end

Discourse::Application.routes.draw { mount ::InstantSearch::Engine, at: "instant-search" }
