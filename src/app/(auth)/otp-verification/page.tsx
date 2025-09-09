'use client';

import { useState, useEffect } from 'react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import * as z from 'zod';
import { createUserWithEmailAndPassword } from 'firebase/auth';
import { doc, setDoc } from 'firebase/firestore';
import { auth, db } from '@/lib/firebase';
import { useToast } from '@/hooks/use-toast';
import { useRouter, useSearchParams } from 'next/navigation';
import Link from 'next/link';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from '@/components/ui/card';
import { Form, FormControl, FormField, FormItem, FormLabel, FormMessage } from '@/components/ui/form';
import { Loader2, Mail, ArrowLeft } from 'lucide-react';

const formSchema = z.object({
  otp: z.string().min(6, { message: 'OTP must be 6 digits.' }).max(6, { message: 'OTP must be 6 digits.' }),
});

export default function OTPVerificationPage() {
  const [loading, setLoading] = useState(false);
  const [resendLoading, setResendLoading] = useState(false);
  const [countdown, setCountdown] = useState(60);
  const { toast } = useToast();
  const router = useRouter();
  const searchParams = useSearchParams();

  // Get user data from URL params
  const email = searchParams.get('email');
  const name = searchParams.get('name');
  const password = searchParams.get('password');
  const dob = searchParams.get('dob');
  const country = searchParams.get('country');
  const fontSize = searchParams.get('fontSize');

  const form = useForm<z.infer<typeof formSchema>>({
    resolver: zodResolver(formSchema),
    defaultValues: {
      otp: '',
    },
  });

  // Countdown timer for resend
  useEffect(() => {
    if (countdown > 0) {
      const timer = setTimeout(() => setCountdown(countdown - 1), 1000);
      return () => clearTimeout(timer);
    }
  }, [countdown]);

  const sendOTP = async () => {
    if (!email) return;

    setResendLoading(true);
    try {
      const response = await fetch('/api/send-otp', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          email,
          name: name || 'User',
        }),
      });

      const data = await response.json();

      if (data.success) {
        toast({
          title: 'OTP Sent',
          description: 'A new OTP has been sent to your email.',
        });
        setCountdown(60);
      } else {
        toast({
          variant: 'destructive',
          title: 'Failed to Send OTP',
          description: data.error || 'Please try again.',
        });
      }
    } catch (error) {
      toast({
        variant: 'destructive',
        title: 'Network Error',
        description: 'Please check your connection and try again.',
      });
    } finally {
      setResendLoading(false);
    }
  };

  const onSubmit = async (values: z.infer<typeof formSchema>) => {
    if (!email || !password || !name || !dob || !country || !fontSize) {
      toast({
        variant: 'destructive',
        title: 'Missing Information',
        description: 'Please go back and complete the signup form.',
      });
      return;
    }

    setLoading(true);
    try {
      // Verify OTP first
      const verifyResponse = await fetch('/api/verify-otp', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          email,
          otp: values.otp,
        }),
      });

      const verifyData = await verifyResponse.json();

      if (!verifyData.success) {
        toast({
          variant: 'destructive',
          title: 'Invalid OTP',
          description: verifyData.error || 'Please check your OTP and try again.',
        });
        return;
      }

      // OTP verified, now create Firebase account
      const userCredential = await createUserWithEmailAndPassword(auth, email, password);
      const user = userCredential.user;

      // Save user data to Firestore
      await setDoc(doc(db, 'users', user.uid), {
        uid: user.uid,
        email: user.email,
        name,
        dob,
        country,
        fontSize,
        photoURL: '',
        createdAt: new Date().toISOString(),
        emailVerified: true,
      });

      toast({
        title: 'Account Created Successfully',
        description: 'Welcome to Noor! Your account has been verified.',
      });

      // Redirect to home page
      router.push('/');

    } catch (error: any) {
      toast({
        variant: 'destructive',
        title: 'Account Creation Failed',
        description: error.message,
      });
    } finally {
      setLoading(false);
    }
  };

  // Send initial OTP when component mounts
  useEffect(() => {
    if (email) {
      sendOTP();
    }
  }, [email]);

  if (!email || !password || !name || !dob || !country || !fontSize) {
    return (
      <Card className="w-full max-w-md mx-auto">
        <CardHeader className="text-center">
          <CardTitle className="text-2xl font-headline text-accent">Invalid Access</CardTitle>
          <CardDescription>Please complete the signup form first</CardDescription>
        </CardHeader>
        <CardContent className="text-center">
          <Link href="/signup">
            <Button className="bg-accent hover:bg-accent/90 text-accent-foreground">
              <ArrowLeft className="mr-2 h-4 w-4" />
              Back to Signup
            </Button>
          </Link>
        </CardContent>
      </Card>
    );
  }

  return (
    <Card className="w-full max-w-md mx-auto">
      <CardHeader className="text-center">
        <Mail className="mx-auto h-12 w-12 text-accent mb-4" />
        <CardTitle className="text-3xl font-headline text-accent">Verify Your Email</CardTitle>
        <CardDescription>
          We've sent a 6-digit code to <strong>{email}</strong>
        </CardDescription>
      </CardHeader>
      <CardContent>
        <Form {...form}>
          <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-4">
            <FormField
              control={form.control}
              name="otp"
              render={({ field }) => (
                <FormItem>
                  <FormLabel>Enter OTP Code</FormLabel>
                  <FormControl>
                    <Input
                      placeholder="000000"
                      maxLength={6}
                      className="text-center text-2xl tracking-widest"
                      {...field}
                    />
                  </FormControl>
                  <FormMessage />
                </FormItem>
              )}
            />
            <Button
              type="submit"
              className="w-full bg-accent hover:bg-accent/90 text-accent-foreground"
              disabled={loading}
            >
              {loading ? <Loader2 className="mr-2 h-4 w-4 animate-spin" /> : 'Verify & Create Account'}
            </Button>
          </form>
        </Form>
      </CardContent>
      <CardFooter className="flex flex-col space-y-4">
        <div className="text-center">
          <p className="text-sm text-muted-foreground mb-2">
            Didn't receive the code?
          </p>
          <Button
            variant="outline"
            onClick={sendOTP}
            disabled={countdown > 0 || resendLoading}
            className="w-full"
          >
            {resendLoading ? (
              <Loader2 className="mr-2 h-4 w-4 animate-spin" />
            ) : countdown > 0 ? (
              `Resend in ${countdown}s`
            ) : (
              'Resend OTP'
            )}
          </Button>
        </div>
        <Link href="/signup" className="text-center">
          <Button variant="ghost" className="text-sm">
            <ArrowLeft className="mr-2 h-4 w-4" />
            Back to Signup
          </Button>
        </Link>
      </CardFooter>
    </Card>
  );
}
