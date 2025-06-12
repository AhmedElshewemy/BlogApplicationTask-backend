class User < ApplicationRecord
  # Adds methods to set and authenticate against a BCrypt password using `password_digest`
  has_secure_password

  # Associations
  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :destroy

  # Validations
  validates :name,  presence: true
  validates :email, presence: true, uniqueness: true
  validates :password_confirmation, presence: true, if: -> { password.present? }

  # The `image` attribute is optional and can be blank or a URL
end
