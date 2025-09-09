'use client';

import { useState, useEffect, useMemo, useCallback } from 'react';
import { useAuth } from '@/hooks/useAuth';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Loader2, Sunrise, Sun, Sunset, Moon, BellRing, Bell } from 'lucide-react';
import { useToast } from '@/hooks/use-toast';
import { countries } from '@/lib/countries';
import { cn } from '@/lib/utils';
import { parse, isAfter, format, differenceInMilliseconds } from 'date-fns';
import { Button } from '@/components/ui/button';

// A mapping from full country names to two-letter ISO codes for the API.
const countryCodeMapping: { [key: string]: string } = {
    "United States of America": "US", "United Kingdom": "GB", "United Arab Emirates": "AE", "Saudi Arabia": "SA", "Pakistan": "PK", "India": "IN", "Bangladesh": "BD", "Indonesia": "ID", "Egypt": "EG", "Turkey": "TR", "Canada": "CA", "Malaysia": "MY", "Nigeria": "NG",
};

const prayerIcons = {
    Fajr: <Sunrise className="h-6 w-6 text-accent" />,
    Dhuhr: <Sun className="h-6 w-6 text-accent" />,
    Asr: <Sun className="h-6 w-6 text-accent opacity-70" />,
    Maghrib: <Sunset className="h-6 w-6 text-accent" />,
    Isha: <Moon className="h-6 w-6 text-accent" />,
};
type PrayerName = keyof typeof prayerIcons;
const prayerOrder: PrayerName[] = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

function formatTime12h(time24: string) {
    if (!time24) return '';
    const date = parse(time24, 'HH:mm', new Date());
    return format(date, 'hh:mm a');
}

function formatDistance(ms: number) {
    if (ms < 0) ms = 0;
    const totalSeconds = Math.floor(ms / 1000);
    const hours = Math.floor(totalSeconds / 3600);
    const minutes = Math.floor((totalSeconds % 3600) / 60);
    const seconds = totalSeconds % 60;
    
    return [
        hours.toString().padStart(2, '0'),
        minutes.toString().padStart(2, '0'),
        seconds.toString().padStart(2, '0')
    ].join(':');
}

export default function PrayerTimesPage() {
    const { userData } = useAuth();
    const [prayerTimes, setPrayerTimes] = useState<Record<string, string> | null>(null);
    const [loading, setLoading] = useState(true);
    const [location, setLocation] = useState<string>('your location');
    const [now, setNow] = useState(new Date());
    const [notificationStatus, setNotificationStatus] = useState<NotificationPermission>('default');
    const { toast } = useToast();

    useEffect(() => {
       if (typeof window !== 'undefined' && 'Notification' in window) {
            setNotificationStatus(Notification.permission);
       }
    }, []);

     useEffect(() => {
        const timer = setInterval(() => {
            setNow(new Date());
        }, 1000); // Update every second
        return () => clearInterval(timer);
    }, []);

    const nextPrayerInfo = useMemo(() => {
        if (!prayerTimes) return null;

        const today = new Date(); // Use a stable `today` for all comparisons in this cycle
        
        for (const prayerName of prayerOrder) {
            const prayerTimeStr = prayerTimes[prayerName];
            if (!prayerTimeStr) continue;

            // Ensure we are parsing the time against the current date
            const prayerDateTime = parse(prayerTimeStr, 'HH:mm', today);

            if (isAfter(prayerDateTime, now)) {
                return {
                    name: prayerName,
                    time: prayerDateTime,
                };
            }
        }
        
        // If all prayers for today are done, the next prayer is Fajr of the next day
        const fajrTimeStr = prayerTimes['Fajr'];
        if (fajrTimeStr) {
            const tomorrow = new Date(today);
            tomorrow.setDate(tomorrow.getDate() + 1);
            const fajrDateTime = parse(fajrTimeStr, 'HH:mm', tomorrow);
            return {
                name: 'Fajr',
                time: fajrDateTime,
            };
        }

        return null;
    }, [prayerTimes, now]);

    const timeToNextPrayer = useMemo(() => {
        if (!nextPrayerInfo) return 0;
        return differenceInMilliseconds(nextPrayerInfo.time, now);
    }, [nextPrayerInfo, now]);

    const fetchPrayerTimes = useCallback(async (latitude: number, longitude: number) => {
        setLoading(true);
        try {
            const response = await fetch(`https://api.aladhan.com/v1/timings?latitude=${latitude}&longitude=${longitude}&method=2`);
            if (!response.ok) throw new Error('Failed to fetch prayer times for your location.');
            const data = await response.json();
            setPrayerTimes(data.data.timings);
            setLocation('your current location');
        } catch (error) {
            console.error(error);
            toast({ variant: 'destructive', title: 'Error', description: 'Could not fetch prayer times for your location.' });
            fetchTimesByCountry(); // Fallback to country
        } finally {
            setLoading(false);
        }
    }, [toast]); // Added toast to dependency array

    const fetchTimesByCountry = useCallback(async () => {
        if (userData?.country) {
            // Use mapping first, then fallback to substring if not found. Default to US.
            const countryCode = countryCodeMapping[userData.country] || 'US'; 
            try {
                 const response = await fetch(`https://api.aladhan.com/v1/timingsByCity?city=${userData.country}&country=${countryCode}&method=2`);
                 if (!response.ok) throw new Error('Failed to fetch prayer times by country.');
                 const data = await response.json();
                 setPrayerTimes(data.data.timings);
                 setLocation(userData.country);
            } catch(e) {
                toast({ variant: 'destructive', title: 'Error', description: `Could not fetch prayer times for ${userData.country}.` });
            }
        } else {
             toast({ variant: 'destructive', title: 'Location Needed', description: 'Please set your country in your profile.' });
        }
        setLoading(false);
    }, [userData?.country, toast]);

    useEffect(() => {
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(
                (position) => {
                    fetchPrayerTimes(position.coords.latitude, position.coords.longitude);
                },
                (error) => {
                    console.warn(`Geolocation error: ${error.message}`);
                    toast({ title: "Location Access Denied", description: "Falling back to country from your profile."});
                    fetchTimesByCountry();
                }
            );
        } else {
            toast({ title: "Geolocation Not Supported", description: "Falling back to country from your profile."});
            fetchTimesByCountry();
        }

    }, [userData?.country, toast, fetchPrayerTimes, fetchTimesByCountry]);

    const handleEnableNotifications = async () => {
        if (typeof window === 'undefined' || !('Notification' in window)) {
            toast({ variant: 'destructive', title: 'Unsupported', description: 'Your browser does not support notifications.'});
            return;
        }

        const permission = await Notification.requestPermission();
        setNotificationStatus(permission);

        if (permission === 'granted') {
            toast({ title: 'Success!', description: 'You will now receive prayer time reminders.' });
            // Here you would typically register the service worker and get the push subscription
        } else if (permission === 'denied') {
            toast({ variant: 'destructive', title: 'Permission Denied', description: 'You have blocked notifications. To enable them, check your browser settings.' });
        } else {
            toast({ title: 'Permission Pending', description: 'Notification permission request was dismissed.' });
        }
    };


    return (
        <div className="container mx-auto p-4">
            <header className="my-6 text-center">
                <h1 className="text-4xl font-headline font-bold text-accent">Prayer Times</h1>
                <p className="text-muted-foreground text-lg">Based on {location}</p>
                 <p className="text-2xl font-mono font-bold text-foreground mt-2">
                    {format(now, 'hh:mm:ss a')}
                </p>
            </header>

            {loading && (
                <div className="flex justify-center mt-8">
                    <Loader2 className="h-10 w-10 animate-spin text-accent" />
                </div>
            )}
            
            {!loading && prayerTimes && (
                <div className="max-w-lg mx-auto space-y-6">
                    {nextPrayerInfo && (
                        <Card className="bg-accent/10 border-accent shadow-lg">
                            <CardHeader className="text-center">
                                <CardTitle className="flex items-center justify-center gap-2 font-headline text-accent">
                                    <BellRing />
                                    Next Prayer: {nextPrayerInfo.name}
                                </CardTitle>
                            </CardHeader>
                            <CardContent className="text-center">
                                <p className="text-4xl font-bold font-mono text-foreground">
                                    {formatDistance(timeToNextPrayer)}
                                </p>
                                <p className="text-muted-foreground mt-1">until Adhan</p>
                            </CardContent>
                        </Card>
                    )}

                    <Card>
                        <CardHeader>
                            <CardTitle className="text-center font-headline">Today's Schedule</CardTitle>
                        </CardHeader>
                        <CardContent className="space-y-4">
                            {prayerOrder
                                .map((key) => (
                                <div key={key} className={cn(
                                    "flex items-center justify-between p-3 rounded-lg transition-all",
                                    nextPrayerInfo?.name === key ? "bg-accent/20" : "bg-primary/10"
                                )}>
                                    <div className="flex items-center gap-4">
                                        {prayerIcons[key as PrayerName]}
                                        <span className="text-lg font-semibold">{key}</span>
                                    </div>
                                    <span className="text-lg font-mono font-bold">{formatTime12h(prayerTimes[key])}</span>
                                </div>
                            ))}
                        </CardContent>
                    </Card>
                    
                    <Card>
                        <CardHeader>
                            <CardTitle className="font-headline flex items-center gap-2"><Bell />Reminders</CardTitle>
                            <CardDescription>Enable push notifications for prayer times.</CardDescription>
                        </CardHeader>
                        <CardContent>
                            {notificationStatus === 'granted' ? (
                                <p className='text-green-600 font-semibold'>Notifications are enabled.</p>
                            ) : (
                                <Button className="w-full bg-accent hover:bg-accent/90" onClick={handleEnableNotifications} disabled={notificationStatus === 'denied'}>
                                    {notificationStatus === 'denied' ? 'Notifications Blocked' : 'Enable Notifications'}
                                </Button>
                            )}
                            {notificationStatus === 'denied' && (
                                <p className="text-xs text-muted-foreground mt-2">You have blocked notifications. You may need to go into your browser's site settings to re-enable them.</p>
                            )}
                        </CardContent>
                    </Card>
                </div>
            )}

            {!loading && !prayerTimes && (
                 <div className="text-center mt-8 p-4 bg-card rounded-lg max-w-lg mx-auto">
                    <p className="text-card-foreground font-semibold">Could Not Load Prayer Times</p>
                    <p className="text-muted-foreground mt-2">We couldn't fetch prayer times. Please check your location settings or set your country in your profile.</p>
                </div>
            )}
        </div>
    );
}
