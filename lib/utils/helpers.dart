String formatImageUrl(String? url) {
  if (url == null || url.isEmpty) return '';
  return url.startsWith('http') ? url : 'https:$url';
}
