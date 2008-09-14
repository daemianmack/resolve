# Events are posts created by the application to reflect changes to an Item
# Events might include:
# - Changing the due date of an item
# - Assigning an Item to a fixer
# - Adding a file to an Item
class Event < Post
  before_save :set_content
  # enumerate the types of changes which may happen, and reference the right constants
  
  def set_content
  # Assuming we have constants like EVENT_ASSIGNED_ITEM_TO_FIXER
  # in environment.rb: EVENT_ASSIGNED_ITEM_TO_FIXER = "%s assigned to %s"
  #sprintf(EVENT_ASSIGNED_ITEM_TO_FIXER, "Chris", "Daemian")
  end
end