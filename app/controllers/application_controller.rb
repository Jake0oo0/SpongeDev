class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  protect_from_forgery with: :exception
  before_filter :get_notifications
  include ApplicationHelper

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:username, :email, :password, :password_confirmation, :remember_me) }
    devise_parameter_sanitizer.for(:sign_in) { |u| u.permit(:login, :password, :remember_me) }
    devise_parameter_sanitizer.for(:account_update) { |u| u.permit(:username, :email, :password, :password_confirmation, :current_password, :avatar_serve, :gender, :location, :about, :github) }
  end

  def get_notifications
    if current_user
      @notifications = Mailboxer::Receipt.recipient(current_user).is_unread.not_trash
    end
  end

  def contact
    form = params[:contact]
    username = form[:username]
    email = form[:email]
    question = form[:question]
    return redirect_to root_path, notice: 'Please make sure to fill all fields.' if username == nil or email == nil or question == nil
    UserMailer.contact(email, username, question).deliver
    return redirect_to root_path, notice: 'Successfully submitted an inquiry.'
  end
end
