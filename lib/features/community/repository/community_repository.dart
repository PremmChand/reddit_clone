import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:reddit_clone/core/constants/firebase_constants.dart';
import 'package:reddit_clone/core/failure.dart';
import 'package:reddit_clone/core/providers/firebase_providers.dart';
import 'package:reddit_clone/core/type_defs.dart';
import 'package:reddit_clone/models/community_model.dart';
import 'package:reddit_clone/models/post_model.dart';

final communityRepositoryProvider = Provider((ref) {
  return CommunityRepository(firestore: ref.watch(firestoreProvider));
});

class CommunityRepository {
  final FirebaseFirestore _firestore;
  CommunityRepository({required FirebaseFirestore firestore})
    : _firestore = firestore;

  FutureVoid createCommunity(Community communnity) async {
    try {
      var communityDoc = await _communities.doc(communnity.name).get();
      if (communityDoc.exists) {
        throw 'Community with the same name already exists!';
      }

      return right(_communities.doc(communnity.name).set(communnity.toMap()));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureVoid joinCommunity(String communityName, String userId) async {
    try {
      return right(
        _communities.doc(communityName).update({
          'members': FieldValue.arrayUnion([userId]),
        }),
      );
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureVoid leaveCommunity(String communityName, String userId) async {
    try {
      return right(
        _communities.doc(communityName).update({
          'members': FieldValue.arrayRemove([userId]),
        }),
      );
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<Community>> getUserCommunities1(String uid) {
    return _communities.where('members', arrayContains: uid).snapshots().map((
      event,
    ) {
      List<Community> communities = [];
      for (var doc in event.docs) {
        communities.add(Community.fromMap(doc.data() as Map<String, dynamic>));
      }
      return communities;
    });
  }

  Stream<List<Community>> getUserCommunities(String uid) {
    return _communities
        .where('members', arrayContains: uid) // ✅ must use arrayContains
        .snapshots()
        .map(
          (event) => event.docs
              .map((e) => Community.fromMap(e.data() as Map<String, dynamic>))
              .toList(),
        );
  }

  // Stream<Community> getCommunityByName(String name) {
  //   return _communities
  //       .doc(name)
  //       .snapshots()
  //       .map(
  //         (event) => Community.fromMap(event.data() as Map<String, dynamic>),
  //       );
  // }

  // Option 1: Throw error if not found
Stream<Community> getCommunityByName(String name) {
  return _communities.doc(name).snapshots().map((event) {
    final data = event.data();
    if (data == null) {
      throw Exception("Community $name not found");
    }
    return Community.fromMap(data as Map<String, dynamic>);
  });
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

  Stream<List<Community>> searchCommunity(String query) {
    if (query.isEmpty) {
      return Stream.value([]);
    }

    final String endQuery =
        query.substring(0, query.length - 1) +
        String.fromCharCode(query.codeUnitAt(query.length - 1) + 1);

    return _communities
        .where('name', isGreaterThanOrEqualTo: query, isLessThan: endQuery)
        .snapshots()
        .map((event) {
          return event.docs
              .map(
                (doc) => Community.fromMap(doc.data() as Map<String, dynamic>),
              )
              .toList();
        });
  }

  CollectionReference get _communities => _firestore.collection(FirebaseConstants.communitiesCollection);
CollectionReference get _posts => _firestore.collection(FirebaseConstants.postsCollection);

  Stream<List<Post>> getCommunityPosts(String name) {
    return _posts
        .where('communityName', isEqualTo: name)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (event) => event.docs
              .map((e) => Post.fromMap(e.data() as Map<String, dynamic>))
              .toList(),
        );
  }
}
