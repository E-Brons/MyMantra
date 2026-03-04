import React, { useState, useMemo } from 'react';
import { useNavigate } from 'react-router';
import { Plus, Search, Bell, Flame, X, BookOpen } from 'lucide-react';
import { useApp } from '../context/AppContext';
import { motion } from 'motion/react';

function MantraCard({
  mantra,
  onClick,
}: {
  mantra: ReturnType<typeof useApp>['mantras'][0];
  onClick: () => void;
}) {
  const { sessions } = useApp();
  const lastSession = sessions.find((s) => s.mantraId === mantra.id);

  return (
    <motion.div
      initial={{ opacity: 0, y: 16 }}
      animate={{ opacity: 1, y: 0 }}
      whileTap={{ scale: 0.97 }}
      onClick={onClick}
      className="relative rounded-2xl p-4 cursor-pointer overflow-hidden"
      style={{
        background: 'linear-gradient(135deg, rgba(139,92,246,0.08) 0%, rgba(30,27,75,0.4) 100%)',
        border: '1px solid rgba(139,92,246,0.2)',
        backdropFilter: 'blur(8px)',
      }}
    >
      <div className="flex items-start justify-between gap-3">
        <div className="flex-1 min-w-0">
          <h3 className="text-foreground truncate pr-2" style={{ fontSize: '15px', fontWeight: 600 }}>
            {mantra.title}
          </h3>
          <p
            className="mt-1 text-muted-foreground truncate"
            style={{
              fontSize: '16px',
              fontFamily: "'Noto Sans Devanagari', sans-serif",
              lineHeight: '1.4',
            }}
          >
            {mantra.text.split('\n')[0]}
          </p>
          {mantra.translation && (
            <p className="mt-1 text-muted-foreground truncate" style={{ fontSize: '12px' }}>
              {mantra.translation}
            </p>
          )}
        </div>

        <div className="flex flex-col items-end gap-2 shrink-0">
          <span
            className="px-2.5 py-1 rounded-full text-violet-300"
            style={{ fontSize: '11px', background: 'rgba(139,92,246,0.2)' }}
          >
            {mantra.targetRepetitions}×
          </span>
        </div>
      </div>

      <div className="mt-3 flex items-center gap-3">
        {mantra.reminders.length > 0 && (
          <span className="flex items-center gap-1 text-muted-foreground" style={{ fontSize: '12px' }}>
            <Bell size={12} />
            {mantra.reminders.length} reminder{mantra.reminders.length !== 1 ? 's' : ''}
          </span>
        )}
        {lastSession && (
          <span className="text-muted-foreground" style={{ fontSize: '12px' }}>
            Last: {new Date(lastSession.startTime).toLocaleDateString()}
          </span>
        )}
        {mantra.tradition && (
          <span
            className="px-2 py-0.5 rounded-full text-violet-400"
            style={{ fontSize: '11px', background: 'rgba(139,92,246,0.1)' }}
          >
            {mantra.tradition}
          </span>
        )}
      </div>
    </motion.div>
  );
}

export function Home() {
  const navigate = useNavigate();
  const { mantras, progress } = useApp();
  const [searchQuery, setSearchQuery] = useState('');

  const filtered = useMemo(() => {
    if (!searchQuery.trim()) return mantras;
    const q = searchQuery.toLowerCase();
    return mantras.filter(
      (m) =>
        m.title.toLowerCase().includes(q) ||
        m.text.toLowerCase().includes(q) ||
        m.translation?.toLowerCase().includes(q)
    );
  }, [mantras, searchQuery]);

  return (
    <div className="flex flex-col min-h-full">
      {/* Header */}
      <div
        className="px-5 pt-12 pb-4"
        style={{
          background:
            'linear-gradient(180deg, rgba(139,92,246,0.12) 0%, transparent 100%)',
        }}
      >
        <div className="flex items-center justify-between mb-4">
          <div>
            <h1
              className="text-foreground"
              style={{
                fontFamily: "'Cinzel', serif",
                fontSize: '24px',
                fontWeight: 600,
                letterSpacing: '0.02em',
              }}
            >
              MyMantra
            </h1>
            <p className="text-muted-foreground" style={{ fontSize: '13px' }}>
              Your daily practice
            </p>
          </div>

          {/* Streak badge */}
          {progress.currentStreak > 0 && (
            <motion.div
              initial={{ scale: 0 }}
              animate={{ scale: 1 }}
              className="flex items-center gap-1.5 px-3 py-2 rounded-2xl"
              style={{
                background: 'linear-gradient(135deg, rgba(249,115,22,0.2), rgba(234,88,12,0.1))',
                border: '1px solid rgba(249,115,22,0.3)',
              }}
            >
              <Flame size={16} className="text-orange-400" />
              <span className="text-orange-300" style={{ fontSize: '14px', fontWeight: 700 }}>
                {progress.currentStreak}
              </span>
              <span className="text-orange-400/70" style={{ fontSize: '11px' }}>
                day{progress.currentStreak !== 1 ? 's' : ''}
              </span>
            </motion.div>
          )}
        </div>

        {/* Search */}
        <div
          className="flex items-center gap-3 px-4 py-3 rounded-2xl"
          style={{
            background: 'rgba(139,92,246,0.08)',
            border: '1px solid rgba(139,92,246,0.15)',
          }}
        >
          <Search size={16} className="text-muted-foreground shrink-0" />
          <input
            type="text"
            placeholder="Search mantras..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="flex-1 bg-transparent text-foreground placeholder-muted-foreground outline-none"
            style={{ fontSize: '14px' }}
          />
          {searchQuery && (
            <button onClick={() => setSearchQuery('')}>
              <X size={14} className="text-muted-foreground" />
            </button>
          )}
        </div>
      </div>

      {/* Mantra List */}
      <div className="flex-1 px-4 pb-4">
        {filtered.length === 0 ? (
          <div className="flex flex-col items-center justify-center py-16 text-center">
            {searchQuery ? (
              <>
                <p className="text-muted-foreground" style={{ fontSize: '15px' }}>
                  No mantras found for "{searchQuery}"
                </p>
                <button
                  onClick={() => setSearchQuery('')}
                  className="mt-3 text-violet-400 underline"
                  style={{ fontSize: '13px' }}
                >
                  Clear search
                </button>
              </>
            ) : (
              <>
                <div
                  className="w-16 h-16 rounded-full flex items-center justify-center mb-4"
                  style={{ background: 'rgba(139,92,246,0.1)', border: '1px solid rgba(139,92,246,0.2)' }}
                >
                  <span style={{ fontSize: '28px' }}>🙏</span>
                </div>
                <h3 className="text-foreground mb-2" style={{ fontSize: '18px', fontWeight: 600 }}>
                  Start your journey
                </h3>
                <p className="text-muted-foreground mb-6" style={{ fontSize: '14px' }}>
                  Create your first mantra or explore the library
                </p>
                <div className="flex gap-3">
                  <button
                    onClick={() => navigate('/mantras/new')}
                    className="flex items-center gap-2 px-4 py-2.5 rounded-xl text-white"
                    style={{ background: 'linear-gradient(135deg, #7c3aed, #6d28d9)' }}
                  >
                    <Plus size={16} />
                    <span style={{ fontSize: '14px' }}>Create</span>
                  </button>
                  <button
                    onClick={() => navigate('/library')}
                    className="flex items-center gap-2 px-4 py-2.5 rounded-xl text-violet-300"
                    style={{ background: 'rgba(139,92,246,0.1)', border: '1px solid rgba(139,92,246,0.2)' }}
                  >
                    <BookOpen size={16} />
                    <span style={{ fontSize: '14px' }}>Library</span>
                  </button>
                </div>
              </>
            )}
          </div>
        ) : (
          <div className="space-y-3">
            {filtered.map((mantra) => (
              <MantraCard
                key={mantra.id}
                mantra={mantra}
                onClick={() => navigate(`/mantras/${mantra.id}`)}
              />
            ))}
          </div>
        )}
      </div>

      {/* FAB */}
      <button
        onClick={() => navigate('/mantras/new')}
        className="fixed bottom-24 right-4 w-14 h-14 rounded-full flex items-center justify-center shadow-lg z-40 transition-transform active:scale-95"
        style={{
          background: 'linear-gradient(135deg, #7c3aed, #6d28d9)',
          boxShadow: '0 4px 20px rgba(124,58,237,0.4)',
        }}
        aria-label="Create new mantra"
      >
        <Plus size={24} className="text-white" strokeWidth={2.5} />
      </button>
    </div>
  );
}