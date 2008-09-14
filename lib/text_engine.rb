# Handles Text Processing for Resolve
# Repurposed from XSSTerminate
#
# By default, ALL string / text fields will have tags stripped out.
# This can be overridden at the model level on a per-field basis by specifying
# :except and :allows_html
# Fields included in the :except array will be unprocessed
# Fields included in the :allows_html array will be sanitized, but nondangerous html will be left intact
#
# text_cleanup :allows_html => [ :content ]
# or
# text_cleanup :except => [ :dangerfield ]
# or
# text_cleanup :except => [ :dangerfield ], :allows_html => [ :content ]
module TextEngine
  def self.included(base)
    base.extend(ClassMethods)
    # sets up default of stripping tags for all fields
    base.send(:text_cleanup)
  end

  module ClassMethods
    def text_cleanup(options = {})
      before_save :sanitize_fields

      write_inheritable_attribute(:text_cleanup_options, {
        :except => (options[:except] || []),
        :allows_html => (options[:allows_html] || [])
      })

      class_inheritable_reader :text_cleanup_options
      
      include TextEngine::InstanceMethods
    end
  end
  
  module InstanceMethods
        
    def sanitize_fields
      self.class.columns.each do |column|
        next unless (column.type == :string || column.type == :text)
        
        field = column.name.to_sym
        value = self[field]
        
        if text_cleanup_options[:except].include?(field)
          next
        elsif text_cleanup_options[:allows_html].include?(field)
          self[field] = TextSanitizer.white_list_sanitizer.sanitize(value)
        else
          self[field] = TextSanitizer.full_sanitizer.sanitize(value)
        end
      end
    end
  end
end