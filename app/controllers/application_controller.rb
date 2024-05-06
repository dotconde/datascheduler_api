class ApplicationController < ActionController::API
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_default_response_format

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[full_name])
    devise_parameter_sanitizer.permit(:account_update, keys: %i[full_name])
  end

  private

  def set_default_response_format
    request.format = :json
  end
end
