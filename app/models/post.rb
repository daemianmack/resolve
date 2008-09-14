class Post < ActiveRecord::Base  
  belongs_to :item
  belongs_to :user
  validates_presence_of :item_id
  validates_presence_of :user_id
  
  before_save :sanitize_content
  after_save :update_item_timestamp
  
  def plaintext_content
    strip_tags(content.gsub(/<br(\s+\/)?>/, "\n").gsub(/<\/(p|ol|ul|dl)>/, "\n\n"))
  end
  
  protected
    def sanitize_content
      content = sanitize(auto_link(content))
    end

    def update_item_timestamp
      item.updated_at = Time.now
      item.save!
    end
end
