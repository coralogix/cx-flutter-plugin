// user_context.dart

class UserContext {
  final String userId;
  final String userName;
  final String userEmail;
  final Map<String, String> userMetadata;

  UserContext({
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.userMetadata,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'userMetadata': userMetadata,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserContext &&
        other.userId == userId &&
        other.userName == userName &&
        other.userEmail == userEmail;
  }

  @override
  int get hashCode {
    return userId.hashCode ^
        userName.hashCode ^
        userEmail.hashCode ^
        userMetadata.hashCode;
  }
}
