class Book {
  final String title;
  final String author;
  final String subject;
  final String synopsis;
  double? price;
  final String cover_image;
  final String id;
  final String content;

  Book({
    required this.title,
    required this.author,
    required this.subject,
    required this.synopsis,
    this.price,
    required this.cover_image,
    required this.id,
    this.content = '',
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      title: json['title'],
      author: json['author'],
      subject: json['subject'],
      synopsis: json['synopsis'],
      price: json['price']?.toDouble(),
      cover_image: json['cover_image'],
      id: json['id'],
      content: json['content'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'author': author,
      'subject': subject,
      'synopsis': synopsis,
      'price': price,
      'cover_image': cover_image,
      'id': id,
      'content': content,
    };
  }
}
