import React, { useState } from 'react';
import { useNavigate } from 'react-router';
import { Flame, Trophy, Hash, Clock, Calendar, ChevronRight, Lock } from 'lucide-react';
import { useApp } from '../context/AppContext';
import { ACHIEVEMENTS, RARITY_LABELS, RARITY_COLORS } from '../data/achievements';
import { motion } from 'motion/react';

function StatCard({
  icon,
  label,
  value,
  color,
}: {
  icon: React.ReactNode;
  label: string;
  value: string | number;
  color: string;
}) {
  return (
    <div
      className="flex-1 rounded-2xl p-4"
      style={{
        background: 'rgba(139,92,246,0.06)',
        border: '1px solid rgba(139,92,246,0.15)',
      }}
    >
      <div className={`mb-2 ${color}`}>{icon}</div>
      <p className="text-foreground" style={{ fontSize: '22px', fontWeight: 700, lineHeight: 1.2 }}>
        {value}
      </p>
      <p className="text-muted-foreground mt-0.5" style={{ fontSize: '12px' }}>
        {label}
      </p>
    </div>
  );
}

function WeekCalendar({ sessions }: { sessions: ReturnType<typeof useApp>['sessions'] }) {
  const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  const today = new Date();

  // Build last 7 days
  const week = Array.from({ length: 7 }).map((_, i) => {
    const d = new Date(today);
    d.setDate(today.getDate() - (6 - i));
    return d;
  });

  const sessionDates = new Set(
    sessions.map((s) => s.startTime.split('T')[0])
  );

  return (
    <div
      className="rounded-2xl p-4"
      style={{ background: 'rgba(139,92,246,0.06)', border: '1px solid rgba(139,92,246,0.15)' }}
    >
      <p className="text-muted-foreground mb-3" style={{ fontSize: '13px' }}>
        Last 7 days
      </p>
      <div className="flex gap-1">
        {week.map((date, i) => {
          const dateKey = date.toISOString().split('T')[0];
          const hasSession = sessionDates.has(dateKey);
          const isToday = i === 6;

          return (
            <div key={i} className="flex-1 flex flex-col items-center gap-1.5">
              <span
                className="text-muted-foreground"
                style={{ fontSize: '10px' }}
              >
                {days[date.getDay()][0]}
              </span>
              <div
                className="w-8 h-8 rounded-full flex items-center justify-center transition-all"
                style={{
                  background: hasSession
                    ? 'linear-gradient(135deg, #7c3aed, #a78bfa)'
                    : isToday
                    ? 'rgba(139,92,246,0.15)'
                    : 'rgba(255,255,255,0.04)',
                  border: isToday
                    ? '1px solid rgba(139,92,246,0.4)'
                    : '1px solid transparent',
                }}
              >
                {hasSession ? (
                  <span style={{ fontSize: '14px' }}>✓</span>
                ) : (
                  <span
                    className="text-muted-foreground"
                    style={{ fontSize: '11px' }}
                  >
                    {date.getDate()}
                  </span>
                )}
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
}

function AchievementBadge({
  id,
  unlockedAt,
}: {
  id: string;
  unlockedAt?: string;
}) {
  const def = ACHIEVEMENTS.find((a) => a.id === id) ?? ACHIEVEMENTS[0];
  const isUnlocked = !!unlockedAt;

  return (
    <div
      className={`rounded-2xl p-3 flex items-center gap-3 ${
        isUnlocked ? '' : 'opacity-50'
      }`}
      style={{
        background: isUnlocked ? def.bgColor : 'rgba(255,255,255,0.03)',
        border: `1px solid ${isUnlocked ? 'rgba(139,92,246,0.25)' : 'rgba(255,255,255,0.06)'}`,
      }}
    >
      <div
        className="w-10 h-10 rounded-xl flex items-center justify-center shrink-0"
        style={{
          background: isUnlocked ? 'rgba(255,255,255,0.1)' : 'rgba(255,255,255,0.04)',
          filter: isUnlocked ? 'none' : 'grayscale(100%)',
        }}
      >
        {isUnlocked ? (
          <span style={{ fontSize: '22px' }}>{def.emoji}</span>
        ) : (
          <Lock size={16} className="text-muted-foreground" />
        )}
      </div>
      <div className="flex-1 min-w-0">
        <p
          className={isUnlocked ? def.color : 'text-muted-foreground'}
          style={{ fontSize: '13px', fontWeight: 600 }}
        >
          {def.title}
        </p>
        <p className="text-muted-foreground truncate" style={{ fontSize: '11px' }}>
          {isUnlocked
            ? `Unlocked ${new Date(unlockedAt!).toLocaleDateString('en-US', { month: 'short', day: 'numeric' })}`
            : def.description}
        </p>
      </div>
      <span
        className={`text-[10px] px-1.5 py-0.5 rounded-full ${RARITY_COLORS[def.rarity]}`}
        style={{ background: 'rgba(255,255,255,0.05)' }}
      >
        {RARITY_LABELS[def.rarity]}
      </span>
    </div>
  );
}

export function Progress() {
  const { progress, sessions } = useApp();
  const navigate = useNavigate();
  const [showAllAchievements, setShowAllAchievements] = useState(false);

  const unlockedIds = new Set(progress.unlockedAchievements.map((a) => a.id));

  // Next milestone for reps
  const repMilestones = [1000, 5000, 10000, 100000];
  const nextMilestone = repMilestones.find((m) => m > progress.totalRepetitions) ?? repMilestones[repMilestones.length - 1];
  const prevMilestone = repMilestones[repMilestones.indexOf(nextMilestone) - 1] ?? 0;
  const milestoneProgress =
    (progress.totalRepetitions - prevMilestone) / (nextMilestone - prevMilestone);

  const unlockedCount = progress.unlockedAchievements.length;
  const totalCount = ACHIEVEMENTS.length;

  const visibleAchievements = showAllAchievements ? ACHIEVEMENTS : ACHIEVEMENTS.slice(0, 4);

  return (
    <div className="flex flex-col min-h-full">
      {/* Header */}
      <div
        className="px-5 pt-12 pb-4"
        style={{
          background: 'linear-gradient(180deg, rgba(139,92,246,0.12) 0%, transparent 100%)',
        }}
      >
        <h1
          className="text-foreground"
          style={{
            fontFamily: "'Cinzel', serif",
            fontSize: '22px',
            fontWeight: 600,
          }}
        >
          Progress
        </h1>
        <p className="text-muted-foreground" style={{ fontSize: '13px' }}>
          Member since{' '}
          {new Date(progress.memberSince).toLocaleDateString('en-US', {
            month: 'long',
            year: 'numeric',
          })}
        </p>
      </div>

      <div className="flex-1 overflow-y-auto px-4 pb-6 space-y-4">
        {/* Streak Hero */}
        <motion.div
          initial={{ opacity: 0, y: 12 }}
          animate={{ opacity: 1, y: 0 }}
          className="rounded-3xl p-6 text-center"
          style={{
            background: 'linear-gradient(135deg, rgba(249,115,22,0.15), rgba(234,88,12,0.05))',
            border: '1px solid rgba(249,115,22,0.25)',
          }}
        >
          <div style={{ fontSize: '48px', lineHeight: 1 }}>🔥</div>
          <p
            className="text-orange-300 mt-2"
            style={{ fontSize: '56px', fontWeight: 800, lineHeight: 1 }}
          >
            {progress.currentStreak}
          </p>
          <p className="text-orange-400/80 mt-1" style={{ fontSize: '16px' }}>
            day{progress.currentStreak !== 1 ? 's' : ''} streak
          </p>
          {progress.longestStreak > progress.currentStreak && (
            <p className="text-orange-400/50 mt-1" style={{ fontSize: '12px' }}>
              Best: {progress.longestStreak} days
            </p>
          )}
        </motion.div>

        {/* Weekly Calendar */}
        <WeekCalendar sessions={sessions} />

        {/* Stats Grid */}
        <div className="flex gap-3">
          <StatCard
            icon={<Trophy size={18} />}
            label="Total Sessions"
            value={progress.totalSessions.toLocaleString()}
            color="text-violet-400"
          />
          <StatCard
            icon={<Hash size={18} />}
            label="Total Reps"
            value={progress.totalRepetitions.toLocaleString()}
            color="text-amber-400"
          />
        </div>

        <div className="flex gap-3">
          <StatCard
            icon={<Flame size={18} />}
            label="Longest Streak"
            value={`${progress.longestStreak}d`}
            color="text-orange-400"
          />
          <StatCard
            icon={<Calendar size={18} />}
            label="Last Session"
            value={
              progress.lastSessionDate
                ? new Date(progress.lastSessionDate).toLocaleDateString('en-US', {
                    month: 'short',
                    day: 'numeric',
                  })
                : '—'
            }
            color="text-blue-400"
          />
        </div>

        {/* Rep Milestone Progress */}
        <div
          className="rounded-2xl p-4"
          style={{ background: 'rgba(139,92,246,0.06)', border: '1px solid rgba(139,92,246,0.15)' }}
        >
          <div className="flex items-center justify-between mb-3">
            <p className="text-foreground" style={{ fontSize: '14px', fontWeight: 600 }}>
              Next Milestone
            </p>
            <p className="text-violet-400" style={{ fontSize: '13px' }}>
              {progress.totalRepetitions.toLocaleString()} / {nextMilestone.toLocaleString()}
            </p>
          </div>
          <div className="h-2 rounded-full overflow-hidden" style={{ background: 'rgba(139,92,246,0.15)' }}>
            <motion.div
              initial={{ width: 0 }}
              animate={{ width: `${milestoneProgress * 100}%` }}
              transition={{ duration: 0.8, ease: 'easeOut' }}
              className="h-full rounded-full"
              style={{ background: 'linear-gradient(90deg, #7c3aed, #a78bfa)' }}
            />
          </div>
          <p className="text-muted-foreground mt-2" style={{ fontSize: '12px' }}>
            {(nextMilestone - progress.totalRepetitions).toLocaleString()} reps to go
          </p>
        </div>

        {/* Achievements */}
        <div>
          <div className="flex items-center justify-between mb-3">
            <h3 className="text-foreground" style={{ fontSize: '15px', fontWeight: 600 }}>
              Achievements
            </h3>
            <span className="text-muted-foreground" style={{ fontSize: '13px' }}>
              {unlockedCount}/{totalCount}
            </span>
          </div>

          <div className="space-y-2">
            {/* Show unlocked first */}
            {visibleAchievements
              .sort((a, b) => {
                const aUnlocked = unlockedIds.has(a.id) ? -1 : 1;
                const bUnlocked = unlockedIds.has(b.id) ? -1 : 1;
                return aUnlocked - bUnlocked;
              })
              .map((ach) => {
                const unlocked = progress.unlockedAchievements.find(
                  (u) => u.id === ach.id
                );
                return (
                  <AchievementBadge
                    key={ach.id}
                    id={ach.id}
                    unlockedAt={unlocked?.unlockedAt}
                  />
                );
              })}
          </div>

          <button
            onClick={() => setShowAllAchievements(!showAllAchievements)}
            className="w-full mt-3 py-3 rounded-xl text-violet-400 flex items-center justify-center gap-2"
            style={{
              border: '1px solid rgba(139,92,246,0.2)',
              fontSize: '14px',
            }}
          >
            {showAllAchievements ? 'Show less' : `View all ${totalCount} achievements`}
            <ChevronRight
              size={16}
              className={`transition-transform ${showAllAchievements ? 'rotate-90' : ''}`}
            />
          </button>
        </div>

        {/* Session History */}
        {sessions.length > 0 && (
          <div>
            <h3 className="text-foreground mb-3" style={{ fontSize: '15px', fontWeight: 600 }}>
              Recent Sessions
            </h3>
            <div className="space-y-2">
              {sessions.slice(0, 8).map((session) => (
                <div
                  key={session.id}
                  className="flex items-center justify-between px-4 py-3 rounded-xl"
                  style={{
                    background: 'rgba(139,92,246,0.05)',
                    border: '1px solid rgba(139,92,246,0.1)',
                  }}
                >
                  <div>
                    <p className="text-foreground" style={{ fontSize: '13px', fontWeight: 500 }}>
                      {session.mantraTitle}
                    </p>
                    <p className="text-muted-foreground mt-0.5" style={{ fontSize: '12px' }}>
                      {new Date(session.startTime).toLocaleDateString('en-US', {
                        month: 'short',
                        day: 'numeric',
                        hour: '2-digit',
                        minute: '2-digit',
                      })}
                    </p>
                  </div>
                  <div className="text-right">
                    <p className="text-violet-400" style={{ fontSize: '14px', fontWeight: 600 }}>
                      {session.repsCompleted}×
                    </p>
                    <p className="text-muted-foreground" style={{ fontSize: '11px' }}>
                      <Clock size={10} className="inline mr-0.5" />
                      {Math.floor(session.duration / 60)}m
                    </p>
                  </div>
                </div>
              ))}
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
