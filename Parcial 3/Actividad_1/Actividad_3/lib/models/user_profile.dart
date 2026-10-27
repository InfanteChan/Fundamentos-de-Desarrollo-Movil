class UserProfile {
  final String id;
  final String email;
  final String fullName;
  final String role; // 'comprador' | 'vendedor'
  final DateTime createdAt;

  const UserProfile({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    required this.createdAt,
  });

  bool get isSeller => role == 'vendedor';
  bool get isBuyer => role == 'comprador';
}