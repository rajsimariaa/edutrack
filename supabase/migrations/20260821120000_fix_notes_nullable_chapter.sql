-- Make notes.chapter_id nullable so general notes don't need a chapter
ALTER TABLE notes ALTER COLUMN chapter_id DROP NOT NULL;
