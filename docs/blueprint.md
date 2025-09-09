# **App Name**: Noor: Quran Companion

## Core Features:

- Firebase Setup: Connect to an existing Firebase project using the provided hardcoded configuration in src/lib/firebase.ts. This is a mandatory step.
- Data Initializer: Seed Firestore 'quran' collection with data from https://quran-api-plpa.onrender.com/quran/surahs if the collection is empty, then read exclusively from Firestore thereafter.
- User Authentication: Implement user authentication (Sign Up, Login, Forgot Password) using Firebase Authentication. Capture and store country and font size preference on signup.
- UI Navigation: Implement a bottom navigation bar with Home, Continue Reading, Bookmarks, and Profile.
- Quran Reader: Display all 114 Surahs from Firestore in the Home screen. Display Surah verses with Arabic, English, and Hindi translations. Enable font size adjustments based on user preference.
- Bookmark Verses: Enable users to bookmark verses with personal notes.
- Last Read Tracking: Automatically update and store the last read position (Surah and verse) in Firestore and implement 'Continue Reading' feature to take user directly to the last read position.

## Style Guidelines:

- Primary color: Soft, muted green (#A7D1AB), reminiscent of traditional Islamic design and conveying peace and serenity. In RGB: (167, 209, 171)
- Background color: Light beige (#F5F5DC) to provide a warm, neutral backdrop, suggesting simplicity and focus. In RGB: (245, 245, 220)
- Accent color: Gold (#D4AF37) is an analogous color to the primary green; use for highlights, accents, and key interactive elements, evoking a sense of reverence. In RGB: (212, 175, 55)
- Font pairing: 'Alegreya', a serif font, for a blend of modern readability with classical elegance; used for headings. 'PT Sans', a modern and readable sans-serif font, is suitable for body text.
- Use simple, line-based icons in gold (#D4AF37) for navigation and interactive elements, ensuring clarity and elegance.
- Employ a clean, spacious layout with generous use of whitespace to promote readability and reduce visual clutter.
- Incorporate subtle transitions and animations for interactive elements (e.g., bookmark saving, navigation) to enhance user engagement without distraction.