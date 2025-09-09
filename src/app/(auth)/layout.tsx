'use client'
import { useAuth } from "@/hooks/useAuth";
import { useRouter } from "next/navigation";
import { useEffect } from "react";
import { Loader2 } from "lucide-react";

export default function AuthLayout({
  children,
}: {
  children: React.ReactNode
}) {
  const { user, loading } = useAuth();
  const router = useRouter();

  useEffect(() => {
    if (!loading && user) {
      router.replace('/home');
    }
  }, [user, loading, router]);

  if (loading) {
    return (
        <div className="flex h-screen w-full flex-col items-center justify-center bg-background text-primary-foreground gap-4">
            <h1 className="text-4xl font-headline font-bold text-accent">Noor</h1>
            <Loader2 className="h-8 w-8 animate-spin text-accent mt-4" />
        </div>
    );
  }

  if (user) return null;

  return (
    <div className="flex min-h-screen w-full items-center justify-center bg-background p-4">
      <div className="w-full max-w-md">
        {children}
      </div>
    </div>
  )
}
