/**
 * Route name constants for navigation
 */

// Auth Routes
export const AUTH_ROUTES = {
  WELCOME: 'Welcome',
  LOGIN: 'Login',
  REGISTER: 'Register',
  PLAN_SELECTION: 'PlanSelection',
  PLAN_COMPARISON: 'PlanComparison',
} as const;

// Main Routes
export const MAIN_ROUTES = {
  DASHBOARD: 'Dashboard',
  VIEW_MANTRA: 'ViewMantra',
  CREATE_MANTRA: 'CreateMantra',
  EDIT_MANTRA: 'EditMantra',
  GOALS: 'Goals',
  ADD_EDIT_GOAL: 'AddEditGoal',
  SETTINGS: 'Settings',
  ABOUT: 'About',
  THEME_SELECTION: 'ThemeSelection',
} as const;

// Root Routes
export const ROOT_ROUTES = {
  AUTH: 'Auth',
  MAIN: 'Main',
} as const;

// Combined exports
export const ROUTES = {
  ...AUTH_ROUTES,
  ...MAIN_ROUTES,
  ...ROOT_ROUTES,
} as const;

export default ROUTES;
