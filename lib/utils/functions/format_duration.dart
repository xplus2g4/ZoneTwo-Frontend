String formatDuration(Duration duration) {
  if (duration.inHours > 0) {
    return '${duration.inHours}:${duration.inMinutes.remainder(60).toString().padLeft(2, '0')}:${duration.inSeconds.remainder(60).toString().padLeft(2, '0')}';
  }
  return "${duration.inMinutes.remainder(60).toString().padLeft(2, '0')}:${duration.inSeconds.remainder(60).toString().padLeft(2, '0')}";
}
