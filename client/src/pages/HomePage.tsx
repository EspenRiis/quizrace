import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import api from '../services/api';
import { Quiz } from '../types';
import { motion } from 'framer-motion';

export default function HomePage() {
  const [quizzes, setQuizzes] = useState<Quiz[]>([]);
  const [selectedQuiz, setSelectedQuiz] = useState<number | null>(null);
  const [roomCode, setRoomCode] = useState('');
  const [username, setUsername] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const navigate = useNavigate();

  useEffect(() => {
    loadQuizzes();
  }, []);

  const loadQuizzes = async () => {
    try {
      const data = await api.getQuizzes();
      setQuizzes(data);
      if (data.length > 0) {
        setSelectedQuiz(data[0].id);
      }
    } catch (err) {
      console.error('Failed to load quizzes:', err);
      setError('Failed to load quizzes');
    }
  };

  const handleCreateRoom = async () => {
    if (!selectedQuiz) {
      setError('Please select a quiz');
      return;
    }

    setLoading(true);
    setError('');

    try {
      const room = await api.createRoom(selectedQuiz);
      // Store as host
      localStorage.setItem('isHost', 'true');
      localStorage.setItem('roomCode', room.room_code);
      navigate(`/lobby/${room.room_code}`);
    } catch (err: any) {
      setError(err.message || 'Failed to create room');
    } finally {
      setLoading(false);
    }
  };

  const handleJoinRoom = async () => {
    if (!roomCode.trim()) {
      setError('Please enter a room code');
      return;
    }

    if (!username.trim()) {
      setError('Please enter your name');
      return;
    }

    setLoading(true);
    setError('');

    try {
      const result = await api.joinRoom(roomCode.toUpperCase(), username);
      // Store player info
      localStorage.setItem('playerUuid', result.player.uuid);
      localStorage.setItem('playerSecret', result.player.player_secret || '');
      localStorage.setItem('roomCode', roomCode.toUpperCase());
      localStorage.setItem('isHost', 'false');
      navigate(`/lobby/${roomCode.toUpperCase()}`);
    } catch (err: any) {
      setError(err.message || 'Failed to join room');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="home-page">
      <motion.div
        className="container"
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.5 }}
      >
        <h1 className="title">🏁 QuizRace 🏁</h1>
        <p className="subtitle">Real-time multiplayer quiz racing game</p>

        {error && <div className="error-message">{error}</div>}

        <div className="actions-grid">
          {/* Create Room Section */}
          <motion.div
            className="card create-card"
            whileHover={{ scale: 1.02 }}
            transition={{ type: 'spring', stiffness: 300 }}
          >
            <h2>🎮 Host a Game</h2>
            <div className="form-group">
              <label>Select Quiz:</label>
              <select
                value={selectedQuiz || ''}
                onChange={(e) => setSelectedQuiz(Number(e.target.value))}
                disabled={loading}
              >
                {quizzes.map((quiz) => (
                  <option key={quiz.id} value={quiz.id}>
                    {quiz.name} ({quiz.questions_count} questions)
                  </option>
                ))}
              </select>
            </div>
            <button
              className="btn btn-primary"
              onClick={handleCreateRoom}
              disabled={loading || !selectedQuiz}
            >
              {loading ? 'Creating...' : 'Create Room'}
            </button>
          </motion.div>

          {/* Join Room Section */}
          <motion.div
            className="card join-card"
            whileHover={{ scale: 1.02 }}
            transition={{ type: 'spring', stiffness: 300 }}
          >
            <h2>🚀 Join a Game</h2>
            <div className="form-group">
              <label>Your Name:</label>
              <input
                type="text"
                value={username}
                onChange={(e) => setUsername(e.target.value)}
                placeholder="Enter your name"
                maxLength={50}
                disabled={loading}
              />
            </div>
            <div className="form-group">
              <label>Room Code:</label>
              <input
                type="text"
                value={roomCode}
                onChange={(e) => setRoomCode(e.target.value.toUpperCase())}
                placeholder="6-digit code"
                maxLength={6}
                disabled={loading}
              />
            </div>
            <button
              className="btn btn-secondary"
              onClick={handleJoinRoom}
              disabled={loading || !roomCode || !username}
            >
              {loading ? 'Joining...' : 'Join Room'}
            </button>
          </motion.div>
        </div>

        <div className="info-section">
          <h3>How to Play:</h3>
          <ol>
            <li>Host creates a room and shares the 6-digit code</li>
            <li>Players join using the room code and their name</li>
            <li>Host starts the game when everyone is ready</li>
            <li>Answer questions quickly to earn more points!</li>
            <li>Watch your avatar race forward as you score</li>
          </ol>
        </div>
      </motion.div>
    </div>
  );
}
