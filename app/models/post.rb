class Post < ActiveRecord::Base
  
  belongs_to :item
  belongs_to :user
  validates_presence_of :item_id
  validates_presence_of :user_id
  
  before_save :sanitize_content
  after_save :update_item_timestamp
  
  def plaintext_content
    content.strip_tags.simple_format
  end
  
  protected
    def sanitize_content
      self.content = content.sanitize.auto_link.simple_format
    end

    def update_item_timestamp
      item.updated_at = Time.now
      item.save!
    end
end
