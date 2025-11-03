module Api
  module V1
    class PlayersController < BaseController
      def show
        @player = Player.find_by!(uuid: params[:id])
        render json: {
          id: @player.id,
          uuid: @player.uuid,
          username: @player.username,
          avatar: @player.avatar,
          score: @player.score,
          position: @player.position,
          room_code: @player.room.room_code
        }
      end
    end
  end
end
