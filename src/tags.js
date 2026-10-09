export function domain2tag(bookmark) {
  bookmark.tags ||= [];
  const domain = bookmark.url.hostname.split('.');
  if (domain.length <= 2) bookmark.tags.push(domain[0]);
  else bookmark.tags.push(domain[1]);
  return bookmark;
}
