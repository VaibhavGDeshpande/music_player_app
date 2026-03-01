class LyricLine {
  final int startTimeMs;
  final String words;

  LyricLine({required this.startTimeMs, required this.words});

  factory LyricLine.fromJson(Map<String, dynamic> json) {
    return LyricLine(
      startTimeMs: int.tryParse(json['startTimeMs'].toString()) ?? 0,
      words: json['words']?.toString() ?? '',
    );
  }
}
