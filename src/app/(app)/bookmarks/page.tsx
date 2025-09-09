'use client';

import { useState, useEffect } from 'react';
import { useAuth } from '@/hooks/useAuth';
import { db } from '@/lib/firebase';
import { collection, query, orderBy, getDocs, onSnapshot } from 'firebase/firestore';
import type { Bookmark } from '@/types';
import { Loader2 } from 'lucide-react';
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '@/components/ui/card';
import { ScrollArea } from '@/components/ui/scroll-area';
import Link from 'next/link';

export default function BookmarksPage() {
  const { user } = useAuth();
  const [bookmarks, setBookmarks] = useState<Bookmark[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (user) {
      const bookmarksColRef = collection(db, 'users', user.uid, 'bookmarks');
      const q = query(bookmarksColRef, orderBy('createdAt', 'desc'));

      const unsubscribe = onSnapshot(q, (querySnapshot) => {
        const bookmarksData = querySnapshot.docs.map(doc => ({ id: doc.id, ...doc.data() } as Bookmark));
        setBookmarks(bookmarksData);
        setLoading(false);
      }, (error) => {
        console.error("Error fetching bookmarks: ", error);
        setLoading(false);
      });

      return () => unsubscribe();
    } else {
        setLoading(false);
    }
  }, [user]);

  return (
    <div className="container mx-auto p-4">
      <header className="my-6 text-center">
        <h1 className="text-4xl font-headline font-bold text-accent">Bookmarks</h1>
        <p className="text-muted-foreground text-lg">Your saved verses and notes</p>
      </header>

      {loading && (
        <div className="flex justify-center mt-8">
          <Loader2 className="h-10 w-10 animate-spin text-accent" />
        </div>
      )}

      {!loading && bookmarks.length === 0 && (
        <div className="text-center mt-8">
          <p className="text-muted-foreground">You haven't saved any bookmarks yet.</p>
        </div>
      )}

      {!loading && bookmarks.length > 0 && (
        <ScrollArea className="h-[calc(100vh-200px)]">
          <div className="space-y-4">
            {bookmarks.map(bookmark => (
              <Link href={`/surah/${bookmark.surah}#verse-${bookmark.verse}`} key={bookmark.id} passHref>
                <div className="hover:border-accent cursor-pointer transition-colors border rounded-lg">
                    <Card>
                    <CardHeader>
                        <CardTitle className="font-headline">{bookmark.surahName} : {bookmark.verse}</CardTitle>
                        <CardDescription className="font-arabic text-lg text-right mt-2 text-foreground">{bookmark.verseText}</CardDescription>
                    </CardHeader>
                    {bookmark.note && (
                        <CardContent>
                        <p className="text-sm text-muted-foreground italic border-l-2 border-accent pl-3">
                            {bookmark.note}
                        </p>
                        </CardContent>
                    )}
                    </Card>
                </div>
              </Link>
            ))}
          </div>
        </ScrollArea>
      )}
    </div>
  );
}
