import { URL } from 'node:url';
import { normalizeBookmark } from './common.js';

function convert(node, bookmarks) {
  if (node.children) {
    for (let i = 0; i < node.children.length; i++) convert(node.children[i], bookmarks);
  } else if (node.uri) {
    const url = new URL(node.uri);
    if (url.origin === 'null') return bookmarks;
    bookmarks.push(normalizeBookmark({
      title: node.title,
      url,
    }));
  }
  return bookmarks;
}

export default function convertFirefoxBookmarks(firefoxBookmarks) {
  return convert(firefoxBookmarks, []);
}
