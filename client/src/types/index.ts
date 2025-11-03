export interface Quiz {
  id: number;
  name: string;
  questions_count: number;
  created_by_id?: number;
}

export enum QuestionType {
  TrueFalse = 'true_false',
  MultipleChoice = 'multiple_choice',
  MultipleChoiceImages = 'multiple_choice_images',
}

export interface Question {
  id: number;
  quiz_id: number;
  sentence: string;
  question_type: QuestionType;
  time_limit: number;
  points: number;
  question_number: number;
  possible_answers: string[];
  correct_answer?: string; // Only for host/results
}

export enum RoomStatus {
  Lobby = 'lobby',
  Playing = 'playing',
  Ended = 'ended',
}

export interface Room {
  id: number;
  room_code: string;
  status: RoomStatus;
  player_count: number;
  max_players: number;
  quiz: Quiz;
  started_at?: string;
}

export interface Player {
  id: number;
  uuid: string;
  username: string;
  avatar: string;
  score: number;
  position: number;
  player_secret?: string;
}

export interface Answer {
  id: number;
  room_id: number;
  player_id: number;
  question_id: number;
  answer: string;
  time_taken: number;
  correct: boolean;
}

// WebSocket message types
export interface WSMessage {
  type: string;
  [key: string]: any;
}

export interface PlayerJoinedMessage extends WSMessage {
  type: 'player_joined';
  player: Player;
  player_count: number;
}

export interface GameStartedMessage extends WSMessage {
  type: 'game_started';
  started_at: string;
}

export interface NextQuestionMessage extends WSMessage {
  type: 'next_question';
  question: Question;
  question_index: number;
  total_questions: number;
}

export interface PositionsUpdatedMessage extends WSMessage {
  type: 'positions_updated';
  players: Player[];
}

export interface GameEndedMessage extends WSMessage {
  type: 'game_ended';
  final_standings: Player[];
}

export interface AnswerReceivedMessage extends WSMessage {
  type: 'answer_received';
  correct: boolean;
  earned_score: number;
  total_score: number;
}

export interface ConnectedMessage extends WSMessage {
  type: 'connected';
  room: Room;
}
