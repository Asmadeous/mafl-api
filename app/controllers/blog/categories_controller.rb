class Blog::CategoriesController < ApplicationController
  def index
    categories = Blog::Category.all
    render json: categories.as_json(only: [ :id, :name, :slug, :description ])
  end
end
