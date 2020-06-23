class UsersController < ApplicationController

  before_action :find_user, except: [:index, :create]

  def index
    @users = User.all
  end

  def show
    @user = User.find_by(id: params[:id])
    render_404 unless @user
  end

  def create
    auth_hash = request.env["omniauth.auth"]
    user = User.find_by(uid: auth_hash[:uid], provider: "github")
    if user
      session[:user_id] = user.uid
      flash[:success] = "Logged in as returning user #{user.username}"
      redirect_to root_path
      return
    else
      user = User.build_from_github(auth_hash)
      if user.save
        session[:username] = user.username
        session[:user_id] = user.uid
        flash[:success] = "Successfully created new user #{user.username} with ID #{user.uid}"
        redirect_to root_path
        return
      else
        flash[:failure] = "Could not log in"
        flash[:result_text] = "Could not log in"
        flash[:messages] = user.errors.messages
        redirect_to github_login_path
        return
      end
    end
  end

  # def login
  #   username = params[:username]
  #   if username and user = User.find_by(username: username)
  #     session[:user_id] = user.id
  #     flash[:status] = :success
  #     flash[:result_text] = "Successfully logged in as existing user #{user.username}"
  #   else
  #     user = User.new(username: username)
  #     if user.save
  #       session[:user_id] = user.id
  #       flash[:status] = :success
  #       flash[:result_text] = "Successfully created new user #{user.username} with ID #{user.id}"
  #     else
  #       flash.now[:status] = :failure
  #       flash.now[:result_text] = "Could not log in"
  #       flash.now[:messages] = user.errors.messages
  #       render "login_form", status: :bad_request
  #       return
  #     end
  #   end
  #   redirect_to root_path
  # end

  def destroy
    session[:user_id] = nil
    flash[:status] = :success
    flash[:result_text] = "Successfully logged out"
    redirect_to root_path
  end
end
