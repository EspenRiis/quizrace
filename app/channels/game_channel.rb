class GameChannel < ApplicationCable::Channel
  def subscribed
    room = Room.find_by(room_code: params[:room_code])

    if room
      stream_from "room_#{room.room_code}"

      # Send current room state to new subscriber
      transmit({
        type: 'connected',
        room: room_state(room)
      })
    else
      reject
    end
  end

  def unsubscribed
    # Cleanup when channel is unsubscribed
    stop_all_streams
  end

  def next_question(data)
    room = Room.find_by(room_code: data['room_code'])
    return unless room&.playing?

    # Increment question index
    room.increment!(:current_question_index)

    question = room.quiz.questions.order(:question_number)[room.current_question_index]

    if question
      # Strip correct answer for players
      question_data = question.as_json(except: [:correct_answer, :created_at, :updated_at])

      ActionCable.server.broadcast(
        "room_#{room.room_code}",
        {
          type: 'next_question',
          question: question_data,
          question_index: room.current_question_index,
          total_questions: room.quiz.questions_count
        }
      )
    else
      # No more questions, end game
      room.update!(status: :ended)

      ActionCable.server.broadcast(
        "room_#{room.room_code}",
        {
          type: 'game_ended',
          final_standings: calculate_standings(room)
        }
      )
    end
  end

  def submit_answer(data)
    room = Room.find_by(room_code: data['room_code'])
    player = Player.find_by(uuid: data['player_uuid'])
    question = Question.find(data['question_id'])

    return unless room&.playing? && player && question

    # Check if player secret matches (basic auth)
    return unless player.player_secret == data['player_secret']

    # Create answer record
    answer = Answer.create!(
      room: room,
      player: player,
      question: question,
      answer: data['answer'],
      time_taken: data['time_taken']
    )

    # Check if answer is correct
    is_correct = check_answer(question, data['answer'])
    answer.update!(correct: is_correct)

    # Calculate and update score
    if is_correct
      earned_score = answer.calculate_score(question)
      player.increment!(:score, earned_score)
    end

    # Broadcast answer received (to player only)
    transmit({
      type: 'answer_received',
      correct: is_correct,
      earned_score: is_correct ? earned_score : 0,
      total_score: player.score
    })

    # Update positions and broadcast to all
    update_positions(room)
  end

  def player_ready(data)
    player = Player.find_by(uuid: data['player_uuid'])
    return unless player

    ActionCable.server.broadcast(
      "room_#{player.room.room_code}",
      {
        type: 'player_ready',
        player_uuid: player.uuid
      }
    )
  end

  private

  def room_state(room)
    {
      room_code: room.room_code,
      status: room.status,
      player_count: room.players.count,
      current_question_index: room.current_question_index,
      quiz: room.quiz.as_json(only: [:id, :name, :questions_count])
    }
  end

  def check_answer(question, answer)
    case question.question_type
    when 'true_false'
      answer.to_s.downcase == question.correct_answer.to_s.downcase
    when 'multiple_choice', 'multiple_choice_images'
      answer.to_s == question.correct_answer.to_s
    else
      false
    end
  end

  def update_positions(room)
    # Get players sorted by score
    sorted_players = room.players.order(score: :desc, updated_at: :asc)

    positions_data = []
    sorted_players.each_with_index do |player, index|
      player.update_column(:position, index + 1)
      positions_data << {
        uuid: player.uuid,
        username: player.username,
        avatar: player.avatar,
        score: player.score,
        position: player.position
      }
    end

    # Broadcast updated positions to all players
    ActionCable.server.broadcast(
      "room_#{room.room_code}",
      {
        type: 'positions_updated',
        players: positions_data
      }
    )
  end

  def calculate_standings(room)
    room.players.order(score: :desc, updated_at: :asc).map do |player|
      {
        uuid: player.uuid,
        username: player.username,
        avatar: player.avatar,
        score: player.score,
        position: player.position
      }
    end
  end
end
