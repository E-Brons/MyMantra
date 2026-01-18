/**
 * Goal (Practice Reminder) type definitions
 */

export type RepeatType = 'daily' | 'weekdays' | 'weekends' | 'custom' | 'once';

export type DayOfWeek = 'mon' | 'tue' | 'wed' | 'thu' | 'fri' | 'sat' | 'sun';

export interface Goal {
  id: string;
  userId: string;
  mantraId: string;
  mantraTitle: string; // Denormalized for display
  time: string; // Format: "HH:mm" (24-hour format)
  repeat: RepeatType;
  customDays?: DayOfWeek[]; // Only used when repeat === 'custom'
  enabled: boolean;
  createdAt: string;
  updatedAt: string;
}

export interface CreateGoalInput {
  mantraId: string;
  mantraTitle: string;
  time: string;
  repeat: RepeatType;
  customDays?: DayOfWeek[];
  enabled?: boolean;
}

export interface UpdateGoalInput extends Partial<CreateGoalInput> {
  id: string;
}

export interface GoalSettings {
  enabled: boolean; // Master switch for all goals
  soundEnabled: boolean;
  vibrationEnabled: boolean;
  defaultSound: string;
}
