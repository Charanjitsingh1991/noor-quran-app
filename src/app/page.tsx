'use client';
import { useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { useAuth } from '@/hooks/useAuth';
import { Loader2 } from 'lucide-react';

export default function SplashPage() {
    const { user, loading } = useAuth();
    const router = useRouter();

    useEffect(() => {
        if (!loading) {
            if (user) {
                router.replace('/home');
            } else {
                router.replace('/login');
            }
        }
    }, [user, loading, router]);

    return (
        <div className="flex h-screen w-full flex-col items-center justify-center bg-background text-primary-foreground gap-4">
            <h1 className="text-4xl font-headline font-bold text-accent">Noor</h1>
            <p className="text-lg">Your Quran Companion</p>
            <Loader2 className="h-8 w-8 animate-spin text-accent mt-4" />
        </div>
    );
}
