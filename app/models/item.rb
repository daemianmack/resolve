## NOTES TO SELF
#
#########
# 
# on category change, validate that the fixer is still valid - otherwise, set a flash and set fixer_id to null
# add post-create hooks to allow auto-email or auto-assignment of items upon creation, based on their category
# look at will_paginate plugin for pagination (better performance, reportedly)
# look at acts_as_solr plugin for search (when we get to that point)
# Should we prevent requester from _ever_ being updated?
# Do we want to support proxy requesters?
#
#########
#
# do we want to use custom errors for cases like "attempting to assign to an invalid fixer"?
# if so, we can use something like
#
# class AssignmentNotAllowed < StandardError; end
# class UpdateNotAllowed < StandardError; end
# 
# uncertain if we'd be better off inheriting from one of the ActiveRecord errors, though
#
#########
class Item < ActiveRecord::Base
  
  # These are the only attributes which can be accessed via mass-assignment.
  attr_accessible :name, :priority, :description, :wanted_on, :dropdead_on
  
  has_many :posts, :order => :created_at
  belongs_to :category
  belongs_to :requester, :class_name => "User", :foreign_key => "requester_id"
  belongs_to :fixer, :class_name => "User", :foreign_key => "fixer_id"
  has_and_belongs_to_many :watchers, :join_table => "items_watchers", :foreign_key => "user_id"
  
  # This will allow us to store any arbitrary additional fields with an item.
  # Assumptions:
  # * Extra fields will be text fields <input type="text">
  # * Extra fields will not be subject to any validation
  # * category model will store what extra_fields are allowed
  serialize :extra_fields
  
  validates_presence_of :name, :description, :requester
  validates_inclusion_of :priority, :in=>1..4, :allow_nil => false
  # If there is a dropdead date specified, there _must_ be a wanted_on date
  validates_presence_of :wanted_on, :unless => Proc.new { |item| item.dropdead_on.nil? }
  validates_associated :requester
  validates_associated :fixer

  validate              :wanted_on_not_later_than_dropdead_on
  validate_on_create    :wanted_on_not_past
  validate_on_create    :dropdead_on_not_past
  
  # We may actually want to move the requester-related validations to the User model.
  validate_on_create    :ensure_requester_permissions

  validate              :ensure_assigned_fixer_permissions
  validate_on_update    :ensure_updater_permissions
  validate_on_update    :compare_with_previous
  
  
  
  before_save :hashify_fields
    

  # Unserializes the extra_fields value and returns a hash containing those fields
  def extra_fields
    read_attribute(:extra_fields) || {}
  end

  def finished?
    !finished_at.nil? && closed_at.nil?
  end

  def closed?
    !closed_at.nil?
  end
  
  def overdue?
    Date.today > wanted_on
  end

  def past_dropdead?
    Date.today > dropdead_on
  end
  
  # Returns the text description for this Item's status.
  # These constants are defined in environment.rb, but will eventually be moved into a more user-friendly config file (probably YAML-formatted)
  def status
    if (closed_at)
      STATUS_FOR_CLOSED_TICKET
    elsif (finished_at)
      STATUS_FOR_FINISHED_TICKET
    elsif (fixer)
      STATUS_FOR_IN_PROGRESS_TICKET
    else
      STATUS_FOR_NEW_TICKET
    end
  end
  
  # Returns the most recent Comment for this item (or nil, if no comments have been posted yet). Relies on comments being sorted by created_at
  def most_recent_comment
    comments.empty? ? nil : comments.last
  end

  # Returns the most User who wrote recent Comment for this item (or nil, if no comments have been posted yet). Relies on comments being sorted by created_at
  def most_recent_author
    comments.empty? ? nil : comments.last.author
  end
  
  # Method which allows auto-email or auto-assignment of items upon their first arrival to a new category
  def move_to_category(category)
  end
  
  # Returns a list of folks who should recieve emailed posts. This can be overridden by users prior to posting
  #
  # Returns an empty array if there are no default recipients.
  def default_email_recipients
    []
  end
  

  protected
    def hashify_fields
      extra_fields = {}.merge(extra_fields.nil? ? {} : extra_fields)
    end
    
    # Recursively calls those validations which require comparison with previous values.
    # Done to prevent having to hit the db multiple times
    def compare_with_previous
      @old_self = Item.find(self.id)
      no_changes_to_item(@old_self)
      check_description_updated(@old_self)
      past_wanted_on_changed_to_another_past_date(@old_self)
      past_dropdead_on_changed_to_another_past_date(@old_self)
    end
 
    def wanted_on_not_later_than_dropdead_on
      errors.add("wanted_on", "can't be after the dropdead date") if (wanted_on && dropdead_on) && (self.wanted_on > self.dropdead_on)
    end
    
    def wanted_on_not_past
      errors.add("wanted_on", "can't be in the past") if wanted_on && wanted_on.to_date < Date.today
    end

    def dropdead_on_not_past
      errors.add("dropdead_on", "can't be in the past") if dropdead_on && dropdead_on.to_date < Date.today
    end

    def no_changes_to_item(original)
      errors.add_to_base("No changes have occurred") if original.attributes == attributes
    end

    def check_description_updated(original)
      errors.add("description", "cannot be updated after Item creation") if original.description != description
    end 

    def past_wanted_on_changed_to_another_past_date(original)
      errors.add("wanted_on", "cannot be updated to a different past date") if (original.wanted_on != wanted_on && wanted_on < Date.today)
    end  

    def past_dropdead_on_changed_to_another_past_date(original)
      errors.add("dropdead_on", "cannot be updated to a different past date") if (original.dropdead_on != dropdead_on && dropdead_on < Date.today)
    end

    def ensure_updater_permissions
      errors.add_to_base("You don't have permission to update this Item") if !valid_updater_permissions?('dummy_user')
    end

    def ensure_assigned_fixer_permissions
      errors.add("fixer_id", "is not eligible to be a fixer for this Item") if !valid_assigned_fixer_permissions?(fixer)
    end

    def ensure_requester_permissions
      errors.add("requester_id", "is not eligible to create this Item") if !valid_requester_permissions?(requester)
    end

    # Filter method to enforce correct permissions for altering item attributes.
    def valid_updater_permissions?(user)
      user = user.is_a?( User ) ? User : User.find_by_id( user )
      #raise ArgumentError if user.nil?
      true
    end
  
    # Filter method to enforce correct permissions for the fixer.
    def valid_assigned_fixer_permissions?(user)
      true
    end

    # Filter method to enforce correct permissions for the requester.
    def valid_requester_permissions?(user)
      true
    end
end