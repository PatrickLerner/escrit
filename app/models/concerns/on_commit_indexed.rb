# immediately index the object instead of being lazy as ES usually is
module OnCommitIndexed
  extend ActiveSupport::Concern

  def self.included(base)
    base.after_save :__force_reindex!
  end

  protected

  def __force_reindex!
    reindex
    self.class.searchkick_index.refresh
  end
end
