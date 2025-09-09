'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { Home, BookOpen, Bookmark, User, Clock } from 'lucide-react';
import { cn } from '@/lib/utils';

const navItems = [
  { href: '/home', icon: Home, label: 'Home' },
  { href: '/continue-reading', icon: BookOpen, label: 'Continue' },
  { href: '/prayer-times', icon: Clock, label: 'Prayer Times' },
  { href: '/bookmarks', icon: Bookmark, label: 'Bookmarks' },
  { href: '/profile', icon: User, label: 'Profile' },
];

export default function BottomNav() {
  const pathname = usePathname();

  return (
    <div className="fixed bottom-0 left-0 right-0 h-16 bg-primary/80 backdrop-blur-sm border-t border-primary/20 shadow-lg md:left-1/2 md:-translate-x-1/2 md:bottom-4 md:w-full md:max-w-lg md:rounded-full">
      <nav className="flex h-full items-center justify-around">
        {navItems.map((item) => {
          const isActive = pathname.startsWith(item.href);
          return (
            <Link href={item.href} key={item.label} passHref>
              <div
                className={cn(
                  'flex flex-col items-center justify-center gap-1 transition-colors duration-200 w-16',
                  isActive ? 'text-accent' : 'text-primary-foreground/70 hover:text-primary-foreground'
                )}
              >
                <item.icon className="h-6 w-6" />
                <span className="text-xs font-medium text-center">{item.label}</span>
              </div>
            </Link>
          );
        })}
      </nav>
    </div>
  );
}