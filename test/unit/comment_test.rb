require File.dirname(__FILE__) + '/../test_helper'

class CommentTest < Test::Unit::TestCase
  fixtures :items, :posts, :users
  include CommentTestHelper

  def test_valid_with_valid_attributes
    
  end
  
  def test_invalid_when_adding_comment_to_closed_item
    
  end

  def test_valid_when_adding_comment_by_valid_user

  end

  def test_invalid_when_adding_comment_by_invalid_user

  end
  
  def test_invalid_when_adding_comment_by_nonexistent_user

  end
end
