import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:social_crossplatform/core/constants/firebase_constants.dart';
import 'package:social_crossplatform/core/failure.dart';
import 'package:social_crossplatform/core/providers/firebase_providers.dart';
import 'package:social_crossplatform/core/type_defs.dart';
import 'package:social_crossplatform/models/comment_model.dart';
import 'package:social_crossplatform/models/community_model.dart';
import 'package:social_crossplatform/models/post_model.dart';

final postRepositoryProvider = Provider((ref) {
  return PostRepository(firestore: ref.watch(firestoreProvider));
});

class PostRepository {
  final FirebaseFirestore _firestore;
  PostRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  CollectionReference get _posts =>
      _firestore.collection(FirebaseConstants.postsCollection);

  CollectionReference get _comments =>
      _firestore.collection(FirebaseConstants.commentsCollection);

  CollectionReference get _users =>
      _firestore.collection(FirebaseConstants.usersCollection);

  FutureVoid addPost(Post post) async {
    try {
      return right(_posts.doc(post.id).set(post.toMap()));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(
        Failure(
          e.toString(),
        ),
      );
    }
  }

  Stream<List<Post>> fetchUserPosts(List<Community> communities) {
    return _posts
        .where('communityName',
            whereIn: communities.map((e) => e.name).toList())
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (event) => event.docs
              .map(
                (e) => Post.fromMap(
                  e.data() as Map<String, dynamic>,
                ),
              )
              .toList(),
        );
  }

  Stream<List<Post>> fetchGuestPosts() {
    return _posts
        .orderBy('createdAt', descending: true)
        .limit(10)
        .snapshots()
        .map(
          (event) => event.docs
              .map(
                (e) => Post.fromMap(
                  e.data() as Map<String, dynamic>,
                ),
              )
              .toList(),
        );
  }

  FutureVoid deletePost(Post post) async {
    var storageImagePost = FirebaseStorage.instance
        .ref()
        .child('posts/${post.communityName}/${post.id}');
    storageImagePost.delete();

    var comments = await FirebaseFirestore.instance
        .collection('comments')
        .where('postId', isEqualTo: post.id)
        .get();
    for (var comment in comments.docs) {
      comment.reference.delete();
    }

    try {
      return right(_posts.doc(post.id).delete());
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  void upvote(Post post, String userId) async {
    if (post.downvotes.contains(userId)) {
      _posts.doc(post.id).update({
        'downvotes': FieldValue.arrayRemove([userId]),
      });
    }

    if (post.upvotes.contains(userId)) {
      _posts.doc(post.id).update({
        'upvotes': FieldValue.arrayRemove([userId]),
      });
    } else {
      _posts.doc(post.id).update({
        'upvotes': FieldValue.arrayUnion([userId]),
      });
    }
  }

  void downvote(Post post, String userId) async {
    if (post.upvotes.contains(userId)) {
      _posts.doc(post.id).update({
        'upvotes': FieldValue.arrayRemove([userId]),
      });
    }

    if (post.downvotes.contains(userId)) {
      _posts.doc(post.id).update({
        'downvotes': FieldValue.arrayRemove([userId]),
      });
    } else {
      _posts.doc(post.id).update({
        'downvotes': FieldValue.arrayUnion([userId]),
      });
    }
  }

  Stream<Post> getPostById(String postId) {
    return _posts
        .doc(postId)
        .snapshots()
        .map((event) => Post.fromMap(event.data() as Map<String, dynamic>));
  }

  FutureVoid addComment(Comment comment) async {
    try {
      await _comments.doc(comment.id).set(comment.toMap());

      return right(_posts.doc(comment.postId).update({
        'commentCount': FieldValue.increment(1),
      }));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureVoid deleteComment(Comment comment) async {
    final commentRef =
    FirebaseFirestore.instance.collection('comments').doc(comment.id);

    final postRef =
    FirebaseFirestore.instance.collection('posts').doc(comment.postId);
    final postDoc = await postRef.get();
    final currentCommentCount = postDoc.data()!['commentCount'];

    final batch = FirebaseFirestore.instance.batch();
    batch.delete(commentRef);
    batch.update(postRef, {'commentCount': currentCommentCount - 1});

    try {
      await batch.commit();
      return right(null);
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }


  Stream<List<Comment>> getCommentsOfPost(String postId) {
    return _comments
        .where('postId', isEqualTo: postId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (event) => event.docs
              .map(
                (e) => Comment.fromMap(
                  e.data() as Map<String, dynamic>,
                ),
              )
              .toList(),
        );
  }

  FutureVoid awardPost(Post post, String award, String senderId) async {
    try {
      _posts.doc(post.id).update({
        'awards': FieldValue.arrayUnion([award]),
      });
      _users.doc(senderId).update({
        'awards': FieldValue.arrayRemove([award]),
      });
      return right(_users.doc(post.uid).update({
        'awards': FieldValue.arrayUnion([award]),
      }));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
