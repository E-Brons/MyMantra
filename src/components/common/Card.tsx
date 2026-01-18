import React from 'react';
import { View, StyleSheet, ViewStyle } from 'react-native';
import { useTheme } from '../../theme';

interface CardProps {
  children: React.ReactNode;
  style?: ViewStyle;
}

export const Card: React.FC<CardProps> = ({ children, style }) => {
  const { theme } = useTheme();

  return (
    <View
      style={[
        styles.card,
        {
          backgroundColor: theme.colors.surface,
          shadowColor: theme.shadows.sm.shadowColor,
          shadowOffset: theme.shadows.sm.shadowOffset,
          shadowOpacity: theme.shadows.sm.shadowOpacity,
          shadowRadius: theme.shadows.sm.shadowRadius,
          elevation: theme.shadows.sm.elevation,
        },
        style,
      ]}
    >
      {children}
    </View>
  );
};

const styles = StyleSheet.create({
  card: {
    borderRadius: 16,
    padding: 16,
    marginVertical: 8,
  },
});
