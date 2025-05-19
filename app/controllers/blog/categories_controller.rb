class Blog::CategoriesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :index ]

  def index
  categories = Blog::Category.all
   render json: Blog::CategorySerializer.new(categories)
  end
end
