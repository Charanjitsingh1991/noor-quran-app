import type { Timestamp } from "firebase/firestore";

export interface UserProfile {
  uid: string;
  email: string | null;
  name?: string;
  dob?: string;
  photoURL?: string;
  country: string;
  fontSize: 'sm' | 'md' | 'lg';
  lastRead?: {
    surah: number;
    verse: number;
  };
}

export interface Verse {
  number: number;
  numberInSurah: number;
  arabicText: string;
  englishText: string;
  hindiText: string;
}

export interface Surah {
  number: number;
  name: string;
  englishName: string;
  englishNameTranslation: string;
  revelationType: string;
  numberOfAyahs: number;
  verses: Verse[];
}

export interface Bookmark {
  id: string;
  surah: number;
  verse: number;
  note: string;
  createdAt: Timestamp;
  surahName: string;
  verseText: string;
}
