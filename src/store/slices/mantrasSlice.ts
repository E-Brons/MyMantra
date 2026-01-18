/**
 * Mantras slice - manages user mantras
 */

import { createSlice, PayloadAction } from '@reduxjs/toolkit';
import type { Mantra, CreateMantraInput, UpdateMantraInput } from '../../types';

interface MantrasState {
  mantras: Mantra[];
  selectedMantra: Mantra | null;
  isLoading: boolean;
  error: string | null;
  searchQuery: string;
}

const initialState: MantrasState = {
  mantras: [],
  selectedMantra: null,
  isLoading: false,
  error: null,
  searchQuery: '',
};

const mantrasSlice = createSlice({
  name: 'mantras',
  initialState,
  reducers: {
    setMantras(state, action: PayloadAction<Mantra[]>) {
      state.mantras = action.payload;
      state.isLoading = false;
    },
    addMantra(state, action: PayloadAction<Mantra>) {
      state.mantras.unshift(action.payload);
    },
    updateMantra(state, action: PayloadAction<Mantra>) {
      const index = state.mantras.findIndex(m => m.id === action.payload.id);
      if (index !== -1) {
        state.mantras[index] = action.payload;
      }
      if (state.selectedMantra?.id === action.payload.id) {
        state.selectedMantra = action.payload;
      }
    },
    deleteMantra(state, action: PayloadAction<string>) {
      state.mantras = state.mantras.filter(m => m.id !== action.payload);
      if (state.selectedMantra?.id === action.payload) {
        state.selectedMantra = null;
      }
    },
    toggleFavorite(state, action: PayloadAction<string>) {
      const mantra = state.mantras.find(m => m.id === action.payload);
      if (mantra) {
        mantra.isFavorite = !mantra.isFavorite;
      }
    },
    selectMantra(state, action: PayloadAction<string>) {
      state.selectedMantra = state.mantras.find(m => m.id === action.payload) || null;
    },
    clearSelectedMantra(state) {
      state.selectedMantra = null;
    },
    setSearchQuery(state, action: PayloadAction<string>) {
      state.searchQuery = action.payload;
    },
    setLoading(state, action: PayloadAction<boolean>) {
      state.isLoading = action.payload;
    },
    setError(state, action: PayloadAction<string | null>) {
      state.error = action.payload;
      state.isLoading = false;
    },
    clearError(state) {
      state.error = null;
    },
  },
});

export const {
  setMantras,
  addMantra,
  updateMantra,
  deleteMantra,
  toggleFavorite,
  selectMantra,
  clearSelectedMantra,
  setSearchQuery,
  setLoading,
  setError,
  clearError,
} = mantrasSlice.actions;

export default mantrasSlice.reducer;
