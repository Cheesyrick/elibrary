class Book {
  final String title;
  final String author;
  final String subject;
  final String synopsis;
  final double? price;
  final String cover_image;

  Book({
    required this.title,
    required this.author,
    required this.subject,
    required this.synopsis,
    this.price,
    required this.cover_image,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      title: json['title'],
      author: json['author'],
      subject: json['subject'],
      synopsis: json['synopsis'],
      price: json['price']?.toDouble(),
      cover_image: json['cover_image'],
    );
  }
}
