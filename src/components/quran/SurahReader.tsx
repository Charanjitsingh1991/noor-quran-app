'use client';

import { useState, useEffect, useRef, useCallback } from 'react';
import type { Surah, Verse } from '@/types';
import { useAuth } from '@/hooks/useAuth';
import { db } from '@/lib/firebase';
import { doc, setDoc, addDoc, collection, serverTimestamp } from 'firebase/firestore';
import { Bookmark, Loader2, ArrowLeft, Languages } from 'lucide-react';
import { cn } from '@/lib/utils';
import { useToast } from '@/hooks/use-toast';
import { Button } from '@/components/ui/button';
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogDescription,
  DialogFooter,
} from '@/components/ui/dialog';
import { Textarea } from '@/components/ui/textarea';
import throttle from 'lodash/throttle';
import Link from 'next/link';
import { Tabs, TabsList, TabsTrigger } from '@/components/ui/tabs';

type SurahReaderProps = {
  surah: Surah;
};

const fontSizes = {
  sm: 'text-lg',
  md: 'text-xl',
  lg: 'text-2xl',
};
const translationFontSizes = {
    sm: 'text-sm',
    md: 'text-base',
    lg: 'text-lg',
}

export default function SurahReader({ surah }: SurahReaderProps) {
  const { user, userData } = useAuth();
  const { toast } = useToast();
  const [activeBookmarkVerse, setActiveBookmarkVerse] = useState<Verse | null>(null);
  const [note, setNote] = useState('');
  const [isSaving, setIsSaving] = useState(false);
  const [selectedLanguage, setSelectedLanguage] = useState<'english' | 'hindi'>('english');
  const verseRefs = useRef<(HTMLDivElement | null)[]>([]);

  const updateLastRead = useCallback(async (surahId: number, verseId: number) => {
    if (user) {
      const userRef = doc(db, 'users', user.uid);
      await setDoc(userRef, { lastRead: { surah: surahId, verse: verseId } }, { merge: true });
    }
  }, [user]);

  const throttledUpdateLastRead = useCallback(throttle(updateLastRead, 5000, {'trailing': true}), [updateLastRead]);

  useEffect(() => {
    const observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            const verseId = entry.target.getAttribute('data-verse-id');
            if (verseId) {
              throttledUpdateLastRead(surah.number, parseInt(verseId));
            }
          }
        });
      },
      { rootMargin: '0px 0px -80% 0px', threshold: 0.1 }
    );

    verseRefs.current.forEach((ref) => {
      if (ref) observer.observe(ref);
    });

    return () => {
      verseRefs.current.forEach((ref) => {
        if (ref) observer.unobserve(ref);
      });
      throttledUpdateLastRead.cancel();
    };
  }, [surah.number, throttledUpdateLastRead]);
  
  useEffect(() => {
    const verseId = window.location.hash.replace('#verse-', '');
    if (verseId) {
        const verseElement = document.getElementById(`verse-${verseId}`);
        if(verseElement) {
            verseElement.scrollIntoView({ behavior: 'smooth'});
        }
    }
  }, []);

  const handleBookmarkClick = (verse: Verse) => {
    setActiveBookmarkVerse(verse);
  };

  const handleSaveBookmark = async () => {
    if (!user || !activeBookmarkVerse) return;
    setIsSaving(true);
    try {
      const bookmarksColRef = collection(db, 'users', user.uid, 'bookmarks');
      await addDoc(bookmarksColRef, {
        surah: surah.number,
        surahName: surah.englishName,
        verse: activeBookmarkVerse.numberInSurah,
        verseText: activeBookmarkVerse.arabicText,
        note: note,
        createdAt: serverTimestamp(),
      });
      toast({ title: 'Bookmark saved!' });
    } catch (error) {
      toast({ variant: 'destructive', title: 'Error', description: 'Could not save bookmark.' });
    } finally {
      setIsSaving(false);
      setActiveBookmarkVerse(null);
      setNote('');
    }
  };

  const arabicFontSize = userData?.fontSize ? fontSizes[userData.fontSize] : fontSizes.md;
  const translationFontSize = userData?.fontSize ? translationFontSizes[userData.fontSize] : translationFontSizes.md;

  return (
    <div className="p-4 md:p-6">
      <header className="bg-primary/10 rounded-lg p-6 mb-8 text-center shadow-md relative">
        <Link href="/home" passHref>
          <Button variant="outline" size="icon" className="absolute top-4 left-4">
            <ArrowLeft className="h-4 w-4" />
            <span className="sr-only">Back to all surahs</span>
          </Button>
        </Link>
        <h1 className="text-4xl font-arabic font-bold">{surah.name}</h1>
        <h2 className="text-3xl font-headline text-accent mt-2">{surah.englishName}</h2>
        <p className="text-muted-foreground mt-1">{surah.englishNameTranslation}</p>
        <p className="text-sm text-muted-foreground mt-2">
          {surah.revelationType} • {surah.numberOfAyahs} Verses
        </p>

        <div className="flex justify-center mt-4">
             <Tabs defaultValue="english" onValueChange={(value) => setSelectedLanguage(value as 'english' | 'hindi')} className="w-auto">
                <TabsList>
                    <TabsTrigger value="english">English</TabsTrigger>
                    <TabsTrigger value="hindi">Hindi</TabsTrigger>
                </TabsList>
            </Tabs>
        </div>
      </header>

      <div className="space-y-8">
        {surah.verses.map((verse, index) => (
          <div
            key={verse.numberInSurah}
            id={`verse-${verse.numberInSurah}`}
            ref={(el) => (verseRefs.current[index] = el)}
            data-verse-id={verse.numberInSurah}
            className="p-4 border-b border-primary/20"
          >
            <div className="flex justify-between items-start">
              <span className="text-accent font-bold">{surah.number}:{verse.numberInSurah}</span>
              <Button variant="ghost" size="icon" onClick={() => handleBookmarkClick(verse)}>
                <Bookmark className="h-5 w-5 text-accent/70 hover:text-accent hover:scale-110 transition-transform" />
              </Button>
            </div>
            <p className={cn('text-right leading-loose mt-2 font-arabic', arabicFontSize)}>{verse.arabicText}</p>
            <div className={cn("mt-4 space-y-2", translationFontSize)}>
                {selectedLanguage === 'english' && (
                    <p className="italic text-muted-foreground">"{verse.englishText}"</p>
                )}
                {selectedLanguage === 'hindi' && (
                    <p className="italic text-muted-foreground">"{verse.hindiText}"</p>
                )}
            </div>
          </div>
        ))}
      </div>

      <Dialog open={!!activeBookmarkVerse} onOpenChange={() => setActiveBookmarkVerse(null)}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Add Note to Bookmark</DialogTitle>
            <DialogDescription>
              Surah {surah.englishName}, Verse {activeBookmarkVerse?.numberInSurah}
            </DialogDescription>
          </DialogHeader>
          <Textarea
            placeholder="Write your reflection here..."
            value={note}
            onChange={(e) => setNote(e.target.value)}
            rows={4}
          />
          <DialogFooter>
            <Button variant="outline" onClick={() => setActiveBookmarkVerse(null)}>Cancel</Button>
            <Button onClick={handleSaveBookmark} disabled={isSaving} className="bg-accent hover:bg-accent/90">
              {isSaving ? <Loader2 className="mr-2 h-4 w-4 animate-spin" /> : 'Save Bookmark'}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}
