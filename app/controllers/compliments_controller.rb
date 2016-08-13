class ComplimentsController < ReadScaffoldController
  resource Compliment

  protected

  def collection
    current_user.compliments
  end
end
