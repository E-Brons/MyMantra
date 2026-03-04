import React, { useState } from 'react';
import {
  Sun,
  Moon,
  Monitor,
  Bell,
  Vibrate,
  Hash,
  Info,
  ChevronRight,
  Download,
  Upload,
  Trash2,
  Heart,
} from 'lucide-react';
import { useApp } from '../context/AppContext';
import { motion, AnimatePresence } from 'motion/react';

function SettingRow({
  icon,
  label,
  description,
  children,
  danger,
}: {
  icon: React.ReactNode;
  label: string;
  description?: string;
  children: React.ReactNode;
  danger?: boolean;
}) {
  return (
    <div className="flex items-center gap-4 py-4">
      <div
        className={`w-9 h-9 rounded-xl flex items-center justify-center shrink-0 ${
          danger ? 'bg-red-900/30' : 'bg-violet-900/30'
        }`}
      >
        <span className={danger ? 'text-red-400' : 'text-violet-400'}>{icon}</span>
      </div>
      <div className="flex-1 min-w-0">
        <p
          className={danger ? 'text-red-400' : 'text-foreground'}
          style={{ fontSize: '15px', fontWeight: 500 }}
        >
          {label}
        </p>
        {description && (
          <p className="text-muted-foreground" style={{ fontSize: '12px' }}>
            {description}
          </p>
        )}
      </div>
      {children}
    </div>
  );
}

function Toggle({
  enabled,
  onChange,
}: {
  enabled: boolean;
  onChange: (v: boolean) => void;
}) {
  return (
    <button
      onClick={() => onChange(!enabled)}
      className={`w-12 h-7 rounded-full relative transition-all duration-200 shrink-0 ${
        enabled ? 'bg-violet-500' : 'bg-muted'
      }`}
    >
      <div
        className={`absolute top-1.5 w-4 h-4 rounded-full bg-white shadow transition-all duration-200 ${
          enabled ? 'left-7' : 'left-1.5'
        }`}
      />
    </button>
  );
}

function Section({
  title,
  children,
}: {
  title: string;
  children: React.ReactNode;
}) {
  return (
    <div className="mb-6">
      <p
        className="text-muted-foreground px-4 mb-1"
        style={{ fontSize: '12px', fontWeight: 600, textTransform: 'uppercase', letterSpacing: '0.08em' }}
      >
        {title}
      </p>
      <div
        className="mx-4 rounded-2xl overflow-hidden"
        style={{ border: '1px solid rgba(139,92,246,0.15)', background: 'rgba(139,92,246,0.04)' }}
      >
        <div className="divide-y divide-white/5 px-4">{children}</div>
      </div>
    </div>
  );
}

function ClearDataModal({
  onConfirm,
  onCancel,
}: {
  onConfirm: () => void;
  onCancel: () => void;
}) {
  return (
    <motion.div
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      exit={{ opacity: 0 }}
      className="fixed inset-0 z-50 flex items-center justify-center p-6"
      style={{ background: 'rgba(0,0,0,0.7)', backdropFilter: 'blur(4px)' }}
    >
      <motion.div
        initial={{ scale: 0.9 }}
        animate={{ scale: 1 }}
        exit={{ scale: 0.9 }}
        className="w-full max-w-sm rounded-3xl p-6"
        style={{ background: '#0d0b1a', border: '1px solid rgba(239,68,68,0.3)' }}
      >
        <div className="text-center mb-6">
          <div className="text-4xl mb-3">⚠️</div>
          <h3 className="text-foreground mb-2" style={{ fontSize: '18px', fontWeight: 600 }}>
            Clear All Data
          </h3>
          <p className="text-muted-foreground" style={{ fontSize: '14px' }}>
            This will permanently delete all your mantras, sessions, and progress. This cannot be undone.
          </p>
        </div>
        <div className="flex gap-3">
          <button
            onClick={onCancel}
            className="flex-1 py-3 rounded-xl text-foreground"
            style={{ border: '1px solid rgba(139,92,246,0.2)', fontSize: '14px' }}
          >
            Cancel
          </button>
          <button
            onClick={onConfirm}
            className="flex-1 py-3 rounded-xl text-white"
            style={{ background: '#dc2626', fontSize: '14px' }}
          >
            Delete All
          </button>
        </div>
      </motion.div>
    </motion.div>
  );
}

export function Settings() {
  const { settings, updateSettings, mantras, sessions, progress } = useApp();
  const [showClearConfirm, setShowClearConfirm] = useState(false);
  const [repsInput, setRepsInput] = useState(String(settings.defaultRepetitions));

  const themeOptions: { value: typeof settings.theme; icon: React.ReactNode; label: string }[] = [
    { value: 'light', icon: <Sun size={14} />, label: 'Light' },
    { value: 'dark', icon: <Moon size={14} />, label: 'Dark' },
    { value: 'system', icon: <Monitor size={14} />, label: 'System' },
  ];

  const fontOptions: { value: typeof settings.fontSize; label: string }[] = [
    { value: 'small', label: 'S' },
    { value: 'medium', label: 'M' },
    { value: 'large', label: 'L' },
  ];

  const handleExport = () => {
    const data = { mantras, sessions, progress, settings, exportedAt: new Date().toISOString() };
    const blob = new Blob([JSON.stringify(data, null, 2)], { type: 'application/json' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `mymantra-backup-${new Date().toISOString().split('T')[0]}.json`;
    a.click();
    URL.revokeObjectURL(url);
  };

  const handleClearData = () => {
    localStorage.removeItem('mymantra_state');
    window.location.reload();
  };

  return (
    <div className="flex flex-col min-h-full">
      {/* Header */}
      <div
        className="px-5 pt-12 pb-5"
        style={{ background: 'linear-gradient(180deg, rgba(139,92,246,0.12) 0%, transparent 100%)' }}
      >
        <h1
          className="text-foreground"
          style={{ fontFamily: "'Cinzel', serif", fontSize: '22px', fontWeight: 600 }}
        >
          Settings
        </h1>
        <p className="text-muted-foreground" style={{ fontSize: '13px' }}>
          Customize your practice
        </p>
      </div>

      <div className="flex-1 overflow-y-auto pb-6">
        {/* Appearance */}
        <Section title="Appearance">
          <SettingRow
            icon={<Moon size={16} />}
            label="Theme"
            description="Choose your preferred color theme"
          >
            <div
              className="flex rounded-xl overflow-hidden"
              style={{ border: '1px solid rgba(139,92,246,0.2)' }}
            >
              {themeOptions.map(({ value, icon, label }) => (
                <button
                  key={value}
                  onClick={() => updateSettings({ theme: value })}
                  className={`flex items-center gap-1.5 px-2.5 py-1.5 transition-all ${
                    settings.theme === value
                      ? 'text-white bg-violet-600'
                      : 'text-muted-foreground'
                  }`}
                  style={{ fontSize: '12px' }}
                >
                  {icon}
                  {label}
                </button>
              ))}
            </div>
          </SettingRow>

          <SettingRow
            icon={<span style={{ fontSize: '14px' }}>Aa</span>}
            label="Font Size"
            description="Adjust text size for readability"
          >
            <div
              className="flex rounded-xl overflow-hidden"
              style={{ border: '1px solid rgba(139,92,246,0.2)' }}
            >
              {fontOptions.map(({ value, label }) => (
                <button
                  key={value}
                  onClick={() => updateSettings({ fontSize: value })}
                  className={`px-3 py-1.5 transition-all ${
                    settings.fontSize === value
                      ? 'text-white bg-violet-600'
                      : 'text-muted-foreground'
                  }`}
                  style={{ fontSize: '13px', fontWeight: 600 }}
                >
                  {label}
                </button>
              ))}
            </div>
          </SettingRow>
        </Section>

        {/* Notifications */}
        <Section title="Notifications">
          <SettingRow
            icon={<Bell size={16} />}
            label="Enable Notifications"
            description="Reminders for daily practice"
          >
            <Toggle
              enabled={settings.notificationsEnabled}
              onChange={(v) => updateSettings({ notificationsEnabled: v })}
            />
          </SettingRow>

          <SettingRow
            icon={<Vibrate size={16} />}
            label="Vibration"
            description="Haptic feedback during sessions"
          >
            <Toggle
              enabled={settings.vibrationEnabled}
              onChange={(v) => updateSettings({ vibrationEnabled: v })}
            />
          </SettingRow>
        </Section>

        {/* Practice Defaults */}
        <Section title="Practice Defaults">
          <SettingRow
            icon={<Hash size={16} />}
            label="Default Repetitions"
            description="Used when creating new mantras"
          >
            <input
              type="number"
              min={1}
              max={10000}
              value={repsInput}
              onChange={(e) => setRepsInput(e.target.value)}
              onBlur={() => {
                const val = parseInt(repsInput);
                if (!isNaN(val) && val >= 1 && val <= 10000) {
                  updateSettings({ defaultRepetitions: val });
                } else {
                  setRepsInput(String(settings.defaultRepetitions));
                }
              }}
              className="w-20 text-center px-3 py-1.5 rounded-xl text-foreground outline-none"
              style={{
                background: 'rgba(139,92,246,0.08)',
                border: '1px solid rgba(139,92,246,0.25)',
                fontSize: '15px',
                fontWeight: 600,
              }}
            />
          </SettingRow>
        </Section>

        {/* Data */}
        <Section title="Data">
          <SettingRow
            icon={<Download size={16} />}
            label="Export Data"
            description="Download all your data as JSON"
          >
            <button
              onClick={handleExport}
              className="flex items-center gap-1.5 px-3 py-1.5 rounded-xl text-violet-400"
              style={{ fontSize: '13px', border: '1px solid rgba(139,92,246,0.2)' }}
            >
              Export
              <ChevronRight size={14} />
            </button>
          </SettingRow>
        </Section>

        {/* About */}
        <Section title="About">
          <SettingRow
            icon={<Info size={16} />}
            label="Version"
            description="MyMantra — Your spiritual practice companion"
          >
            <span className="text-muted-foreground" style={{ fontSize: '13px' }}>1.0.0</span>
          </SettingRow>

          <SettingRow
            icon={<Heart size={16} />}
            label="Philosophy"
            description={`"abhyāsa-vairāgya-ābhyāṃ tat-nirodhaḥ"`}
          >
            <span className="text-violet-400" style={{ fontSize: '11px' }}>YS I.12</span>
          </SettingRow>
        </Section>

        {/* Danger zone */}
        <Section title="Danger Zone">
          <SettingRow
            icon={<Trash2 size={16} />}
            label="Clear All Data"
            description="Permanently delete all mantras and progress"
            danger
          >
            <button
              onClick={() => setShowClearConfirm(true)}
              className="flex items-center gap-1.5 px-3 py-1.5 rounded-xl text-red-400"
              style={{ fontSize: '13px', border: '1px solid rgba(239,68,68,0.2)' }}
            >
              Clear
              <ChevronRight size={14} />
            </button>
          </SettingRow>
        </Section>

        {/* Stats summary */}
        <div className="mx-4 mt-2 px-4 py-4 rounded-2xl text-center" style={{ background: 'rgba(139,92,246,0.05)', border: '1px solid rgba(139,92,246,0.1)' }}>
          <p className="text-muted-foreground" style={{ fontSize: '13px' }}>
            {mantras.length} mantras · {sessions.length} sessions · {progress.totalRepetitions.toLocaleString()} repetitions
          </p>
          <p className="text-muted-foreground mt-1" style={{ fontSize: '12px' }}>
            Privacy-first · All data stored locally
          </p>
        </div>
      </div>

      <AnimatePresence>
        {showClearConfirm && (
          <ClearDataModal
            onConfirm={handleClearData}
            onCancel={() => setShowClearConfirm(false)}
          />
        )}
      </AnimatePresence>
    </div>
  );
}
