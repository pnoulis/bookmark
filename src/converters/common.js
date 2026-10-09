import { join } from 'node:path';

export function normalizeBookmark(bookmark) {
  // 1. Strip search query parameters
  // 2. Decode
  bookmark.decodedURL = bookmark.url.origin + decodeURIComponent(bookmark.url.pathname);

  // 3. Remove trailing path delimiters
  if (bookmark.decodedURL.endsWith('/')) bookmark.decodedURL = bookmark.decodedURL.slice(0, -1);

  return bookmark;
}
