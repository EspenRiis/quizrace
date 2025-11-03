class Question < ApplicationRecord
  belongs_to :quiz
  has_many :answers, dependent: :destroy

  enum question_type: {
    true_false: 0,
    multiple_choice: 1,
    multiple_choice_images: 2
  }

  validates :sentence, presence: true, length: { minimum: 3, maximum: 200 }
  validates :time_limit, presence: true, numericality: { greater_than_or_equal_to: 3, less_than_or_equal_to: 60 }
  validates :points, presence: true, numericality: { greater_than: 0 }
  validates :question_number, presence: true, numericality: { greater_than: 0 }
  validates :question_type, presence: true
  validates :possible_answers, presence: true

  after_initialize :set_defaults

  private

  def set_defaults
    self.time_limit ||= 10
    self.points ||= 100
    self.possible_answers ||= []
  end
end
