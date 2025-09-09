'use client';

import { useEffect } from 'react';
import { useAuth } from '@/hooks/useAuth';
import { useRouter } from 'next/navigation';
import { Loader2 } from 'lucide-react';

export default function ContinueReadingPage() {
  const { userData, loading } = useAuth();
  const router = useRouter();

  useEffect(() => {
    if (!loading && userData) {
      const lastRead = userData.lastRead;
      if (lastRead && lastRead.surah && lastRead.verse) {
        router.replace(`/surah/${lastRead.surah}#verse-${lastRead.verse}`);
      } else {
        // If no last read position, send to home to select a surah
        router.replace('/home');
      }
    } else if (!loading && !userData) {
      // Should be handled by layout, but as a fallback
      router.replace('/login');
    }
  }, [userData, loading, router]);

  return (
    <div className="flex flex-col h-screen w-full items-center justify-center bg-background">
      <Loader2 className="h-10 w-10 animate-spin text-accent" />
      <p className="mt-4 text-lg font-semibold">Jumping to your last read position...</p>
    </div>
  );
}
