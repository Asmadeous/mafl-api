class Blog::TagsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index]

  def index
    tags = Blog::Tag.all
    render json: ActiveModelSerializers::SerializableResource.new(tags, each_serializer: Blog::TagSerializer), status: :ok
  end
end