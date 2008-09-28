# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem
  
  helper :all # include all helpers, all the time

  before_filter :login_required

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '6b68b4aac7ceba865bafc0abb0b582b1'
  
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  filter_parameter_logging :password
  
  # Declarative Exception Handling
  rescue_from ActiveRecord::RecordInvalid do |exception|
    render :action => (exception.record.new_record? ? :new : :edit)
  end
  
  #rescue_from ActionController::RoutingError, :with => :render_404
  
  # [TODO] would we want to differentiate these from Routing Errors?
  rescue_from ActiveRecord::RecordNotFound, :with => :render_404

  def render_401 
    respond_to do |format| 
      # we may also want to consider setting a flash and redirecting instead
      format.html { render :file => "#{RAILS_ROOT}/public/401.html", :status => '401 Not Authorized' } 
      format.xml  { render :nothing => true, :status => '401 Not Authorized' } 
    end 
    true 
  end

  def render_404 
    respond_to do |format| 
      format.html { render :file => "#{RAILS_ROOT}/public/404.html", :status => '404 Not Found' } 
      format.xml  { render :nothing => true, :status => '404 Not Found' } 
    end 
    true 
  end
  
  # TODO: should we look at throwing an exception and rescue that instead?
  def insufficient_permission(user, requested_path)
    logger.error "User #{user.username} (ID #{user.id}) attempted to access #{requested_path} at #{Time.now} but did not have sufficient permission"
    render_401
  end
end
