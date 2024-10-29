// Created a Model to get access to firestore to store our data
class UserModel {
  String? uid;
  String? phoneNumber;
  String? firstName;
  String? lastName;

  UserModel({this.uid, this.phoneNumber, this.firstName, this.lastName});

  // receiving data from server
  factory UserModel.fromMap(map) {
    return UserModel(
      uid: map['uid'],
      phoneNumber: map['phoneNumber'],
      firstName: map['firstName'],
      lastName: map['lastName'],
    );
  }

  // sending data to our server
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': phoneNumber,
      'firstName': firstName,
      'lastName': lastName,
    };
  }
}