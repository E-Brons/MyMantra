/**
 * User and authentication type definitions
 */

export type AuthProvider = 'google' | 'apple' | 'meta';

export type PlanType = 'free' | 'premium';

export interface User {
  id: string;
  email: string;
  name?: string;
  photoUrl?: string;
  authProvider: AuthProvider;
  plan: PlanType;
  createdAt: string;
  updatedAt: string;
}

export interface AuthState {
  user: User | null;
  isAuthenticated: boolean;
  isLoading: boolean;
  error: string | null;
}

export interface LoginCredentials {
  provider: AuthProvider;
  token: string;
}
