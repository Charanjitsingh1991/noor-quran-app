'use client';

import React, { createContext, useState, useEffect, ReactNode } from 'react';
import { onAuthStateChanged, User } from 'firebase/auth';
import { doc, getDoc, onSnapshot } from 'firebase/firestore';
import { auth, db } from '@/lib/firebase';
import type { UserProfile } from '@/types';

interface AuthContextType {
  user: User | null;
  userData: UserProfile | null;
  loading: boolean;
  refetchUserData: () => void;
}

export const AuthContext = createContext<AuthContextType>({
  user: null,
  userData: null,
  loading: true,
  refetchUserData: () => {},
});

export const AuthProvider = ({ children }: { children: ReactNode }) => {
  const [user, setUser] = useState<User | null>(null);
  const [userData, setUserData] = useState<UserProfile | null>(null);
  const [loading, setLoading] = useState(true);

  const fetchUserData = (currentUser: User) => {
    const userDocRef = doc(db, 'users', currentUser.uid);
    // Use onSnapshot to listen for real-time updates
    const unsubscribe = onSnapshot(userDocRef, (doc) => {
      if (doc.exists()) {
        setUserData(doc.data() as UserProfile);
      } else {
        setUserData(null); // Handle case where user document doesn't exist
      }
      // Data is loaded, set loading to false
      if(loading) setLoading(false);
    }, (error) => {
        console.error("Error fetching user data:", error);
        setUserData(null);
        if(loading) setLoading(false);
    });
    return unsubscribe; // Return the unsubscribe function for cleanup
  };
  
  const refetchUserData = () => {
    if (user) {
        const userDocRef = doc(db, 'users', user.uid);
        getDoc(userDocRef).then(doc => {
             if (doc.exists()) {
                setUserData(doc.data() as UserProfile);
            }
        });
    }
  }

  useEffect(() => {
    let userDataUnsubscribe: (() => void) | undefined;

    const authUnsubscribe = onAuthStateChanged(auth, (currentUser) => {
      // If there's an existing user data listener, unsubscribe from it
      if (userDataUnsubscribe) {
        userDataUnsubscribe();
      }

      if (currentUser) {
        setUser(currentUser);
        // Set up a new listener for the new user's data
        userDataUnsubscribe = fetchUserData(currentUser);
      } else {
        setUser(null);
        setUserData(null);
        setLoading(false); // No user, so not loading
      }
    });

    // Cleanup both listeners on component unmount
    return () => {
      authUnsubscribe();
      if (userDataUnsubscribe) {
        userDataUnsubscribe();
      }
    };
  }, []); // The empty dependency array ensures this runs only once on mount

  const value = { user, userData, loading, refetchUserData };

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
};
