/**
 * App configuration constants
 */

export const CONFIG = {
  app: {
    name: 'MyMantra',
    version: '1.0.0',
    tagline: 'Practice, No Attachment',
  },

  storage: {
    keys: {
      USER: '@mymantra:user',
      MANTRAS: '@mymantra:mantras',
      GOALS: '@mymantra:goals',
      SETTINGS: '@mymantra:settings',
      THEME: '@mymantra:theme',
    },
  },

  audio: {
    maxRecordingDuration: 300, // 5 minutes in seconds
    recordingQuality: 'high' as const,
    defaultVolume: 1.0,
  },

  notifications: {
    channelId: 'mantra-goals',
    channelName: 'Practice Goals',
    channelDescription: 'Reminders for your mantra practice goals',
  },

  limits: {
    maxMantraTextLength: 5000,
    maxMantraTitleLength: 100,
    maxTagsPerMantra: 10,
    maxGoalsPerMantra: 10,
  },

  animation: {
    welcomeScreenDuration: 2500, // milliseconds
    defaultTransitionDuration: 300,
  },
};

export default CONFIG;
