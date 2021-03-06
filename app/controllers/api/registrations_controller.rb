class Api::RegistrationsController < Devise::RegistrationsController

  prepend_before_filter :require_no_authentication
  before_filter :configure_permitted_parameters

  protect_from_forgery
  respond_to :json

  # GET /api/users/sign_up
  def new
    if request.xhr?
      build_resource({})
      set_minimum_password_length
      yield resource if block_given?
      render partial: 'devise/registrations/sign_up_form'
    else
      super
    end
  end

  # POST /api/users
  def create
    # get local part of email (ex: test1@test.com => test1) to set as username
    full_email = sign_up_params[:email]
    local_email = full_email[/[^@]+/]
    # return sign_up_params without username key
    new_params = sign_up_params.dup.except('username')
    new_params[:username] = local_email

    build_resource(new_params)
    resource.save
    yield resource if block_given?
    if resource.persisted?
      if resource.active_for_authentication?
        set_flash_message :notice, :signed_up if is_flashing_format?
        sign_up('user', resource) # resource_name gives api_user, but for some reason we need 'user' here
        respond_with resource, location: after_sign_up_path_for(resource)
      else
        set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_flashing_format?
        expire_data_after_sign_in!
        respond_with resource, location: after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords resource
      set_minimum_password_length
      respond_with resource
    end


    # user = User.new(sign_up_params)
    # # user = User.new({:email=>params[:api_user][:email], :password=>params[:api_user][:password], :username => params[:api_user][:username]})
    # if user.save
    #   respond_to do |format|
    #     format.json{
    #       render :json => user.as_json
    #     }
    #     format.html{
    #       flash[:notice] = "Welcome to Bible Fitbit!"
    #       redirect_to new_api_user_session_path
    #       # sign_up("user", resource)
    #       # respond_with resource, location: after_sign_up_path_for(resource)
    #     }
    #   end
    # else
    #   warden.custom_failure!
    #   respond_to do |format|
    #     format.json {
    #       render :json=> user.errors, :status=>422
    #     }
    #     format.html {
    #       flash[:alert] = user.errors
    #       render 'new'
    #     }
    #   end
    # end
    # super
  end

   # GET /api/users/edit
  def edit
  	render :edit
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up).push(:username)
    devise_parameter_sanitizer.for(:sign_up).push(:lastname)
    devise_parameter_sanitizer.for(:sign_up).push(:firstname)
    devise_parameter_sanitizer.for(:sign_up).push(:avatar)
  end

end
