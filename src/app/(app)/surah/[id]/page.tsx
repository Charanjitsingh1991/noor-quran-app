import { doc, getDoc, collection, getDocs } from 'firebase/firestore';
import { db } from '@/lib/firebase';
import type { Surah, Verse } from '@/types';
import SurahReader from '@/components/quran/SurahReader';
import { notFound } from 'next/navigation';

type SurahPageProps = {
  params: { id: string };
};

// This function tells Next.js which pages to generate at build time
export async function generateStaticParams() {
  try {
    const surahsCollection = collection(db, 'surahs');
    const surahSnapshot = await getDocs(surahsCollection);
    const paths = surahSnapshot.docs.map(doc => ({
      id: doc.id,
    }));
    return paths;
  } catch (error) {
    console.error("Failed to generate static params:", error);
    // Return an empty array or a default path if fetching fails
    return [];
  }
}

// This function now fetches from 'surahs' and 'ayahs' collections
async function getSurah(id: string): Promise<Surah | null> {
  if (!id || isNaN(parseInt(id))) {
    console.error(`Invalid Surah ID provided: ${id}`);
    return null;
  }
  
  const surahDocRef = doc(db, 'surahs', id);
  const ayahsDocRef = doc(db, 'ayahs', id);

  try {
    const [surahDocSnap, ayahsDocSnap] = await Promise.all([
      getDoc(surahDocRef),
      getDoc(ayahsDocRef),
    ]);

    if (surahDocSnap.exists() && ayahsDocSnap.exists()) {
      // The 'verses' field in the ayahs document is named 'ayahs', let's use that.
      const surahData = surahDocSnap.data() as Omit<Surah, 'verses'>;
      const ayahsData = ayahsDocSnap.data() as { ayahs: Verse[] };
      
      // Combine the data, mapping 'ayahs' to 'verses'
      return {
        ...surahData,
        verses: ayahsData.ayahs || [],
      };
    } else {
      console.error(`Surah or Ayahs not found for id ${id}.`);
      return null;
    }
  } catch (error) {
    console.error("Error fetching surah and ayahs:", error);
    return null;
  }
}

export default async function SurahPage({ params }: SurahPageProps) {
  const surah = await getSurah(params.id);

  if (!surah) {
    notFound();
  }

  return (
    <div>
      <SurahReader surah={surah} />
    </div>
  );
}
