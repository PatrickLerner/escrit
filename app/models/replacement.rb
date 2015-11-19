class Replacement < ActiveRecord::Base
  belongs_to :language

  def self.for_language language_id
    all_replacements = Rails.cache.fetch('replacements') do
      Replacement.all
    end
    all_replacements.select { |r|
      [language_id, nil, 0].include? r.language_id
    }
  end
end
