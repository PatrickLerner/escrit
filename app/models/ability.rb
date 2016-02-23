class Ability
  include CanCan::Ability

  def initialize(user)
    if user.councilor? || user.advisor? || user.doge?
      can :publish, Text
      can :manage, Text, public: true
    end

    if user.advisor? || user.doge?
      can :manage, Artwork
      can :manage, Compliment
      can :manage, Text
      can :shadow, User
    end

    if user.doge?
      can :publish, Service
      can :manage, Language
      can :manage, Replacement
    end

    can :manage, Text, user_id: user.id
  end
end
