class ApplicationController < ActionController::API
  # before_action :authenticate_employee!
  # before_action :ensure_admin!

  # private

  # def ensure_admin!
  #   unless current_employee&.admin?
  #     render json: { message: "Admin access required." }, status: :forbidden
  #   end
  # end
end
