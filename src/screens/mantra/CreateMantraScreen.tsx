import React, { useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  KeyboardAvoidingView,
  Platform,
} from 'react-native';
import { useNavigation } from '@react-navigation/native';
import { useTheme } from '../../theme';
import { useAppDispatch } from '../../store';
import { Input, Button } from '../../components/common';
import { addMantra } from '../../store/slices/mantrasSlice';
import { Mantra } from '../../types';

export const CreateMantraScreen: React.FC = () => {
  const navigation = useNavigation();
  const { theme } = useTheme();
  const dispatch = useAppDispatch();

  const [title, setTitle] = useState('');
  const [text, setText] = useState('');
  const [category, setCategory] = useState('');
  const [errors, setErrors] = useState<{ title?: string; text?: string }>({});

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
    if (!validate()) return;

    const newMantra: Mantra = {
      id: `mantra-${Date.now()}`,
      userId: 'demo-user-123',
      type: 'custom',
      title: title.trim(),
      text: text.trim(),
      category: category.trim() || undefined,
      isFavorite: false,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
    };

    dispatch(addMantra(newMantra));
    navigation.goBack();
  };

  const handleCancel = () => {
    navigation.goBack();
  };

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
            Create New Mantra
          </Text>
          <Text style={[styles.subtitle, { color: theme.colors.textSecondary }]}>
            Add a mantra to your practice
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

          <View style={styles.voiceSection}>
            <Text style={[styles.voiceLabel, { color: theme.colors.text }]}>
              Voice Recording
            </Text>
            <Text style={[styles.voiceNote, { color: theme.colors.textSecondary }]}>
              Voice recording feature coming soon
            </Text>
          </View>
        </View>

        <View style={styles.actions}>
          <Button
            title="Save Mantra"
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
    marginBottom: 8,
  },
  subtitle: {
    fontSize: 16,
  },
  form: {
    marginBottom: 32,
  },
  textArea: {
    height: 120,
    textAlignVertical: 'top',
  },
  voiceSection: {
    marginTop: 16,
    padding: 16,
    borderRadius: 12,
    backgroundColor: 'rgba(0,0,0,0.02)',
  },
  voiceLabel: {
    fontSize: 16,
    fontWeight: '600',
    marginBottom: 4,
  },
  voiceNote: {
    fontSize: 14,
  },
  actions: {
    gap: 12,
  },
});
