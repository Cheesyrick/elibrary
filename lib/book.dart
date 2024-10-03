class Book {
  final String title;
  final String author;
  final String subject;
  final double? price;
  Book({
    required this.title,
    required this.author,
    required this.subject,
    this.price,
  });
  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      title: json['title'],
      author: json['author'],
      subject: json['subject'],
      price: json['price']?.toDouble(),
    );
  }
}
