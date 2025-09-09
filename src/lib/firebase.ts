import { initializeApp, getApp, getApps } from "firebase/app";
import { getAuth } from "firebase/auth";
import { getFirestore } from "firebase/firestore";

// This is the specific configuration for the existing Firebase project.
const firebaseConfig = {
  "projectId": "noor-4asnz",
  "appId": "1:965023247103:web:2a15ae0cffed5fc0423aca",
  "storageBucket": "noor-4asnz.appspot.com",
  "apiKey": "AIzaSyAt01Mu5xOU4CsPpgWIRUC3XZ5ANiSikEI",
  "authDomain": "noor-4asnz.firebaseapp.com",
  "messagingSenderId": "965023247103"
};

// Initialize Firebase
const app = !getApps().length ? initializeApp(firebaseConfig) : getApp();
const auth = getAuth(app);
const db = getFirestore(app);

export { app, auth, db };
