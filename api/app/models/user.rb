class User < ApplicationRecord
    # bcrypt will look for `password_digest`
    has_secure_password

    # AE
    has_many :posts,    dependent: :destroy
    has_many :comments, dependent: :destroy

    # Validations
    validates :name,  presence: true
    validates :email, presence: true, uniqueness: true
    # `image` can be blank or a URL—no strict validation here
end
