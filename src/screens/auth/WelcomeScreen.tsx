import React, { useEffect } from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { useNavigation } from '@react-navigation/native';
import { useTheme } from '../../theme';
import { CONFIG } from '../../constants/config';

export const WelcomeScreen: React.FC = () => {
  const navigation = useNavigation();
  const { theme } = useTheme();

  useEffect(() => {
    const timer = setTimeout(() => {
      navigation.navigate('Login' as never);
    }, CONFIG.animation.welcomeScreenDuration);

    return () => clearTimeout(timer);
  }, [navigation]);

  return (
    <View style={[styles.container, { backgroundColor: theme.colors.background }]}>
      <Text style={styles.logo}>🪷</Text>
      <Text style={[styles.sanskrit, { color: theme.colors.text }]}>ॐ</Text>
      <Text style={[styles.title, { color: theme.colors.primary }]}>
        {CONFIG.app.name}
      </Text>
      <Text style={[styles.tagline, { color: theme.colors.textSecondary }]}>
        {CONFIG.app.tagline}
      </Text>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 24,
  },
  logo: {
    fontSize: 120,
    marginBottom: 24,
  },
  sanskrit: {
    fontSize: 60,
    marginBottom: 16,
  },
  title: {
    fontSize: 32,
    fontWeight: 'bold',
    marginBottom: 8,
  },
  tagline: {
    fontSize: 18,
    fontStyle: 'italic',
    textAlign: 'center',
  },
});
