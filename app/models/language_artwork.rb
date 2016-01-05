class LanguageArtwork < ActiveRecord::Base
  belongs_to :language

  has_attached_file :image

  validates_attachment_presence :image
  # Validate content type
  validates_attachment_content_type :image, content_type: /\Aimage/
  # Validate filename
  validates_attachment_file_name :image, matches: [/png\Z/, /jpe?g\Z/]
  # Validate filesize
  validates_with AttachmentSizeValidator, attributes: :image, less_than: 600.kilobytes
end
