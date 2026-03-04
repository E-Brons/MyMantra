import React, { useState } from 'react';
import { useParams, useNavigate } from 'react-router';
import {
  ArrowLeft,
  Play,
  Bell,
  BellOff,
  Plus,
  Trash2,
  Edit3,
  Clock,
  Hash,
  Calendar,
  MoreVertical,
  X,
  Check,
} from 'lucide-react';
import { useApp, Reminder } from '../context/AppContext';
import { motion, AnimatePresence } from 'motion/react';

const DAYS = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

function ReminderItem({
  reminder,
  mantraId,
}: {
  reminder: Reminder;
  mantraId: string;
}) {
  const { updateReminder, deleteReminder } = useApp();

  return (
    <div
      className="flex items-center gap-3 px-4 py-3 rounded-xl"
      style={{
        background: 'rgba(139,92,246,0.06)',
        border: '1px solid rgba(139,92,246,0.12)',
      }}
    >
      <Bell size={16} className="text-violet-400 shrink-0" />
      <div className="flex-1 min-w-0">
        <p className="text-foreground" style={{ fontSize: '14px', fontWeight: 500 }}>
          {reminder.time}
        </p>
        <p className="text-muted-foreground" style={{ fontSize: '12px' }}>
          {reminder.days.length === 7
            ? 'Every day'
            : reminder.days.map((d) => DAYS[d]).join(', ')}
        </p>
      </div>
      <div className="flex items-center gap-2">
        {/* Toggle */}
        <button
          onClick={() =>
            updateReminder(mantraId, reminder.id, { enabled: !reminder.enabled })
          }
          className={`w-10 h-6 rounded-full transition-all duration-200 relative ${
            reminder.enabled ? 'bg-violet-500' : 'bg-muted'
          }`}
        >
          <div
            className={`absolute top-1 w-4 h-4 rounded-full bg-white transition-all duration-200 ${
              reminder.enabled ? 'left-5' : 'left-1'
            }`}
          />
        </button>
        <button onClick={() => deleteReminder(mantraId, reminder.id)}>
          <Trash2 size={14} className="text-muted-foreground hover:text-red-400 transition-colors" />
        </button>
      </div>
    </div>
  );
}

function AddReminderModal({
  mantraId,
  onClose,
}: {
  mantraId: string;
  onClose: () => void;
}) {
  const { addReminder } = useApp();
  const [time, setTime] = useState('07:00');
  const [selectedDays, setSelectedDays] = useState<number[]>([0, 1, 2, 3, 4, 5, 6]);

  const toggleDay = (day: number) => {
    setSelectedDays((prev) =>
      prev.includes(day) ? prev.filter((d) => d !== day) : [...prev, day]
    );
  };

  const handleSave = () => {
    if (selectedDays.length === 0) return;
    addReminder(mantraId, { time, days: selectedDays.sort(), enabled: true });
    onClose();
  };

  return (
    <motion.div
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      exit={{ opacity: 0 }}
      className="fixed inset-0 z-50 flex items-end justify-center"
      style={{ background: 'rgba(0,0,0,0.7)', backdropFilter: 'blur(4px)' }}
      onClick={onClose}
    >
      <motion.div
        initial={{ y: 300 }}
        animate={{ y: 0 }}
        exit={{ y: 300 }}
        transition={{ type: 'spring', damping: 28, stiffness: 300 }}
        className="w-full max-w-[430px] rounded-t-3xl p-6 pb-8"
        style={{ background: 'var(--background, #0d0b1a)', border: '1px solid rgba(139,92,246,0.2)' }}
        onClick={(e) => e.stopPropagation()}
      >
        <div className="flex items-center justify-between mb-6">
          <h3 className="text-foreground" style={{ fontSize: '18px', fontWeight: 600 }}>
            Add Reminder
          </h3>
          <button onClick={onClose}>
            <X size={20} className="text-muted-foreground" />
          </button>
        </div>

        <div className="space-y-5">
          <div>
            <label className="text-muted-foreground block mb-2" style={{ fontSize: '13px' }}>
              Time
            </label>
            <input
              type="time"
              value={time}
              onChange={(e) => setTime(e.target.value)}
              className="w-full px-4 py-3 rounded-xl text-foreground bg-transparent outline-none"
              style={{
                border: '1px solid rgba(139,92,246,0.3)',
                background: 'rgba(139,92,246,0.08)',
                fontSize: '18px',
                fontWeight: 600,
              }}
            />
          </div>

          <div>
            <label className="text-muted-foreground block mb-2" style={{ fontSize: '13px' }}>
              Repeat on
            </label>
            <div className="flex gap-2">
              {DAYS.map((day, i) => (
                <button
                  key={day}
                  onClick={() => toggleDay(i)}
                  className={`flex-1 py-2 rounded-xl transition-all duration-200 ${
                    selectedDays.includes(i)
                      ? 'text-white bg-violet-600'
                      : 'text-muted-foreground'
                  }`}
                  style={{
                    fontSize: '11px',
                    border: '1px solid rgba(139,92,246,0.2)',
                    background: selectedDays.includes(i)
                      ? undefined
                      : 'rgba(139,92,246,0.04)',
                  }}
                >
                  {day[0]}
                </button>
              ))}
            </div>
          </div>
        </div>

        <button
          onClick={handleSave}
          disabled={selectedDays.length === 0}
          className="mt-6 w-full py-3.5 rounded-2xl text-white transition-all duration-200 disabled:opacity-50"
          style={{ background: 'linear-gradient(135deg, #7c3aed, #6d28d9)', fontSize: '15px', fontWeight: 600 }}
        >
          Save Reminder
        </button>
      </motion.div>
    </motion.div>
  );
}

function DeleteConfirmModal({
  mantraTitle,
  onConfirm,
  onCancel,
}: {
  mantraTitle: string;
  onConfirm: () => void;
  onCancel: () => void;
}) {
  return (
    <motion.div
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      exit={{ opacity: 0 }}
      className="fixed inset-0 z-50 flex items-center justify-center p-6"
      style={{ background: 'rgba(0,0,0,0.7)', backdropFilter: 'blur(4px)' }}
    >
      <motion.div
        initial={{ scale: 0.9, opacity: 0 }}
        animate={{ scale: 1, opacity: 1 }}
        exit={{ scale: 0.9, opacity: 0 }}
        className="w-full max-w-sm rounded-3xl p-6"
        style={{ background: 'var(--background, #0d0b1a)', border: '1px solid rgba(239,68,68,0.3)' }}
      >
        <div className="text-center mb-6">
          <div className="text-4xl mb-3">⚠️</div>
          <h3 className="text-foreground mb-2" style={{ fontSize: '18px', fontWeight: 600 }}>
            Delete Mantra
          </h3>
          <p className="text-muted-foreground" style={{ fontSize: '14px' }}>
            Are you sure you want to delete "{mantraTitle}"? This action cannot be undone.
          </p>
        </div>
        <div className="flex gap-3">
          <button
            onClick={onCancel}
            className="flex-1 py-3 rounded-xl text-foreground"
            style={{ border: '1px solid rgba(139,92,246,0.2)', fontSize: '14px' }}
          >
            Cancel
          </button>
          <button
            onClick={onConfirm}
            className="flex-1 py-3 rounded-xl text-white"
            style={{ background: '#dc2626', fontSize: '14px' }}
          >
            Delete
          </button>
        </div>
      </motion.div>
    </motion.div>
  );
}

function formatDuration(seconds: number): string {
  const m = Math.floor(seconds / 60);
  const s = seconds % 60;
  return `${m}m ${s}s`;
}

export function MantraDetail() {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const { getMantra, deleteMantra, getRecentSessions } = useApp();

  const [showAddReminder, setShowAddReminder] = useState(false);
  const [showDelete, setShowDelete] = useState(false);
  const [showMenu, setShowMenu] = useState(false);
  const [activeLanguage, setActiveLanguage] = useState(0);

  const mantra = getMantra(id!);
  const recentSessions = getRecentSessions(id!, 5);

  if (!mantra) {
    return (
      <div className="flex flex-col items-center justify-center min-h-screen text-center px-8">
        <p className="text-muted-foreground mb-4">Mantra not found.</p>
        <button onClick={() => navigate('/')} className="text-violet-400">
          Go home
        </button>
      </div>
    );
  }

  const handleDelete = () => {
    deleteMantra(mantra.id);
    navigate('/');
  };

  // Build language tabs for display
  const languages = [
    { label: 'Original', text: mantra.text },
    ...(mantra.transliteration ? [{ label: 'IAST', text: mantra.transliteration }] : []),
    ...(mantra.translation ? [{ label: 'English', text: mantra.translation }] : []),
  ];

  return (
    <div className="flex flex-col min-h-full">
      {/* Header */}
      <div
        className="px-4 pt-12 pb-4 flex items-center justify-between"
        style={{ borderBottom: '1px solid rgba(139,92,246,0.1)' }}
      >
        <button
          onClick={() => navigate(-1)}
          className="w-10 h-10 rounded-full flex items-center justify-center"
          style={{ background: 'rgba(139,92,246,0.1)' }}
        >
          <ArrowLeft size={18} className="text-foreground" />
        </button>

        <h2 className="text-foreground flex-1 mx-4 truncate text-center" style={{ fontSize: '16px', fontWeight: 600 }}>
          {mantra.title}
        </h2>

        <div className="relative">
          <button
            onClick={() => setShowMenu(!showMenu)}
            className="w-10 h-10 rounded-full flex items-center justify-center"
            style={{ background: 'rgba(139,92,246,0.1)' }}
          >
            <MoreVertical size={18} className="text-foreground" />
          </button>

          <AnimatePresence>
            {showMenu && (
              <motion.div
                initial={{ opacity: 0, scale: 0.9, y: -8 }}
                animate={{ opacity: 1, scale: 1, y: 0 }}
                exit={{ opacity: 0, scale: 0.9, y: -8 }}
                className="absolute right-0 top-12 rounded-2xl overflow-hidden z-20 min-w-[140px]"
                style={{ background: '#1a1535', border: '1px solid rgba(139,92,246,0.2)' }}
              >
                <button
                  onClick={() => { setShowMenu(false); navigate(`/mantras/${mantra.id}/edit`); }}
                  className="flex items-center gap-3 w-full px-4 py-3 text-left hover:bg-violet-500/10 transition-colors"
                >
                  <Edit3 size={14} className="text-violet-400" />
                  <span className="text-foreground" style={{ fontSize: '14px' }}>Edit</span>
                </button>
                <button
                  onClick={() => { setShowMenu(false); setShowDelete(true); }}
                  className="flex items-center gap-3 w-full px-4 py-3 text-left hover:bg-red-500/10 transition-colors"
                >
                  <Trash2 size={14} className="text-red-400" />
                  <span className="text-red-400" style={{ fontSize: '14px' }}>Delete</span>
                </button>
              </motion.div>
            )}
          </AnimatePresence>
        </div>
      </div>

      <div className="flex-1 overflow-y-auto">
        {/* Mantra Text Display */}
        <div
          className="mx-4 mt-5 rounded-3xl p-6"
          style={{
            background: 'linear-gradient(135deg, rgba(139,92,246,0.12), rgba(30,27,75,0.5))',
            border: '1px solid rgba(139,92,246,0.2)',
          }}
        >
          {/* Language Tabs */}
          {languages.length > 1 && (
            <div className="flex gap-2 mb-4 flex-wrap">
              {languages.map((lang, i) => (
                <button
                  key={i}
                  onClick={() => setActiveLanguage(i)}
                  className={`px-3 py-1.5 rounded-full transition-all ${
                    activeLanguage === i
                      ? 'text-white bg-violet-600'
                      : 'text-muted-foreground'
                  }`}
                  style={{
                    fontSize: '12px',
                    border: '1px solid rgba(139,92,246,0.2)',
                    background: activeLanguage === i ? undefined : 'rgba(139,92,246,0.06)',
                  }}
                >
                  {lang.label}
                </button>
              ))}
            </div>
          )}

          <p
            className="text-foreground leading-relaxed"
            style={{
              fontFamily:
                activeLanguage === 0
                  ? "'Noto Sans Devanagari', sans-serif"
                  : "'Inter', sans-serif",
              fontSize: activeLanguage === 0 ? '22px' : '16px',
              whiteSpace: 'pre-line',
            }}
          >
            {languages[activeLanguage]?.text}
          </p>

          <div className="mt-4 flex items-center gap-4 flex-wrap">
            <span className="flex items-center gap-1.5 text-muted-foreground" style={{ fontSize: '13px' }}>
              <Hash size={13} className="text-violet-400" />
              {mantra.targetRepetitions} repetitions
            </span>
            {mantra.tradition && (
              <span
                className="px-2.5 py-1 rounded-full text-violet-300"
                style={{ fontSize: '11px', background: 'rgba(139,92,246,0.15)' }}
              >
                {mantra.tradition}
              </span>
            )}
          </div>
        </div>

        {/* Start Session Button */}
        <div className="px-4 mt-4">
          <motion.button
            whileTap={{ scale: 0.97 }}
            onClick={() => navigate(`/mantras/${mantra.id}/session`)}
            className="w-full py-4 rounded-2xl flex items-center justify-center gap-3 text-white"
            style={{
              background: 'linear-gradient(135deg, #7c3aed, #6d28d9)',
              boxShadow: '0 4px 20px rgba(124,58,237,0.35)',
              fontSize: '16px',
              fontWeight: 600,
            }}
          >
            <Play size={20} fill="white" />
            Start Session
          </motion.button>
        </div>

        {/* Reminders */}
        <div className="px-4 mt-6">
          <div className="flex items-center justify-between mb-3">
            <h3 className="text-foreground" style={{ fontSize: '15px', fontWeight: 600 }}>
              Reminders
            </h3>
            <button
              onClick={() => setShowAddReminder(true)}
              className="flex items-center gap-1.5 text-violet-400"
              style={{ fontSize: '13px' }}
            >
              <Plus size={15} />
              Add
            </button>
          </div>

          {mantra.reminders.length === 0 ? (
            <button
              onClick={() => setShowAddReminder(true)}
              className="w-full py-4 rounded-xl flex items-center gap-3 text-muted-foreground"
              style={{
                border: '1px dashed rgba(139,92,246,0.2)',
                background: 'rgba(139,92,246,0.03)',
              }}
            >
              <BellOff size={16} className="ml-4 text-violet-400/50" />
              <span style={{ fontSize: '14px' }}>No reminders yet — tap to add</span>
            </button>
          ) : (
            <div className="space-y-2">
              {mantra.reminders.map((r) => (
                <ReminderItem key={r.id} reminder={r} mantraId={mantra.id} />
              ))}
            </div>
          )}
        </div>

        {/* Recent Sessions */}
        <div className="px-4 mt-6 mb-6">
          <h3 className="text-foreground mb-3" style={{ fontSize: '15px', fontWeight: 600 }}>
            Recent Sessions
          </h3>

          {recentSessions.length === 0 ? (
            <div
              className="py-6 rounded-xl text-center text-muted-foreground"
              style={{ border: '1px solid rgba(139,92,246,0.1)', fontSize: '14px' }}
            >
              No sessions yet. Start practicing!
            </div>
          ) : (
            <div className="space-y-2">
              {recentSessions.map((session) => (
                <div
                  key={session.id}
                  className="flex items-center justify-between px-4 py-3 rounded-xl"
                  style={{ background: 'rgba(139,92,246,0.05)', border: '1px solid rgba(139,92,246,0.1)' }}
                >
                  <div>
                    <div className="flex items-center gap-2">
                      <Calendar size={12} className="text-violet-400" />
                      <span className="text-foreground" style={{ fontSize: '13px' }}>
                        {new Date(session.startTime).toLocaleDateString('en-US', {
                          month: 'short',
                          day: 'numeric',
                        })}
                      </span>
                    </div>
                    <div className="flex items-center gap-3 mt-1">
                      <span className="text-muted-foreground" style={{ fontSize: '12px' }}>
                        {session.repsCompleted}/{session.targetReps} reps
                      </span>
                      <span className="text-muted-foreground" style={{ fontSize: '12px' }}>
                        <Clock size={11} className="inline mr-1" />
                        {formatDuration(session.duration)}
                      </span>
                    </div>
                  </div>
                  <div>
                    {session.completed ? (
                      <Check size={16} className="text-emerald-400" />
                    ) : (
                      <span className="text-muted-foreground" style={{ fontSize: '11px' }}>
                        partial
                      </span>
                    )}
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      </div>

      {/* Modals */}
      <AnimatePresence>
        {showAddReminder && (
          <AddReminderModal
            mantraId={mantra.id}
            onClose={() => setShowAddReminder(false)}
          />
        )}
        {showDelete && (
          <DeleteConfirmModal
            mantraTitle={mantra.title}
            onConfirm={handleDelete}
            onCancel={() => setShowDelete(false)}
          />
        )}
      </AnimatePresence>
    </div>
  );
}
