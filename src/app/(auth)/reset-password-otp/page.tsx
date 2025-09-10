'use client';

import { useState, useEffect } from 'react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import * as z from 'zod';
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
  newPassword: z.string().min(6, { message: 'Password must be at least 6 characters.' }),
  confirmPassword: z.string().min(6, { message: 'Please confirm your password.' }),
}).refine((data) => data.newPassword === data.confirmPassword, {
  message: "Passwords don't match",
  path: ["confirmPassword"],
});

export default function ResetPasswordOTPPage() {
  const [loading, setLoading] = useState(false);
  const [resendLoading, setResendLoading] = useState(false);
  const [countdown, setCountdown] = useState(60);
  const { toast } = useToast();
  const router = useRouter();
  const searchParams = useSearchParams();

  // Get email from URL params
  const email = searchParams.get('email');

  const form = useForm<z.infer<typeof formSchema>>({
    resolver: zodResolver(formSchema),
    defaultValues: {
      otp: '',
      newPassword: '',
      confirmPassword: '',
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
      const response = await fetch('/api/forgot-password', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          email,
          name: 'User',
        }),
      });

      const data = await response.json();

      if (data.success) {
        toast({
          title: 'OTP Sent',
          description: 'A new password reset OTP has been sent to your email.',
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
    if (!email) {
      toast({
        variant: 'destructive',
        title: 'Missing Information',
        description: 'Please go back and enter your email.',
      });
      return;
    }

    setLoading(true);
    try {
      // Verify OTP and reset password
      const verifyResponse = await fetch('/api/reset-password', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          email,
          otp: values.otp,
          newPassword: values.newPassword,
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

      toast({
        title: 'Password Reset Successful',
        description: 'Your password has been reset successfully. You can now login with your new password.',
      });

      // Redirect to login page
      router.push('/login');

    } catch (error: any) {
      toast({
        variant: 'destructive',
        title: 'Password Reset Failed',
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

  if (!email) {
    return (
      <Card className="w-full max-w-md mx-auto">
        <CardHeader className="text-center">
          <CardTitle className="text-2xl font-headline text-accent">Invalid Access</CardTitle>
          <CardDescription>Please enter your email first</CardDescription>
        </CardHeader>
        <CardContent className="text-center">
          <Link href="/forgot-password">
            <Button className="bg-accent hover:bg-accent/90 text-accent-foreground">
              <ArrowLeft className="mr-2 h-4 w-4" />
              Back to Forgot Password
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
        <CardTitle className="text-3xl font-headline text-accent">Reset Your Password</CardTitle>
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

            <FormField
              control={form.control}
              name="newPassword"
              render={({ field }) => (
                <FormItem>
                  <FormLabel>New Password</FormLabel>
                  <FormControl>
                    <Input
                      type="password"
                      placeholder="••••••••"
                      {...field}
                    />
                  </FormControl>
                  <FormMessage />
                </FormItem>
              )}
            />

            <FormField
              control={form.control}
              name="confirmPassword"
              render={({ field }) => (
                <FormItem>
                  <FormLabel>Confirm New Password</FormLabel>
                  <FormControl>
                    <Input
                      type="password"
                      placeholder="••••••••"
                      {...field}
                    />
                  </FormControl>
                  <FormMessage />
                </FormItem>
              )}
            />

            <Button type="submit" className="w-full bg-accent hover:bg-accent/90 text-accent-foreground" disabled={loading}>
              {loading ? <Loader2 className="mr-2 h-4 w-4 animate-spin" /> : 'Reset Password'}
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
        <Link href="/forgot-password" className="text-center">
          <Button variant="ghost" className="text-sm">
            <ArrowLeft className="mr-2 h-4 w-4" />
            Back to Forgot Password
          </Button>
        </Link>
      </CardFooter>
    </Card>
  );
}
