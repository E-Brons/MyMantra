/**
 * Plan and feature type definitions
 */

export type PlanType = 'free' | 'premium';

export interface Plan {
  id: PlanType;
  name: string;
  price: string; // e.g., "$0/month" or "$4.99/month"
  features: string[];
  recommended?: boolean;
}

export interface FeatureFlags {
  cloudBackup: boolean;
  cloudRestore: boolean;
  translations: boolean;
  voiceRecording: boolean; // Always true for now
  textToSpeech: boolean;
  advancedGoals: boolean;
  multiDeviceSync: boolean;
}

// Plan-to-feature mapping
export const PLAN_FEATURES: Record<PlanType, FeatureFlags> = {
  free: {
    cloudBackup: false,
    cloudRestore: false,
    translations: false,
    voiceRecording: true,
    textToSpeech: false,
    advancedGoals: false,
    multiDeviceSync: false,
  },
  premium: {
    cloudBackup: true,
    cloudRestore: true,
    translations: true,
    voiceRecording: true,
    textToSpeech: true,
    advancedGoals: true,
    multiDeviceSync: true,
  },
};

export const PLANS: Plan[] = [
  {
    id: 'free',
    name: 'Free Plan',
    price: '$0/month',
    features: [
      'Unlimited user-defined mantras',
      'Voice recording',
      'Basic goals',
      'Offline access',
    ],
  },
  {
    id: 'premium',
    name: 'Premium Plan',
    price: '$4.99/month',
    features: [
      'Everything in Free',
      'Text-to-speech generation',
      'Translations',
      'Cloud backup (Drive/iCloud)',
      'Multi-device sync',
    ],
    recommended: true,
  },
];
