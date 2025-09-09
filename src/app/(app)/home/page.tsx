'use client';

import { useState, useEffect, useCallback } from 'react';
import { collection, getDocs, query } from 'firebase/firestore';
import { db } from '@/lib/firebase';
import type { Surah } from '@/types';
import Link from 'next/link';
import { Card, CardHeader, CardTitle, CardDescription } from '@/components/ui/card';
import { Loader2 } from 'lucide-react';
import { useToast } from '@/hooks/use-toast';

export default function HomePage() {
  const [surahs, setSurahs] = useState<Surah[]>([]);
  const [loading, setLoading] = useState(true);
  const { toast } = useToast();

  const loadSurahsFromFirestore = useCallback(async () => {
    setLoading(true);
    try {
      const surahsCollection = collection(db, 'surahs');
      const q = query(surahsCollection);
      const querySnapshot = await getDocs(q);
      
      if (!querySnapshot.empty) {
        const surahsData = querySnapshot.docs.map(doc => doc.data() as Surah);
        // Sort the surahs by their number on the client side
        surahsData.sort((a, b) => a.number - b.number);
        setSurahs(surahsData);
      } else {
        toast({
          variant: 'destructive',
          title: 'Surah Data Not Found',
          description: 'The `surahs` collection in your database appears to be empty. Please ensure it has been populated with data.',
        });
      }
    } catch (error) {
        console.error("Error loading Surahs from Firestore:", error);
        toast({
            variant: 'destructive',
            title: 'Error Loading Surahs',
            description: 'Failed to load Surah list. Please check your Firestore security rules and internet connection.',
        });
    } finally {
        setLoading(false);
    }
  }, [toast]);

  useEffect(() => {
    loadSurahsFromFirestore();
  }, [loadSurahsFromFirestore]);

  if (loading) {
    return (
      <div className="flex flex-col items-center justify-center min-h-screen p-4">
        <Loader2 className="h-10 w-10 animate-spin text-accent" />
        <p className="mt-4 text-lg font-semibold">Loading Surahs...</p>
      </div>
    );
  }

  return (
    <div className="container mx-auto p-4">
      <header className="my-6 text-center">
        <h1 className="text-4xl font-headline font-bold text-accent">Al-Quran</h1>
        <p className="text-muted-foreground text-lg">Select a Surah to begin reading</p>
      </header>
      {surahs.length > 0 ? (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          {surahs.map((surah) => (
            <Link href={`/surah/${surah.number}`} key={surah.number}>
              <Card className="hover:border-accent hover:shadow-lg transition-all duration-200 cursor-pointer h-full">
                <CardHeader>
                  <div className="flex items-center justify-between">
                    <div className="flex items-center gap-4">
                      <div className="flex items-center justify-center w-10 h-10 rounded-full bg-accent/20 text-accent font-bold">
                        {surah.number}
                      </div>
                      <div>
                        <CardTitle className="font-headline">{surah.englishName}</CardTitle>
                        <CardDescription>{surah.englishNameTranslation}</CardDescription>
                      </div>
                    </div>
                    <div className="text-right">
                      <p className="text-lg font-arabic font-bold">{surah.name}</p>
                      <p className="text-xs text-muted-foreground">{surah.numberOfAyahs} Verses</p>
                    </div>
                  </div>
                </CardHeader>
              </Card>
            </Link>
          ))}
        </div>
      ) : (
         <div className="text-center mt-8 p-4 bg-card rounded-lg">
            <p className="text-card-foreground font-semibold">Could Not Load Surahs</p>
            <p className="text-muted-foreground mt-2">Please ensure your Firestore database is populated and the security rules are correct.</p>
        </div>
      )}
    </div>
  );
}
