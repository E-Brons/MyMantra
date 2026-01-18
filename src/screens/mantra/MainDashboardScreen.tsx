import React, { useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  FlatList,
} from 'react-native';
import { useNavigation } from '@react-navigation/native';
import { useTheme } from '../../theme';
import { useAppSelector, useAppDispatch } from '../../store';
import { MantraCard } from '../../components/mantra/MantraCard';
import { Input } from '../../components/common';
import { BUILT_IN_MANTRAS } from '../../constants/builtInMantras';
import { addMantra } from '../../store/slices/mantrasSlice';
import { Mantra } from '../../types';

export const MainDashboardScreen: React.FC = () => {
  const navigation = useNavigation();
  const { theme } = useTheme();
  const dispatch = useAppDispatch();
  const { mantras } = useAppSelector(state => state.mantras);
  const { user } = useAppSelector(state => state.auth);
  const [searchQuery, setSearchQuery] = useState('');

  // Initialize with built-in mantras if empty
  React.useEffect(() => {
    if (mantras.length === 0) {
      BUILT_IN_MANTRAS.forEach(builtIn => {
        const mantra: Mantra = {
          id: builtIn.id,
          userId: 'system',
          type: 'builtin',
          title: builtIn.title,
          sanskrit: builtIn.sanskrit,
          text: builtIn.text,
          transliteration: builtIn.transliteration,
          translation: builtIn.translation,
          category: builtIn.category,
          isFavorite: false,
          createdAt: new Date().toISOString(),
          updatedAt: new Date().toISOString(),
        };
        dispatch(addMantra(mantra));
      });
    }
  }, [dispatch, mantras.length]);

  const filteredMantras = mantras.filter(mantra =>
    mantra.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
    mantra.text?.toLowerCase().includes(searchQuery.toLowerCase())
  );

  const handleMantraPress = (mantraId: string) => {
    navigation.navigate('ViewMantra' as never, { mantraId } as never);
  };

  const handleCreateMantra = () => {
    navigation.navigate('CreateMantra' as never);
  };

  return (
    <View style={[styles.container, { backgroundColor: theme.colors.background }]}>
      {/* Header */}
      <View style={styles.header}>
        <Text style={[styles.greeting, { color: theme.colors.text }]}>
          Namaste, {user?.name || 'Practitioner'}
        </Text>
        <Text style={[styles.subtitle, { color: theme.colors.textSecondary }]}>
          Your spiritual practice awaits
        </Text>
      </View>

      {/* Search */}
      <View style={styles.searchContainer}>
        <Input
          placeholder="Search mantras..."
          value={searchQuery}
          onChangeText={setSearchQuery}
        />
      </View>

      {/* Mantras List */}
      <FlatList
        data={filteredMantras}
        keyExtractor={(item) => item.id}
        renderItem={({ item }) => (
          <MantraCard
            mantra={item}
            onPress={() => handleMantraPress(item.id)}
          />
        )}
        contentContainerStyle={styles.listContent}
        ListEmptyComponent={
          <View style={styles.emptyState}>
            <Text style={[styles.emptyText, { color: theme.colors.textSecondary }]}>
              No mantras yet. Create your first one!
            </Text>
          </View>
        }
      />

      {/* FAB */}
      <TouchableOpacity
        style={[styles.fab, { backgroundColor: theme.colors.primary }]}
        onPress={handleCreateMantra}
        activeOpacity={0.8}
      >
        <Text style={styles.fabIcon}>+</Text>
      </TouchableOpacity>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  header: {
    padding: 24,
    paddingBottom: 16,
  },
  greeting: {
    fontSize: 28,
    fontWeight: 'bold',
    marginBottom: 4,
  },
  subtitle: {
    fontSize: 16,
  },
  searchContainer: {
    paddingHorizontal: 24,
    paddingBottom: 8,
  },
  listContent: {
    paddingHorizontal: 24,
    paddingBottom: 100,
  },
  emptyState: {
    padding: 48,
    alignItems: 'center',
  },
  emptyText: {
    fontSize: 16,
    textAlign: 'center',
  },
  fab: {
    position: 'absolute',
    right: 24,
    bottom: 24,
    width: 64,
    height: 64,
    borderRadius: 32,
    alignItems: 'center',
    justifyContent: 'center',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.3,
    shadowRadius: 8,
    elevation: 8,
  },
  fabIcon: {
    color: '#fff',
    fontSize: 32,
    fontWeight: '300',
  },
});
