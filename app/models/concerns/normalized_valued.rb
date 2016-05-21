module NormalizedValued
  extend ActiveSupport::Concern

  WORD_REGEX = %r{                # either it
    ^\p{Ll}                       #   starts with alpha
    [\p{Ll}\-\|\.:\/\?=0-9%_]+    #   continues with alpha, num or special
    [\p{Ll}0-9]$                  #   and finally ends in alpha or num
    |                             # or alternatively
    ^\p{Ll}+$                     #   it is only alpha, even just one letter
  }x

  def self.included(base)
    base.validates :value, length: { minimum: 1 }, format: { with: WORD_REGEX }

    base.normalize_attribute :value, with: :umlaut

    base.param_field :value
  end
end
