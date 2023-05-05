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

final communityRepositoryProvider = Provider((ref) {
  return CommunityRepository(firestore: ref.watch(firestoreProvider));
});

class CommunityRepository {
  final FirebaseFirestore _firestore;
  CommunityRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  FutureVoid createCommunity(Community community) async {
    try {
      var communityDoc = await _communities.doc(community.name).get();
      if (communityDoc.exists) {
        throw 'Community with the same name already exists!';
      }
      return right(_communities.doc(community.name).set(community.toMap()));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureVoid joinCommunity(String communityName, String userId) async {
    try {
      return right(
        _communities.doc(communityName).update(
          {
            'members': FieldValue.arrayUnion([userId]),
          },
        ),
      );
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

  FutureVoid leaveCommunity(String communityName, String userId) async {
    try {
      return right(
        _communities.doc(communityName).update(
          {
            'members': FieldValue.arrayRemove([userId]),
          },
        ),
      );
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

  Stream<List<Community>> getUserCommunities(String uid) {
    return _communities
        .where('members', arrayContains: uid)
        .snapshots()
        .map((event) {
      List<Community> communities = [];
      for (var doc in event.docs) {
        communities.add(Community.fromMap(doc.data() as Map<String, dynamic>));
      }
      return communities;
    });
  }

  Stream<Community> getCommunityByName(String name) {
    return _communities.doc(name).snapshots().map(
          (event) => Community.fromMap(event.data() as Map<String, dynamic>),
        );
  }

  FutureVoid editCommunity(Community community) async {
    try {
      return right(_communities.doc(community.name).update(community.toMap()));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureVoid deleteCommunity(Community community) async {
    var storageBanner = FirebaseStorage.instance
        .ref()
        .child('communities/banner/${community.name}');
    storageBanner.delete();
    var storageAvatar = FirebaseStorage.instance
        .ref()
        .child('communities/profile/${community.name}');
    storageAvatar.delete();

    var postsQuerySnapshot = await FirebaseFirestore.instance
        .collection('posts')
        .where('communityName', isEqualTo: community.name)
        .get();
    for (var postDoc in postsQuerySnapshot.docs) {
      var commentsQuerySnapshot = await FirebaseFirestore.instance
          .collection('comments')
          .where('postId', isEqualTo: postDoc.id)
          .get();
      for (var commentDoc in commentsQuerySnapshot.docs) {
        await commentDoc.reference.delete();
      }
      var postImageRef = FirebaseStorage.instance
          .ref()
          .child('posts/${community.name}/${postDoc.id}');
      postImageRef.delete();
    }
    for (var postDoc in postsQuerySnapshot.docs) {
      postDoc.reference.delete();
    }

    try {
      return right(_communities.doc(community.name).delete());
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<Community>> searchCommunity(String query) {
    return _communities
        .where(
          'name',
          isGreaterThanOrEqualTo: query.isEmpty ? 0 : query,
          isLessThan: query.isEmpty
              ? null
              : query.substring(0, query.length - 1) +
                  String.fromCharCode(
                    query.codeUnitAt(query.length - 1) + 1,
                  ),
        )
        .snapshots()
        .map((event) {
      List<Community> communities = [];
      for (var community in event.docs) {
        communities
            .add(Community.fromMap(community.data() as Map<String, dynamic>));
      }
      return communities;
    });
  }

  FutureVoid addMods(String communityName, List<String> uids) async {
    try {
      return right(_communities.doc(communityName).update({
        'mods': uids,
      }));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<Post>> getCommunityPosts(String name) {
    return _posts
        .where('communityName', isEqualTo: name)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((event) => event.docs
            .map(
              (e) => Post.fromMap(e.data() as Map<String, dynamic>),
            )
            .toList());
  }

  CollectionReference get _posts =>
      _firestore.collection(FirebaseConstants.postsCollection);

  CollectionReference get _communities =>
      _firestore.collection(FirebaseConstants.communitiesCollection);
}
