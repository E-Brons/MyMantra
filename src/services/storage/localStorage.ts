/**
 * Local storage service using AsyncStorage
 */

import AsyncStorage from '@react-native-async-storage/async-storage';
import { CONFIG } from '../../constants/config';
import type { User, Mantra, Goal, GoalSettings } from '../../types';
import type { ThemeName } from '../../theme';
import type { AppTheme, Language } from '../../store/slices/settingsSlice';

/**
 * Storage keys
 */
const KEYS = CONFIG.storage.keys;

/**
 * Save user data
 */
export const saveUser = async (user: User): Promise<void> => {
  try {
    await AsyncStorage.setItem(KEYS.USER, JSON.stringify(user));
  } catch (error) {
    console.error('Error saving user:', error);
    throw error;
  }
};

/**
 * Get user data
 */
export const getUser = async (): Promise<User | null> => {
  try {
    const userData = await AsyncStorage.getItem(KEYS.USER);
    return userData ? JSON.parse(userData) : null;
  } catch (error) {
    console.error('Error getting user:', error);
    return null;
  }
};

/**
 * Remove user data
 */
export const removeUser = async (): Promise<void> => {
  try {
    await AsyncStorage.removeItem(KEYS.USER);
  } catch (error) {
    console.error('Error removing user:', error);
  }
};

/**
 * Save mantras
 */
export const saveMantras = async (mantras: Mantra[]): Promise<void> => {
  try {
    await AsyncStorage.setItem(KEYS.MANTRAS, JSON.stringify(mantras));
  } catch (error) {
    console.error('Error saving mantras:', error);
    throw error;
  }
};

/**
 * Get mantras
 */
export const getMantras = async (): Promise<Mantra[]> => {
  try {
    const mantrasData = await AsyncStorage.getItem(KEYS.MANTRAS);
    return mantrasData ? JSON.parse(mantrasData) : [];
  } catch (error) {
    console.error('Error getting mantras:', error);
    return [];
  }
};

/**
 * Save goals
 */
export const saveGoals = async (goals: Goal[]): Promise<void> => {
  try {
    await AsyncStorage.setItem(KEYS.GOALS, JSON.stringify(goals));
  } catch (error) {
    console.error('Error saving goals:', error);
    throw error;
  }
};

/**
 * Get goals
 */
export const getGoals = async (): Promise<Goal[]> => {
  try {
    const goalsData = await AsyncStorage.getItem(KEYS.GOALS);
    return goalsData ? JSON.parse(goalsData) : [];
  } catch (error) {
    console.error('Error getting goals:', error);
    return [];
  }
};

/**
 * Save goal settings
 */
export const saveGoalSettings = async (settings: GoalSettings): Promise<void> => {
  try {
    const settingsKey = `${KEYS.SETTINGS}:goals`;
    await AsyncStorage.setItem(settingsKey, JSON.stringify(settings));
  } catch (error) {
    console.error('Error saving goal settings:', error);
    throw error;
  }
};

/**
 * Get goal settings
 */
export const getGoalSettings = async (): Promise<GoalSettings | null> => {
  try {
    const settingsKey = `${KEYS.SETTINGS}:goals`;
    const settingsData = await AsyncStorage.getItem(settingsKey);
    return settingsData ? JSON.parse(settingsData) : null;
  } catch (error) {
    console.error('Error getting goal settings:', error);
    return null;
  }
};

/**
 * Save app settings
 */
export const saveAppSettings = async (settings: {
  theme: ThemeName;
  appTheme: AppTheme;
  language: Language;
}): Promise<void> => {
  try {
    await AsyncStorage.setItem(KEYS.SETTINGS, JSON.stringify(settings));
  } catch (error) {
    console.error('Error saving app settings:', error);
    throw error;
  }
};

/**
 * Get app settings
 */
export const getAppSettings = async (): Promise<{
  theme: ThemeName;
  appTheme: AppTheme;
  language: Language;
} | null> => {
  try {
    const settingsData = await AsyncStorage.getItem(KEYS.SETTINGS);
    return settingsData ? JSON.parse(settingsData) : null;
  } catch (error) {
    console.error('Error getting app settings:', error);
    return null;
  }
};

/**
 * Clear all data
 */
export const clearAllData = async (): Promise<void> => {
  try {
    await AsyncStorage.multiRemove([
      KEYS.USER,
      KEYS.MANTRAS,
      KEYS.GOALS,
      KEYS.SETTINGS,
      KEYS.THEME,
    ]);
  } catch (error) {
    console.error('Error clearing all data:', error);
    throw error;
  }
};

/**
 * Export all data (for backup)
 */
export const exportAllData = async (): Promise<string> => {
  try {
    const [user, mantras, goals, settings] = await Promise.all([
      getUser(),
      getMantras(),
      getGoals(),
      getAppSettings(),
    ]);

    const exportData = {
      version: '1.0.0',
      exportDate: new Date().toISOString(),
      user,
      mantras,
      goals,
      settings,
    };

    return JSON.stringify(exportData, null, 2);
  } catch (error) {
    console.error('Error exporting data:', error);
    throw error;
  }
};

/**
 * Import all data (for restore)
 */
export const importAllData = async (jsonData: string): Promise<void> => {
  try {
    const data = JSON.parse(jsonData);

    if (data.user) await saveUser(data.user);
    if (data.mantras) await saveMantras(data.mantras);
    if (data.goals) await saveGoals(data.goals);
    if (data.settings) await saveAppSettings(data.settings);
  } catch (error) {
    console.error('Error importing data:', error);
    throw error;
  }
};
