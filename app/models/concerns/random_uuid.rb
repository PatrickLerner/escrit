module RandomUuid
  extend ActiveSupport::Concern

  UUID_LENGTH = 6
  UUID_REGEX = /\A[A-Za-z0-9]{#{UUID_LENGTH}}\z/

  included do
    before_validation :set_uuid, unless: :uuid?

    validates :uuid, format: { with: UUID_REGEX }
  end

  private

  def set_uuid
    generate_unique_random_base64(:uuid, UUID_LENGTH)
  end

  def generate_unique_random_base64(attribute, n)
    send(:"#{attribute}=", random_base64(n)) until random_is_unique?(attribute)
  end

  def random_is_unique?(attribute)
    val = send(:"#{attribute}")
    val && !self.class.send(:"find_by_#{attribute}", val)
  end

  def random_base64(n)
    val = base64_url
    val += base64_url while val.length < n
    val.slice(0..(n - 1))
  end

  def base64_url
    SecureRandom.base64(60).downcase.gsub(/\W/, '')
  end
end
