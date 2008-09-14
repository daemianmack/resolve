require File.dirname(__FILE__) + '/../test_helper'

class PostTest < Test::Unit::TestCase
  fixtures :items, :posts, :users
  include PostTestHelper

  def test_adding_post_should_update_item_timestamp
    create_post
    @post.attributes = valid_post_attributes
    @item = items(:item_without_updates_in_past_week)
    # make sure it's not starting with a recent / current update time
    assert (@item.updated_at < 30.seconds.ago)
    @post.item = @item
    @post.save!
    assert (@item.updated_at > 30.seconds.ago)
  end
end
