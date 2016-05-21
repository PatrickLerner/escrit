AttributeNormalizer.configure do |config|
  config.normalizers[:umlaut] = lambda do |value, _|
    if value.is_a?(String) || value.is_a?(ActiveSupport::Multibyte::Chars)
      value.mb_chars.normalize(:kc).delete("\r").to_s
    else
      value
    end
  end

  config.normalizers[:downcase] = lambda do |value, _|
    if value.is_a?(String) || value.is_a?(ActiveSupport::Multibyte::Chars)
      value.mb_chars.downcase.to_s
    else
      value
    end
  end

  config.default_normalizers = [:umlaut, :strip, :blank]
end
