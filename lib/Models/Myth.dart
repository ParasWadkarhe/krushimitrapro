class Myth {
  final String title;
  final String description;
  final String url;
  final String? urlToImage; // nullable field
  final String? publishedAt; // nullable field

  Myth({
    required this.title,
    required this.description,
    required this.url,
    this.urlToImage,
    this.publishedAt,
  });

  factory Myth.fromJson(Map<String, dynamic> json) {
    return Myth(
      title: json['title'] ?? '', // Default to empty string if null
      description: json['description'] ?? '', // Default to empty string if null
      url: json['url'] ?? '', // Default to empty string if null
      urlToImage: json['urlToImage'] as String?, // Handle nullable fields
      publishedAt: json['publishedAt'] as String?, // Handle nullable fields
    );
  }
}
