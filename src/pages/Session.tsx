import React, { useState, useEffect, useRef, useCallback } from 'react';
import { useParams, useNavigate } from 'react-router';
import { X, Pause, Play, RotateCcw, Check, ChevronDown } from 'lucide-react';
import { useApp } from '../context/AppContext';
import { motion, AnimatePresence } from 'motion/react';
import { ACHIEVEMENTS } from '../data/achievements';
import type { UnlockedAchievement } from '../context/AppContext';

function formatTime(seconds: number): string {
  const m = Math.floor(seconds / 60);
  const s = seconds % 60;
  return `${String(m).padStart(2, '0')}:${String(s).padStart(2, '0')}`;
}

function CelebrationOverlay({
  newAchievements,
  totalReps,
  duration,
  onDone,
}: {
  newAchievements: UnlockedAchievement[];
  totalReps: number;
  duration: number;
  onDone: () => void;
}) {
  const achievementDefs = newAchievements
    .map((ua) => ACHIEVEMENTS.find((a) => a.id === ua.id))
    .filter(Boolean);

  return (
    <motion.div
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      exit={{ opacity: 0 }}
      className="fixed inset-0 z-50 flex flex-col items-center justify-center"
      style={{ background: 'linear-gradient(180deg, #1a0a3d 0%, #0d0b1a 100%)' }}
    >
      {/* Confetti-like particles */}
      {Array.from({ length: 20 }).map((_, i) => (
        <motion.div
          key={i}
          className="absolute w-2 h-2 rounded-full"
          style={{
            background: ['#7c3aed', '#f59e0b', '#ec4899', '#10b981', '#3b82f6'][i % 5],
            left: `${Math.random() * 100}%`,
            top: '-10px',
          }}
          animate={{
            y: ['0vh', '110vh'],
            rotate: [0, 360 * (Math.random() > 0.5 ? 1 : -1)],
            opacity: [1, 0.5, 0],
          }}
          transition={{
            duration: 2 + Math.random() * 2,
            delay: Math.random() * 1,
            ease: 'easeIn',
          }}
        />
      ))}

      <motion.div
        initial={{ scale: 0.5, opacity: 0 }}
        animate={{ scale: 1, opacity: 1 }}
        transition={{ type: 'spring', damping: 20, stiffness: 200, delay: 0.2 }}
        className="text-center px-8"
      >
        <div style={{ fontSize: '72px', lineHeight: 1 }}>🙏</div>

        <h2
          className="text-white mt-4"
          style={{ fontFamily: "'Cinzel', serif", fontSize: '28px', fontWeight: 700 }}
        >
          Session Complete
        </h2>

        <p className="text-violet-300 mt-2" style={{ fontSize: '16px' }}>
          {totalReps} repetitions · {formatTime(duration)}
        </p>

        {achievementDefs.length > 0 && (
          <motion.div
            initial={{ y: 20, opacity: 0 }}
            animate={{ y: 0, opacity: 1 }}
            transition={{ delay: 0.6 }}
            className="mt-6 space-y-3"
          >
            <p className="text-amber-400" style={{ fontSize: '14px', fontWeight: 600 }}>
              Achievement{achievementDefs.length > 1 ? 's' : ''} Unlocked!
            </p>
            {achievementDefs.map((ach) => (
              <div
                key={ach!.id}
                className="flex items-center gap-3 px-4 py-3 rounded-2xl"
                style={{
                  background: 'rgba(245,158,11,0.1)',
                  border: '1px solid rgba(245,158,11,0.3)',
                }}
              >
                <span style={{ fontSize: '28px' }}>{ach!.emoji}</span>
                <div className="text-left">
                  <p className="text-amber-300" style={{ fontSize: '15px', fontWeight: 600 }}>
                    {ach!.title}
                  </p>
                  <p className="text-amber-400/70" style={{ fontSize: '12px' }}>
                    {ach!.description}
                  </p>
                </div>
              </div>
            ))}
          </motion.div>
        )}

        <motion.button
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ delay: 1 }}
          onClick={onDone}
          className="mt-8 px-8 py-4 rounded-2xl text-white"
          style={{
            background: 'linear-gradient(135deg, #7c3aed, #6d28d9)',
            fontSize: '16px',
            fontWeight: 600,
          }}
        >
          Continue
        </motion.button>
      </motion.div>
    </motion.div>
  );
}

export function Session() {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const { getMantra, completeSession } = useApp();

  const mantra = getMantra(id!);

  const [count, setCount] = useState(0);
  const [isPaused, setIsPaused] = useState(false);
  const [isComplete, setIsComplete] = useState(false);
  const [duration, setDuration] = useState(0);
  const [showRipple, setShowRipple] = useState(false);
  const [ripplePos, setRipplePos] = useState({ x: 0, y: 0 });
  const [showConfirmExit, setShowConfirmExit] = useState(false);
  const [newAchievements, setNewAchievements] = useState<UnlockedAchievement[]>([]);
  const [showCelebration, setShowCelebration] = useState(false);
  const [tapCount, setTapCount] = useState(0);

  const startTime = useRef(new Date().toISOString());
  const intervalRef = useRef<ReturnType<typeof setInterval> | null>(null);

  const target = mantra?.targetRepetitions ?? 108;
  const progress = Math.min(count / target, 1);

  // Timer
  useEffect(() => {
    if (!isPaused && !isComplete) {
      intervalRef.current = setInterval(() => {
        setDuration((d) => d + 1);
      }, 1000);
    } else {
      if (intervalRef.current) clearInterval(intervalRef.current);
    }
    return () => {
      if (intervalRef.current) clearInterval(intervalRef.current);
    };
  }, [isPaused, isComplete]);

  const handleTap = useCallback(
    (e: React.MouseEvent | React.TouchEvent) => {
      if (isPaused || isComplete) return;

      // Get position for ripple
      const rect = (e.currentTarget as HTMLElement).getBoundingClientRect();
      let clientX: number, clientY: number;
      if ('touches' in e) {
        clientX = e.touches[0].clientX;
        clientY = e.touches[0].clientY;
      } else {
        clientX = (e as React.MouseEvent).clientX;
        clientY = (e as React.MouseEvent).clientY;
      }
      setRipplePos({ x: clientX - rect.left, y: clientY - rect.top });
      setShowRipple(true);
      setTimeout(() => setShowRipple(false), 600);

      // Haptic
      if (navigator.vibrate) navigator.vibrate(30);

      setCount((prev) => {
        const next = prev + 1;
        if (next >= target) {
          setIsComplete(true);
          // Trigger completion after a moment
          setTimeout(() => finishSession(next, true), 300);
        }
        return next;
      });

      setTapCount((t) => t + 1);
    },
    [isPaused, isComplete, target]
  );

  const finishSession = useCallback(
    (finalCount: number, completed: boolean) => {
      if (!mantra) return;
      const unlocked = completeSession({
        mantraId: mantra.id,
        mantraTitle: mantra.title,
        repsCompleted: finalCount,
        targetReps: target,
        duration,
        startTime: startTime.current,
        completed,
      });
      setNewAchievements(unlocked);
      setShowCelebration(true);
    },
    [mantra, completeSession, duration, target]
  );

  const handleManualComplete = () => {
    setIsComplete(true);
    finishSession(count, count >= target);
  };

  const handleReset = () => {
    setCount(0);
    setIsComplete(false);
    setDuration(0);
    startTime.current = new Date().toISOString();
  };

  const handleExit = () => {
    if (count > 0) {
      setShowConfirmExit(true);
    } else {
      navigate(-1);
    }
  };

  if (!mantra) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <p className="text-muted-foreground">Mantra not found.</p>
      </div>
    );
  }

  // Progress ring dimensions
  const ringSize = 220;
  const strokeWidth = 10;
  const radius = (ringSize - strokeWidth) / 2;
  const circumference = 2 * Math.PI * radius;
  const strokeDashoffset = circumference * (1 - progress);

  return (
    <div
      className="fixed inset-0 flex flex-col select-none"
      style={{
        background: 'linear-gradient(180deg, #0d0520 0%, #0d0b1a 50%, #0a0d20 100%)',
        userSelect: 'none',
        WebkitUserSelect: 'none',
      }}
    >
      {/* Top bar */}
      <div className="flex items-center justify-between px-5 pt-12 pb-4 z-10">
        <button
          onClick={handleExit}
          className="w-10 h-10 rounded-full flex items-center justify-center"
          style={{ background: 'rgba(255,255,255,0.08)' }}
        >
          <X size={18} className="text-white/80" />
        </button>

        <div className="text-center">
          <p className="text-white/50" style={{ fontSize: '12px' }}>
            {mantra.title}
          </p>
          <p className="text-white/30" style={{ fontSize: '11px' }}>
            {formatTime(duration)}
          </p>
        </div>

        <button
          onClick={() => setIsPaused(!isPaused)}
          className="w-10 h-10 rounded-full flex items-center justify-center"
          style={{ background: 'rgba(255,255,255,0.08)' }}
        >
          {isPaused ? (
            <Play size={16} className="text-white/80" fill="rgba(255,255,255,0.8)" />
          ) : (
            <Pause size={18} className="text-white/80" />
          )}
        </button>
      </div>

      {/* Mantra Text */}
      <div className="px-6 text-center z-10">
        <p
          className="text-white/90 leading-relaxed"
          style={{
            fontFamily: "'Noto Sans Devanagari', sans-serif",
            fontSize: '20px',
            textShadow: '0 0 20px rgba(139,92,246,0.4)',
          }}
        >
          {mantra.text.split('\n')[0]}
        </p>
        {mantra.translation && (
          <p className="text-white/40 mt-1" style={{ fontSize: '13px' }}>
            {mantra.translation}
          </p>
        )}
      </div>

      {/* Main tap area */}
      <div
        className="flex-1 flex items-center justify-center relative cursor-pointer"
        onMouseDown={handleTap}
        onTouchStart={handleTap}
        style={{ WebkitTapHighlightColor: 'transparent' }}
      >
        {/* Ripple */}
        <AnimatePresence>
          {showRipple && (
            <motion.div
              key={tapCount}
              initial={{ width: 0, height: 0, opacity: 0.6, borderRadius: '50%' }}
              animate={{ width: 300, height: 300, opacity: 0 }}
              exit={{ opacity: 0 }}
              transition={{ duration: 0.6, ease: 'easeOut' }}
              style={{
                position: 'absolute',
                left: ripplePos.x - 0,
                top: ripplePos.y - 0,
                transform: 'translate(-50%, -50%)',
                background: 'rgba(139,92,246,0.3)',
                borderRadius: '50%',
                pointerEvents: 'none',
                zIndex: 1,
              }}
            />
          )}
        </AnimatePresence>

        {/* Progress Ring + Counter */}
        <div className="relative flex items-center justify-center" style={{ zIndex: 2 }}>
          <svg width={ringSize} height={ringSize} style={{ transform: 'rotate(-90deg)' }}>
            {/* Background ring */}
            <circle
              cx={ringSize / 2}
              cy={ringSize / 2}
              r={radius}
              fill="none"
              stroke="rgba(139,92,246,0.12)"
              strokeWidth={strokeWidth}
            />
            {/* Progress ring */}
            <circle
              cx={ringSize / 2}
              cy={ringSize / 2}
              r={radius}
              fill="none"
              stroke="url(#progress-gradient)"
              strokeWidth={strokeWidth}
              strokeLinecap="round"
              strokeDasharray={circumference}
              strokeDashoffset={strokeDashoffset}
              style={{ transition: 'stroke-dashoffset 0.15s ease-out' }}
            />
            <defs>
              <linearGradient id="progress-gradient" x1="0%" y1="0%" x2="100%" y2="100%">
                <stop offset="0%" stopColor="#7c3aed" />
                <stop offset="100%" stopColor="#a78bfa" />
              </linearGradient>
            </defs>
          </svg>

          {/* Counter */}
          <div
            className="absolute inset-0 flex flex-col items-center justify-center"
            style={{ pointerEvents: 'none' }}
          >
            <motion.span
              key={count}
              initial={{ scale: 1.3, opacity: 0.7 }}
              animate={{ scale: 1, opacity: 1 }}
              transition={{ duration: 0.15 }}
              className="text-white"
              style={{
                fontSize: '72px',
                fontWeight: 800,
                fontFamily: "'Inter', sans-serif",
                lineHeight: 1,
                textShadow: '0 0 30px rgba(139,92,246,0.6)',
              }}
            >
              {count}
            </motion.span>
            <span className="text-white/40 mt-1" style={{ fontSize: '14px' }}>
              of {target}
            </span>
          </div>
        </div>

        {/* Pause overlay */}
        <AnimatePresence>
          {isPaused && (
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              className="absolute inset-0 flex items-center justify-center"
              style={{ background: 'rgba(13,11,26,0.7)', backdropFilter: 'blur(4px)', zIndex: 5 }}
            >
              <div className="text-center">
                <Pause size={48} className="text-white/60 mx-auto mb-3" />
                <p className="text-white/60" style={{ fontSize: '16px' }}>
                  Paused
                </p>
                <p className="text-white/40 mt-1" style={{ fontSize: '13px' }}>
                  Tap pause button to resume
                </p>
              </div>
            </motion.div>
          )}
        </AnimatePresence>
      </div>

      {/* Bottom controls */}
      <div className="px-8 pb-12 flex items-center justify-between z-10">
        <button
          onClick={handleReset}
          className="flex flex-col items-center gap-1.5"
        >
          <div
            className="w-12 h-12 rounded-full flex items-center justify-center"
            style={{ background: 'rgba(255,255,255,0.07)' }}
          >
            <RotateCcw size={18} className="text-white/60" />
          </div>
          <span className="text-white/40" style={{ fontSize: '11px' }}>Reset</span>
        </button>

        <div className="text-center">
          <p className="text-white/30" style={{ fontSize: '12px' }}>
            Tap anywhere to count
          </p>
          <div className="flex justify-center gap-1 mt-2">
            {Array.from({ length: Math.min(target, 20) }).map((_, i) => (
              <div
                key={i}
                className="w-1 h-1 rounded-full transition-all duration-200"
                style={{
                  background: i < Math.round((count / target) * Math.min(target, 20))
                    ? '#7c3aed'
                    : 'rgba(255,255,255,0.1)',
                }}
              />
            ))}
          </div>
        </div>

        <button
          onClick={handleManualComplete}
          className="flex flex-col items-center gap-1.5"
        >
          <div
            className="w-12 h-12 rounded-full flex items-center justify-center"
            style={{ background: 'rgba(139,92,246,0.2)', border: '1px solid rgba(139,92,246,0.3)' }}
          >
            <Check size={18} className="text-violet-400" />
          </div>
          <span className="text-white/40" style={{ fontSize: '11px' }}>Done</span>
        </button>
      </div>

      {/* Exit confirm */}
      <AnimatePresence>
        {showConfirmExit && (
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            className="fixed inset-0 z-50 flex items-end justify-center"
            style={{ background: 'rgba(0,0,0,0.7)', backdropFilter: 'blur(4px)' }}
          >
            <motion.div
              initial={{ y: 200 }}
              animate={{ y: 0 }}
              exit={{ y: 200 }}
              transition={{ type: 'spring', damping: 28, stiffness: 300 }}
              className="w-full max-w-[430px] rounded-t-3xl p-6 pb-10"
              style={{ background: '#0d0b1a', border: '1px solid rgba(139,92,246,0.2)' }}
            >
              <h3 className="text-white text-center mb-2" style={{ fontSize: '18px', fontWeight: 600 }}>
                Exit Session?
              </h3>
              <p className="text-white/50 text-center mb-6" style={{ fontSize: '14px' }}>
                You have {count} repetitions. Save as partial session?
              </p>
              <div className="space-y-3">
                <button
                  onClick={() => { setShowConfirmExit(false); finishSession(count, false); }}
                  className="w-full py-3.5 rounded-2xl text-white"
                  style={{ background: 'rgba(139,92,246,0.3)', border: '1px solid rgba(139,92,246,0.3)', fontSize: '15px' }}
                >
                  Save & Exit
                </button>
                <button
                  onClick={() => { setShowConfirmExit(false); navigate(-1); }}
                  className="w-full py-3.5 rounded-2xl text-red-400"
                  style={{ border: '1px solid rgba(239,68,68,0.2)', fontSize: '15px' }}
                >
                  Discard & Exit
                </button>
                <button
                  onClick={() => setShowConfirmExit(false)}
                  className="w-full py-3.5 rounded-2xl text-white/60"
                  style={{ fontSize: '15px' }}
                >
                  Continue Session
                </button>
              </div>
            </motion.div>
          </motion.div>
        )}
      </AnimatePresence>

      {/* Celebration */}
      <AnimatePresence>
        {showCelebration && (
          <CelebrationOverlay
            newAchievements={newAchievements}
            totalReps={count}
            duration={duration}
            onDone={() => navigate(-1)}
          />
        )}
      </AnimatePresence>
    </div>
  );
}
