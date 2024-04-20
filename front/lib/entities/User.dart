class User {
  final String? phone, firstName, secondName, lastName, picturePath;

  User(this.phone, this.firstName, this.secondName, this.lastName, this.picturePath);

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      json['phone'],
      json['first_name'],
      json['second_name'],
      json['last_name'],
      json['picture_path'],
    );
  }
}