class Profile {
  final String id;
  final String? spotifyUserId;
  final String? displayName;
  final String? email;
  final String? profileImageUrl;
  final String? country;
  final String? productType;

  Profile({
    required this.id,
    this.spotifyUserId,
    this.displayName,
    this.email,
    this.profileImageUrl,
    this.country,
    this.productType,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as String,
      spotifyUserId: json['spotify_user_id'] as String?,
      displayName: json['display_name'] as String?,
      email: json['email'] as String?,
      profileImageUrl: json['profile_image_url'] as String?,
      country: json['country'] as String?,
      productType: json['product_type'] as String?,
    );
  }
}
