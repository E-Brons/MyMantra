import React, {
  createContext,
  useContext,
  useState,
  useEffect,
  useCallback,
  ReactNode,
} from 'react';
import { ACHIEVEMENTS } from '../data/achievements';

// ─── Types ───────────────────────────────────────────────────────────────────

export interface Reminder {
  id: string;
  time: string; // "HH:MM"
  days: number[]; // 0-6 (Sun–Sat)
  enabled: boolean;
}

export interface Mantra {
  id: string;
  title: string;
  text: string;
  transliteration?: string;
  translation?: string;
  targetRepetitions: number;
  isCustom: boolean;
  tradition?: string;
  reminders: Reminder[];
  createdAt: string;
  updatedAt: string;
}

export interface Session {
  id: string;
  mantraId: string;
  mantraTitle: string;
  repsCompleted: number;
  targetReps: number;
  duration: number; // seconds
  startTime: string;
  completed: boolean;
}

export interface UnlockedAchievement {
  id: string;
  unlockedAt: string;
}

export interface Progress {
  currentStreak: number;
  longestStreak: number;
  totalSessions: number;
  totalRepetitions: number;
  lastSessionDate: string | null;
  unlockedAchievements: UnlockedAchievement[];
  memberSince: string;
}

export interface Settings {
  theme: 'light' | 'dark' | 'system';
  notificationsEnabled: boolean;
  vibrationEnabled: boolean;
  defaultRepetitions: number;
  fontSize: 'small' | 'medium' | 'large';
}

interface AppState {
  mantras: Mantra[];
  sessions: Session[];
  progress: Progress;
  settings: Settings;
}

interface AppContextValue extends AppState {
  // Mantra actions
  createMantra: (data: Omit<Mantra, 'id' | 'createdAt' | 'updatedAt'>) => Mantra;
  updateMantra: (id: string, data: Partial<Mantra>) => void;
  deleteMantra: (id: string) => void;
  getMantra: (id: string) => Mantra | undefined;

  // Session actions
  completeSession: (session: Omit<Session, 'id'>) => UnlockedAchievement[];

  // Settings actions
  updateSettings: (data: Partial<Settings>) => void;

  // Reminder actions
  addReminder: (mantraId: string, reminder: Omit<Reminder, 'id'>) => void;
  updateReminder: (mantraId: string, reminderId: string, data: Partial<Reminder>) => void;
  deleteReminder: (mantraId: string, reminderId: string) => void;

  // Utilities
  getRecentSessions: (mantraId?: string, limit?: number) => Session[];
  effectiveTheme: 'light' | 'dark';
}

// ─── Defaults ────────────────────────────────────────────────────────────────

const DEFAULT_PROGRESS: Progress = {
  currentStreak: 0,
  longestStreak: 0,
  totalSessions: 0,
  totalRepetitions: 0,
  lastSessionDate: null,
  unlockedAchievements: [],
  memberSince: new Date().toISOString(),
};

const DEFAULT_SETTINGS: Settings = {
  theme: 'dark',
  notificationsEnabled: true,
  vibrationEnabled: true,
  defaultRepetitions: 108,
  fontSize: 'medium',
};

const SEED_MANTRAS: Mantra[] = [
  {
    id: 'seed-1',
    title: 'Om Mani Padme Hum',
    text: 'ॐ मणिपद्मे हूँ',
    transliteration: 'oṃ maṇipadme hūṃ',
    translation: 'Praise to the Jewel in the Lotus',
    targetRepetitions: 108,
    isCustom: false,
    tradition: 'Tibetan Buddhism',
    reminders: [],
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
  },
  {
    id: 'seed-2',
    title: 'Abhyāsa-Vairāgya (Yoga Sutra I.12)',
    text: 'अभ्यासवैराग्याभ्यां तन्निरोधः॥',
    transliteration: 'abhyāsa-vairāgya-ābhyāṃ tat-nirodhaḥ',
    translation: 'Through steady practice and dispassion, the mind is stilled.',
    targetRepetitions: 108,
    isCustom: false,
    tradition: 'Classical Yoga',
    reminders: [],
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
  },
];

// ─── Utilities ────────────────────────────────────────────────────────────────

function generateId(): string {
  return `${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
}

function todayDateStr(): string {
  return new Date().toISOString().split('T')[0];
}

function calculateStreak(
  sessions: Session[],
  lastSessionDate: string | null,
  currentStreak: number
): { currentStreak: number; longestStreak: number; lastSessionDate: string } {
  const today = todayDateStr();
  const yesterday = new Date();
  yesterday.setDate(yesterday.getDate() - 1);
  const yesterdayStr = yesterday.toISOString().split('T')[0];

  let newStreak = currentStreak;

  if (!lastSessionDate) {
    newStreak = 1;
  } else if (lastSessionDate === today) {
    // Already practiced today, streak unchanged
    newStreak = currentStreak;
  } else if (lastSessionDate === yesterdayStr) {
    // Practiced yesterday → increment
    newStreak = currentStreak + 1;
  } else {
    // Gap — reset
    newStreak = 1;
  }

  return { currentStreak: newStreak, longestStreak: newStreak, lastSessionDate: today };
}

function checkNewAchievements(
  progress: Progress,
  newSession: Session,
  updatedStreak: number,
  updatedTotalSessions: number,
  updatedTotalReps: number
): UnlockedAchievement[] {
  const alreadyUnlocked = new Set(progress.unlockedAchievements.map((a) => a.id));
  const newlyUnlocked: UnlockedAchievement[] = [];

  for (const ach of ACHIEVEMENTS) {
    if (alreadyUnlocked.has(ach.id)) continue;

    let unlock = false;
    const { metric, value, before } = ach.condition;
    const sessionHour = new Date(newSession.startTime).getHours();

    if (metric === 'sessions') unlock = updatedTotalSessions >= value;
    else if (metric === 'streak') unlock = updatedStreak >= value;
    else if (metric === 'totalReps') unlock = updatedTotalReps >= value;
    else if (metric === 'hour') {
      unlock = before ? sessionHour < value : sessionHour >= value;
    }

    if (unlock) {
      newlyUnlocked.push({ id: ach.id, unlockedAt: new Date().toISOString() });
    }
  }

  return newlyUnlocked;
}

// ─── Context ─────────────────────────────────────────────────────────────────

const AppContext = createContext<AppContextValue | null>(null);

function loadState(): AppState {
  try {
    const raw = localStorage.getItem('mymantra_state');
    if (raw) {
      const parsed = JSON.parse(raw) as AppState;
      // Migration: ensure arrays exist
      if (!parsed.mantras) parsed.mantras = SEED_MANTRAS;
      if (!parsed.sessions) parsed.sessions = [];
      if (!parsed.progress) parsed.progress = DEFAULT_PROGRESS;
      if (!parsed.settings) parsed.settings = DEFAULT_SETTINGS;
      return parsed;
    }
  } catch {
    // ignore
  }
  return {
    mantras: SEED_MANTRAS,
    sessions: [],
    progress: { ...DEFAULT_PROGRESS, memberSince: new Date().toISOString() },
    settings: { ...DEFAULT_SETTINGS },
  };
}

// Apply theme immediately on load (before React mounts) to prevent flash
const _initialState = loadState();
const _initialTheme =
  _initialState.settings.theme === 'system'
    ? window.matchMedia('(prefers-color-scheme: dark)').matches
      ? 'dark'
      : 'light'
    : _initialState.settings.theme;
document.documentElement.classList.toggle('dark', _initialTheme === 'dark');

function saveState(state: AppState) {
  try {
    localStorage.setItem('mymantra_state', JSON.stringify(state));
  } catch {
    // ignore
  }
}

export function AppProvider({ children }: { children: ReactNode }) {
  const [state, setState] = useState<AppState>(loadState);

  // Persist to localStorage on every change
  useEffect(() => {
    saveState(state);
  }, [state]);

  // Theme application
  const effectiveTheme: 'light' | 'dark' =
    state.settings.theme === 'system'
      ? window.matchMedia('(prefers-color-scheme: dark)').matches
        ? 'dark'
        : 'light'
      : state.settings.theme;

  useEffect(() => {
    document.documentElement.classList.toggle('dark', effectiveTheme === 'dark');
  }, [effectiveTheme]);

  // ── Mantra actions ──────────────────────────────────────────────────────────

  const createMantra = useCallback(
    (data: Omit<Mantra, 'id' | 'createdAt' | 'updatedAt'>): Mantra => {
      const newMantra: Mantra = {
        ...data,
        id: generateId(),
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString(),
      };
      setState((prev) => ({
        ...prev,
        mantras: [newMantra, ...prev.mantras],
      }));
      return newMantra;
    },
    []
  );

  const updateMantra = useCallback((id: string, data: Partial<Mantra>) => {
    setState((prev) => ({
      ...prev,
      mantras: prev.mantras.map((m) =>
        m.id === id ? { ...m, ...data, updatedAt: new Date().toISOString() } : m
      ),
    }));
  }, []);

  const deleteMantra = useCallback((id: string) => {
    setState((prev) => ({
      ...prev,
      mantras: prev.mantras.filter((m) => m.id !== id),
    }));
  }, []);

  const getMantra = useCallback(
    (id: string) => state.mantras.find((m) => m.id === id),
    [state.mantras]
  );

  // ── Session actions ─────────────────────────────────────────────────────────

  const completeSession = useCallback(
    (sessionData: Omit<Session, 'id'>): UnlockedAchievement[] => {
      const session: Session = { ...sessionData, id: generateId() };

      setState((prev) => {
        const newTotalSessions = prev.progress.totalSessions + 1;
        const newTotalReps = prev.progress.totalRepetitions + session.repsCompleted;

        const streakResult = calculateStreak(
          prev.sessions,
          prev.progress.lastSessionDate,
          prev.progress.currentStreak
        );

        const newStreak = streakResult.currentStreak;
        const newLongest = Math.max(prev.progress.longestStreak, newStreak);

        const newAchievements = checkNewAchievements(
          prev.progress,
          session,
          newStreak,
          newTotalSessions,
          newTotalReps
        );

        return {
          ...prev,
          sessions: [session, ...prev.sessions],
          progress: {
            ...prev.progress,
            currentStreak: newStreak,
            longestStreak: newLongest,
            totalSessions: newTotalSessions,
            totalRepetitions: newTotalReps,
            lastSessionDate: streakResult.lastSessionDate,
            unlockedAchievements: [
              ...prev.progress.unlockedAchievements,
              ...newAchievements,
            ],
          },
        };
      });

      // Return newly unlocked for celebration UI
      return checkNewAchievements(
        state.progress,
        session,
        calculateStreak(state.sessions, state.progress.lastSessionDate, state.progress.currentStreak).currentStreak,
        state.progress.totalSessions + 1,
        state.progress.totalRepetitions + session.repsCompleted
      );
    },
    [state.progress, state.sessions]
  );

  // ── Settings actions ────────────────────────────────────────────────────────

  const updateSettings = useCallback((data: Partial<Settings>) => {
    setState((prev) => ({
      ...prev,
      settings: { ...prev.settings, ...data },
    }));
  }, []);

  // ── Reminder actions ────────────────────────────────────────────────────────

  const addReminder = useCallback(
    (mantraId: string, reminderData: Omit<Reminder, 'id'>) => {
      const reminder: Reminder = { ...reminderData, id: generateId() };
      setState((prev) => ({
        ...prev,
        mantras: prev.mantras.map((m) =>
          m.id === mantraId
            ? { ...m, reminders: [...m.reminders, reminder], updatedAt: new Date().toISOString() }
            : m
        ),
      }));
    },
    []
  );

  const updateReminder = useCallback(
    (mantraId: string, reminderId: string, data: Partial<Reminder>) => {
      setState((prev) => ({
        ...prev,
        mantras: prev.mantras.map((m) =>
          m.id === mantraId
            ? {
                ...m,
                reminders: m.reminders.map((r) =>
                  r.id === reminderId ? { ...r, ...data } : r
                ),
                updatedAt: new Date().toISOString(),
              }
            : m
        ),
      }));
    },
    []
  );

  const deleteReminder = useCallback((mantraId: string, reminderId: string) => {
    setState((prev) => ({
      ...prev,
      mantras: prev.mantras.map((m) =>
        m.id === mantraId
          ? {
              ...m,
              reminders: m.reminders.filter((r) => r.id !== reminderId),
              updatedAt: new Date().toISOString(),
            }
          : m
      ),
    }));
  }, []);

  // ── Utilities ───────────────────────────────────────────────────────────────

  const getRecentSessions = useCallback(
    (mantraId?: string, limit = 10): Session[] => {
      let filtered = state.sessions;
      if (mantraId) filtered = filtered.filter((s) => s.mantraId === mantraId);
      return filtered.slice(0, limit);
    },
    [state.sessions]
  );

  const value: AppContextValue = {
    ...state,
    createMantra,
    updateMantra,
    deleteMantra,
    getMantra,
    completeSession,
    updateSettings,
    addReminder,
    updateReminder,
    deleteReminder,
    getRecentSessions,
    effectiveTheme,
  };

  return <AppContext.Provider value={value}>{children}</AppContext.Provider>;
}

export function useApp(): AppContextValue {
  const ctx = useContext(AppContext);
  if (!ctx) throw new Error('useApp must be used within AppProvider');
  return ctx;
}