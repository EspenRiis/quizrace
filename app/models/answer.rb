class Answer < ApplicationRecord
  belongs_to :room
  belongs_to :player
  belongs_to :question

  validates :answer, presence: true
  validates :time_taken, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :correct, inclusion: { in: [true, false] }, allow_nil: true

  scope :for_question, ->(question_id) { where(question_id: question_id) }
  scope :for_player, ->(player_id) { where(player_id: player_id) }
  scope :correct_answers, -> { where(correct: true) }

  def calculate_score(question)
    return 0 unless correct

    base_score = question.points
    time_bonus = calculate_time_bonus(question.time_limit)

    (base_score * time_bonus).round
  end

  private

  def calculate_time_bonus
    # Speed bonus: 70% to 130% based on answer speed
    # Faster answers get higher multipliers
    return 1.3 if time_taken.nil?

    max_time = question.time_limit
    speed_ratio = (max_time - time_taken) / max_time
    0.7 + (0.6 * [speed_ratio, 1.0].min)
  end
end
