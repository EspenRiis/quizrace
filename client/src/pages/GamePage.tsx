import { useState, useEffect, useRef } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { motion, AnimatePresence } from 'framer-motion';
import confetti from 'canvas-confetti';
import cable from '../services/cable';
import {
  Player,
  Question,
  WSMessage,
  NextQuestionMessage,
  PositionsUpdatedMessage,
  GameEndedMessage,
  AnswerReceivedMessage,
} from '../types';

export default function GamePage() {
  const { roomCode } = useParams<{ roomCode: string }>();
  const navigate = useNavigate();

  const [players, setPlayers] = useState<Player[]>([]);
  const [currentQuestion, setCurrentQuestion] = useState<Question | null>(null);
  const [questionIndex, setQuestionIndex] = useState(0);
  const [totalQuestions, setTotalQuestions] = useState(0);
  const [timeLeft, setTimeLeft] = useState(0);
  const [answered, setAnswered] = useState(false);
  const [selectedAnswer, setSelectedAnswer] = useState<string | null>(null);
  const [isCorrect, setIsCorrect] = useState<boolean | null>(null);
  const [gameEnded, setGameEnded] = useState(false);
  const [finalStandings, setFinalStandings] = useState<Player[]>([]);

  const questionStartTime = useRef<number>(0);
  const timerRef = useRef<NodeJS.Timeout | null>(null);
  const playerUuid = localStorage.getItem('playerUuid');
  const playerSecret = localStorage.getItem('playerSecret');
  const isHost = localStorage.getItem('isHost') === 'true';

  useEffect(() => {
    if (!roomCode) {
      navigate('/');
      return;
    }

    cable.connect(roomCode, playerUuid || undefined, playerSecret || undefined);
    cable.onMessage(handleMessage);

    // Host starts first question
    if (isHost) {
      setTimeout(() => {
        cable.nextQuestion(roomCode);
      }, 2000);
    }

    return () => {
      if (timerRef.current) clearInterval(timerRef.current);
      cable.disconnect();
    };
  }, [roomCode]);

  useEffect(() => {
    if (currentQuestion && !answered) {
      questionStartTime.current = Date.now();
      setTimeLeft(currentQuestion.time_limit);

      if (timerRef.current) clearInterval(timerRef.current);

      timerRef.current = setInterval(() => {
        setTimeLeft((prev) => {
          if (prev <= 1) {
            clearInterval(timerRef.current!);
            return 0;
          }
          return prev - 1;
        });
      }, 1000);
    }

    return () => {
      if (timerRef.current) clearInterval(timerRef.current);
    };
  }, [currentQuestion, answered]);

  const handleMessage = (data: WSMessage) => {
    console.log('Game message:', data);

    switch (data.type) {
      case 'next_question':
        const nextMsg = data as NextQuestionMessage;
        setCurrentQuestion(nextMsg.question);
        setQuestionIndex(nextMsg.question_index);
        setTotalQuestions(nextMsg.total_questions);
        setAnswered(false);
        setSelectedAnswer(null);
        setIsCorrect(null);
        break;

      case 'positions_updated':
        const posMsg = data as PositionsUpdatedMessage;
        setPlayers(posMsg.players);
        break;

      case 'answer_received':
        const answerMsg = data as AnswerReceivedMessage;
        setIsCorrect(answerMsg.correct);
        break;

      case 'game_ended':
        const endMsg = data as GameEndedMessage;
        setGameEnded(true);
        setFinalStandings(endMsg.final_standings);
        setCurrentQuestion(null);

        // Confetti for winner!
        if (endMsg.final_standings[0]?.uuid === playerUuid) {
          confetti({
            particleCount: 100,
            spread: 70,
            origin: { y: 0.6 },
          });
        }
        break;
    }
  };

  const handleAnswerClick = (answer: string) => {
    if (answered || !currentQuestion || !playerUuid || !playerSecret) return;

    const timeTaken = (Date.now() - questionStartTime.current) / 1000;
    setAnswered(true);
    setSelectedAnswer(answer);

    cable.submitAnswer(
      roomCode!,
      playerUuid,
      playerSecret,
      currentQuestion.id,
      answer,
      timeTaken
    );

    // Host moves to next question after delay
    if (isHost) {
      setTimeout(() => {
        cable.nextQuestion(roomCode!);
      }, 3000);
    }
  };

  const getAnswerClass = (answer: string) => {
    if (!answered || selectedAnswer !== answer) return '';
    return isCorrect ? 'correct' : 'incorrect';
  };

  if (gameEnded) {
    return (
      <div className="game-page">
        <motion.div
          className="winner-screen"
          initial={{ opacity: 0, scale: 0.9 }}
          animate={{ opacity: 1, scale: 1 }}
          style={{
            display: 'flex',
            flexDirection: 'column',
            alignItems: 'center',
            justifyContent: 'center',
            minHeight: '100vh',
            padding: '2rem',
          }}
        >
          <h1 style={{ fontSize: '3rem', marginBottom: '2rem' }}>🏁 Game Over! 🏁</h1>

          <div className="podium" style={{ marginBottom: '2rem' }}>
            {finalStandings.slice(0, 3).map((player, index) => (
              <motion.div
                key={player.uuid}
                className="podium-place"
                initial={{ opacity: 0, y: 50 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: index * 0.2 }}
                style={{
                  background: 'var(--bg-card)',
                  border: '2px solid var(--border)',
                  borderRadius: '1rem',
                  padding: '2rem',
                  margin: '1rem',
                  textAlign: 'center',
                  minWidth: '200px',
                }}
              >
                <div style={{ fontSize: '3rem' }}>
                  {index === 0 ? '🥇' : index === 1 ? '🥈' : '🥉'}
                </div>
                <div style={{ fontSize: '2rem', margin: '0.5rem 0' }}>{player.avatar}</div>
                <div style={{ fontSize: '1.5rem', fontWeight: 'bold' }}>{player.username}</div>
                <div style={{ fontSize: '1.2rem', color: 'var(--primary)' }}>
                  {player.score} points
                </div>
              </motion.div>
            ))}
          </div>

          <button
            className="btn btn-primary"
            onClick={() => navigate('/')}
            style={{ maxWidth: '300px' }}
          >
            Back to Home
          </button>
        </motion.div>
      </div>
    );
  }

  return (
    <div className="game-page">
      <div className="game-header">
        <div>
          Question {questionIndex + 1} / {totalQuestions}
        </div>
        <div>Room: {roomCode}</div>
      </div>

      <div className="race-track">
        <div className="track-container" style={{ position: 'relative', height: '100%', padding: '2rem' }}>
          {/* Simple 2D Track Visualization */}
          <div className="track-lines" style={{ position: 'relative', height: '100%' }}>
            {players.map((player, index) => {
              const maxScore = Math.max(...players.map(p => p.score), 1);
              const progress = (player.score / maxScore) * 100;

              return (
                <motion.div
                  key={player.uuid}
                  className="player-lane"
                  style={{
                    position: 'relative',
                    height: `${100 / Math.min(players.length, 10)}%`,
                    borderBottom: '1px solid var(--border)',
                    display: 'flex',
                    alignItems: 'center',
                    padding: '0.5rem',
                  }}
                >
                  <motion.div
                    className="player-vehicle"
                    animate={{ left: `${progress}%` }}
                    transition={{ type: 'spring', stiffness: 100, damping: 20 }}
                    style={{
                      position: 'absolute',
                      fontSize: '2rem',
                      filter: player.uuid === playerUuid ? 'drop-shadow(0 0 10px var(--primary))' : 'none',
                    }}
                  >
                    {player.avatar}
                  </motion.div>
                  <div style={{ marginLeft: '3rem', fontSize: '0.9rem' }}>
                    {player.username}: {player.score}
                  </div>
                </motion.div>
              );
            })}
          </div>
        </div>
      </div>

      {/* Question Overlay */}
      <AnimatePresence>
        {currentQuestion && (
          <motion.div
            className="question-overlay"
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
          >
            <motion.div
              className="question-card"
              initial={{ scale: 0.9 }}
              animate={{ scale: 1 }}
            >
              <div className="timer-display">{timeLeft}s</div>
              <div className="question-text">{currentQuestion.sentence}</div>

              <div className="answers-grid">
                {currentQuestion.possible_answers.map((answer) => (
                  <button
                    key={answer}
                    className={`answer-btn ${getAnswerClass(answer)}`}
                    onClick={() => handleAnswerClick(answer)}
                    disabled={answered || timeLeft === 0}
                  >
                    {answer}
                  </button>
                ))}
              </div>

              {answered && (
                <motion.div
                  initial={{ opacity: 0, y: 20 }}
                  animate={{ opacity: 1, y: 0 }}
                  style={{ marginTop: '1rem', fontSize: '1.5rem', fontWeight: 'bold' }}
                >
                  {isCorrect ? '✅ Correct!' : '❌ Wrong!'}
                </motion.div>
              )}
            </motion.div>
          </motion.div>
        )}
      </AnimatePresence>

      {/* Leaderboard */}
      <div className="leaderboard">
        <h3>🏆 Leaderboard</h3>
        {players
          .sort((a, b) => b.score - a.score)
          .map((player, index) => (
            <div
              key={player.uuid}
              className={`leaderboard-item ${player.uuid === playerUuid ? 'current-player' : ''}`}
            >
              <span>{index + 1}.</span>
              <span>{player.avatar}</span>
              <span style={{ flex: 1 }}>{player.username}</span>
              <span style={{ fontWeight: 'bold' }}>{player.score}</span>
            </div>
          ))}
      </div>
    </div>
  );
}
