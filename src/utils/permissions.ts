/**
 * Permission handling utilities
 */

import { Platform, PermissionsAndroid, Alert } from 'react-native';
import { PERMISSIONS, request, check, RESULTS } from 'react-native-permissions';

export type PermissionType = 'notifications' | 'microphone' | 'storage';

/**
 * Request notification permissions
 */
export const requestNotificationPermission = async (): Promise<boolean> => {
  try {
    if (Platform.OS === 'android') {
      if (Platform.Version >= 33) {
        const result = await request(PERMISSIONS.ANDROID.POST_NOTIFICATIONS);
        return result === RESULTS.GRANTED;
      }
      return true; // No permission needed for Android < 13
    } else if (Platform.OS === 'ios') {
      const result = await request(PERMISSIONS.IOS.NOTIFICATIONS);
      return result === RESULTS.GRANTED;
    }
    return false;
  } catch (error) {
    console.error('Error requesting notification permission:', error);
    return false;
  }
};

/**
 * Check if notification permission is granted
 */
export const checkNotificationPermission = async (): Promise<boolean> => {
  try {
    if (Platform.OS === 'android') {
      if (Platform.Version >= 33) {
        const result = await check(PERMISSIONS.ANDROID.POST_NOTIFICATIONS);
        return result === RESULTS.GRANTED;
      }
      return true;
    } else if (Platform.OS === 'ios') {
      const result = await check(PERMISSIONS.IOS.NOTIFICATIONS);
      return result === RESULTS.GRANTED;
    }
    return false;
  } catch (error) {
    console.error('Error checking notification permission:', error);
    return false;
  }
};

/**
 * Request microphone permission for voice recording
 */
export const requestMicrophonePermission = async (): Promise<boolean> => {
  try {
    if (Platform.OS === 'android') {
      const result = await request(PERMISSIONS.ANDROID.RECORD_AUDIO);
      return result === RESULTS.GRANTED;
    } else if (Platform.OS === 'ios') {
      const result = await request(PERMISSIONS.IOS.MICROPHONE);
      return result === RESULTS.GRANTED;
    }
    return false;
  } catch (error) {
    console.error('Error requesting microphone permission:', error);
    return false;
  }
};

/**
 * Check if microphone permission is granted
 */
export const checkMicrophonePermission = async (): Promise<boolean> => {
  try {
    if (Platform.OS === 'android') {
      const result = await check(PERMISSIONS.ANDROID.RECORD_AUDIO);
      return result === RESULTS.GRANTED;
    } else if (Platform.OS === 'ios') {
      const result = await check(PERMISSIONS.IOS.MICROPHONE);
      return result === RESULTS.GRANTED;
    }
    return false;
  } catch (error) {
    console.error('Error checking microphone permission:', error);
    return false;
  }
};

/**
 * Show alert when permission is denied
 */
export const showPermissionAlert = (permissionType: PermissionType): void => {
  const messages = {
    notifications: {
      title: 'Notification Permission Required',
      message: 'Please enable notifications in settings to receive practice goal reminders.',
    },
    microphone: {
      title: 'Microphone Permission Required',
      message: 'Please enable microphone access in settings to record voice for your mantras.',
    },
    storage: {
      title: 'Storage Permission Required',
      message: 'Please enable storage access in settings to save your mantras.',
    },
  };

  const { title, message } = messages[permissionType];

  Alert.alert(title, message, [
    { text: 'Cancel', style: 'cancel' },
    { text: 'Open Settings', onPress: () => {
      // Open settings - would need react-native-settings library
      console.log('Open settings');
    }},
  ]);
};
