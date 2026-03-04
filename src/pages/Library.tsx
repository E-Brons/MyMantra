import React, { useState } from 'react';
import { useNavigate } from 'react-router';
import { Star, Plus, ChevronRight, X, Check, Globe } from 'lucide-react';
import { BUILT_IN_MANTRAS, CATEGORIES, BuiltInMantra } from '../data/mantras';
import { useApp } from '../context/AppContext';
import { motion, AnimatePresence } from 'motion/react';

function MantraDetailSheet({
  mantra,
  onClose,
  onAdd,
  alreadyAdded,
}: {
  mantra: BuiltInMantra;
  onClose: () => void;
  onAdd: () => void;
  alreadyAdded: boolean;
}) {
  const [activeLanguage, setActiveLanguage] = useState(0);

  return (
    <motion.div
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      exit={{ opacity: 0 }}
      className="fixed inset-0 z-50 flex items-end justify-center"
      style={{ background: 'rgba(0,0,0,0.75)', backdropFilter: 'blur(6px)' }}
      onClick={onClose}
    >
      <motion.div
        initial={{ y: '100%' }}
        animate={{ y: 0 }}
        exit={{ y: '100%' }}
        transition={{ type: 'spring', damping: 28, stiffness: 280 }}
        className="w-full max-w-[430px] rounded-t-3xl overflow-hidden"
        style={{
          maxHeight: '90vh',
          background: 'linear-gradient(180deg, #1a1535 0%, #0d0b1a 100%)',
          border: '1px solid rgba(139,92,246,0.2)',
        }}
        onClick={(e) => e.stopPropagation()}
      >
        <div className="overflow-y-auto" style={{ maxHeight: '90vh' }}>
          {/* Handle */}
          <div className="flex justify-center pt-3 pb-1">
            <div className="w-10 h-1 rounded-full bg-white/20" />
          </div>

          {/* Header */}
          <div className="px-5 pt-3 pb-4 flex items-start justify-between">
            <div className="flex-1">
              {mantra.isSignature && (
                <div
                  className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full mb-2"
                  style={{ background: 'rgba(245,158,11,0.15)', border: '1px solid rgba(245,158,11,0.3)' }}
                >
                  <Star size={11} className="text-amber-400" fill="currentColor" />
                  <span className="text-amber-400" style={{ fontSize: '11px' }}>Signature Mantra</span>
                </div>
              )}
              <h3 className="text-white" style={{ fontSize: '20px', fontWeight: 700 }}>
                {mantra.title}
              </h3>
              <p className="text-white/50 mt-1" style={{ fontSize: '13px' }}>
                {mantra.source}
              </p>
            </div>
            <button onClick={onClose} className="ml-3 mt-1">
              <X size={20} className="text-white/50" />
            </button>
          </div>

          {/* Language Tabs */}
          <div className="px-5">
            <div className="flex gap-2 flex-wrap">
              {mantra.languages.map((lang, i) => (
                <button
                  key={lang.code}
                  onClick={() => setActiveLanguage(i)}
                  className={`px-3 py-1.5 rounded-full text-sm transition-all ${
                    activeLanguage === i ? 'text-white bg-violet-600' : 'text-white/50'
                  }`}
                  style={{
                    fontSize: '12px',
                    border: '1px solid rgba(139,92,246,0.2)',
                    background: activeLanguage === i ? undefined : 'rgba(139,92,246,0.06)',
                  }}
                >
                  {lang.name}
                </button>
              ))}
            </div>
          </div>

          {/* Mantra Text */}
          <div className="px-5 mt-4">
            <div
              className="rounded-2xl p-5"
              style={{ background: 'rgba(139,92,246,0.1)', border: '1px solid rgba(139,92,246,0.2)' }}
            >
              <p
                className="text-white leading-relaxed"
                style={{
                  fontFamily:
                    mantra.languages[activeLanguage]?.code === 'sa'
                      ? "'Noto Sans Devanagari', sans-serif"
                      : "'Inter', sans-serif",
                  fontSize: mantra.languages[activeLanguage]?.code === 'sa' ? '22px' : '16px',
                  whiteSpace: 'pre-line',
                  direction: mantra.languages[activeLanguage]?.code === 'he' ? 'rtl' : 'ltr',
                }}
              >
                {mantra.languages[activeLanguage]?.text}
              </p>
            </div>
          </div>

          {/* Metadata */}
          <div className="px-5 mt-4 flex flex-wrap gap-2">
            <span
              className="px-3 py-1.5 rounded-full text-violet-300"
              style={{ fontSize: '12px', background: 'rgba(139,92,246,0.12)', border: '1px solid rgba(139,92,246,0.2)' }}
            >
              {mantra.tradition}
            </span>
            <span
              className="px-3 py-1.5 rounded-full text-emerald-300"
              style={{ fontSize: '12px', background: 'rgba(16,185,129,0.1)', border: '1px solid rgba(16,185,129,0.2)' }}
            >
              {mantra.difficulty}
            </span>
            <span
              className="px-3 py-1.5 rounded-full text-amber-300"
              style={{ fontSize: '12px', background: 'rgba(245,158,11,0.1)', border: '1px solid rgba(245,158,11,0.2)' }}
            >
              {mantra.targetRepetitions}× recommended
            </span>
          </div>

          {/* Cultural Context */}
          <div className="px-5 mt-4">
            <p className="text-white/70 leading-relaxed" style={{ fontSize: '14px' }}>
              {mantra.culturalContext}
            </p>
          </div>

          {/* Pronunciation */}
          {mantra.pronunciationGuide && (
            <div className="px-5 mt-4">
              <div
                className="px-4 py-3 rounded-xl"
                style={{ background: 'rgba(255,255,255,0.04)', border: '1px solid rgba(255,255,255,0.08)' }}
              >
                <p className="text-white/40 mb-1" style={{ fontSize: '11px' }}>Pronunciation</p>
                <p className="text-white/70 italic" style={{ fontSize: '13px' }}>
                  "{mantra.pronunciationGuide}"
                </p>
              </div>
            </div>
          )}

          {/* Duration estimates */}
          <div className="px-5 mt-4">
            <p className="text-white/40 mb-2" style={{ fontSize: '12px' }}>Estimated duration</p>
            <div className="flex gap-2">
              {Object.entries(mantra.estimatedDuration).map(([reps, time]) => (
                <div
                  key={reps}
                  className="flex-1 rounded-xl p-2 text-center"
                  style={{ background: 'rgba(139,92,246,0.06)', border: '1px solid rgba(139,92,246,0.1)' }}
                >
                  <p className="text-violet-400" style={{ fontSize: '14px', fontWeight: 600 }}>{reps}×</p>
                  <p className="text-white/40" style={{ fontSize: '11px' }}>{time}</p>
                </div>
              ))}
            </div>
          </div>

          {/* Add button */}
          <div className="px-5 mt-6 pb-8">
            <motion.button
              whileTap={{ scale: 0.97 }}
              onClick={() => !alreadyAdded && onAdd()}
              className="w-full py-4 rounded-2xl flex items-center justify-center gap-3 text-white"
              style={{
                background: alreadyAdded
                  ? 'rgba(16,185,129,0.15)'
                  : 'linear-gradient(135deg, #7c3aed, #6d28d9)',
                border: alreadyAdded ? '1px solid rgba(16,185,129,0.3)' : 'none',
                fontSize: '15px',
                fontWeight: 600,
              }}
            >
              {alreadyAdded ? (
                <>
                  <Check size={18} className="text-emerald-400" />
                  <span className="text-emerald-300">Added to My Mantras</span>
                </>
              ) : (
                <>
                  <Plus size={18} />
                  Add to My Mantras
                </>
              )}
            </motion.button>
          </div>
        </div>
      </motion.div>
    </motion.div>
  );
}

export function Library() {
  const navigate = useNavigate();
  const { mantras, createMantra } = useApp();
  const [selectedCategory, setSelectedCategory] = useState('all');
  const [selectedMantra, setSelectedMantra] = useState<BuiltInMantra | null>(null);
  const [addedIds, setAddedIds] = useState<Set<string>>(new Set());

  const filtered =
    selectedCategory === 'all'
      ? BUILT_IN_MANTRAS
      : BUILT_IN_MANTRAS.filter((m) => m.category === selectedCategory);

  const isAlreadyAdded = (mantraId: string) => {
    return addedIds.has(mantraId) || mantras.some((m) => m.tradition === BUILT_IN_MANTRAS.find(b => b.id === mantraId)?.tradition && !m.isCustom);
  };

  const handleAdd = (mantra: BuiltInMantra) => {
    const primary = mantra.languages.find((l) => l.isPrimary) ?? mantra.languages[0];
    const en = mantra.languages.find((l) => l.code === 'en');
    const iast = mantra.languages.find((l) => l.code === 'sa-Latn');

    createMantra({
      title: mantra.title,
      text: primary.text,
      transliteration: iast?.text,
      translation: en?.text,
      targetRepetitions: mantra.targetRepetitions,
      isCustom: false,
      tradition: mantra.tradition,
      reminders: [],
    });

    setAddedIds((prev) => new Set([...prev, mantra.id]));
    setSelectedMantra(null);

    // Navigate to home after brief delay
    setTimeout(() => navigate('/'), 300);
  };

  return (
    <div className="flex flex-col min-h-full">
      {/* Header */}
      <div
        className="px-5 pt-12 pb-4"
        style={{
          background: 'linear-gradient(180deg, rgba(139,92,246,0.12) 0%, transparent 100%)',
        }}
      >
        <div className="flex items-center gap-3 mb-1">
          <Globe size={20} className="text-violet-400" />
          <h1
            className="text-foreground"
            style={{ fontFamily: "'Cinzel', serif", fontSize: '22px', fontWeight: 600 }}
          >
            Mantra Library
          </h1>
        </div>
        <p className="text-muted-foreground" style={{ fontSize: '13px' }}>
          Curated collection from sacred traditions
        </p>

        {/* Signature mantra callout */}
        <motion.div
          initial={{ opacity: 0, y: 8 }}
          animate={{ opacity: 1, y: 0 }}
          className="mt-4 px-4 py-3 rounded-2xl flex items-center gap-3"
          style={{
            background: 'linear-gradient(135deg, rgba(245,158,11,0.12), rgba(234,179,8,0.05))',
            border: '1px solid rgba(245,158,11,0.25)',
          }}
        >
          <Star size={18} className="text-amber-400 shrink-0" fill="currentColor" />
          <div>
            <p className="text-amber-300" style={{ fontSize: '13px', fontWeight: 600 }}>
              Signature Mantra
            </p>
            <p className="text-amber-400/60" style={{ fontSize: '12px' }}>
              Yoga Sutra I.12 — the philosophy behind this app
            </p>
          </div>
        </motion.div>
      </div>

      {/* Category Filter */}
      <div className="px-4 mb-3">
        <div className="flex gap-2 overflow-x-auto pb-1 scrollbar-hide">
          {CATEGORIES.map((cat) => (
            <button
              key={cat.id}
              onClick={() => setSelectedCategory(cat.id)}
              className={`flex items-center gap-1.5 px-3 py-2 rounded-full whitespace-nowrap transition-all ${
                selectedCategory === cat.id ? 'text-white' : 'text-muted-foreground'
              }`}
              style={{
                fontSize: '13px',
                background:
                  selectedCategory === cat.id
                    ? 'linear-gradient(135deg, #7c3aed, #6d28d9)'
                    : 'rgba(139,92,246,0.07)',
                border: '1px solid rgba(139,92,246,0.2)',
                flexShrink: 0,
              }}
            >
              <span>{cat.emoji}</span>
              <span>{cat.label}</span>
            </button>
          ))}
        </div>
      </div>

      {/* Mantra Cards */}
      <div className="flex-1 overflow-y-auto px-4 pb-4 space-y-3">
        {filtered.map((mantra, index) => {
          const primary = mantra.languages.find((l) => l.isPrimary) ?? mantra.languages[0];
          const en = mantra.languages.find((l) => l.code === 'en');
          const added = isAlreadyAdded(mantra.id) || addedIds.has(mantra.id);

          return (
            <motion.button
              key={mantra.id}
              initial={{ opacity: 0, y: 16 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: index * 0.05 }}
              whileTap={{ scale: 0.97 }}
              onClick={() => setSelectedMantra(mantra)}
              className="w-full rounded-2xl p-4 text-left overflow-hidden"
              style={{
                background: mantra.isSignature
                  ? 'linear-gradient(135deg, rgba(245,158,11,0.1), rgba(139,92,246,0.1))'
                  : 'linear-gradient(135deg, rgba(139,92,246,0.08), rgba(30,27,75,0.4))',
                border: mantra.isSignature
                  ? '1px solid rgba(245,158,11,0.25)'
                  : '1px solid rgba(139,92,246,0.2)',
              }}
            >
              <div className="flex items-start justify-between gap-3">
                <div className="flex-1 min-w-0">
                  <div className="flex items-center gap-2 flex-wrap">
                    {mantra.isSignature && (
                      <Star size={12} className="text-amber-400 shrink-0" fill="currentColor" />
                    )}
                    <span className="text-foreground" style={{ fontSize: '14px', fontWeight: 600 }}>
                      {mantra.shortTitle}
                    </span>
                  </div>
                  <p
                    className="mt-1.5 text-muted-foreground"
                    style={{
                      fontFamily: "'Noto Sans Devanagari', sans-serif",
                      fontSize: '17px',
                      lineHeight: '1.4',
                    }}
                  >
                    {primary.text.split('\n')[0]}
                  </p>
                  {en && (
                    <p className="mt-1 text-muted-foreground truncate" style={{ fontSize: '12px' }}>
                      {en.text}
                    </p>
                  )}
                </div>
                <ChevronRight size={16} className="text-muted-foreground shrink-0 mt-1" />
              </div>

              <div className="mt-3 flex items-center gap-2 flex-wrap">
                <span
                  className="px-2 py-0.5 rounded-full text-violet-300"
                  style={{ fontSize: '11px', background: 'rgba(139,92,246,0.12)' }}
                >
                  {mantra.tradition}
                </span>
                <span
                  className="px-2 py-0.5 rounded-full text-muted-foreground"
                  style={{ fontSize: '11px', background: 'rgba(255,255,255,0.05)' }}
                >
                  {mantra.difficulty}
                </span>
                <span className="text-muted-foreground" style={{ fontSize: '11px' }}>
                  {mantra.languages.length} languages
                </span>
                {added && (
                  <span
                    className="flex items-center gap-1 text-emerald-400"
                    style={{ fontSize: '11px' }}
                  >
                    <Check size={10} />
                    Added
                  </span>
                )}
              </div>
            </motion.button>
          );
        })}
      </div>

      {/* Detail Sheet */}
      <AnimatePresence>
        {selectedMantra && (
          <MantraDetailSheet
            mantra={selectedMantra}
            onClose={() => setSelectedMantra(null)}
            onAdd={() => handleAdd(selectedMantra)}
            alreadyAdded={isAlreadyAdded(selectedMantra.id) || addedIds.has(selectedMantra.id)}
          />
        )}
      </AnimatePresence>
    </div>
  );
}
