import React from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
} from 'react-native';
import { useRoute, useNavigation } from '@react-navigation/native';
import { useTheme } from '../../theme';
import { useAppSelector, useAppDispatch } from '../../store';
import { Button, Card } from '../../components/common';
import { deleteMantra } from '../../store/slices/mantrasSlice';

export const ViewMantraScreen: React.FC = () => {
  const route = useRoute();
  const navigation = useNavigation();
  const { theme } = useTheme();
  const dispatch = useAppDispatch();
  const { mantraId } = (route.params as { mantraId: string }) || {};

  const mantra = useAppSelector(state =>
    state.mantras.mantras.find(m => m.id === mantraId)
  );

  if (!mantra) {
    return (
      <View style={[styles.container, { backgroundColor: theme.colors.background }]}>
        <Text style={[styles.error, { color: theme.colors.error }]}>
          Mantra not found
        </Text>
      </View>
    );
  }

  const handleEdit = () => {
    navigation.navigate('EditMantra' as never, { mantraId } as never);
  };

  const handleDelete = () => {
    dispatch(deleteMantra(mantraId));
    navigation.goBack();
  };

  return (
    <ScrollView
      style={[styles.container, { backgroundColor: theme.colors.background }]}
      contentContainerStyle={styles.content}
    >
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

      <Card>
        <Text style={[styles.mantraText, { color: theme.colors.text }]}>
          {mantra.text}
        </Text>
      </Card>

      {mantra.voiceUri && (
        <Card>
          <Text style={[styles.sectionTitle, { color: theme.colors.text }]}>
            Voice Recording
          </Text>
          <Text style={[styles.note, { color: theme.colors.textSecondary }]}>
            Audio player coming soon
          </Text>
        </Card>
      )}

      <View style={styles.actions}>
        {mantra.type === 'custom' && (
          <>
            <Button
              title="Edit Mantra"
              onPress={handleEdit}
            />
            <Button
              title="Delete Mantra"
              onPress={handleDelete}
              variant="outline"
            />
          </>
        )}
        <Button
          title="Back to Dashboard"
          onPress={() => navigation.goBack()}
          variant="secondary"
        />
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
  },
  header: {
    marginBottom: 24,
    gap: 8,
  },
  title: {
    fontSize: 32,
    fontWeight: 'bold',
  },
  badge: {
    alignSelf: 'flex-start',
    paddingHorizontal: 12,
    paddingVertical: 6,
    borderRadius: 8,
  },
  badgeText: {
    fontSize: 14,
    fontWeight: '600',
  },
  mantraText: {
    fontSize: 18,
    lineHeight: 28,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: '600',
    marginBottom: 8,
  },
  note: {
    fontSize: 14,
  },
  actions: {
    marginTop: 32,
    gap: 12,
  },
  error: {
    fontSize: 18,
    textAlign: 'center',
    marginTop: 48,
  },
});
