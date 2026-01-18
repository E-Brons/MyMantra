/**
 * Settings slice - manages app settings
 */

import { createSlice, PayloadAction } from '@reduxjs/toolkit';
import type { ThemeName } from '../../types';

export type AppTheme = 'light' | 'dark' | 'auto';
export type Language = 'en' | 'he';

interface SettingsState {
  theme: ThemeName;
  appTheme: AppTheme;
  language: Language;
  hasCompletedOnboarding: boolean;
  notificationsPermissionGranted: boolean;
}

const initialState: SettingsState = {
  theme: 'lotus',
  appTheme: 'auto',
  language: 'en',
  hasCompletedOnboarding: false,
  notificationsPermissionGranted: false,
};

const settingsSlice = createSlice({
  name: 'settings',
  initialState,
  reducers: {
    setTheme(state, action: PayloadAction<ThemeName>) {
      state.theme = action.payload;
    },
    setAppTheme(state, action: PayloadAction<AppTheme>) {
      state.appTheme = action.payload;
    },
    setLanguage(state, action: PayloadAction<Language>) {
      state.language = action.payload;
    },
    completeOnboarding(state) {
      state.hasCompletedOnboarding = true;
    },
    setNotificationsPermission(state, action: PayloadAction<boolean>) {
      state.notificationsPermissionGranted = action.payload;
    },
    resetSettings(state) {
      return initialState;
    },
  },
});

export const {
  setTheme,
  setAppTheme,
  setLanguage,
  completeOnboarding,
  setNotificationsPermission,
  resetSettings,
} = settingsSlice.actions;

export default settingsSlice.reducer;
