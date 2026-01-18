/**
 * Main theme index
 * Combines all theme configuration
 */

import { ColorPalette, ThemeName, defaultTheme, themes } from './colors';
import { borderRadius, opacity, shadows, spacing } from './spacing';
import { textStyles, typography } from './typography';

export interface Theme {
  colors: ColorPalette;
  typography: typeof typography;
  textStyles: typeof textStyles;
  spacing: typeof spacing;
  borderRadius: typeof borderRadius;
  shadows: typeof shadows;
  opacity: typeof opacity;
}

export const createTheme = (themeName: ThemeName = 'lotus'): Theme => ({
  colors: themes[themeName],
  typography,
  textStyles,
  spacing,
  borderRadius,
  shadows,
  opacity,
});

// Export everything
export { ThemeName, borderRadius, defaultTheme, opacity, shadows, spacing, textStyles, themes, typography };
export type { ColorPalette };
export { ThemeProvider, useTheme } from './ThemeProvider';

// Default export
export default createTheme();
