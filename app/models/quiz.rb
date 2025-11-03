class Quiz < ApplicationRecord
  has_many :questions, dependent: :destroy
  has_many :rooms, dependent: :destroy

  validates :name, presence: true, length: { minimum: 3, maximum: 100 }
  validates :questions_count, numericality: { greater_than_or_equal_to: 0 }

  after_initialize :set_defaults

  private

  def set_defaults
    self.questions_count ||= 0
  end
end
