module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_player

    def connect
      self.current_player = find_verified_player
      logger.add_tags 'ActionCable', current_player&.uuid
    end

    private

    def find_verified_player
      # Optional: verify player via query params
      player_uuid = request.params[:player_uuid]
      player_secret = request.params[:player_secret]

      if player_uuid.present?
        player = Player.find_by(uuid: player_uuid)
        if player && player_secret.present? && player.player_secret == player_secret
          player
        else
          nil # Allow anonymous connections for spectators
        end
      else
        nil # Allow anonymous connections
      end
    end
  end
end
