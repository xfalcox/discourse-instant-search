# frozen_string_literal: true

InstantSearch::Engine.routes.draw do
  get "/instant-search" => "searches#index"
  # define routes here
end

Discourse::Application.routes.draw { mount ::InstantSearch::Engine, at: "instant-search" }
