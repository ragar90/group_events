class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordNotFound do
    render json: { errors: [ { description: "Could not find resource" } ] }, status: :not_found
  end
end
