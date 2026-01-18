/**
 * App.tsx - Root component
 * Wraps the app with all necessary providers
 */

import React, { useEffect } from 'react';
import { StatusBar, LogBox } from 'react-native';
import { SafeAreaProvider } from 'react-native-safe-area-context';
import { Provider as ReduxProvider } from 'react-redux';
import { GestureHandlerRootView } from 'react-native-gesture-handler';

import store from './store';
import { ThemeProvider } from './theme/ThemeProvider';
import AppNavigator from './navigation/AppNavigator';

// Ignore specific warnings (optional)
LogBox.ignoreLogs([
  'Non-serializable values were found in the navigation state',
]);

const App: React.FC = () => {
  useEffect(() => {
    // Initialize app on mount
    initializeApp();
  }, []);

  const initializeApp = async () => {
    try {
      // Load persisted data
      // This would load user, mantras, goals, settings from AsyncStorage
      // and populate the Redux store
      console.log('App initialized');
    } catch (error) {
      console.error('Error initializing app:', error);
    }
  };

  return (
    <GestureHandlerRootView style={{ flex: 1 }}>
      <ReduxProvider store={store}>
        <SafeAreaProvider>
          <ThemeProvider>
            <StatusBar barStyle="dark-content" />
            <AppNavigator />
          </ThemeProvider>
        </SafeAreaProvider>
      </ReduxProvider>
    </GestureHandlerRootView>
  );
};

export default App;
