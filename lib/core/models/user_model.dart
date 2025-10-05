import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserModel extends Equatable {
  final String uid;
  final String? email;
  final String? displayName;
  final String? firstName;
  final String? lastName;
  final String? phoneNumber;
  final String? photoURL;
  final bool isEmailVerified;
  final bool isPhoneVerified;
  final DateTime? createdAt;
  final DateTime? lastSignInAt;
  final DateTime? lastUpdatedAt;
  final String? providerId;
  final List<String> providerIds;
  final Map<String, dynamic>? customClaims;
  final String? locale;
  final String? timezone;
  final bool isAnonymous;
  final bool isDisabled;
  final Map<String, dynamic>? metadata;

  const UserModel({
    required this.uid,
    this.email,
    this.displayName,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.photoURL,
    this.isEmailVerified = false,
    this.isPhoneVerified = false,
    this.createdAt,
    this.lastSignInAt,
    this.lastUpdatedAt,
    this.providerId,
    this.providerIds = const [],
    this.customClaims,
    this.locale,
    this.timezone,
    this.isAnonymous = false,
    this.isDisabled = false,
    this.metadata,
  });

  // Create UserModel from Firebase User
  factory UserModel.fromFirebaseUser(User user) {
    // Parse display name into first and last name
    String? firstName;
    String? lastName;
    if (user.displayName != null && user.displayName!.isNotEmpty) {
      final nameParts = user.displayName!.split(' ');
      if (nameParts.length >= 2) {
        firstName = nameParts.first;
        lastName = nameParts.sublist(1).join(' ');
      } else {
        firstName = nameParts.first;
      }
    }

    // Extract provider IDs
    final providerIds =
        user.providerData.map((info) => info.providerId).toList();

    return UserModel(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      firstName: firstName,
      lastName: lastName,
      phoneNumber: user.phoneNumber,
      photoURL: user.photoURL,
      isEmailVerified: user.emailVerified,
      isPhoneVerified: user.phoneNumber != null,
      createdAt: user.metadata.creationTime,
      lastSignInAt: user.metadata.lastSignInTime,
      lastUpdatedAt: DateTime.now(),
      providerId: user.providerData.isNotEmpty
          ? user.providerData.first.providerId
          : null,
      providerIds: providerIds,
      isAnonymous: user.isAnonymous,
      isDisabled: false, // Firebase User doesn't have isDisabled property
      metadata: {
        'refreshToken': user.refreshToken,
        'tenantId': user.tenantId,
        'multiFactor': false, // Multi-factor authentication status
      },
    );
  }

  // Create UserModel from Map (for local storage)
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'],
      displayName: map['displayName'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      phoneNumber: map['phoneNumber'],
      photoURL: map['photoURL'],
      isEmailVerified: map['isEmailVerified'] ?? false,
      isPhoneVerified: map['isPhoneVerified'] ?? false,
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
          : null,
      lastSignInAt: map['lastSignInAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['lastSignInAt'])
          : null,
      lastUpdatedAt: map['lastUpdatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['lastUpdatedAt'])
          : null,
      providerId: map['providerId'],
      providerIds: List<String>.from(map['providerIds'] ?? []),
      customClaims: map['customClaims'],
      locale: map['locale'],
      timezone: map['timezone'],
      isAnonymous: map['isAnonymous'] ?? false,
      isDisabled: map['isDisabled'] ?? false,
      metadata: map['metadata'],
    );
  }

  // Convert UserModel to Map (for local storage)
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'photoURL': photoURL,
      'isEmailVerified': isEmailVerified,
      'isPhoneVerified': isPhoneVerified,
      'createdAt': createdAt?.millisecondsSinceEpoch,
      'lastSignInAt': lastSignInAt?.millisecondsSinceEpoch,
      'lastUpdatedAt': lastUpdatedAt?.millisecondsSinceEpoch,
      'providerId': providerId,
      'providerIds': providerIds,
      'customClaims': customClaims,
      'locale': locale,
      'timezone': timezone,
      'isAnonymous': isAnonymous,
      'isDisabled': isDisabled,
      'metadata': metadata,
    };
  }

  // Create a copy of UserModel with updated fields
  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? photoURL,
    bool? isEmailVerified,
    bool? isPhoneVerified,
    DateTime? createdAt,
    DateTime? lastSignInAt,
    DateTime? lastUpdatedAt,
    String? providerId,
    List<String>? providerIds,
    Map<String, dynamic>? customClaims,
    String? locale,
    String? timezone,
    bool? isAnonymous,
    bool? isDisabled,
    Map<String, dynamic>? metadata,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photoURL: photoURL ?? this.photoURL,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      createdAt: createdAt ?? this.createdAt,
      lastSignInAt: lastSignInAt ?? this.lastSignInAt,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      providerId: providerId ?? this.providerId,
      providerIds: providerIds ?? this.providerIds,
      customClaims: customClaims ?? this.customClaims,
      locale: locale ?? this.locale,
      timezone: timezone ?? this.timezone,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      isDisabled: isDisabled ?? this.isDisabled,
      metadata: metadata ?? this.metadata,
    );
  }

  // Get full name from first and last name or display name
  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    }
    if (firstName != null) {
      return firstName!;
    }
    return displayName ?? email ?? 'Unknown User';
  }

  // Get display name or email as fallback
  String get displayNameOrEmail => displayName ?? fullName;

  // Get initials for avatar
  String get initials {
    if (firstName != null && lastName != null) {
      return '${firstName![0]}${lastName![0]}'.toUpperCase();
    }
    if (firstName != null) {
      return firstName![0].toUpperCase();
    }
    if (displayName != null && displayName!.isNotEmpty) {
      final names = displayName!.split(' ');
      if (names.length >= 2) {
        return '${names[0][0]}${names[1][0]}'.toUpperCase();
      }
      return names[0][0].toUpperCase();
    }
    if (email != null && email!.isNotEmpty) {
      return email![0].toUpperCase();
    }
    return 'U';
  }

  // Check if user has complete profile
  bool get hasCompleteProfile =>
      email != null && firstName != null && lastName != null && isEmailVerified;

  // Get user's primary contact method
  String? get primaryContact {
    if (phoneNumber != null && isPhoneVerified) {
      return phoneNumber;
    }
    if (email != null && isEmailVerified) {
      return email;
    }
    return null;
  }

  @override
  List<Object?> get props => [
        uid,
        email,
        displayName,
        firstName,
        lastName,
        phoneNumber,
        photoURL,
        isEmailVerified,
        isPhoneVerified,
        createdAt,
        lastSignInAt,
        lastUpdatedAt,
        providerId,
        providerIds,
        customClaims,
        locale,
        timezone,
        isAnonymous,
        isDisabled,
        metadata,
      ];

  @override
  String toString() {
    return 'UserModel(uid: $uid, email: $email, fullName: $fullName, phoneNumber: $phoneNumber, isEmailVerified: $isEmailVerified, isPhoneVerified: $isPhoneVerified)';
  }
}
