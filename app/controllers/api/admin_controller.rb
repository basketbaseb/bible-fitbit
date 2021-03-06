class Api::AdminController < ApplicationController
	before_filter :authorize_admin!

	def home
	end

	# BEGIN Grant users administrative privileges
  def manage_users
  	@users = User.all

  	respond_to do |format|
      format.json {
        render :json => @users.as_json(:only => [:id, :username, :firstname, :lastname, :email], :methods => [:avatar_url])
      }
      format.html {
        render 'manage_users'
      }
    end
  end

  def make_admin
  	@user = User.find_by_id(params[:user_id])
  	@user.update_attribute :admin, true
  	redirect_to api_admin_manage_users_path
  end

  def render_admin_form
  	@user = User.find_by_username(params[:username])
  end
  # END Grant users administrative privileges

  def become_user
    return unless current_user.admin?

    respond_to do |format|
    	format.html
  		format.js {
  			# Check if user to become is an admin. If so, then redirect.
  			render :js => "window.location.href='" + api_admin_home_path + "'" and return if User.find_by_email(params[:email]).admin?

  			# Sign in as user and redirect
  			sign_in(:user, User.find_by_email(params[:email]), { :bypass => true })
    		render :js => "window.location.href='" + home_index_path + "'"
  		}
  	end
  end

  def show_users
    @users = User.all
  end

  private

  def authorize_admin!
  	redirect_to home_index_path, notice: "You need admin privileges to view this page" unless current_user.admin?
  end

end
