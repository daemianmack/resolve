# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
#  before_filter :login_required
  
  include AuthenticatedSystem
  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery  :secret => 'b714c45ba8db7ea39bc7371be6f5760a'

  # Declarative Exception Handling
  rescue_from ActiveRecord::RecordInvalid do |exception|
    render :action => (exception.record.new_record? ? :new : :edit)
  end
  
  rescue_from ActionController::RoutingError, :with => :render_404
  
  # [TODO] would we want to differentiate these from Routing Errors?
  rescue_from ActiveRecord::RecordNotFound, :with => :render_404

  
  # Never show passwords in the logs
  filter_parameter_logging :password
  
  # Pick a unique cookie name to distinguish our session data from others'
  session :session_key => '_resolve_session_id'

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
