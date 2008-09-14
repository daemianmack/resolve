class TextSanitizer
  include ActionView::Helpers::TextHelper #will allow autolinking and text transformation, if we want it
  include ActionView::Helpers::SanitizeHelper
end