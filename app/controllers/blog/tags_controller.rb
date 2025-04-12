class Blog::TagsController < ApplicationController
  def index
    tags = Tag.all
    render json: tags.as_json(only: [ :id, :name, :slug ])
  end
end
