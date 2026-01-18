import React, { useState } from 'react';
import { View, Text, StyleSheet, ScrollView } from 'react-native';
import { useNavigation } from '@react-navigation/native';
import { Button } from '../../components/common';
import { useTheme } from '../../theme';
import { CONFIG } from '../../constants/config';
import { useAppDispatch } from '../../store';
import { loginSuccess } from '../../store/slices/authSlice';
import { User } from '../../types';

export const LoginScreen: React.FC = () => {
  const navigation = useNavigation();
  const dispatch = useAppDispatch();
  const { theme } = useTheme();
  const [loading, setLoading] = useState(false);

  const handleMockLogin = async () => {
    setLoading(true);

    // Simulate API call delay
    setTimeout(() => {
      // Create a mock user for demo
      const mockUser: User = {
        id: 'demo-user-123',
        email: 'demo@mymantra.app',
        name: 'Demo User',
        authProvider: 'google',
        plan: 'free',
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString(),
      };

      dispatch(loginSuccess(mockUser));
      setLoading(false);
      navigation.navigate('MainDashboard' as never);
    }, 1000);
  };

  return (
    <ScrollView
      style={[styles.container, { backgroundColor: theme.colors.background }]}
      contentContainerStyle={styles.content}
    >
      <View style={styles.header}>
        <Text style={styles.logo}>🪷</Text>
        <Text style={[styles.appName, { color: theme.colors.primary }]}>
          {CONFIG.app.name}
        </Text>
        <Text style={[styles.tagline, { color: theme.colors.textSecondary }]}>
          {CONFIG.app.tagline}
        </Text>
      </View>

      <View style={styles.authSection}>
        <Text style={[styles.welcomeText, { color: theme.colors.text }]}>
          Welcome to your spiritual practice
        </Text>

        <View style={styles.authButtons}>
          <Button
            title="Continue with Demo"
            onPress={handleMockLogin}
            loading={loading}
          />

          <Button
            title="Continue with Google"
            onPress={() => {
              // For demo, just use mock login
              handleMockLogin();
            }}
            variant="outline"
            disabled
          />

          <Button
            title="Continue with Apple"
            onPress={() => {}}
            variant="outline"
            disabled
          />
        </View>

        <Text style={[styles.note, { color: theme.colors.textSecondary }]}>
          Demo mode - OAuth providers coming soon
        </Text>
      </View>
    </ScrollView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  content: {
    padding: 24,
    justifyContent: 'center',
    minHeight: '100%',
  },
  header: {
    alignItems: 'center',
    marginBottom: 48,
  },
  logo: {
    fontSize: 80,
    marginBottom: 16,
  },
  appName: {
    fontSize: 32,
    fontWeight: 'bold',
    marginBottom: 8,
  },
  tagline: {
    fontSize: 16,
    textAlign: 'center',
    fontStyle: 'italic',
  },
  authSection: {
    marginBottom: 32,
  },
  welcomeText: {
    fontSize: 18,
    textAlign: 'center',
    marginBottom: 32,
  },
  authButtons: {
    gap: 12,
  },
  note: {
    fontSize: 12,
    textAlign: 'center',
    marginTop: 16,
  },
});
