/**
 * Theme Context Provider
 * Provides theme values throughout the app
 */

import React, { createContext, useContext, useState, useEffect, ReactNode } from 'react';
import { useColorScheme } from 'react-native';
import { useAppSelector, useAppDispatch } from '../store';
import { setTheme as setThemeAction } from '../store/slices/settingsSlice';
import { createTheme, ThemeName, Theme } from '../theme';
import type { AppTheme } from '../store/slices/settingsSlice';

interface ThemeContextValue {
  theme: Theme;
  themeName: ThemeName;
  appTheme: AppTheme;
  isDark: boolean;
  setTheme: (themeName: ThemeName) => void;
}

const ThemeContext = createContext<ThemeContextValue | undefined>(undefined);

interface ThemeProviderProps {
  children: ReactNode;
}

export const ThemeProvider: React.FC<ThemeProviderProps> = ({ children }) => {
  const dispatch = useAppDispatch();
  const themeName = useAppSelector(state => state.settings.theme);
  const appTheme = useAppSelector(state => state.settings.appTheme);
  const systemColorScheme = useColorScheme();

  // Determine if dark mode should be active
  const isDark =
    appTheme === 'dark' || (appTheme === 'auto' && systemColorScheme === 'dark');

  // Create theme based on selected theme name
  const theme = createTheme(themeName);

  const setTheme = (newThemeName: ThemeName) => {
    dispatch(setThemeAction(newThemeName));
  };

  const value: ThemeContextValue = {
    theme,
    themeName,
    appTheme,
    isDark,
    setTheme,
  };

  return <ThemeContext.Provider value={value}>{children}</ThemeContext.Provider>;
};

/**
 * Hook to use theme context
 */
export const useTheme = (): ThemeContextValue => {
  const context = useContext(ThemeContext);
  if (!context) {
    throw new Error('useTheme must be used within ThemeProvider');
  }
  return context;
};

export default ThemeProvider;
