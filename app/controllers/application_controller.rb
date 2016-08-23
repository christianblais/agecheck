class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def shop
    @shop ||= Shop.find(session[:shopify])
  rescue ActiveRecord::RecordNotFound
    nil
  end
  helper_method :shop
end
