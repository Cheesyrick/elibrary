class Book {
  final String title;
  final String author;
  final String subject;
  final double? price;
  final String synopsis;
  Book({
    required this.title,
    required this.author,
    required this.subject,
    this.price,
    required this.synopsis,
  });
  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      title: json['title'],
      author: json['author'],
      subject: json['subject'],
      price: json['price']?.toDouble(),
      synopsis: json['synopsis'],
    );
  }
}
