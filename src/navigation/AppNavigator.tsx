/**
 * App Navigator - Root navigation structure
 */

import React from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { useAppSelector } from '../store';

// Auth Screens
import { WelcomeScreen } from '../screens/auth/WelcomeScreen';
import { LoginScreen } from '../screens/auth/LoginScreen';

// Mantra Screens
import { MainDashboardScreen } from '../screens/mantra/MainDashboardScreen';
import { CreateMantraScreen } from '../screens/mantra/CreateMantraScreen';
import { EditMantraScreen } from '../screens/mantra/EditMantraScreen';
import { ViewMantraScreen } from '../screens/mantra/ViewMantraScreen';

const Stack = createNativeStackNavigator();

const AppNavigator: React.FC = () => {
  const isAuthenticated = useAppSelector(state => state.auth.isAuthenticated);

  return (
    <NavigationContainer>
      <Stack.Navigator
        screenOptions={{
          headerShown: true,
          headerBackTitleVisible: false,
        }}
      >
        {!isAuthenticated ? (
          // Auth Stack
          <>
            <Stack.Screen
              name="Welcome"
              component={WelcomeScreen}
              options={{ headerShown: false }}
            />
            <Stack.Screen
              name="Login"
              component={LoginScreen}
              options={{ headerShown: false }}
            />
          </>
        ) : (
          // Main Stack
          <>
            <Stack.Screen
              name="MainDashboard"
              component={MainDashboardScreen}
              options={{ title: 'My Mantras', headerShown: false }}
            />
            <Stack.Screen
              name="CreateMantra"
              component={CreateMantraScreen}
              options={{ title: 'Create Mantra' }}
            />
            <Stack.Screen
              name="EditMantra"
              component={EditMantraScreen}
              options={{ title: 'Edit Mantra' }}
            />
            <Stack.Screen
              name="ViewMantra"
              component={ViewMantraScreen}
              options={{ title: 'Mantra' }}
            />
          </>
        )}
      </Stack.Navigator>
    </NavigationContainer>
  );
};

export default AppNavigator;
