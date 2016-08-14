class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new

    user_permissions(user)      if user.admin? || user.moderator? || user.user?
    moderator_permissions(user) if user.admin? || user.moderator?
    admin_permissions(user)     if user.admin?
  end

  def user_permissions(user)
    # languages can only be read by users
    can :read, [Language, Word, Service, Compliment]
    can :manage, Token

    # everybody may mange their own texts and services
    can :read, Text do |object|
      object.user_id == user.id || object.public?
    end

    can %i(update create destroy), Text do |object|
      object.user_id == user.id
    end

    can %i(read update create destroy), Service do |object|
      object.user_id == user.id
    end
  end

  def moderator_permissions(_user)
    can :manage, [Text, Compliment]
  end

  def admin_permissions(_user)
    can :manage, :all
  end
end
