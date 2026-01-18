/**
 * Built-in mantras library
 */

import { BuiltInMantra } from '../types/mantra';

export const BUILT_IN_MANTRAS: BuiltInMantra[] = [
  {
    id: 'om',
    title: 'Om (Aum)',
    sanskrit: 'ॐ',
    text: 'Om',
    transliteration: 'Oṃ',
    translation: 'The primordial sound of the universe',
    category: 'Universal',
    description: 'The most sacred syllable in Hinduism, representing the sound of the universe.',
  },
  {
    id: 'gayatri',
    title: 'Gayatri Mantra',
    sanskrit: 'ॐ भूर्भुवः स्वः तत्सवितुर्वरेण्यं भर्गो देवस्य धीमहि धियो यो नः प्रचोदयात्',
    text: 'Om Bhur Bhuvah Svah Tat Savitur Varenyam Bhargo Devasya Dhimahi Dhiyo Yo Nah Prachodayat',
    transliteration: 'Oṃ bhūr bhuvaḥ svaḥ tat savitur vareṇyaṃ bhargo devasya dhīmahi dhiyo yo naḥ prachodayāt',
    translation: 'We meditate on the glory of the Creator who has created the universe, who is worthy of worship, who is the embodiment of knowledge and light, and who is the remover of all sins and ignorance. May he enlighten our intellect.',
    category: 'Vedic',
    description: 'One of the oldest and most powerful mantras from the Rig Veda.',
  },
  {
    id: 'yoga-sutra-1-12',
    title: 'Yoga Sutra I.12',
    sanskrit: 'अभ्यासवैराग्याभ्यां तन्निरोधः',
    text: 'Abhyasa-vairagyabhyam tan-nirodhah',
    transliteration: 'abhyāsa-vairāgya-ābhyāṃ tat-nirodhaḥ',
    translation: 'Through steady practice and dispassion, the mind is stilled',
    category: 'Yoga Sutras',
    description: 'From Patanjali\'s Yoga Sutras, describing the path to mental clarity.',
  },
  {
    id: 'maha-mrityunjaya',
    title: 'Maha Mrityunjaya Mantra',
    sanskrit: 'ॐ त्र्यम्बकं यजामहे सुगन्धिं पुष्टिवर्धनम् उर्वारुकमिव बन्धनान् मृत्योर्मुक्षीय मामृतात्',
    text: 'Om Tryambakam Yajamahe Sugandhim Pushtivardhanam Urvarukamiva Bandhanan Mrityormukshiya Mamritat',
    transliteration: 'Oṃ tryambakaṃ yajāmahe sugandhiṃ puṣṭi-vardhanam urvārukam iva bandhanān mṛtyor mukṣīya māmṛtāt',
    translation: 'We worship the three-eyed One (Lord Shiva) who is fragrant and nourishes all beings. May he liberate us from death for the sake of immortality, just as a ripe cucumber is severed from its bondage to the vine.',
    category: 'Vedic',
    description: 'A powerful healing mantra dedicated to Lord Shiva, promoting health and longevity.',
  },
  {
    id: 'om-mani-padme-hum',
    title: 'Om Mani Padme Hum',
    sanskrit: 'ॐ मणिपद्मे हूँ',
    text: 'Om Mani Padme Hum',
    transliteration: 'Oṃ maṇi padme hūṃ',
    translation: 'The jewel is in the lotus',
    category: 'Buddhist',
    description: 'The six-syllable Sanskrit mantra of Avalokiteshvara, the bodhisattva of compassion.',
  },
  {
    id: 'lokah-samastah',
    title: 'Lokah Samastah',
    sanskrit: 'लोकाः समस्ताः सुखिनो भवन्तु',
    text: 'Lokah Samastah Sukhino Bhavantu',
    transliteration: 'Lokāḥ samastāḥ sukhino bhavantu',
    translation: 'May all beings everywhere be happy and free',
    category: 'Universal',
    description: 'A mantra of peace and compassion for all beings.',
  },
];

/**
 * Get built-in mantra by ID
 */
export const getBuiltInMantra = (id: string): BuiltInMantra | undefined => {
  return BUILT_IN_MANTRAS.find(mantra => mantra.id === id);
};

/**
 * Get built-in mantras by category
 */
export const getBuiltInMantrasByCategory = (category: string): BuiltInMantra[] => {
  return BUILT_IN_MANTRAS.filter(mantra => mantra.category === category);
};

/**
 * Get all categories
 */
export const getMantraCategories = (): string[] => {
  const categories = BUILT_IN_MANTRAS.map(mantra => mantra.category);
  return Array.from(new Set(categories));
};
