/**
 * Goals slice - manages practice goals/reminders
 */

import { createSlice, PayloadAction } from '@reduxjs/toolkit';
import type { Goal, GoalSettings, CreateGoalInput } from '../../types';

interface GoalsState {
  goals: Goal[];
  settings: GoalSettings;
  isLoading: boolean;
  error: string | null;
}

const initialState: GoalsState = {
  goals: [],
  settings: {
    enabled: true,
    soundEnabled: true,
    vibrationEnabled: true,
    defaultSound: 'default',
  },
  isLoading: false,
  error: null,
};

const goalsSlice = createSlice({
  name: 'goals',
  initialState,
  reducers: {
    setGoals(state, action: PayloadAction<Goal[]>) {
      state.goals = action.payload;
      state.isLoading = false;
    },
    addGoal(state, action: PayloadAction<Goal>) {
      state.goals.push(action.payload);
    },
    updateGoal(state, action: PayloadAction<Goal>) {
      const index = state.goals.findIndex(g => g.id === action.payload.id);
      if (index !== -1) {
        state.goals[index] = action.payload;
      }
    },
    deleteGoal(state, action: PayloadAction<string>) {
      state.goals = state.goals.filter(g => g.id !== action.payload);
    },
    toggleGoalEnabled(state, action: PayloadAction<string>) {
      const goal = state.goals.find(g => g.id === action.payload);
      if (goal) {
        goal.enabled = !goal.enabled;
      }
    },
    deleteGoalsByMantraId(state, action: PayloadAction<string>) {
      state.goals = state.goals.filter(g => g.mantraId !== action.payload);
    },
    updateSettings(state, action: PayloadAction<Partial<GoalSettings>>) {
      state.settings = { ...state.settings, ...action.payload };
    },
    toggleGoalsEnabled(state) {
      state.settings.enabled = !state.settings.enabled;
    },
    setLoading(state, action: PayloadAction<boolean>) {
      state.isLoading = action.payload;
    },
    setError(state, action: PayloadAction<string | null>) {
      state.error = action.payload;
      state.isLoading = false;
    },
    clearError(state) {
      state.error = null;
    },
  },
});

export const {
  setGoals,
  addGoal,
  updateGoal,
  deleteGoal,
  toggleGoalEnabled,
  deleteGoalsByMantraId,
  updateSettings,
  toggleGoalsEnabled,
  setLoading,
  setError,
  clearError,
} = goalsSlice.actions;

export default goalsSlice.reducer;
