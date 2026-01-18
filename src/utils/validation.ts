/**
 * Validation utility functions
 */

export const EMAIL_REGEX = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

/**
 * Validate email address
 */
export const isValidEmail = (email: string): boolean => {
  return EMAIL_REGEX.test(email);
};

/**
 * Validate mantra title
 */
export const isValidMantraTitle = (title: string): boolean => {
  return title.trim().length > 0 && title.length <= 100;
};

/**
 * Validate mantra text
 */
export const isValidMantraText = (text: string): boolean => {
  return text.trim().length > 0 && text.length <= 5000;
};

/**
 * Validate time string (HH:mm format)
 */
export const isValidTime = (time: string): boolean => {
  const timeRegex = /^([01]\d|2[0-3]):([0-5]\d)$/;
  return timeRegex.test(time);
};

/**
 * Sanitize string input
 */
export const sanitizeString = (input: string): string => {
  return input.trim().replace(/\s+/g, ' ');
};

/**
 * Validate array length
 */
export const isValidArrayLength = (arr: any[], min: number, max: number): boolean => {
  return arr.length >= min && arr.length <= max;
};
