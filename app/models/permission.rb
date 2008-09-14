class Permission < ActiveRecord::Base
  belongs_to :user
  belongs_to :category
  
  validates_uniqueness_of :role, :scope => [:category_id, :user_id]
  validates_associated :user
  validates_associated :category
  validate :ensure_valid_role
  
  
  protected
    def ensure_valid_role
      errors.add("role", "must be a valid role") unless all_possible_roles.include?(role)
    end

    def all_possible_roles
    (ROLES_WHICH_ALLOW_ITEM_CREATION + ROLES_WHICH_ALLOW_VIEWING_OF_ITEMS_FROM_OTHER_REQUESTERS + ROLES_WHICH_ALLOW_SETTING_AS_ITEM_WATCHER + ROLES_WHICH_ALLOW_POSTING_TO_ITEMS_FROM_OTHER_REQUESTERS + ROLES_WHICH_ALLOW_ADDING_FILES_TO_ITEM + ROLES_WHICH_ALLOW_CHANGING_ITEM_PRIORITY + ROLES_WHICH_ALLOW_CHANGING_DUE_DATES_FOR_ITEMS_FROM_OTHER_REQUESTERS + ROLES_WHICH_ALLOW_MOVING_TO_THIS_CATEGORY + ROLES_WHICH_ALLOW_ASSIGNING_ITEM_FIXER + ROLES_WHICH_ALLOW_SETTING_AS_ITEM_FIXER).uniq
    end
end
