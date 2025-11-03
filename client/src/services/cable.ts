import { createConsumer, Cable, Channel } from '@rails/actioncable';
import { WSMessage } from '../types';

class CableService {
  private cable: Cable | null = null;
  private channel: Channel | null = null;

  connect(roomCode: string, playerUuid?: string, playerSecret?: string): Channel {
    const url = playerUuid && playerSecret
      ? `/cable?player_uuid=${playerUuid}&player_secret=${playerSecret}`
      : '/cable';

    this.cable = createConsumer(url);

    this.channel = this.cable.subscriptions.create(
      {
        channel: 'GameChannel',
        room_code: roomCode,
      },
      {
        connected: () => {
          console.log('Connected to GameChannel', roomCode);
        },
        disconnected: () => {
          console.log('Disconnected from GameChannel');
        },
        received: (data: WSMessage) => {
          // Messages will be handled by onMessage callback
          console.log('Received:', data);
        },
      }
    );

    return this.channel;
  }

  onMessage(callback: (data: WSMessage) => void) {
    if (this.channel) {
      this.channel.received = callback;
    }
  }

  send(action: string, data: any) {
    if (this.channel) {
      this.channel.perform(action, data);
    }
  }

  nextQuestion(roomCode: string) {
    this.send('next_question', { room_code: roomCode });
  }

  submitAnswer(
    roomCode: string,
    playerUuid: string,
    playerSecret: string,
    questionId: number,
    answer: string,
    timeTaken: number
  ) {
    this.send('submit_answer', {
      room_code: roomCode,
      player_uuid: playerUuid,
      player_secret: playerSecret,
      question_id: questionId,
      answer,
      time_taken: timeTaken,
    });
  }

  playerReady(playerUuid: string) {
    this.send('player_ready', { player_uuid: playerUuid });
  }

  disconnect() {
    if (this.channel) {
      this.channel.unsubscribe();
      this.channel = null;
    }
    if (this.cable) {
      this.cable.disconnect();
      this.cable = null;
    }
  }
}

export default new CableService();
