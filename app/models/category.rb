class Category < ActiveRecord::Base
  has_many :items
  
  validates_presence_of :name
  
  #
  # Returns a sorted array of 'open' Items for this category.
  # Open items are those which have null values for *both* the closed_at and finished_at columns.
  #
  # Note: the array is always also sorted by most-recently updated. This is not currently configurable.
  #
  def open_items(sort_by="priority")
    raise ArgumentError("Attempt to sort open items by invalid field.") unless ITEM_FIELDS_WHICH_ALLOW_SORTING.include?(sort_by)
    items.find(:all, :conditions => ["closed_at is null and finished_at is null"], :order => ["#{sort_by}, updated_at"])
  end

  #
  # Returns a sorted array of 'finished' Items for this category.
  # Finished items are those which have null values for the closed_at column,
  # but *do* have a date in the finished_at column.
  #
  # Note: the array is always also sorted by most-recently updated. This is not currently configurable.
  #
  def finished_items(sort_by="priority")
    raise ArgumentError("Attempt to sort finished items by invalid field.") unless ITEM_FIELDS_WHICH_ALLOW_SORTING.include?(sort_by)
    items.find(:all, :conditions => ["closed_at is null and finished_at is null"], :order => ["#{sort_by}, updated_at"])
  end
  
end
