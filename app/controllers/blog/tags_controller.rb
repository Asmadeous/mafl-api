class Blog::TagsController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :index ]

  def index
  tags = Blog::Tag.all
  render json: tags
  end
end
