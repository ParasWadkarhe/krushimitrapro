class NewsArticle {
  final String title;
  final String description;
  final String url;
  final String? imageUrl;
  final String author;
  final String publishedAt;
  final String? sourceName;

  NewsArticle({
    required this.title,
    required this.description,
    required this.url,
    this.imageUrl,
    required this.author,
    required this.publishedAt,
    this.sourceName,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      title: json['title'] ?? 'No Title Available',
      description: json['description'] ?? 'No Description Available',
      url: json['url'] ?? '',
      imageUrl: json['urlToImage'],
      author: json['author'] ?? 'Unknown',
      publishedAt: json['publishedAt'] ?? 'Unknown Date',
      sourceName: json['source'] != null ? json['source']['name'] ?? 'Unknown Source' : 'Unknown Source',
    );
  }
}
