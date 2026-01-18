import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  KeyboardAvoidingView,
  Platform,
} from 'react-native';
import { useRoute, useNavigation } from '@react-navigation/native';
import { useTheme } from '../../theme';
import { useAppDispatch, useAppSelector } from '../../store';
import { Input, Button } from '../../components/common';
import { updateMantra } from '../../store/slices/mantrasSlice';

export const EditMantraScreen: React.FC = () => {
  const route = useRoute();
  const navigation = useNavigation();
  const { theme } = useTheme();
  const dispatch = useAppDispatch();
  const { mantraId } = (route.params as { mantraId: string }) || {};

  const mantra = useAppSelector(state =>
    state.mantras.mantras.find(m => m.id === mantraId)
  );

  const [title, setTitle] = useState('');
  const [text, setText] = useState('');
  const [category, setCategory] = useState('');
  const [errors, setErrors] = useState<{ title?: string; text?: string }>({});

  useEffect(() => {
    if (mantra) {
      setTitle(mantra.title);
      setText(mantra.text || '');
      setCategory(mantra.category || '');
    }
  }, [mantra]);

  const validate = (): boolean => {
    const newErrors: { title?: string; text?: string } = {};

    if (!title.trim()) {
      newErrors.title = 'Title is required';
    }

    if (!text.trim()) {
      newErrors.text = 'Mantra text is required';
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSave = () => {
    if (!validate() || !mantra) return;

    const updatedMantra: Mantra = {
      ...mantra,
      title: title.trim(),
      text: text.trim(),
      category: category.trim() || undefined,
      updatedAt: new Date().toISOString(),
    };

    dispatch(updateMantra(updatedMantra));
    navigation.goBack();
  };

  const handleCancel = () => {
    navigation.goBack();
  };

  if (!mantra) {
    return (
      <View style={[styles.container, { backgroundColor: theme.colors.background }]}>
        <Text style={[styles.error, { color: theme.colors.error }]}>
          Mantra not found
        </Text>
      </View>
    );
  }

  return (
    <KeyboardAvoidingView
      style={[styles.container, { backgroundColor: theme.colors.background }]}
      behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
    >
      <ScrollView
        contentContainerStyle={styles.content}
        keyboardShouldPersistTaps="handled"
      >
        <View style={styles.header}>
          <Text style={[styles.title, { color: theme.colors.text }]}>
            Edit Mantra
          </Text>
        </View>

        <View style={styles.form}>
          <Input
            label="Title *"
            placeholder="Enter mantra title"
            value={title}
            onChangeText={setTitle}
            error={errors.title}
          />

          <Input
            label="Mantra Text *"
            placeholder="Enter mantra text"
            value={text}
            onChangeText={setText}
            multiline
            numberOfLines={4}
            style={styles.textArea}
            error={errors.text}
          />

          <Input
            label="Category (Optional)"
            placeholder="e.g., Peace, Healing, Gratitude"
            value={category}
            onChangeText={setCategory}
          />
        </View>

        <View style={styles.actions}>
          <Button
            title="Save Changes"
            onPress={handleSave}
          />
          <Button
            title="Cancel"
            onPress={handleCancel}
            variant="outline"
          />
        </View>
      </ScrollView>
    </KeyboardAvoidingView>
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
    marginBottom: 32,
  },
  title: {
    fontSize: 28,
    fontWeight: 'bold',
  },
  form: {
    marginBottom: 32,
  },
  textArea: {
    height: 120,
    textAlignVertical: 'top',
  },
  actions: {
    gap: 12,
  },
  error: {
    fontSize: 18,
    textAlign: 'center',
    marginTop: 48,
  },
});
