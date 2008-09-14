class CreateItemsPostsAndUsers < ActiveRecord::Migration
  def self.up
    create_table :items do |t|
      t.column :name,                       :string
      t.column :priority,                   :integer, :default => 3, :null => false
      t.column :description,                :text
      t.column :extra_fields,               :text
      t.column :wanted_on,                  :date
      t.column :dropdead_on,                :date
      t.column :category_id,               :integer
      t.column :requester_id,               :integer
      t.column :fixer_id,                   :integer
      t.column :lock_version,               :integer, :default => 0, :null => false
      t.column :finished_at,                :datetime
      t.column :closed_at,                  :datetime
      t.column :created_at,                 :datetime
      t.column :updated_at,                 :datetime
    end

    create_table :posts do |t|
      t.column :item_id,                    :integer
      t.column :user_id,                    :integer #for events, this will be the person initiating the change - for comments, it'll be the author
      t.column :content,                    :text
      t.column :emailed_to,                 :text # comma-delimited list of addresses post was sent to
      t.column :emailed_cc,                 :text # comma-delimited list of addresses post was cc:ed to
      t.column :type,                       :text
      t.column :created_at,                 :datetime
      t.column :updated_at,                 :datetime
    end

    create_table :users do |t|
      t.column :login,                      :string
      t.column :email,                      :string
      t.column :first_name,                 :string
      t.column :last_name,                  :string
      t.column :phone_number,               :string
      t.column :crypted_password,           :string, :limit => 40
      t.column :salt,                       :string, :limit => 40
      t.column :remember_token,             :string
      t.column :remember_token_expires_at,  :datetime
      t.column :created_at,                 :datetime
      t.column :updated_at,                 :datetime
      t.column :lock_version,               :integer, :default => 0, :null => false
    end

    create_table :items_watchers, :id => false do |t|
      t.column :item_id,                    :integer
      t.column :user_id,                    :integer
    end
    
    create_table :categories do |t|
      t.column :name,                       :string
      t.column :created_at,                 :datetime
      t.column :updated_at,                 :datetime
    end

    create_table :permissions do |t|
      t.column :role,                       :string
      t.column :user_id,                    :integer
      t.column :category_id,                :integer
      t.column :created_at,                 :datetime
      t.column :updated_at,                 :datetime
    end
  end

  def self.down
    drop_table :users
    drop_table :posts
    drop_table :items
    drop_table :items_watchers
    drop_table :categories
    drop_table :permissions
  end
end
