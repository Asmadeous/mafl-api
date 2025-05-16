class Blog::CategoriesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index]

  def index
    categories = Blog::Category.all
    render json: ActiveModelSerializers::SerializableResource.new(categories, each_serializer: Blog::CategorySerializer), status: :ok
  end
end