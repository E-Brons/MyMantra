/**
 * MyMantra - Screen Mockups
 * Aligned with app_flowchart.md requirements
 *
 * Features:
 * - OAuth login only (Google, Apple, Meta)
 * - User-defined and built-in mantras
 * - Voice recording/playback (not TTS playback)
 * - Goals (not notifications) accessible only from View Mantra screen
 * - Practice, no attachment philosophy
 * - Theme support with 6 color schemes
 */

import React, { useState } from 'react';
import {
  View,
  Text,
  ScrollView,
  TouchableOpacity,
  TextInput,
  Switch,
  StyleSheet
} from 'react-native';

// Icons (would use react-native-vector-icons or similar)
const Icon = ({ name }: { name: string }) => <Text>{name}</Text>;

// Sample theme (Lotus Purple)
const theme = {
  primary: '#8B5CF6',
  primaryLight: '#A78BFA',
  background: '#F9FAFB',
  surface: '#FFFFFF',
  text: '#111827',
  textSecondary: '#6B7280',
  border: '#E5E7EB',
};

// ==========================================
// 1. WELCOME SCREEN
// ==========================================
export const WelcomeScreen = () => (
  <View style={styles.container}>
    {/* Animated Lotus */}
    <View style={styles.lotusContainer}>
      <Text style={styles.lotusAnimation}>🪷</Text>
    </View>

    {/* Sanskrit Main Mantra */}
    <Text style={styles.sanskritText}>ॐ</Text>

    {/* Auto-proceeds after 2-3 seconds */}
  </View>
);

// ==========================================
// 2. LOGIN SCREEN
// ==========================================
export const LoginScreen = () => (
  <ScrollView style={styles.container} contentContainerStyle={styles.centerContent}>
    <Text style={styles.logo}>MyMantra</Text>
    <Text style={styles.tagline}>Practice, No Attachment</Text>

    <View style={styles.authButtons}>
      {/* OAuth Buttons */}
      <TouchableOpacity style={[styles.button, styles.googleButton]}>
        <Icon name="google" />
        <Text style={styles.buttonText}>Continue with Google</Text>
      </TouchableOpacity>

      <TouchableOpacity style={[styles.button, styles.appleButton]}>
        <Icon name="apple" />
        <Text style={styles.buttonText}>Continue with Apple</Text>
      </TouchableOpacity>

      <TouchableOpacity style={[styles.button, styles.metaButton]}>
        <Icon name="meta" />
        <Text style={styles.buttonText}>Continue with Meta</Text>
      </TouchableOpacity>
    </View>

    <TouchableOpacity>
      <Text style={styles.link}>Don't have an account? Sign Up</Text>
    </TouchableOpacity>

    <TouchableOpacity>
      <Text style={styles.link}>Compare Plans</Text>
    </TouchableOpacity>
  </ScrollView>
);

// ==========================================
// 3. REGISTRATION SCREEN
// ==========================================
export const RegisterScreen = () => (
  <ScrollView style={styles.container} contentContainerStyle={styles.centerContent}>
    <Text style={styles.logo}>Create Account</Text>

    <View style={styles.authButtons}>
      <TouchableOpacity style={[styles.button, styles.googleButton]}>
        <Icon name="google" />
        <Text style={styles.buttonText}>Sign up with Google</Text>
      </TouchableOpacity>

      <TouchableOpacity style={[styles.button, styles.appleButton]}>
        <Icon name="apple" />
        <Text style={styles.buttonText}>Sign up with Apple</Text>
      </TouchableOpacity>

      <TouchableOpacity style={[styles.button, styles.metaButton]}>
        <Icon name="meta" />
        <Text style={styles.buttonText}>Sign up with Meta</Text>
      </TouchableOpacity>
    </View>

    <View style={styles.checkbox}>
      <Switch value={false} />
      <Text style={styles.checkboxText}>I agree to Terms & Privacy Policy</Text>
    </View>

    <TouchableOpacity>
      <Text style={styles.link}>Already have an account? Login</Text>
    </TouchableOpacity>
  </ScrollView>
);

// ==========================================
// 4. PLAN SELECTION SCREEN
// ==========================================
export const PlanSelectionScreen = () => (
  <ScrollView style={styles.container}>
    <Text style={styles.title}>Choose Your Plan</Text>

    {/* Free Plan */}
    <View style={styles.planCard}>
      <Text style={styles.planName}>Free Plan</Text>
      <Text style={styles.planPrice}>$0/month</Text>
      <View style={styles.featureList}>
        <Text style={styles.feature}>✓ Unlimited user-defined mantras</Text>
        <Text style={styles.feature}>✓ Voice recording</Text>
        <Text style={styles.feature}>✓ Basic goals</Text>
        <Text style={styles.feature}>✓ Offline access</Text>
      </View>
      <TouchableOpacity style={styles.button}>
        <Text style={styles.buttonText}>Select Free</Text>
      </TouchableOpacity>
    </View>

    {/* Premium Plan */}
    <View style={[styles.planCard, styles.premiumCard]}>
      <Text style={styles.planBadge}>RECOMMENDED</Text>
      <Text style={styles.planName}>Premium Plan</Text>
      <Text style={styles.planPrice}>$4.99/month</Text>
      <View style={styles.featureList}>
        <Text style={styles.feature}>✓ Everything in Free</Text>
        <Text style={styles.feature}>✓ Text-to-speech generation</Text>
        <Text style={styles.feature}>✓ Translations</Text>
        <Text style={styles.feature}>✓ Cloud backup (Drive/iCloud)</Text>
        <Text style={styles.feature}>✓ Multi-device sync</Text>
      </View>
      <TouchableOpacity style={[styles.button, styles.premiumButton]}>
        <Text style={styles.buttonText}>Select Premium</Text>
      </TouchableOpacity>
    </View>
  </ScrollView>
);

// ==========================================
// 5. MAIN DASHBOARD SCREEN
// ==========================================
export const MainDashboardScreen = () => {
  const [searchQuery, setSearchQuery] = useState('');

  // Sample mantras
  const mantras = [
    {
      id: 1,
      title: 'Yoga Sutra I.12',
      sanskrit: 'अभ्यासवैराग्याभ्यां तन्निरोधः',
      preview: 'abhyāsa-vairāgya-ābhyāṃ...',
      category: 'Yoga',
      hasVoice: true,
    },
    {
      id: 2,
      title: 'Om Mantra',
      sanskrit: 'ॐ',
      preview: 'Om',
      category: 'Universal',
      hasVoice: false,
    },
  ];

  return (
    <View style={styles.container}>
      {/* Header */}
      <View style={styles.header}>
        <Text style={styles.logo}>MyMantra</Text>
        <TouchableOpacity>
          <Icon name="settings" />
        </TouchableOpacity>
      </View>

      {/* Search Bar */}
      <TextInput
        style={styles.searchBar}
        placeholder="Search mantras..."
        value={searchQuery}
        onChangeText={setSearchQuery}
      />

      {/* Mantra List */}
      <ScrollView style={styles.mantraList}>
        {mantras.map(mantra => (
          <TouchableOpacity key={mantra.id} style={styles.mantraCard}>
            <View style={styles.mantraHeader}>
              <Text style={styles.mantraTitle}>{mantra.title}</Text>
              {mantra.hasVoice && <Icon name="🔊" />}
            </View>
            <Text style={styles.mantraSanskrit}>{mantra.sanskrit}</Text>
            <Text style={styles.mantraPreview}>{mantra.preview}</Text>
            <View style={styles.mantraFooter}>
              <Text style={styles.mantraCategory}>{mantra.category}</Text>
              <Text style={styles.mantraDate}>Last modified: Today</Text>
            </View>
          </TouchableOpacity>
        ))}
      </ScrollView>

      {/* FAB - Add Mantra */}
      <TouchableOpacity style={styles.fab}>
        <Text style={styles.fabIcon}>+</Text>
      </TouchableOpacity>

      {/* Note: NO notification icon - follows "practice, no attachment" */}
    </View>
  );
};

// ==========================================
// 6. CREATE MANTRA SCREEN
// ==========================================
export const CreateMantraScreen = () => {
  const [mantraType, setMantraType] = useState<'custom' | 'builtin'>('custom');
  const [title, setTitle] = useState('');
  const [text, setText] = useState('');
  const [hasVoice, setHasVoice] = useState(false);

  return (
    <ScrollView style={styles.container}>
      <View style={styles.header}>
        <TouchableOpacity>
          <Text>Cancel</Text>
        </TouchableOpacity>
        <Text style={styles.headerTitle}>Create Mantra</Text>
        <TouchableOpacity>
          <Text style={styles.primaryText}>Save</Text>
        </TouchableOpacity>
      </View>

      {/* Mantra Type Toggle */}
      <View style={styles.toggleContainer}>
        <TouchableOpacity
          style={[styles.toggleButton, mantraType === 'custom' && styles.toggleActive]}
          onPress={() => setMantraType('custom')}
        >
          <Text>User-Defined</Text>
        </TouchableOpacity>
        <TouchableOpacity
          style={[styles.toggleButton, mantraType === 'builtin' && styles.toggleActive]}
          onPress={() => setMantraType('builtin')}
        >
          <Text>Built-In Library</Text>
        </TouchableOpacity>
      </View>

      {mantraType === 'custom' && (
        <>
          {/* Title Input */}
          <TextInput
            style={styles.input}
            placeholder="Mantra Title *"
            value={title}
            onChangeText={setTitle}
          />

          {/* Text Input */}
          <TextInput
            style={[styles.input, styles.textArea]}
            placeholder="Mantra Text *"
            value={text}
            onChangeText={setText}
            multiline
          />

          {/* Voice Options */}
          <View style={styles.voiceSection}>
            <Text style={styles.sectionTitle}>Voice Recording (Optional)</Text>

            <TouchableOpacity style={styles.voiceButton}>
              <Icon name="🎤" />
              <Text>Record Your Voice</Text>
            </TouchableOpacity>

            <TouchableOpacity style={styles.voiceButton}>
              <Icon name="🔊" />
              <Text>Generate with Text-to-Speech</Text>
              <Text style={styles.premiumBadge}>PREMIUM</Text>
            </TouchableOpacity>

            {hasVoice && (
              <TouchableOpacity style={styles.voiceButton}>
                <Icon name="▶️" />
                <Text>Play Preview</Text>
              </TouchableOpacity>
            )}
          </View>

          {/* Premium Features */}
          <TouchableOpacity style={styles.premiumFeature}>
            <Icon name="🌍" />
            <Text>Translate</Text>
            <Text style={styles.premiumBadge}>PREMIUM</Text>
          </TouchableOpacity>
        </>
      )}

      {/* Note: NO "Save & Set Notification" button */}
    </ScrollView>
  );
};

// ==========================================
// 7. VIEW/PLAY MANTRA SCREEN
// ==========================================
export const ViewMantraScreen = () => {
  const [isPlaying, setIsPlaying] = useState(false);

  const mantra = {
    title: 'Yoga Sutra I.12',
    sanskrit: 'अभ्यासवैराग्याभ्यां तन्निरोधः',
    transliteration: 'abhyāsa-vairāgya-ābhyāṃ tat-nirodhaḥ',
    translation: 'Through steady practice and dispassion, the mind is stilled',
    category: 'Yoga Sutras',
    created: '2024-01-15',
    modified: '2024-01-20',
    hasVoice: true,
  };

  return (
    <ScrollView style={styles.container}>
      {/* Header */}
      <View style={styles.header}>
        <TouchableOpacity>
          <Icon name="←" />
        </TouchableOpacity>
        <View style={styles.headerActions}>
          <TouchableOpacity>
            <Icon name="✏️" />
          </TouchableOpacity>
          <TouchableOpacity>
            <Icon name="🗑️" />
          </TouchableOpacity>
        </View>
      </View>

      {/* Mantra Content */}
      <View style={styles.mantraContent}>
        <Text style={styles.mantraTitle}>{mantra.title}</Text>
        <Text style={styles.mantraSanskritLarge}>{mantra.sanskrit}</Text>
        <Text style={styles.transliteration}>{mantra.transliteration}</Text>
        <Text style={styles.translation}>"{mantra.translation}"</Text>

        <View style={styles.metaInfo}>
          <Text style={styles.category}>{mantra.category}</Text>
          <Text style={styles.date}>Created: {mantra.created}</Text>
          <Text style={styles.date}>Modified: {mantra.modified}</Text>
        </View>
      </View>

      {/* Playback Controls (only if voice exists) */}
      {mantra.hasVoice && (
        <View style={styles.playbackControls}>
          <TouchableOpacity
            style={styles.playButton}
            onPress={() => setIsPlaying(!isPlaying)}
          >
            <Icon name={isPlaying ? '⏸️' : '▶️'} />
          </TouchableOpacity>
          {isPlaying && (
            <TouchableOpacity style={styles.stopButton}>
              <Icon name="⏹️" />
            </TouchableOpacity>
          )}
        </View>
      )}

      {/* Actions */}
      <View style={styles.actions}>
        <TouchableOpacity style={styles.primaryButton}>
          <Text style={styles.buttonText}>Set Goals</Text>
        </TouchableOpacity>

        <TouchableOpacity style={styles.secondaryButton}>
          <Icon name="⭐" />
          <Text>Favorite</Text>
        </TouchableOpacity>
      </View>
    </ScrollView>
  );
};

// ==========================================
// 8. GOALS SCREEN
// ==========================================
export const GoalsScreen = () => {
  const [goalsEnabled, setGoalsEnabled] = useState(true);

  const goals = [
    {
      id: 1,
      mantraTitle: 'Yoga Sutra I.12',
      time: '07:00 AM',
      days: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'],
      enabled: true,
    },
    {
      id: 2,
      mantraTitle: 'Om Mantra',
      time: '08:00 PM',
      days: ['Daily'],
      enabled: false,
    },
  ];

  return (
    <View style={styles.container}>
      {/* Header */}
      <View style={styles.header}>
        <TouchableOpacity>
          <Icon name="←" />
        </TouchableOpacity>
        <Text style={styles.headerTitle}>Goals</Text>
      </View>

      {/* Global Settings */}
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Global Settings</Text>

        <View style={styles.settingRow}>
          <Text>Enable Goals</Text>
          <Switch value={goalsEnabled} onValueChange={setGoalsEnabled} />
        </View>

        <TouchableOpacity style={styles.settingRow}>
          <Text>Notification Sound</Text>
          <Text style={styles.settingValue}>Default</Text>
        </TouchableOpacity>

        <View style={styles.settingRow}>
          <Text>Vibration</Text>
          <Switch value={true} />
        </View>
      </View>

      {/* Scheduled Goals */}
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Practice Goals</Text>

        {goals.map(goal => (
          <View key={goal.id} style={styles.goalCard}>
            <View style={styles.goalInfo}>
              <Text style={styles.goalMantra}>{goal.mantraTitle}</Text>
              <Text style={styles.goalTime}>{goal.time}</Text>
              <Text style={styles.goalDays}>{goal.days.join(', ')}</Text>
            </View>
            <View style={styles.goalActions}>
              <TouchableOpacity>
                <Icon name="✏️" />
              </TouchableOpacity>
              <TouchableOpacity>
                <Icon name="🗑️" />
              </TouchableOpacity>
              <Switch value={goal.enabled} />
            </View>
          </View>
        ))}

        {goals.length === 0 && (
          <Text style={styles.emptyState}>No practice goals set</Text>
        )}
      </View>

      <TouchableOpacity style={styles.primaryButton}>
        <Icon name="+" />
        <Text style={styles.buttonText}>Add Goal</Text>
      </TouchableOpacity>

      {/* Note: Back button goes to View Mantra, not Main Dashboard */}
    </View>
  );
};

// ==========================================
// 9. ADD/EDIT GOAL SCREEN
// ==========================================
export const AddEditGoalScreen = () => {
  const [time, setTime] = useState('07:00 AM');
  const [repeat, setRepeat] = useState<'daily' | 'weekdays' | 'weekends' | 'custom' | 'once'>('daily');
  const [customDays, setCustomDays] = useState({
    mon: false,
    tue: false,
    wed: false,
    thu: false,
    fri: false,
    sat: false,
    sun: false,
  });

  const mantra = {
    title: 'Yoga Sutra I.12',
    sanskrit: 'अभ्यासवैराग्याभ्यां तन्निरोधः',
  };

  return (
    <ScrollView style={styles.container}>
      <View style={styles.header}>
        <TouchableOpacity>
          <Text>Cancel</Text>
        </TouchableOpacity>
        <Text style={styles.headerTitle}>Add Goal</Text>
        <TouchableOpacity>
          <Text style={styles.primaryText}>Save</Text>
        </TouchableOpacity>
      </View>

      {/* Mantra Display (pre-selected, non-editable) */}
      <View style={styles.selectedMantra}>
        <Text style={styles.label}>Practice Goal For:</Text>
        <Text style={styles.mantraTitle}>{mantra.title}</Text>
        <Text style={styles.mantraSanskrit}>{mantra.sanskrit}</Text>
      </View>

      {/* Time Picker */}
      <View style={styles.formGroup}>
        <Text style={styles.label}>Time</Text>
        <TouchableOpacity style={styles.timePicker}>
          <Text>{time}</Text>
          <Icon name="🕐" />
        </TouchableOpacity>
      </View>

      {/* Repeat Options */}
      <View style={styles.formGroup}>
        <Text style={styles.label}>Repeat</Text>
        <View style={styles.repeatOptions}>
          <TouchableOpacity
            style={[styles.repeatOption, repeat === 'daily' && styles.repeatActive]}
            onPress={() => setRepeat('daily')}
          >
            <Text>Daily</Text>
          </TouchableOpacity>
          <TouchableOpacity
            style={[styles.repeatOption, repeat === 'weekdays' && styles.repeatActive]}
            onPress={() => setRepeat('weekdays')}
          >
            <Text>Weekdays</Text>
          </TouchableOpacity>
          <TouchableOpacity
            style={[styles.repeatOption, repeat === 'weekends' && styles.repeatActive]}
            onPress={() => setRepeat('weekends')}
          >
            <Text>Weekends</Text>
          </TouchableOpacity>
          <TouchableOpacity
            style={[styles.repeatOption, repeat === 'custom' && styles.repeatActive]}
            onPress={() => setRepeat('custom')}
          >
            <Text>Custom</Text>
          </TouchableOpacity>
          <TouchableOpacity
            style={[styles.repeatOption, repeat === 'once' && styles.repeatActive]}
            onPress={() => setRepeat('once')}
          >
            <Text>Once</Text>
          </TouchableOpacity>
        </View>
      </View>

      {/* Custom Day Selector */}
      {repeat === 'custom' && (
        <View style={styles.formGroup}>
          <Text style={styles.label}>Select Days</Text>
          <View style={styles.daySelector}>
            {Object.keys(customDays).map(day => (
              <TouchableOpacity
                key={day}
                style={[styles.dayButton, customDays[day] && styles.dayActive]}
                onPress={() => setCustomDays({ ...customDays, [day]: !customDays[day] })}
              >
                <Text>{day.toUpperCase().slice(0, 3)}</Text>
              </TouchableOpacity>
            ))}
          </View>
        </View>
      )}
    </ScrollView>
  );
};

// ==========================================
// 10. SETTINGS SCREEN
// ==========================================
export const SettingsScreen = () => {
  return (
    <ScrollView style={styles.container}>
      <View style={styles.header}>
        <TouchableOpacity>
          <Icon name="←" />
        </TouchableOpacity>
        <Text style={styles.headerTitle}>Settings</Text>
      </View>

      {/* Account Section */}
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Account</Text>
        <Text style={styles.userEmail}>user@gmail.com</Text>
        <Text style={styles.authProvider}>Signed in with Google</Text>
        <TouchableOpacity style={styles.settingRow}>
          <Text>Logout</Text>
          <Icon name="→" />
        </TouchableOpacity>
      </View>

      {/* Plan & Billing */}
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Plan & Billing</Text>
        <View style={styles.planInfo}>
          <Text style={styles.currentPlan}>Free Plan</Text>
          <TouchableOpacity style={styles.upgradeButton}>
            <Text>Upgrade to Premium</Text>
          </TouchableOpacity>
        </View>
        <TouchableOpacity style={styles.settingRow}>
          <Text>Plan Selection</Text>
          <Icon name="→" />
        </TouchableOpacity>
        <TouchableOpacity style={styles.settingRow}>
          <Text>Compare Plans</Text>
          <Icon name="→" />
        </TouchableOpacity>
      </View>

      {/* Data */}
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Data</Text>
        <TouchableOpacity style={styles.settingRow}>
          <Text>Backup to Drive/iCloud</Text>
          <Text style={styles.premiumBadge}>PREMIUM</Text>
        </TouchableOpacity>
        <TouchableOpacity style={styles.settingRow}>
          <Text>Restore from Drive/iCloud</Text>
          <Text style={styles.premiumBadge}>PREMIUM</Text>
        </TouchableOpacity>
        <TouchableOpacity style={styles.settingRow}>
          <Text style={styles.dangerText}>Delete All Data</Text>
        </TouchableOpacity>
      </View>

      {/* Preferences */}
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Preferences</Text>
        <TouchableOpacity style={styles.settingRow}>
          <Text>Language</Text>
          <Text style={styles.settingValue}>English</Text>
        </TouchableOpacity>
        <TouchableOpacity style={styles.settingRow}>
          <Text>Theme</Text>
          <Text style={styles.settingValue}>Lotus Purple</Text>
        </TouchableOpacity>
        <TouchableOpacity style={styles.settingRow}>
          <Text>App Theme</Text>
          <Text style={styles.settingValue}>Auto</Text>
        </TouchableOpacity>
      </View>

      {/* App Info */}
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>App Info</Text>
        <TouchableOpacity style={styles.settingRow}>
          <Text>About</Text>
          <Icon name="→" />
        </TouchableOpacity>
        <TouchableOpacity style={styles.settingRow}>
          <Text>Privacy Policy</Text>
          <Icon name="→" />
        </TouchableOpacity>
        <TouchableOpacity style={styles.settingRow}>
          <Text>Terms of Service</Text>
          <Icon name="→" />
        </TouchableOpacity>
        <Text style={styles.version}>Version 1.0.0</Text>
      </View>
    </ScrollView>
  );
};

// ==========================================
// 11. THEME SELECTION SCREEN (NEW!)
// ==========================================
export const ThemeSelectionScreen = () => {
  const [selectedTheme, setSelectedTheme] = useState('lotusPurple');

  const themes = [
    { id: 'lotusPurple', name: 'Lotus Purple', primary: '#8B5CF6', secondary: '#6366F1' },
    { id: 'sacredBlue', name: 'Sacred Blue', primary: '#3B82F6', secondary: '#0EA5E9' },
    { id: 'earthTones', name: 'Earth Tones', primary: '#D97706', secondary: '#059669' },
    { id: 'sunsetRose', name: 'Sunset Rose', primary: '#EC4899', secondary: '#F59E0B' },
    { id: 'zenGreen', name: 'Zen Green', primary: '#059669', secondary: '#0D9488' },
    { id: 'oceanDepths', name: 'Ocean Depths', primary: '#0891B2', secondary: '#6366F1' },
  ];

  return (
    <View style={styles.container}>
      <View style={styles.header}>
        <TouchableOpacity>
          <Icon name="←" />
        </TouchableOpacity>
        <Text style={styles.headerTitle}>Choose Theme</Text>
      </View>

      <ScrollView>
        {themes.map(theme => (
          <TouchableOpacity
            key={theme.id}
            style={[styles.themeCard, selectedTheme === theme.id && styles.themeCardSelected]}
            onPress={() => setSelectedTheme(theme.id)}
          >
            <View style={styles.themeColors}>
              <View style={[styles.colorCircle, { backgroundColor: theme.primary }]} />
              <View style={[styles.colorCircle, { backgroundColor: theme.secondary }]} />
            </View>
            <Text style={styles.themeName}>{theme.name}</Text>
            {selectedTheme === theme.id && <Icon name="✓" />}
          </TouchableOpacity>
        ))}
      </ScrollView>
    </View>
  );
};

// ==========================================
// STYLES
// ==========================================
const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: theme.background,
  },
  centerContent: {
    alignItems: 'center',
    justifyContent: 'center',
    padding: 24,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    padding: 16,
    borderBottomWidth: 1,
    borderBottomColor: theme.border,
  },
  headerTitle: {
    fontSize: 18,
    fontWeight: '600',
    color: theme.text,
  },
  headerActions: {
    flexDirection: 'row',
    gap: 16,
  },
  logo: {
    fontSize: 32,
    fontWeight: 'bold',
    color: theme.text,
  },
  tagline: {
    fontSize: 16,
    color: theme.textSecondary,
    marginTop: 8,
  },
  lotusContainer: {
    alignItems: 'center',
    justifyContent: 'center',
  },
  lotusAnimation: {
    fontSize: 120,
  },
  sanskritText: {
    fontSize: 60,
    marginTop: 32,
  },
  button: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    padding: 16,
    borderRadius: 12,
    marginVertical: 8,
    width: '100%',
  },
  buttonText: {
    fontSize: 16,
    fontWeight: '600',
    marginLeft: 8,
  },
  primaryButton: {
    backgroundColor: theme.primary,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    padding: 16,
    borderRadius: 12,
    marginVertical: 8,
  },
  secondaryButton: {
    backgroundColor: theme.surface,
    borderWidth: 1,
    borderColor: theme.border,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    padding: 16,
    borderRadius: 12,
    marginVertical: 8,
  },
  googleButton: {
    backgroundColor: '#FFFFFF',
    borderWidth: 1,
    borderColor: theme.border,
  },
  appleButton: {
    backgroundColor: '#000000',
  },
  metaButton: {
    backgroundColor: '#1877F2',
  },
  authButtons: {
    width: '100%',
    marginVertical: 24,
  },
  link: {
    color: theme.primary,
    marginTop: 16,
  },
  checkbox: {
    flexDirection: 'row',
    alignItems: 'center',
    marginVertical: 16,
  },
  checkboxText: {
    marginLeft: 8,
    color: theme.textSecondary,
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    color: theme.text,
    padding: 16,
  },
  planCard: {
    backgroundColor: theme.surface,
    borderRadius: 16,
    padding: 24,
    margin: 16,
    borderWidth: 1,
    borderColor: theme.border,
  },
  premiumCard: {
    borderColor: theme.primary,
    borderWidth: 2,
  },
  planBadge: {
    backgroundColor: theme.primary,
    color: '#FFFFFF',
    paddingHorizontal: 12,
    paddingVertical: 4,
    borderRadius: 12,
    fontSize: 12,
    fontWeight: 'bold',
    alignSelf: 'flex-start',
    marginBottom: 8,
  },
  planName: {
    fontSize: 24,
    fontWeight: 'bold',
    color: theme.text,
  },
  planPrice: {
    fontSize: 18,
    color: theme.textSecondary,
    marginVertical: 8,
  },
  featureList: {
    marginVertical: 16,
  },
  feature: {
    fontSize: 14,
    color: theme.text,
    marginVertical: 4,
  },
  searchBar: {
    backgroundColor: theme.surface,
    borderRadius: 12,
    padding: 12,
    margin: 16,
    borderWidth: 1,
    borderColor: theme.border,
  },
  mantraList: {
    flex: 1,
  },
  mantraCard: {
    backgroundColor: theme.surface,
    borderRadius: 12,
    padding: 16,
    marginHorizontal: 16,
    marginVertical: 8,
    borderWidth: 1,
    borderColor: theme.border,
  },
  mantraHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  mantraTitle: {
    fontSize: 16,
    fontWeight: '600',
    color: theme.text,
  },
  mantraSanskrit: {
    fontSize: 24,
    color: theme.primary,
    marginVertical: 8,
  },
  mantraSanskritLarge: {
    fontSize: 36,
    color: theme.primary,
    marginVertical: 16,
    textAlign: 'center',
  },
  mantraPreview: {
    fontSize: 14,
    color: theme.textSecondary,
    fontStyle: 'italic',
  },
  mantraFooter: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginTop: 8,
  },
  mantraCategory: {
    fontSize: 12,
    color: theme.textSecondary,
  },
  mantraDate: {
    fontSize: 12,
    color: theme.textLight,
  },
  fab: {
    position: 'absolute',
    bottom: 24,
    right: 24,
    width: 56,
    height: 56,
    borderRadius: 28,
    backgroundColor: theme.primary,
    alignItems: 'center',
    justifyContent: 'center',
    elevation: 4,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.3,
    shadowRadius: 4,
  },
  fabIcon: {
    fontSize: 32,
    color: '#FFFFFF',
  },
  input: {
    backgroundColor: theme.surface,
    borderRadius: 12,
    padding: 12,
    margin: 16,
    borderWidth: 1,
    borderColor: theme.border,
    fontSize: 16,
  },
  textArea: {
    minHeight: 120,
    textAlignVertical: 'top',
  },
  toggleContainer: {
    flexDirection: 'row',
    margin: 16,
    backgroundColor: theme.surfaceLight,
    borderRadius: 12,
    padding: 4,
  },
  toggleButton: {
    flex: 1,
    padding: 12,
    alignItems: 'center',
    borderRadius: 8,
  },
  toggleActive: {
    backgroundColor: theme.primary,
  },
  section: {
    padding: 16,
    borderBottomWidth: 1,
    borderBottomColor: theme.border,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: '600',
    color: theme.text,
    marginBottom: 12,
  },
  settingRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingVertical: 12,
  },
  settingValue: {
    color: theme.textSecondary,
  },
  voiceSection: {
    margin: 16,
  },
  voiceButton: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: theme.surface,
    borderRadius: 12,
    padding: 16,
    marginVertical: 8,
    borderWidth: 1,
    borderColor: theme.border,
  },
  premiumBadge: {
    backgroundColor: theme.primary,
    color: '#FFFFFF',
    paddingHorizontal: 8,
    paddingVertical: 2,
    borderRadius: 8,
    fontSize: 10,
    fontWeight: 'bold',
    marginLeft: 8,
  },
  premiumFeature: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: theme.surface,
    borderRadius: 12,
    padding: 16,
    marginHorizontal: 16,
    marginVertical: 8,
    borderWidth: 1,
    borderColor: theme.border,
  },
  mantraContent: {
    padding: 24,
  },
  transliteration: {
    fontSize: 14,
    color: theme.textSecondary,
    fontStyle: 'italic',
    textAlign: 'center',
    marginVertical: 8,
  },
  translation: {
    fontSize: 16,
    color: theme.text,
    textAlign: 'center',
    marginVertical: 16,
  },
  metaInfo: {
    marginTop: 24,
    paddingTop: 16,
    borderTopWidth: 1,
    borderTopColor: theme.border,
  },
  category: {
    fontSize: 14,
    color: theme.primary,
    marginVertical: 4,
  },
  date: {
    fontSize: 12,
    color: theme.textSecondary,
    marginVertical: 2,
  },
  playbackControls: {
    flexDirection: 'row',
    justifyContent: 'center',
    alignItems: 'center',
    marginVertical: 24,
  },
  playButton: {
    width: 64,
    height: 64,
    borderRadius: 32,
    backgroundColor: theme.primary,
    alignItems: 'center',
    justifyContent: 'center',
    marginHorizontal: 8,
  },
  stopButton: {
    width: 48,
    height: 48,
    borderRadius: 24,
    backgroundColor: theme.textSecondary,
    alignItems: 'center',
    justifyContent: 'center',
    marginHorizontal: 8,
  },
  actions: {
    padding: 16,
  },
  goalCard: {
    flexDirection: 'row',
    backgroundColor: theme.surface,
    borderRadius: 12,
    padding: 16,
    marginVertical: 8,
    borderWidth: 1,
    borderColor: theme.border,
  },
  goalInfo: {
    flex: 1,
  },
  goalMantra: {
    fontSize: 16,
    fontWeight: '600',
    color: theme.text,
  },
  goalTime: {
    fontSize: 14,
    color: theme.textSecondary,
    marginTop: 4,
  },
  goalDays: {
    fontSize: 12,
    color: theme.textLight,
    marginTop: 2,
  },
  goalActions: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 12,
  },
  emptyState: {
    textAlign: 'center',
    color: theme.textSecondary,
    padding: 32,
  },
  selectedMantra: {
    backgroundColor: theme.surfaceLight,
    borderRadius: 12,
    padding: 16,
    margin: 16,
  },
  label: {
    fontSize: 14,
    fontWeight: '600',
    color: theme.textSecondary,
    marginBottom: 8,
  },
  formGroup: {
    margin: 16,
  },
  timePicker: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    backgroundColor: theme.surface,
    borderRadius: 12,
    padding: 16,
    borderWidth: 1,
    borderColor: theme.border,
  },
  repeatOptions: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 8,
  },
  repeatOption: {
    paddingHorizontal: 16,
    paddingVertical: 8,
    borderRadius: 8,
    backgroundColor: theme.surface,
    borderWidth: 1,
    borderColor: theme.border,
  },
  repeatActive: {
    backgroundColor: theme.primary,
    borderColor: theme.primary,
  },
  daySelector: {
    flexDirection: 'row',
    gap: 8,
  },
  dayButton: {
    flex: 1,
    aspectRatio: 1,
    alignItems: 'center',
    justifyContent: 'center',
    borderRadius: 8,
    backgroundColor: theme.surface,
    borderWidth: 1,
    borderColor: theme.border,
  },
  dayActive: {
    backgroundColor: theme.primary,
    borderColor: theme.primary,
  },
  userEmail: {
    fontSize: 16,
    color: theme.text,
    marginBottom: 4,
  },
  authProvider: {
    fontSize: 14,
    color: theme.textSecondary,
    marginBottom: 16,
  },
  planInfo: {
    marginVertical: 8,
  },
  currentPlan: {
    fontSize: 16,
    fontWeight: '600',
    color: theme.text,
  },
  upgradeButton: {
    backgroundColor: theme.primary,
    padding: 12,
    borderRadius: 8,
    marginTop: 8,
    alignItems: 'center',
  },
  dangerText: {
    color: '#EF4444',
  },
  version: {
    fontSize: 12,
    color: theme.textLight,
    textAlign: 'center',
    marginTop: 16,
  },
  primaryText: {
    color: theme.primary,
    fontWeight: '600',
  },
  themeCard: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: theme.surface,
    borderRadius: 12,
    padding: 16,
    marginHorizontal: 16,
    marginVertical: 8,
    borderWidth: 1,
    borderColor: theme.border,
  },
  themeCardSelected: {
    borderColor: theme.primary,
    borderWidth: 2,
  },
  themeColors: {
    flexDirection: 'row',
    gap: 8,
    marginRight: 16,
  },
  colorCircle: {
    width: 32,
    height: 32,
    borderRadius: 16,
  },
  themeName: {
    flex: 1,
    fontSize: 16,
    fontWeight: '500',
    color: theme.text,
  },
});

export default {
  WelcomeScreen,
  LoginScreen,
  RegisterScreen,
  PlanSelectionScreen,
  MainDashboardScreen,
  CreateMantraScreen,
  ViewMantraScreen,
  GoalsScreen,
  AddEditGoalScreen,
  SettingsScreen,
  ThemeSelectionScreen,
};
