import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router';
import { ArrowLeft, Check, ChevronDown, ChevronUp } from 'lucide-react';
import { useApp } from '../context/AppContext';
import { motion } from 'motion/react';

const REPETITION_PRESETS = [27, 54, 108, 216, 1008];

export function CreateMantra() {
  const { id } = useParams<{ id?: string }>();
  const navigate = useNavigate();
  const { getMantra, createMantra, updateMantra } = useApp();

  const isEdit = id !== 'new' && !!id;
  const existing = isEdit ? getMantra(id!) : undefined;

  const [title, setTitle] = useState(existing?.title ?? '');
  const [text, setText] = useState(existing?.text ?? '');
  const [transliteration, setTransliteration] = useState(existing?.transliteration ?? '');
  const [translation, setTranslation] = useState(existing?.translation ?? '');
  const [targetReps, setTargetReps] = useState(existing?.targetRepetitions ?? 108);
  const [tradition, setTradition] = useState(existing?.tradition ?? '');
  const [showAdvanced, setShowAdvanced] = useState(false);
  const [errors, setErrors] = useState<Record<string, string>>({});

  const validate = (): boolean => {
    const newErrors: Record<string, string> = {};
    if (!title.trim()) newErrors.title = 'Title is required';
    else if (title.trim().length > 100) newErrors.title = 'Title must be 100 characters or less';
    if (!text.trim()) newErrors.text = 'Mantra text is required';
    if (targetReps < 1 || targetReps > 10000) newErrors.targetReps = 'Must be between 1 and 10,000';
    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSave = () => {
    if (!validate()) return;

    const data = {
      title: title.trim(),
      text: text.trim(),
      transliteration: transliteration.trim() || undefined,
      translation: translation.trim() || undefined,
      targetRepetitions: targetReps,
      isCustom: true,
      tradition: tradition.trim() || undefined,
      reminders: existing?.reminders ?? [],
    };

    if (isEdit && existing) {
      updateMantra(existing.id, data);
      navigate(`/mantras/${existing.id}`, { replace: true });
    } else {
      const newMantra = createMantra(data);
      navigate(`/mantras/${newMantra.id}`, { replace: true });
    }
  };

  return (
    <div className="flex flex-col min-h-full">
      {/* Header */}
      <div
        className="px-4 pt-12 pb-4 flex items-center gap-4"
        style={{ borderBottom: '1px solid rgba(139,92,246,0.1)' }}
      >
        <button
          onClick={() => navigate(-1)}
          className="w-10 h-10 rounded-full flex items-center justify-center shrink-0"
          style={{ background: 'rgba(139,92,246,0.1)' }}
        >
          <ArrowLeft size={18} className="text-foreground" />
        </button>

        <h2
          className="text-foreground flex-1"
          style={{ fontSize: '18px', fontWeight: 600 }}
        >
          {isEdit ? 'Edit Mantra' : 'New Mantra'}
        </h2>

        <button
          onClick={handleSave}
          className="flex items-center gap-2 px-4 py-2 rounded-xl text-white"
          style={{ background: 'linear-gradient(135deg, #7c3aed, #6d28d9)', fontSize: '14px' }}
        >
          <Check size={15} />
          Save
        </button>
      </div>

      {/* Form */}
      <div className="flex-1 overflow-y-auto px-4 py-5 space-y-5">
        {/* Title */}
        <div>
          <label className="block mb-2 text-muted-foreground" style={{ fontSize: '13px' }}>
            Title <span className="text-violet-400">*</span>
          </label>
          <input
            type="text"
            placeholder="e.g. Om Mani Padme Hum"
            value={title}
            onChange={(e) => setTitle(e.target.value)}
            maxLength={100}
            className="w-full px-4 py-3.5 rounded-xl text-foreground outline-none"
            style={{
              background: 'rgba(139,92,246,0.08)',
              border: errors.title ? '1px solid rgba(239,68,68,0.5)' : '1px solid rgba(139,92,246,0.2)',
              fontSize: '15px',
            }}
          />
          {errors.title && (
            <p className="text-red-400 mt-1" style={{ fontSize: '12px' }}>{errors.title}</p>
          )}
          <p className="text-muted-foreground mt-1 text-right" style={{ fontSize: '11px' }}>
            {title.length}/100
          </p>
        </div>

        {/* Mantra Text */}
        <div>
          <label className="block mb-2 text-muted-foreground" style={{ fontSize: '13px' }}>
            Mantra Text <span className="text-violet-400">*</span>
          </label>
          <p className="text-muted-foreground mb-2" style={{ fontSize: '12px' }}>
            Enter in original language (Sanskrit, Hebrew, etc.)
          </p>
          <textarea
            placeholder="ॐ मणिपद्मे हूँ"
            value={text}
            onChange={(e) => setText(e.target.value)}
            rows={4}
            className="w-full px-4 py-3.5 rounded-xl text-foreground outline-none resize-none"
            style={{
              background: 'rgba(139,92,246,0.08)',
              border: errors.text ? '1px solid rgba(239,68,68,0.5)' : '1px solid rgba(139,92,246,0.2)',
              fontFamily: "'Noto Sans Devanagari', 'Inter', sans-serif",
              fontSize: '18px',
              lineHeight: '1.6',
            }}
          />
          {errors.text && (
            <p className="text-red-400 mt-1" style={{ fontSize: '12px' }}>{errors.text}</p>
          )}
        </div>

        {/* Target Repetitions */}
        <div>
          <label className="block mb-2 text-muted-foreground" style={{ fontSize: '13px' }}>
            Target Repetitions
          </label>

          {/* Presets */}
          <div className="flex gap-2 mb-3 flex-wrap">
            {REPETITION_PRESETS.map((preset) => (
              <button
                key={preset}
                onClick={() => setTargetReps(preset)}
                className={`px-3 py-2 rounded-xl transition-all ${
                  targetReps === preset ? 'text-white bg-violet-600' : 'text-muted-foreground'
                }`}
                style={{
                  fontSize: '13px',
                  border: '1px solid rgba(139,92,246,0.2)',
                  background: targetReps === preset ? undefined : 'rgba(139,92,246,0.06)',
                }}
              >
                {preset}
              </button>
            ))}
          </div>

          <input
            type="number"
            min={1}
            max={10000}
            value={targetReps}
            onChange={(e) => setTargetReps(parseInt(e.target.value) || 108)}
            className="w-full px-4 py-3.5 rounded-xl text-foreground outline-none"
            style={{
              background: 'rgba(139,92,246,0.08)',
              border: errors.targetReps ? '1px solid rgba(239,68,68,0.5)' : '1px solid rgba(139,92,246,0.2)',
              fontSize: '18px',
              fontWeight: 600,
            }}
          />
          {errors.targetReps && (
            <p className="text-red-400 mt-1" style={{ fontSize: '12px' }}>{errors.targetReps}</p>
          )}
          <p className="text-muted-foreground mt-1" style={{ fontSize: '12px' }}>
            Traditional: 27 (quarter mala) · 54 (half mala) · 108 (full mala)
          </p>
        </div>

        {/* Advanced (optional) */}
        <div>
          <button
            onClick={() => setShowAdvanced(!showAdvanced)}
            className="flex items-center gap-2 text-violet-400 w-full py-2"
            style={{ fontSize: '14px' }}
          >
            {showAdvanced ? <ChevronUp size={16} /> : <ChevronDown size={16} />}
            {showAdvanced ? 'Hide' : 'Show'} optional fields
          </button>

          {showAdvanced && (
            <motion.div
              initial={{ opacity: 0, height: 0 }}
              animate={{ opacity: 1, height: 'auto' }}
              exit={{ opacity: 0, height: 0 }}
              className="space-y-4 mt-3"
            >
              {/* Transliteration */}
              <div>
                <label className="block mb-2 text-muted-foreground" style={{ fontSize: '13px' }}>
                  Transliteration (IAST)
                </label>
                <textarea
                  placeholder="oṃ maṇipadme hūṃ"
                  value={transliteration}
                  onChange={(e) => setTransliteration(e.target.value)}
                  rows={2}
                  className="w-full px-4 py-3 rounded-xl text-foreground outline-none resize-none"
                  style={{
                    background: 'rgba(139,92,246,0.08)',
                    border: '1px solid rgba(139,92,246,0.2)',
                    fontSize: '15px',
                    fontStyle: 'italic',
                  }}
                />
              </div>

              {/* Translation */}
              <div>
                <label className="block mb-2 text-muted-foreground" style={{ fontSize: '13px' }}>
                  Translation (English)
                </label>
                <textarea
                  placeholder="Praise to the Jewel in the Lotus"
                  value={translation}
                  onChange={(e) => setTranslation(e.target.value)}
                  rows={2}
                  className="w-full px-4 py-3 rounded-xl text-foreground outline-none resize-none"
                  style={{
                    background: 'rgba(139,92,246,0.08)',
                    border: '1px solid rgba(139,92,246,0.2)',
                    fontSize: '15px',
                  }}
                />
              </div>

              {/* Tradition */}
              <div>
                <label className="block mb-2 text-muted-foreground" style={{ fontSize: '13px' }}>
                  Tradition / Source
                </label>
                <input
                  type="text"
                  placeholder="e.g. Tibetan Buddhism"
                  value={tradition}
                  onChange={(e) => setTradition(e.target.value)}
                  className="w-full px-4 py-3 rounded-xl text-foreground outline-none"
                  style={{
                    background: 'rgba(139,92,246,0.08)',
                    border: '1px solid rgba(139,92,246,0.2)',
                    fontSize: '15px',
                  }}
                />
              </div>
            </motion.div>
          )}
        </div>

        {/* Save button */}
        <motion.button
          whileTap={{ scale: 0.97 }}
          onClick={handleSave}
          className="w-full py-4 rounded-2xl text-white mt-2"
          style={{
            background: 'linear-gradient(135deg, #7c3aed, #6d28d9)',
            boxShadow: '0 4px 20px rgba(124,58,237,0.35)',
            fontSize: '16px',
            fontWeight: 600,
          }}
        >
          {isEdit ? 'Save Changes' : 'Create Mantra'}
        </motion.button>

        {isEdit && (
          <p className="text-muted-foreground text-center pb-4" style={{ fontSize: '13px' }}>
            Editing: {existing?.title}
          </p>
        )}
      </div>
    </div>
  );
}
