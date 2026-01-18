/**
 * Navigation type definitions
 */

import type { NativeStackScreenProps } from '@react-navigation/native-stack';
import type { BottomTabScreenProps } from '@react-navigation/bottom-tabs';
import type { CompositeScreenProps } from '@react-navigation/native';

// Auth Stack
export type AuthStackParamList = {
  Welcome: undefined;
  Login: undefined;
  Register: undefined;
  PlanSelection: undefined;
  PlanComparison: { from?: 'auth' | 'settings' };
};

// Main Stack (after authentication)
export type MainStackParamList = {
  Dashboard: undefined;
  ViewMantra: { mantraId: string };
  CreateMantra: undefined;
  EditMantra: { mantraId: string };
  Goals: { mantraId: string; mantraTitle: string };
  AddEditGoal: { mantraId: string; mantraTitle: string; goalId?: string };
  Settings: undefined;
  About: undefined;
  ThemeSelection: undefined;
};

// Root Navigator
export type RootStackParamList = {
  Auth: undefined;
  Main: undefined;
};

// Screen props types
export type AuthScreenProps<T extends keyof AuthStackParamList> = NativeStackScreenProps<
  AuthStackParamList,
  T
>;

export type MainScreenProps<T extends keyof MainStackParamList> = NativeStackScreenProps<
  MainStackParamList,
  T
>;

export type RootScreenProps<T extends keyof RootStackParamList> = NativeStackScreenProps<
  RootStackParamList,
  T
>;

// Declare global navigation types for TypeScript
declare global {
  namespace ReactNavigation {
    interface RootParamList extends RootStackParamList {}
  }
}
