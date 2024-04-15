# frozen_string_literal: true

InstantSearch::Engine.routes.draw do
  get "/" => "searches#index"
  # define routes here
end

Discourse::Application.routes.draw { mount ::InstantSearch::Engine, at: "instant-search" }
