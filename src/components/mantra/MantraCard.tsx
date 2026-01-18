import React from 'react';
import { View, Text, TouchableOpacity, StyleSheet } from 'react-native';
import { Card } from '../common';
import { useTheme } from '../../theme';
import { Mantra } from '../../types';

interface MantraCardProps {
  mantra: Mantra;
  onPress: () => void;
}

export const MantraCard: React.FC<MantraCardProps> = ({ mantra, onPress }) => {
  const { theme } = useTheme();

  return (
    <TouchableOpacity onPress={onPress} activeOpacity={0.7}>
      <Card>
        <View style={styles.content}>
          <View style={styles.header}>
            <Text style={[styles.title, { color: theme.colors.text }]}>
              {mantra.title}
            </Text>
            {mantra.category && (
              <View style={[styles.badge, { backgroundColor: theme.colors.primaryLight }]}>
                <Text style={[styles.badgeText, { color: theme.colors.primary }]}>
                  {mantra.category}
                </Text>
              </View>
            )}
          </View>

          {mantra.text && (
            <Text
              style={[styles.text, { color: theme.colors.textSecondary }]}
              numberOfLines={2}
            >
              {mantra.text}
            </Text>
          )}

          {mantra.voiceUri && (
            <View style={styles.voiceIndicator}>
              <Text style={{ color: theme.colors.primary }}>🎵 Voice recording</Text>
            </View>
          )}
        </View>
      </Card>
    </TouchableOpacity>
  );
};

const styles = StyleSheet.create({
  content: {
    gap: 8,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  title: {
    fontSize: 18,
    fontWeight: '600',
    flex: 1,
  },
  badge: {
    paddingHorizontal: 8,
    paddingVertical: 4,
    borderRadius: 8,
  },
  badgeText: {
    fontSize: 12,
    fontWeight: '600',
  },
  text: {
    fontSize: 14,
    lineHeight: 20,
  },
  voiceIndicator: {
    marginTop: 4,
  },
});
