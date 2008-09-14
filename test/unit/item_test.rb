require File.dirname(__FILE__) + '/../test_helper'

class ItemTest < Test::Unit::TestCase
  fixtures :items, :posts, :users
  include ItemTestHelper

  def test_valid_with_valid_attributes
    create_item
    @item.attributes = valid_item_attributes
    assert @item.valid?
  end
  
  def test_invalid_without_name
    create_item
    @item.attributes = valid_item_attributes.except(:name)
    assert !@item.valid?
    assert @item.errors.on(:name)
  end

  def test_invalid_without_description
    create_item
    @item.attributes = valid_item_attributes.except(:description)
    assert !@item.valid?
    assert @item.errors.on(:description)
  end

  def test_invalid_without_requester
    create_item
    # Can't use the Hash#except method here, as requester_id is not an accessible attribute
    @item.attributes = valid_item_attributes
    @item.requester_id = nil
    assert !@item.valid?
    assert @item.errors.on(:requester)
  end

  def test_invalid_without_priority
    create_item
    @item.attributes = valid_item_attributes
    @item.priority = nil
    assert !@item.valid?
    assert @item.errors.on(:priority)
  end

  def test_invalid_with_non_numeric_priority
    create_item
    @item.attributes = valid_item_attributes
    @item.priority = "Urgent"
    assert !@item.valid?
    assert @item.errors.on(:priority)
  end

  def test_invalid_with_invalid_numeric_priority
    create_item
    @item.attributes = valid_item_attributes
    @item.priority = 6
    assert !@item.valid?
    assert @item.errors.on(:priority)
  end

  def test_invalid_with_invalid_requester
    create_item

  end

  def test_invalid_when_dropdead_on_without_wanted_on
    create_item
    @item.attributes = valid_item_attributes.except(:wanted_on)
    assert !@item.valid?
    assert @item.errors.on(:wanted_on)
  end
  
  def test_invalid_when_wanted_on_after_dropdead_on
    create_item
    @item.attributes = valid_item_attributes
    @item.wanted_on = 4.days.from_now
    @item.dropdead_on = 3.days.from_now
    assert !@item.valid?
    assert @item.errors.on(:wanted_on)
  end
  
  def test_invalid_when_creating_with_past_wanted_on
    create_item
    @item.attributes = valid_item_attributes
    @item.wanted_on = 2.days.ago
    assert !@item.valid?
    assert @item.errors.on(:wanted_on)
  end
  
  def test_invalid_when_creating_with_past_dropdead_on
    create_item
    @item.attributes = valid_item_attributes
    @item.dropdead_on = 2.days.ago
    assert !@item.valid?
    assert @item.errors.on(:dropdead_on)
  end
  
  def test_valid_when_updating_with_past_wanted_on
    @item = items(:overdue_unfinished_item)
    @item.name = "Some arbitrary string which is unlikely to ever be the name of a fixture"
    assert @item.valid?
  end
  
  def test_valid_when_updating_with_past_dropdead_on
    @item = items(:overdue_unfinished_item)
    @item.name = "Some arbitrary string which is unlikely to ever be the name of a fixture"
    assert @item.valid?
  end

  # this test needs a better name. In essence, it should not be allowed to update a past wanted_on date to some _other_ past wanted_on date.
  def test_invalid_when_updating_wanted_on_in_past_with_past_wanted_on
    @item = items(:overdue_unfinished_item)
    @item.wanted_on = 3.days.ago.to_date
    assert !@item.valid?
    assert @item.errors.on(:wanted_on)
  end

  # this test needs a better name. In essence, it should be possible to update a past wanted_on date to a future wanted_on date.
  def test_valid_when_updating_wanted_on_in_future_with_past_wanted_on
    @item = items(:overdue_unfinished_item)
    @item.wanted_on = 1.day.from_now.to_date
    # Have to also update dropdead_on, to avoid having wanted_on > dropdead_on
    @item.dropdead_on = 1.day.from_now.to_date
    assert @item.valid?
  end
  
  # this test needs a better name. In essence, it should not be allowed to update a past dropdead_on date to some _other_ past dropdead_on date.
  def test_invalid_when_updating_dropdead_on_in_past_with_past_dropdead_on
    @item = items(:overdue_unfinished_item)
    @item.dropdead_on = 1.days.ago.to_date
    assert !@item.valid?
    assert @item.errors.on(:dropdead_on)
  end

  # this test needs a better name. In essence, it should be possible to update a past dropdead_on date to a future dropdead_on date.
  def test_valid_when_updating_dropdead_on_in_future_with_past_dropdead_on
    @item = items(:overdue_unfinished_item)
    @item.dropdead_on = 1.day.from_now.to_date
    assert @item.valid?
  end
  #

  def test_description_not_updateable_after_creation
    @item = items(:overdue_unfinished_item)
    @item.description = "Sama ometr reprezenti for to. Ont ol hekto mallongigita, ing ne negi bek'o kroma, et ian jesigi alternativo. Li pri volitivo deksesuma esperantigo. Ja nia horo halo', kovri identiga suplemento muo on."
    assert !@item.valid?
    assert @item.errors.on(:description)
  end

  def test_not_valid_if_saved_without_changes
    @item = items(:overdue_unfinished_item)
    assert !@item.valid?
  end

  def test_optimistic_locking #for when an Item is edited in the meantime
    @item1 = Item.find(items(:overdue_unfinished_item).id)
    @item2 = Item.find(items(:overdue_unfinished_item).id)
    @item1.name = "Some arbitrary string which is unlikely to ever be the name of a fixture"
    @item1.save!
    @item2.name = "Some other arbitrary string which is unlikely to ever be the name of a fixture"
    assert_raises(ActiveRecord::StaleObjectError) { @item2.save! } 
  end

  def test_correct_counting_of_posts

  end

  def test_correct_counting_of_comments

  end

  def test_correct_counting_of_events

  end
  
  def test_find_watchers

  end

  def test_most_recent_comment

  end

  def test_status
    create_item
    @item.attributes = valid_item_attributes.except(:fixer_id)
    assert_equal STATUS_FOR_NEW_TICKET, @item.status
    
    # once we start validating fixers, this will have to be a valid User
    @item.fixer = User.find(:first)
    assert_equal STATUS_FOR_IN_PROGRESS_TICKET, @item.status
    
    @item.finished_at = Time.now
    assert_equal STATUS_FOR_FINISHED_TICKET, @item.status
    
    @item.closed_at = Time.now
    assert_equal STATUS_FOR_CLOSED_TICKET, @item.status
    
  end

  def test_moving_to_queue

  end

  def test_assigning_to_valid_fixer

  end

  def test_assigning_to_invalid_fixer

  end
  
  def test_updating_attributes_by_valid_fixer
    #should append new Event record to this item
  end

  def test_updating_attributes_by_invalid_fixer
    # should raise RecordNotValid, and not create a new Event record
  end
end