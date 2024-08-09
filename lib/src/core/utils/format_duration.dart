String formatDuration(int duration) {
  final hours = duration ~/ 60;
  final minutes = duration % 60;

  if (hours == 0) {
    return '${minutes}min';
  } else if (minutes == 0) {
    return '${hours}h';
  } else {
    return '${hours}h ${minutes}min';
  }
}
