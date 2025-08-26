@@ .. @@
      profiles (id, email, full_name, avatar_url, formation, onboarding_completed)
    VALUES (
      NEW.id,
      NEW.email,
      COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.raw_user_meta_data->>'name', SPLIT_PART(NEW.email, '@', 1)),
      NEW.raw_user_meta_data->>'avatar_url',
-     'BUT GEII - Parcours AII',
+     'Votre BUT + Votre Parcours',
      false
    );