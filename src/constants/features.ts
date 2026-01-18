/**
 * Feature flags configuration
 */

import { FeatureFlags, PlanType } from '../types/plan';

export const DEFAULT_FEATURES: FeatureFlags = {
  cloudBackup: false,
  cloudRestore: false,
  translations: false,
  voiceRecording: true, // Always available
  textToSpeech: false,
  advancedGoals: false,
  multiDeviceSync: false,
};

/**
 * Get feature flags for a given plan type
 */
export const getFeaturesForPlan = (plan: PlanType): FeatureFlags => {
  const planFeatures: Record<PlanType, FeatureFlags> = {
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

  return planFeatures[plan] || DEFAULT_FEATURES;
};

/**
 * Check if a feature is available for a plan
 */
export const hasFeature = (plan: PlanType, feature: keyof FeatureFlags): boolean => {
  const features = getFeaturesForPlan(plan);
  return features[feature];
};
