class Room < ApplicationRecord
  belongs_to :quiz
  has_many :players, dependent: :destroy
  has_many :answers, dependent: :destroy

  enum status: {
    lobby: 0,
    playing: 1,
    ended: 2
  }

  validates :room_code, presence: true, uniqueness: true, length: { is: 6 }
  validates :status, presence: true
  validates :max_players, numericality: { greater_than: 0, less_than_or_equal_to: 1000 }
  validates :current_question_index, numericality: { greater_than_or_equal_to: 0 }

  after_initialize :set_defaults
  before_validation :generate_room_code, on: :create

  scope :active, -> { where(status: [:lobby, :playing]) }
  scope :lobby_rooms, -> { where(status: :lobby) }

  def full?
    players.count >= max_players
  end

  def can_start?
    lobby? && players.count > 0
  end

  private

  def set_defaults
    self.status ||= :lobby
    self.max_players ||= 500
    self.current_question_index ||= 0
  end

  def generate_room_code
    return if room_code.present?

    loop do
      code = rand(100_000..999_999).to_s
      break self.room_code = code unless Room.exists?(room_code: code)
    end
  end
end
