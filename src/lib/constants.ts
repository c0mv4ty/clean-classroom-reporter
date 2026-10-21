/** Shared by the user-creation form (client hint) and its server action (validation). */
export const MIN_PASSWORD_LENGTH = 8;

/**
 * Evidence photo cap. The browser compresses to fit under it, the report action enforces it, and
 * the `evidencias` bucket mirrors it (`file_size_limit`, migration 20261023000000).
 */
export const MAX_PHOTO_BYTES = 1024 * 1024;
