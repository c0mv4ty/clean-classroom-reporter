/**
 * Browser-only helpers to shrink evidence photos under the upload cap.
 * Phone photos are typically 2 to 8 MB; they are scaled and re-encoded as JPEG until they fit.
 */

export type PhotoErrorReason = 'unreadable' | 'too_large';

export class PhotoError extends Error {
	readonly reason: PhotoErrorReason;

	constructor(reason: PhotoErrorReason) {
		super(reason);
		this.name = 'PhotoError';
		this.reason = reason;
	}
}

/** Formats the browser can decode and that may be uploaded untouched when already small. */
const PASS_THROUGH_TYPES = new Set(['image/jpeg', 'image/png', 'image/webp']);

/** Long edge steps (px) and JPEG qualities tried, largest and best first. */
const MAX_EDGES = [1600, 1280, 1024, 800];
const QUALITIES = [0.82, 0.72, 0.62, 0.5];

/** Aim below the cap so metadata or rounding never tips the file over it. */
const TARGET_RATIO = 0.95;

type Decoded = {
	source: CanvasImageSource;
	width: number;
	height: number;
	release: () => void;
};

async function decode(file: File): Promise<Decoded> {
	if (typeof createImageBitmap === 'function') {
		try {
			const bitmap = await createImageBitmap(file, { imageOrientation: 'from-image' });
			return {
				source: bitmap,
				width: bitmap.width,
				height: bitmap.height,
				release: () => bitmap.close()
			};
		} catch {
			// Fall through to the <img> path; some browsers reject options or specific formats.
		}
	}

	const url = URL.createObjectURL(file);
	try {
		const img = new Image();
		img.decoding = 'async';
		img.src = url;
		await img.decode();
		return {
			source: img,
			width: img.naturalWidth,
			height: img.naturalHeight,
			release: () => URL.revokeObjectURL(url)
		};
	} catch {
		URL.revokeObjectURL(url);
		throw new PhotoError('unreadable');
	}
}

async function encode(
	{ source, width, height }: Decoded,
	maxEdge: number,
	quality: number
): Promise<Blob | null> {
	const scale = Math.min(1, maxEdge / Math.max(width, height));
	const w = Math.max(1, Math.round(width * scale));
	const h = Math.max(1, Math.round(height * scale));

	if (typeof OffscreenCanvas !== 'undefined') {
		const canvas = new OffscreenCanvas(w, h);
		const ctx = canvas.getContext('2d');
		if (!ctx) return null;
		// JPEG has no alpha: paint white first so transparent PNGs do not turn black.
		ctx.fillStyle = '#fff';
		ctx.fillRect(0, 0, w, h);
		ctx.drawImage(source, 0, 0, w, h);
		return canvas.convertToBlob({ type: 'image/jpeg', quality });
	}

	const canvas = document.createElement('canvas');
	canvas.width = w;
	canvas.height = h;
	const ctx = canvas.getContext('2d');
	if (!ctx) return null;
	ctx.fillStyle = '#fff';
	ctx.fillRect(0, 0, w, h);
	ctx.drawImage(source, 0, 0, w, h);
	return new Promise((resolve) => canvas.toBlob(resolve, 'image/jpeg', quality));
}

function jpegName(name: string) {
	const base = name.replace(/\.[^./\\]+$/, '');
	return `${base || 'foto'}.jpg`;
}

/**
 * Returns a file no larger than `maxBytes`. A small JPEG, PNG or WEBP is returned untouched;
 * anything else is scaled and re-encoded as JPEG. Every file is decoded first, so a file that is
 * not a real image is rejected here instead of reaching the server.
 *
 * @throws {PhotoError} `unreadable` when the browser cannot decode it (e.g. HEIC outside Safari),
 * `too_large` when even the smallest settings stay above the cap.
 */
export async function compressImage(file: File, maxBytes: number): Promise<File> {
	const decoded = await decode(file);
	try {
		if (file.size <= maxBytes && PASS_THROUGH_TYPES.has(file.type)) return file;

		const limit = Math.floor(maxBytes * TARGET_RATIO);
		for (const maxEdge of MAX_EDGES) {
			for (const quality of QUALITIES) {
				const blob = await encode(decoded, maxEdge, quality);
				if (blob && blob.size <= limit) {
					return new File([blob], jpegName(file.name), {
						type: 'image/jpeg',
						lastModified: Date.now()
					});
				}
			}
		}
		throw new PhotoError('too_large');
	} finally {
		decoded.release();
	}
}
