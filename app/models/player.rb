class Player < ApplicationRecord
  belongs_to :room
  has_many :answers, dependent: :destroy

  validates :username, presence: true, length: { minimum: 1, maximum: 50 }
  validates :uuid, presence: true, uniqueness: true
  validates :player_secret, presence: true
  validates :score, numericality: { greater_than_or_equal_to: 0 }
  validates :position, numericality: { greater_than_or_equal_to: 1 }, allow_nil: true

  before_validation :generate_uuid, on: :create
  before_validation :generate_player_secret, on: :create
  after_initialize :set_defaults

  private

  def set_defaults
    self.score ||= 0
    self.position ||= 1
    self.avatar ||= "🏎️"
  end

  def generate_uuid
    require 'securerandom'
    self.uuid ||= SecureRandom.uuid
  end

  def generate_player_secret
    require 'securerandom'
    self.player_secret ||= SecureRandom.hex(16)
  end
end
