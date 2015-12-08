class Occurrence < ActiveRecord::Base
  belongs_to :word
  belongs_to :text
end
