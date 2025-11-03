import { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { motion, AnimatePresence } from 'framer-motion';
import api from '../services/api';
import cable from '../services/cable';
import { Room, Player, WSMessage, PlayerJoinedMessage, GameStartedMessage } from '../types';

export default function LobbyPage() {
  const { roomCode } = useParams<{ roomCode: string }>();
  const navigate = useNavigate();
  const [room, setRoom] = useState<Room | null>(null);
  const [players, setPlayers] = useState<Player[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [isHost, setIsHost] = useState(false);

  useEffect(() => {
    if (!roomCode) {
      navigate('/');
      return;
    }

    loadRoom();
    connectToCable();

    return () => {
      cable.disconnect();
    };
  }, [roomCode]);

  const loadRoom = async () => {
    try {
      const roomData = await api.getRoom(roomCode!);
      setRoom(roomData);
      setIsHost(localStorage.getItem('isHost') === 'true');
      setLoading(false);
    } catch (err: any) {
      setError(err.message || 'Failed to load room');
      setLoading(false);
    }
  };

  const connectToCable = () => {
    const playerUuid = localStorage.getItem('playerUuid');
    const playerSecret = localStorage.getItem('playerSecret');

    cable.connect(roomCode!, playerUuid || undefined, playerSecret || undefined);
    cable.onMessage(handleMessage);
  };

  const handleMessage = (data: WSMessage) => {
    console.log('Received message:', data);

    switch (data.type) {
      case 'connected':
        // Initial room state
        break;

      case 'player_joined':
        const joinMsg = data as PlayerJoinedMessage;
        setPlayers((prev) => {
          const exists = prev.find((p) => p.uuid === joinMsg.player.uuid);
          if (exists) return prev;
          return [...prev, joinMsg.player];
        });
        break;

      case 'game_started':
        const startMsg = data as GameStartedMessage;
        console.log('Game started!', startMsg);
        navigate(`/game/${roomCode}`);
        break;

      default:
        console.log('Unhandled message type:', data.type);
    }
  };

  const handleStartGame = async () => {
    if (!roomCode) return;

    try {
      await api.startGame(roomCode);
      // Navigation will happen via WebSocket message
    } catch (err: any) {
      setError(err.message || 'Failed to start game');
    }
  };

  const copyRoomCode = () => {
    navigator.clipboard.writeText(roomCode!);
    alert('Room code copied to clipboard!');
  };

  if (loading) {
    return (
      <div className="lobby-page">
        <div className="loading">
          <div className="spinner"></div>
          <p>Loading lobby...</p>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="lobby-page">
        <div className="error-message">{error}</div>
        <button className="btn btn-primary" onClick={() => navigate('/')}>
          Back to Home
        </button>
      </div>
    );
  }

  return (
    <div className="lobby-page">
      <motion.div
        className="container"
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
      >
        <div className="lobby-header">
          <h1>🏁 Lobby 🏁</h1>
          <p className="subtitle">{room?.quiz.name}</p>

          <div className="room-code-section">
            <p>Room Code:</p>
            <div className="room-code-display" onClick={copyRoomCode} style={{ cursor: 'pointer' }}>
              {roomCode}
            </div>
            <p className="hint">Click to copy</p>
          </div>

          <div className="player-count">
            <span className="count">{players.length}</span> / {room?.max_players} players
          </div>
        </div>

        {players.length === 0 && (
          <motion.div
            className="waiting-message"
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            style={{ textAlign: 'center', padding: '2rem', color: 'var(--text-dim)' }}
          >
            <h3>Waiting for players to join...</h3>
            <p>Share the room code with your friends!</p>
          </motion.div>
        )}

        <AnimatePresence>
          <div className="players-grid">
            {players.map((player, index) => (
              <motion.div
                key={player.uuid}
                className="player-card"
                initial={{ opacity: 0, scale: 0.8 }}
                animate={{ opacity: 1, scale: 1 }}
                exit={{ opacity: 0, scale: 0.8 }}
                transition={{ delay: index * 0.1 }}
              >
                <div className="player-avatar">{player.avatar}</div>
                <div className="player-name">{player.username}</div>
              </motion.div>
            ))}
          </div>
        </AnimatePresence>

        {isHost && (
          <motion.div
            className="host-controls"
            style={{ marginTop: '2rem' }}
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            transition={{ delay: 0.5 }}
          >
            <button
              className="btn btn-primary"
              onClick={handleStartGame}
              disabled={players.length === 0}
              style={{ maxWidth: '400px', margin: '0 auto' }}
            >
              {players.length === 0 ? 'Waiting for players...' : `Start Game (${players.length} players)`}
            </button>
          </motion.div>
        )}

        {!isHost && (
          <motion.div
            style={{ textAlign: 'center', marginTop: '2rem', color: 'var(--text-dim)' }}
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
          >
            <p>Waiting for host to start the game...</p>
          </motion.div>
        )}
      </motion.div>
    </div>
  );
}
