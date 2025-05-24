class Tag < ApplicationRecord
  has_many :post_tags,  dependent: :destroy
  has_many :posts,      through: :post_tags

  validates :name, presence: true, uniqueness: true
        
    # # Custom validation: ensure that the tag name is not too short
    # validate :name_must_be_long_enough
    
    # private
    
    # def name_must_be_long_enough
    #     errors.add(:name, "must be at least 3 characters long") if name.length < 3
    # end
end
