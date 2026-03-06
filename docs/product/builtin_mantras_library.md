# Built-in Mantras Library
## MyMantra - Curated Collection

**Version:** 0.1
**Date:** November 2025
**Status:** Draft
**Phase:** Version 2.0

---

## Overview

This document contains the curated collection of mantras that will be included in the MyMantra built-in library. Each mantra includes multiple language versions, transliterations, translations, and cultural context.

**Design Principles:**
- Authentic sources with proper attribution
- Multi-language support (Sanskrit, English, Hebrew, and more)
- Cultural respect and accurate representation
- Public domain or properly licensed content

---

## 1. Signature Mantra - Yoga Sutra I.12

**Category:** Foundational Practice | Yogic Philosophy
**Tradition:** Classical Yoga (Patanjali)
**Target Repetitions:** 108 (traditional mala count)

### Sanskrit (Devanagari)
```
अभ्यासवैराग्याभ्यां तन्निरोधः॥
```

### Sanskrit (IAST Transliteration)
```
abhyāsa-vairāgya-ābhyāṃ tat-nirodhaḥ
```

### English Translation
```
Through steady practice and dispassion, the mind is stilled.
```

### Hebrew Translation
```
בהתמדה ובאי-היקשרות — הנפש שקטה
```

### Cultural Context

**Source:** Yoga Sūtra of Patañjali, Book I (Samādhi Pāda), Verse 12

**Meaning:**
This foundational sutra explains the dual path to calming the fluctuations of the mind (chitta-vritti-nirodha):

1. **Abhyāsa (अभ्यास)** - Steady, consistent practice
   - Repetition over time
   - Dedication to the path
   - Building spiritual discipline

2. **Vairāgya (वैराग्य)** - Dispassion, non-attachment
   - Letting go of desires
   - Freedom from cravings
   - Equanimity toward results

**Relevance to MyMantra:**
This sutra perfectly embodies the purpose of the MyMantra app itself:
- **Abhyāsa:** The app encourages daily practice through reminders and streak tracking
- **Vairāgya:** The gamification is designed to motivate without creating unhealthy attachment
- **Tat-nirodhaḥ:** The ultimate goal is inner peace, not external validation

**Why This Mantra First:**
- It's the philosophical foundation of consistent practice
- It resonates with users across spiritual traditions
- It explains *why* we practice, not just *what* to practice
- It's meta: a mantra about practicing mantras

### Pronunciation Guide

**Sanskrit (IAST):**
- **abhyāsa** - ah-bee-YAH-sah (practice)
- **vairāgya** - vai-RAH-gyah (dispassion)
- **ābhyām** - AHB-yahm (through both)
- **tat** - taht (that)
- **nirodhaḥ** - nee-ROH-dah (cessation, stilling)

**Full phrase:**
"ahb-YAH-sah VAI-rah-gyah AHB-yahm taht nee-ROH-dah"

### Recommended Practice

**Beginner:**
- 27 repetitions (1/4 mala)
- Focus on meaning: "practice and letting go"
- Recite in English initially

**Intermediate:**
- 54 repetitions (1/2 mala)
- Learn Sanskrit pronunciation
- Contemplate dual nature (effort + surrender)

**Advanced:**
- 108 repetitions (full mala)
- Recite in Sanskrit
- Meditate on the balance between striving and releasing

### In-App Metadata

```json
{
  "id": "YS-1-12",
  "title": "Yoga Sutra I.12 - The Path of Practice",
  "shortTitle": "Abhyāsa-Vairāgya",
  "category": "Yogic Philosophy",
  "tradition": "Classical Yoga",
  "source": "Yoga Sūtra of Patañjali",
  "sourceReference": "Book I (Samādhi Pāda), Verse 12",
  "isCustom": false,
  "isSignature": true,
  "targetRepetitions": 108,
  "languages": [
    {
      "code": "sa",
      "name": "Sanskrit (Devanagari)",
      "text": "अभ्यासवैराग्याभ्यां तन्निरोधः॥",
      "isPrimary": true
    },
    {
      "code": "sa-Latn",
      "name": "Sanskrit (IAST)",
      "text": "abhyāsa-vairāgya-ābhyāṃ tat-nirodhaḥ",
      "isPrimary": false
    },
    {
      "code": "en",
      "name": "English",
      "text": "Through steady practice and dispassion, the mind is stilled.",
      "isPrimary": false
    },
    {
      "code": "he",
      "name": "Hebrew",
      "text": "בהתמדה ובאי-היקשרות — הנפש שקטה",
      "isPrimary": false
    }
  ],
  "culturalContext": "This sutra from Patañjali's Yoga Sūtra explains the dual path to mental stillness: consistent practice (abhyāsa) and non-attachment (vairāgya). It embodies the philosophy of MyMantra itself—dedicated practice without obsessive attachment to results.",
  "tags": ["foundational", "yoga", "philosophy", "mind", "practice", "discipline"],
  "difficulty": "beginner",
  "estimatedDuration": {
    "27": "2-3 minutes",
    "54": "4-6 minutes",
    "108": "8-12 minutes"
  },
  "pronunciationAudioUrl": null,
  "createdAt": "2025-11-24T00:00:00Z",
  "license": "Public Domain"
}
```

---

## Future Mantras (Planned for v2.0+)

### 2. Om (ॐ)
**Tradition:** Universal (Hindu, Buddhist, Jain)
**Languages:** Sanskrit, English, Hebrew
**Status:** Planned

### 3. Om Mani Padme Hum (ॐ मणिपद्मे हूँ)
**Tradition:** Tibetan Buddhism
**Languages:** Sanskrit, Tibetan, English, Hebrew
**Status:** Planned

### 4. Gayatri Mantra (गायत्री मन्त्र)
**Tradition:** Hindu Vedic
**Languages:** Sanskrit, English, Hebrew
**Status:** Planned

### 5. Shanti Mantra (शान्ति मन्त्र)
**Tradition:** Hindu Vedic
**Languages:** Sanskrit, English, Hebrew
**Status:** Planned

### 6. Mahamrityunjaya Mantra (महामृत्युञ्जय मन्त्र)
**Tradition:** Hindu (Rigveda)
**Languages:** Sanskrit, English, Hebrew
**Status:** Planned

### 7. So Hum (सो ऽहम्)
**Tradition:** Hindu Advaita Vedanta
**Languages:** Sanskrit, English, Hebrew
**Status:** Planned

### 8. Lokah Samastah Sukhino Bhavantu
**Tradition:** Hindu (modern)
**Languages:** Sanskrit, English, Hebrew
**Status:** Planned

---

## Adding New Mantras

### Criteria for Inclusion
1. **Authenticity:** From verified traditional sources
2. **Accessibility:** Suitable for practitioners of all levels
3. **Multi-language:** At least Sanskrit + English + 1 more
4. **Public Domain:** No copyright restrictions
5. **Cultural Respect:** Accurate representation of tradition
6. **Universal Appeal:** Resonates across spiritual backgrounds

### Translation Guidelines
- Sanskrit: Both Devanagari and IAST transliteration
- English: Poetic yet accurate translation
- Hebrew: Natural phrasing while preserving meaning
- Include cultural context and pronunciation guide
- Cite source texts and traditions

### Community Contributions (Phase 3.0+)
- User-submitted mantras (moderated)
- Translations in additional languages
- Pronunciation recordings
- Personal practice notes

---

## Integration with MyMantra App

### Discovery Flow
1. User opens "Explore Mantras" (library icon)
2. Featured: **Yoga Sutra I.12** (signature mantra)
3. Categories: Yogic, Buddhist, Vedic, Universal, etc.
4. User taps mantra card → Full details screen
5. "Add to My Mantras" button → Creates editable copy

### Signature Mantra Placement
- **First-Time Onboarding:** Option to start with Yoga Sutra I.12
- **Empty State:** Suggested first mantra
- **About Screen:** Quote this sutra as app philosophy
- **Achievements:** Special badge for completing this mantra 108× first time

### Display in App
```
┌─────────────────────────────────────┐
│  📿 Signature Mantra                │
├─────────────────────────────────────┤
│                                     │
│  Yoga Sutra I.12                    │
│  The Path of Practice               │
│                                     │
│  अभ्यासवैराग्याभ्यां तन्निरोधः॥      │
│                                     │
│  "Through steady practice and       │
│  dispassion, the mind is stilled."  │
│                                     │
│  [View All Languages]               │
│  [Add to My Mantras]                │
│                                     │
│  ──────────────────                 │
│  Source: Patañjali's Yoga Sūtra     │
│  Target: 108 repetitions            │
│  Duration: ~10 minutes              │
│                                     │
└─────────────────────────────────────┘
```

---

## Attribution & Licensing

### Yoga Sutra I.12
- **Original Text:** Public Domain (ancient text, ~400 CE)
- **Sanskrit Devanagari:** Traditional rendering
- **IAST Transliteration:** Standard academic convention
- **English Translation:** Adapted from traditional translations (public domain)
- **Hebrew Translation:** Custom translation for MyMantra
- **Cultural Context:** Written by MyMantra team based on classical commentaries

### General License
All built-in mantras in MyMantra are either:
1. Public domain (ancient texts)
2. CC0 (modern translations contributed to public domain)
3. CC BY 4.0 (requiring attribution if modified)

**No proprietary restrictions.** Users are free to:
- Export and share their mantra collections
- Use translations for personal practice
- Contribute improvements (Phase 3.0+)

---

## Appendix: Why Yoga Sutra I.12?

### Personal Connection
This sutra embodies the essence of what MyMantra helps users achieve:

**Abhyāsa (Practice):**
- Daily notifications remind you to practice
- Streak tracking encourages consistency
- Session history shows your dedication
- "The practice itself is the goal"

**Vairāgya (Dispassion):**
- Achievements celebrate without creating attachment
- No social comparison or public leaderboards
- Privacy-first design (your practice, your data)
- "Enjoy the journey, don't cling to outcomes"

**Tat-Nirodhaḥ (Stillness):**
- The counting interface minimizes distraction
- Haptic feedback keeps you present
- Progress tracking reveals inner transformation
- "Peace comes through practice, not perfection"

### Developer's Note
> "When we started building MyMantra, we asked ourselves: What is the one sutra that captures the spirit of this app? Yoga Sutra I.12 was the obvious answer. It's not just a mantra to recite—it's the philosophy we coded into every feature. The streaks are abhyāsa. The privacy is vairāgya. The peace you feel after a session is nirodhaḥ. This app *is* this sutra, brought to life."

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2025-11-24 | Added Yoga Sutra I.12 as signature mantra |

---

**Next Steps:**
1. Design mantra card UI with all language variants
2. Record pronunciation audio (Sanskrit, English, Hebrew)
3. Implement multi-language selector in mantra detail view
4. Create "Signature Mantra" achievement (unlock by completing 108× for first time)
5. Add to onboarding flow as suggested first mantra

---

**End of Built-in Mantras Library v1.0**

🙏 May your practice be steady, your attachment light, and your mind still. 🙏
