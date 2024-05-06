class Profile < ApplicationRecord
  belongs_to :user
  belongs_to :company

  has_many :events, dependent: :destroy
  
  enum role: { admin: 0, collaborator: 1 }
end
