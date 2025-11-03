module Api
  module V1
    class RoomsController < BaseController
      before_action :set_room, only: [:show, :status, :join, :start]

      def create
        quiz = Quiz.find(params[:quiz_id])
        @room = Room.new(
          quiz: quiz,
          host_user_id: params[:host_user_id],
          max_players: params[:max_players] || 500
        )

        if @room.save
          render json: {
            room_code: @room.room_code,
            id: @room.id,
            status: @room.status,
            quiz: quiz.as_json(only: [:id, :name, :questions_count])
          }, status: :created
        else
          render_error(@room.errors.full_messages.join(', '), status: :unprocessable_entity)
        end
      end

      def show
        render json: room_json
      end

      def status
        render json: {
          room_code: @room.room_code,
          status: @room.status,
          player_count: @room.players.count,
          max_players: @room.max_players,
          can_start: @room.can_start?,
          full: @room.full?
        }
      end

      def join
        if @room.ended?
          return render_error('Room has ended', status: :gone)
        end

        if @room.full?
          return render_error('Room is full', status: :forbidden)
        end

        player = @room.players.new(
          username: params[:username],
          avatar: params[:avatar] || '🏎️'
        )

        if player.save
          # Broadcast player joined via ActionCable
          ActionCable.server.broadcast(
            "room_#{@room.room_code}",
            {
              type: 'player_joined',
              player: player_json(player),
              player_count: @room.players.count
            }
          )

          render json: {
            player: player_json(player),
            room: room_json
          }, status: :created
        else
          render_error(player.errors.full_messages.join(', '), status: :unprocessable_entity)
        end
      end

      def start
        unless @room.can_start?
          return render_error('Cannot start game', status: :unprocessable_entity)
        end

        @room.update!(status: :playing, started_at: Time.current)

        # Broadcast game start via ActionCable
        ActionCable.server.broadcast(
          "room_#{@room.room_code}",
          {
            type: 'game_started',
            started_at: @room.started_at.iso8601
          }
        )

        render json: { status: @room.status, started_at: @room.started_at }
      end

      private

      def set_room
        @room = Room.find_by!(room_code: params[:id]) if params[:id].length == 6
        @room ||= Room.find(params[:id])
      end

      def room_json
        {
          id: @room.id,
          room_code: @room.room_code,
          status: @room.status,
          player_count: @room.players.count,
          max_players: @room.max_players,
          quiz: @room.quiz.as_json(only: [:id, :name, :questions_count]),
          started_at: @room.started_at
        }
      end

      def player_json(player)
        {
          id: player.id,
          uuid: player.uuid,
          username: player.username,
          avatar: player.avatar,
          score: player.score,
          position: player.position,
          player_secret: player.player_secret
        }
      end
    end
  end
end
