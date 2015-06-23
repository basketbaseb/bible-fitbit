class Api::SessionsController < Devise::SessionsController
  # prepend_before_filter :require_no_authentication, :only => [:create] shouldn't need this as it inherits it from Devise
  protect_from_forgery
  #include Devise::Controllers
  before_filter :ensure_params_exist, :only => :create

  respond_to :json

  # GET /api/users/sign_in
  def new
    # self.resource = resource_class.new(sign_in_params)
    # clean_up_passwords(resource)
    # respond_with(resource, serialize_options(resource))
    super
  end

  # POST /api/users/sign_in
  def create
    #build_resource

    resource = User.find_for_database_authentication(:email=>params[:api_user][:email])

    if resource
      sign_in("user", resource)
      respond_to do |format|
        format.json{
          render :json=> {:success=>true, :email=>resource.email}
        }
        format.html{
          flash[:notice] = "Welcome back " + resource.username + "!"
          redirect_to root_path
        }
      end
    else
      respond_to do |format|
        format.json {
          render :json => {:success=>false, :message=>"Error with your login or password"}
        }
        format.html {
          flash[:alert] = 'Error with your login or password'
          redirect_to new_api_user_session_path
        }
      end
    end

  end

  #DELETE /api/users/sign_out
  def destroy
    #sign_out(resource_name)
    signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
    if signed_out
      set_flash_message :notice, :signed_out if signed_out && is_flashing_format?
      yield if block_given?
      respond_to_on_destroy
    else
      render :json=>{:success=>false, :message=>"logout not successful"}
    end
  end


  protected
  def ensure_params_exist
    puts params
    return unless params[:api_user].blank?
    render :json=>{:success=>false, :message=>"missing user_login parameter"}, :status=>422
  end

  def invalid_login_attempt
    warden.custom_failure!
    render :json=> {:success=>false, :message=>"Error with your login or password"}, :status=>401
  end

  private

  def respond_to_on_destroy
    # We actually need to hardcode this as Rails default responder doesn't
    # support returning empty response on GET request
    respond_to do |format|
      # format.all { head :no_content }
      # format.any(*navigational_formats) { redirect_to after_sign_out_path_for(resource_name) }
      format.json{
        render :json => {:success=>true, :message=>"signed out"}
      }
      format.html{
        redirect_to after_sign_out_path_for(resource_name)
      }
    end
  end

end
