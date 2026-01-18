/**
 * Date and time utility functions
 */

import { DayOfWeek } from '../types/goal';

/**
 * Format date to ISO string
 */
export const toISOString = (date: Date = new Date()): string => {
  return date.toISOString();
};

/**
 * Format date for display
 */
export const formatDate = (dateString: string, format: 'short' | 'long' = 'short'): string => {
  const date = new Date(dateString);

  if (format === 'short') {
    return date.toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'short',
      day: 'numeric',
    });
  }

  return date.toLocaleDateString('en-US', {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
  });
};

/**
 * Format time from 24-hour to 12-hour format
 */
export const formatTime12Hour = (time24: string): string => {
  const [hours, minutes] = time24.split(':').map(Number);
  const period = hours >= 12 ? 'PM' : 'AM';
  const hours12 = hours % 12 || 12;
  return `${hours12}:${minutes.toString().padStart(2, '0')} ${period}`;
};

/**
 * Format time from 12-hour to 24-hour format
 */
export const formatTime24Hour = (time12: string): string => {
  const match = time12.match(/(\d+):(\d+)\s*(AM|PM)/i);
  if (!match) return '00:00';

  let [, hours, minutes, period] = match;
  let hours24 = parseInt(hours);

  if (period.toUpperCase() === 'PM' && hours24 !== 12) {
    hours24 += 12;
  } else if (period.toUpperCase() === 'AM' && hours24 === 12) {
    hours24 = 0;
  }

  return `${hours24.toString().padStart(2, '0')}:${minutes.padStart(2, '0')}`;
};

/**
 * Get relative time string (e.g., "Today", "Yesterday", "2 days ago")
 */
export const getRelativeTime = (dateString: string): string => {
  const date = new Date(dateString);
  const now = new Date();
  const diffMs = now.getTime() - date.getTime();
  const diffDays = Math.floor(diffMs / (1000 * 60 * 60 * 24));

  if (diffDays === 0) return 'Today';
  if (diffDays === 1) return 'Yesterday';
  if (diffDays < 7) return `${diffDays} days ago`;
  if (diffDays < 30) return `${Math.floor(diffDays / 7)} weeks ago`;
  if (diffDays < 365) return `${Math.floor(diffDays / 30)} months ago`;
  return `${Math.floor(diffDays / 365)} years ago`;
};

/**
 * Convert day of week to display name
 */
export const dayOfWeekToDisplay = (day: DayOfWeek): string => {
  const map: Record<DayOfWeek, string> = {
    mon: 'Monday',
    tue: 'Tuesday',
    wed: 'Wednesday',
    thu: 'Thursday',
    fri: 'Friday',
    sat: 'Saturday',
    sun: 'Sunday',
  };
  return map[day];
};

/**
 * Get abbreviated day name
 */
export const dayOfWeekAbbr = (day: DayOfWeek): string => {
  const map: Record<DayOfWeek, string> = {
    mon: 'Mon',
    tue: 'Tue',
    wed: 'Wed',
    thu: 'Thu',
    fri: 'Fri',
    sat: 'Sat',
    sun: 'Sun',
  };
  return map[day];
};

/**
 * Get current day of week
 */
export const getCurrentDayOfWeek = (): DayOfWeek => {
  const days: DayOfWeek[] = ['sun', 'mon', 'tue', 'wed', 'thu', 'fri', 'sat'];
  return days[new Date().getDay()];
};
