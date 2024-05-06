class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher

  after_create :create_default_company_and_profile

  has_one :profile

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  def create_default_company_and_profile
    return if self.profile.present?

    default_company = Company.create(name: 'My company')

    Profile.create(user: self, company: default_company, role: :admin)
  end

  def switch_company_and_role(new_company_id, new_role)
    self.profile.update!(role: new_role, company_id: new_company_id)
  end

  # Permissions 
  def admin?
    self.profile&.admin?
  end

  def collaborator?
    self.profile&.collaborator?
  end

  def can_manage_events_of?(profile)
    can_view_events_of?(profile) && can_create_event_for?(profile)
  end

  def can_view_events_of?(profile)
    self.admin? && profile.company == self.profile.company
  end

  def can_create_event_for?(profile)
    self.admin? && profile.company == self.profile.company
  end
end
