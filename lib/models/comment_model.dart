class Comment {
  final String id;
  final String text;
  final DateTime createdAt;
  final String postId;
  final String uid;
  final String username;
  final String profilePic;
  Comment({
    required this.id,
    required this.text,
    required this.createdAt,
    required this.postId,
    required this.uid,
    required this.username,
    required this.profilePic,
  });

  Comment copyWith({
    String? id,
    String? text,
    DateTime? createdAt,
    String? postId,
    String? uid,
    String? username,
    String? profilePic,
  }) {
    return Comment(
      id: id ?? this.id,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      postId: postId ?? this.postId,
      uid: uid ?? this.uid,
      username: username ?? this.username,
      profilePic: profilePic ?? this.profilePic,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'text': text,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'postId': postId,
      'uid': uid,
      'username': username,
      'profilePic': profilePic,
    };
  }

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      id: map['id'] as String,
      text: map['text'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      postId: map['postId'] as String,
      uid: map['uid'] as String,
      username: map['username'] as String,
      profilePic: map['profilePic'] as String,
    );
  }

  @override
  String toString() {
    return 'Comment(id: $id, text: $text, createdAt: $createdAt, postId: $postId, uid: $uid, username: $username, profilePic: $profilePic)';
  }

  @override
  bool operator ==(covariant Comment other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.text == text &&
        other.createdAt == createdAt &&
        other.postId == postId &&
        other.uid == uid &&
        other.username == username &&
        other.profilePic == profilePic;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        text.hashCode ^
        createdAt.hashCode ^
        postId.hashCode ^
        uid.hashCode ^
        username.hashCode ^
        profilePic.hashCode;
  }
}
