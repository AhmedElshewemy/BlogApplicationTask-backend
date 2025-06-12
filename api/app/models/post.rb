class Post < ApplicationRecord
  belongs_to :user
  has_many   :post_tags,  dependent: :destroy
  has_many   :tags,       through: :post_tags
  has_many   :comments,   dependent: :destroy

  # Validations
  validates  :title, presence: true
  validates  :body,  presence: true
  validate   :must_have_at_least_one_tag

  private

  # Ensures that at least one tag is assigned to the post
  def must_have_at_least_one_tag
    errors.add(:tags, "must have at least one") if tags.blank?
  end
end
