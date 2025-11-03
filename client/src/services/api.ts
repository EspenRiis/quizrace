import { Quiz, Room, Player } from '../types';

const API_BASE = '/api/v1';

class ApiService {
  private async request<T>(
    endpoint: string,
    options?: RequestInit
  ): Promise<T> {
    const response = await fetch(`${API_BASE}${endpoint}`, {
      ...options,
      headers: {
        'Content-Type': 'application/json',
        ...options?.headers,
      },
      credentials: 'include',
    });

    if (!response.ok) {
      const error = await response.json().catch(() => ({ error: 'Request failed' }));
      throw new Error(error.error || `HTTP ${response.status}`);
    }

    return response.json();
  }

  // Quizzes
  async getQuizzes(): Promise<Quiz[]> {
    return this.request<Quiz[]>('/quizzes');
  }

  async getQuiz(id: number): Promise<Quiz> {
    return this.request<Quiz>(`/quizzes/${id}`);
  }

  async createQuiz(data: { name: string }): Promise<Quiz> {
    return this.request<Quiz>('/quizzes', {
      method: 'POST',
      body: JSON.stringify({ quiz: data }),
    });
  }

  // Rooms
  async createRoom(quizId: number, hostUserId?: number): Promise<{ room_code: string; id: number; status: string; quiz: Quiz }> {
    return this.request(`/rooms`, {
      method: 'POST',
      body: JSON.stringify({
        quiz_id: quizId,
        host_user_id: hostUserId || 1
      }),
    });
  }

  async getRoom(roomCode: string): Promise<Room> {
    return this.request<Room>(`/rooms/${roomCode}`);
  }

  async getRoomStatus(roomCode: string): Promise<{
    room_code: string;
    status: string;
    player_count: number;
    max_players: number;
    can_start: boolean;
    full: boolean;
  }> {
    return this.request(`/rooms/${roomCode}/status`);
  }

  async joinRoom(roomCode: string, username: string, avatar?: string): Promise<{
    player: Player;
    room: Room;
  }> {
    return this.request(`/rooms/${roomCode}/join`, {
      method: 'POST',
      body: JSON.stringify({
        username,
        avatar: avatar || '🏎️'
      }),
    });
  }

  async startGame(roomCode: string): Promise<{ status: string; started_at: string }> {
    return this.request(`/rooms/${roomCode}/start`, {
      method: 'POST',
    });
  }

  async getPlayer(uuid: string): Promise<Player> {
    return this.request<Player>(`/players/${uuid}`);
  }
}

export default new ApiService();
