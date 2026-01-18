/**
 * Mantra type definitions
 */

export type MantraType = 'custom' | 'builtin';

export interface Mantra {
  id: string;
  userId: string;
  type: MantraType;
  title: string;
  sanskrit?: string;
  text: string;
  transliteration?: string;
  translation?: string;
  category?: string;
  tags?: string[];
  voiceUri?: string; // Local file path or URI to recorded/generated voice
  isFavorite: boolean;
  createdAt: string; // ISO date string
  updatedAt: string; // ISO date string
}

export interface CreateMantraInput {
  type: MantraType;
  title: string;
  sanskrit?: string;
  text: string;
  transliteration?: string;
  translation?: string;
  category?: string;
  tags?: string[];
  voiceUri?: string;
}

export interface UpdateMantraInput extends Partial<CreateMantraInput> {
  id: string;
}

export interface BuiltInMantra {
  id: string;
  title: string;
  sanskrit: string;
  text: string;
  transliteration: string;
  translation: string;
  category: string;
  description?: string;
}
