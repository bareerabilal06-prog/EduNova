class Profile {
  final int? id;
  final String name;
  final String gender;
  final int age;
  final String? email;

  Profile({
    this.id,
    required this.name,
    required this.gender,
    required this.age,
    this.email,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'gender': gender,
      'age': age,
      'email': email,
    };
  }

  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      id: map['id'],
      name: map['name'],
      gender: map['gender'],
      age: map['age'],
      email: map['email'] as String?,
    );
  }
}