module TokenRelated
  extend ActiveSupport::Concern

  def self.included(base)
    base.before_destroy :prepare_delete_words
    base.after_destroy :delete_words
  end

  protected

  def prepare_delete_words
    @token_ids = token_ids
  end

  def delete_words
    Token.where(id: @token_ids).each(&:destroy)
  end
end
