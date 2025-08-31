class Participant {
  final String id;
  final String name;
  final String email;
  final String photoUrl;

  Participant({
    required this.id,
    required this.name,
    required this.email,
    required this.photoUrl,
  });

  factory Participant.fromJson(Map<String, dynamic> json) => Participant(
    id: json['id'],
    name: json['name'],
    email: json['email'],
    photoUrl: json['photoUrl'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'photoUrl': photoUrl,
  };
}
