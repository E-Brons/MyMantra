/**
 * Color Themes for MyMantra
 * Multiple calming, spiritual color schemes
 */

export interface ColorPalette {
  name: string;
  primary: string;
  primaryLight: string;
  primaryDark: string;
  secondary: string;
  secondaryLight: string;
  accent: string;
  background: string;
  surface: string;
  surfaceLight: string;
  text: string;
  textSecondary: string;
  textLight: string;
  border: string;
  success: string;
  warning: string;
  error: string;
  white: string;
  black: string;
}

// Lotus Purple (Default Theme)
export const lotus: ColorPalette = {
  name: 'Lotus',
  primary: '#8B5CF6',        // Purple 500
  primaryLight: '#A78BFA',   // Purple 400
  primaryDark: '#7C3AED',    // Purple 600
  secondary: '#6366F1',      // Indigo 500
  secondaryLight: '#818CF8', // Indigo 400
  accent: '#EC4899',         // Pink 500
  background: '#F9FAFB',     // Gray 50
  surface: '#FFFFFF',
  surfaceLight: '#F3F4F6',   // Gray 100
  text: '#111827',           // Gray 900
  textSecondary: '#6B7280',  // Gray 500
  textLight: '#9CA3AF',      // Gray 400
  border: '#E5E7EB',         // Gray 200
  success: '#10B981',        // Green 500
  warning: '#F59E0B',        // Amber 500
  error: '#EF4444',          // Red 500
  white: '#FFFFFF',
  black: '#000000',
};

// Sacred Blue
export const sacred: ColorPalette = {
  name: 'Sacred',
  primary: '#3B82F6',        // Blue 500
  primaryLight: '#60A5FA',   // Blue 400
  primaryDark: '#2563EB',    // Blue 600
  secondary: '#0EA5E9',      // Sky 500
  secondaryLight: '#38BDF8', // Sky 400
  accent: '#06B6D4',         // Cyan 500
  background: '#F0F9FF',     // Sky 50
  surface: '#FFFFFF',
  surfaceLight: '#E0F2FE',   // Sky 100
  text: '#0F172A',           // Slate 900
  textSecondary: '#64748B',  // Slate 500
  textLight: '#94A3B8',      // Slate 400
  border: '#E2E8F0',         // Slate 200
  success: '#10B981',        // Green 500
  warning: '#F59E0B',        // Amber 500
  error: '#EF4444',          // Red 500
  white: '#FFFFFF',
  black: '#000000',
};

// Earth Tones
export const earth: ColorPalette = {
  name: 'Earth',
  primary: '#D97706',        // Amber 600
  primaryLight: '#F59E0B',   // Amber 500
  primaryDark: '#B45309',    // Amber 700
  secondary: '#059669',      // Emerald 600
  secondaryLight: '#10B981', // Emerald 500
  accent: '#DC2626',         // Red 600
  background: '#FEFCE8',     // Yellow 50
  surface: '#FFFFFF',
  surfaceLight: '#FEF3C7',   // Amber 100
  text: '#292524',           // Stone 800
  textSecondary: '#78716C',  // Stone 500
  textLight: '#A8A29E',      // Stone 400
  border: '#E7E5E4',         // Stone 200
  success: '#10B981',        // Green 500
  warning: '#F59E0B',        // Amber 500
  error: '#EF4444',          // Red 500
  white: '#FFFFFF',
  black: '#000000',
};

// Sunset Rose
export const sunset: ColorPalette = {
  name: 'Sunset',
  primary: '#EC4899',        // Pink 500
  primaryLight: '#F472B6',   // Pink 400
  primaryDark: '#DB2777',    // Pink 600
  secondary: '#F59E0B',      // Amber 500
  secondaryLight: '#FBBF24', // Amber 400
  accent: '#8B5CF6',         // Purple 500
  background: '#FFF7ED',     // Orange 50
  surface: '#FFFFFF',
  surfaceLight: '#FFF1F2',   // Rose 50
  text: '#1F2937',           // Gray 800
  textSecondary: '#6B7280',  // Gray 500
  textLight: '#9CA3AF',      // Gray 400
  border: '#F3F4F6',         // Gray 100
  success: '#10B981',        // Green 500
  warning: '#F59E0B',        // Amber 500
  error: '#EF4444',          // Red 500
  white: '#FFFFFF',
  black: '#000000',
};

// Zen Green
export const zen: ColorPalette = {
  name: 'Zen',
  primary: '#059669',        // Emerald 600
  primaryLight: '#10B981',   // Emerald 500
  primaryDark: '#047857',    // Emerald 700
  secondary: '#0D9488',      // Teal 600
  secondaryLight: '#14B8A6', // Teal 500
  accent: '#84CC16',         // Lime 500
  background: '#F0FDF4',     // Green 50
  surface: '#FFFFFF',
  surfaceLight: '#ECFDF5',   // Emerald 50
  text: '#14532D',           // Green 900
  textSecondary: '#4B5563',  // Gray 600
  textLight: '#6B7280',      // Gray 500
  border: '#D1FAE5',         // Emerald 100
  success: '#10B981',        // Green 500
  warning: '#F59E0B',        // Amber 500
  error: '#EF4444',          // Red 500
  white: '#FFFFFF',
  black: '#000000',
};

// Ocean Depths
export const ocean: ColorPalette = {
  name: 'Ocean',
  primary: '#0891B2',        // Cyan 600
  primaryLight: '#06B6D4',   // Cyan 500
  primaryDark: '#0E7490',    // Cyan 700
  secondary: '#6366F1',      // Indigo 500
  secondaryLight: '#818CF8', // Indigo 400
  accent: '#8B5CF6',         // Purple 500
  background: '#ECFEFF',     // Cyan 50
  surface: '#FFFFFF',
  surfaceLight: '#CFFAFE',   // Cyan 100
  text: '#164E63',           // Cyan 900
  textSecondary: '#0E7490',  // Cyan 700
  textLight: '#155E75',      // Cyan 800
  border: '#A5F3FC',         // Cyan 200
  success: '#10B981',        // Green 500
  warning: '#F59E0B',        // Amber 500
  error: '#EF4444',          // Red 500
  white: '#FFFFFF',
  black: '#000000',
};

// All available themes
export const themes = {
  lotus,
  sacred,
  earth,
  sunset,
  zen,
  ocean,
};

export type ThemeName = keyof typeof themes;

// Default theme
export const defaultTheme = lotus;
