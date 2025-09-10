// In-memory storage for OTPs (in production, use Redis or database)
interface OTPData {
  otp: string;
  expiresAt: number;
  name: string;
  attempts: number;
  type?: string; // 'email_verification' | 'password_reset'
}

class OTPStore {
  private store = new Map<string, OTPData>();

  // Store OTP
  set(email: string, data: OTPData) {
    this.store.set(email, data);
  }

  // Get OTP data
  get(email: string): OTPData | undefined {
    return this.store.get(email);
  }

  // Delete OTP
  delete(email: string) {
    this.store.delete(email);
  }

  // Clean up expired OTPs
  cleanup() {
    const now = Date.now();
    for (const [email, data] of this.store.entries()) {
      if (now > data.expiresAt) {
        this.store.delete(email);
      }
    }
  }

  // Get all entries (for debugging)
  entries() {
    return this.store.entries();
  }
}

// Create singleton instance
const otpStore = new OTPStore();

// Clean up expired OTPs every 5 minutes
setInterval(() => {
  otpStore.cleanup();
}, 5 * 60 * 1000);

export default otpStore;
