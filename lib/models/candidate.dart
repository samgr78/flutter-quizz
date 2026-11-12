const List<String> motivations = [
  "Poursuite d'études",
  'Reconversion pro',
  'Réorientation',
];

class Candidate {
  final String lastName;
  final String firstName;
  final String email;
  final int age;
  final String address;
  final String motivation;

  Candidate({
    required this.lastName,
    required this.firstName,
    required this.email,
    required this.age,
    required this.address,
    required this.motivation,
  });


  Map<String, dynamic> toJson() {
    return {
      'lastName': lastName,
      'firstName': firstName,
      'email': email,
      'age': age,
      'address': address,
      'motivation': motivation,
    };
  }


  factory Candidate.fromJson(Map<String, dynamic> json) {
    return Candidate(
      lastName: json['lastName'],
      firstName: json['firstName'],
      email: json['email'],
      age: json['age'],
      address: json['address'],
      motivation: json['motivation'],
    );
  }
}
