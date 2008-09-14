# Singleton to be called in wrapper module
class TextHelperSingleton
  include Singleton
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::TagHelper #tag_options needed by auto_link
  include ActionView::Helpers::SanitizeHelper
end

# Wrapper module
module ResolveExtensions #:nodoc:
  # Adds utility methods to Resolve's models by extending String
  module String #:nodoc:
    module TextHelper
      def auto_link(link = :all, href_options = {}, &block)
        TextHelperSingleton.instance.auto_link(self, link, href_options, &block)
      end
      def excerpt(phrase, radius = 100, excerpt_string = "...")
        TextHelperSingleton.instance.excerpt(self, phrase, radius, excerpt_string)
      end
      def highlight(phrase, highlighter = '<strong class="highlight">\1</strong>')
        TextHelperSingleton.instance.highlight(self, phrase, highlighter)
      end
      def sanitize
        TextHelperSingleton.instance.sanitize(self)
      end
      def simple_format
        TextHelperSingleton.instance.simple_format(self)
      end
      def strip_tags
        TextHelperSingleton.instance.strip_tags(self)
      end
      begin
        require_library_or_gem 'redcloth'
        def textilize
          TextHelperSingleton.instance.textilize(self)
        end
        def textilize_without_paragraph
          TextHelperSingleton.instance.textilize_without_paragraph(self)
        end
      rescue LoadError
        # do nothing.  methods will be undefined
      end
      def truncate(length = 30, truncate_string = "...")
        TextHelperSingleton.instance.truncate(self, length, truncate_string)
      end
      def word_wrap(line_width = 80)
        TextHelperSingleton.instance.word_wrap(self, line_width)
      end
    end
  end

  module ActiveRecord
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
    #
    module TextScrubber
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

          include TextScrubber::InstanceMethods
        end
      end

      module InstanceMethods

        def sanitize_fields
          self.class.columns.each do |column|
            next unless (column.type == :string || column.type == :text)

            field = column.name.to_sym
            value = self[field]

            if value.nil?
              next
            elsif text_cleanup_options[:except].include?(field)
              next
            elsif text_cleanup_options[:allows_html].include?(field)
              self[field] = value.sanitize
            else
              self[field] = value.strip_tags
            end
          end
        end
      end
    end
  end
end