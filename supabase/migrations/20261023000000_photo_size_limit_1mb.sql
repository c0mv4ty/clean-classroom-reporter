-- Evidence photos are capped at 1 MB (was 10 MB).
-- The app compresses photos in the browser before upload, so presidentes rarely notice the cap.
-- Idempotent: running it again leaves the same value.
-- Deploy order: ship the app first, then run this. A 1 MB bucket would reject the 10 MB
-- uploads an older app version can still send.
update storage.buckets
set file_size_limit = 1048576 -- 1 MB
where id = 'evidencias';
