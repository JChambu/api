=begin
Simple Inventory API

This is a simple API

OpenAPI spec version: 1.0.0
Contact: you@your-company.com
Generated by: https://github.com/swagger-api/swagger-codegen.git

=end
Rails.application.routes.draw do


  namespace 'api' do
    namespace 'v1' do

      get 'projects/synchronization' => 'projects#synchronization', as: :projects_sync
      resources :users
      resources :project_fields
      resources :project_types 
      resources :sessions, only: [:create, :destroy]
      resources :projects
      
      #devise_for :users
    end
  end
end
