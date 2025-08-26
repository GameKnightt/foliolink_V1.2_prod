@@ .. @@
 -- Security policies
 CREATE POLICY "Users can read own categories"
   ON apprentissage_categories
   FOR SELECT
   TO authenticated
-  USING (user_id = auth.uid());
+  USING (user_id = (SELECT id FROM profiles WHERE id = auth.uid()));

 CREATE POLICY "Users can insert own categories"
   ON apprentissage_categories
   FOR INSERT
   TO authenticated
-  WITH CHECK (user_id = auth.uid());
+  WITH CHECK (user_id = (SELECT id FROM profiles WHERE id = auth.uid()));

 CREATE POLICY "Users can update own categories"
   ON apprentissage_categories
   FOR UPDATE
   TO authenticated
-  USING (user_id = auth.uid())
-  WITH CHECK (user_id = auth.uid());
+  USING (user_id = (SELECT id FROM profiles WHERE id = auth.uid()))
+  WITH CHECK (user_id = (SELECT id FROM profiles WHERE id = auth.uid()));

 CREATE POLICY "Users can delete own categories"
   ON apprentissage_categories
   FOR DELETE
   TO authenticated
-  USING (user_id = auth.uid());
+  USING (user_id = (SELECT id FROM profiles WHERE id = auth.uid()));

 -- Update apprentissages table to add category reference
 DO $$
@@ .. @@
 -- Update apprentissages policies to handle categories
 CREATE POLICY "Users can read apprentissages with categories"
   ON apprentissages
   FOR SELECT
   TO authenticated
-  USING (user_id = auth.uid());
+  USING (user_id = (SELECT id FROM profiles WHERE id = auth.uid()));

 CREATE POLICY "Users can insert apprentissages with categories"
   ON apprentissages
   FOR INSERT
   TO authenticated
-  WITH CHECK (user_id = auth.uid());
+  WITH CHECK (user_id = (SELECT id FROM profiles WHERE id = auth.uid()));

 CREATE POLICY "Users can update apprentissages with categories"
   ON apprentissages
   FOR UPDATE
   TO authenticated
-  USING (user_id = auth.uid())
-  WITH CHECK (user_id = auth.uid());
+  USING (user_id = (SELECT id FROM profiles WHERE id = auth.uid()))
+  WITH CHECK (user_id = (SELECT id FROM profiles WHERE id = auth.uid()));

 CREATE POLICY "Users can delete apprentissages with categories"
   ON apprentissages
   FOR DELETE
   TO authenticated
-  USING (user_id = auth.uid());
+  USING (user_id = (SELECT id FROM profiles WHERE id = auth.uid()));