// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:any_link_preview/any_link_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/common/error_text.dart';
import 'package:reddit_clone/core/common/loader.dart';
import 'package:reddit_clone/core/constants/constants.dart';
import 'package:reddit_clone/features/auth/controller/auth_controller.dart';
import 'package:reddit_clone/features/community/controller/community_controller.dart';
import 'package:reddit_clone/features/posts/controller/post_controller.dart';

import 'package:reddit_clone/models/post_model.dart';
import 'package:reddit_clone/responsive/responsive.dart';
import 'package:reddit_clone/theme/pallete.dart';
import 'package:routemaster/routemaster.dart';

class PostCard extends ConsumerWidget {
  final Post post;
  const PostCard({super.key, required this.post});

  void deletePost(WidgetRef ref, BuildContext context) async {
    ref.read(postControllerProvider.notifier).deletePost(post, context);
  }

  void upvotePost(WidgetRef ref) async {
    ref.read(postControllerProvider.notifier).upvote(post);
  }

  void downvotePost(WidgetRef ref) async {
    ref.read(postControllerProvider.notifier).downvote(post);
  }

  void awardPost(WidgetRef ref, String award, BuildContext context) async {
    ref
        .read(postControllerProvider.notifier)
        .awardPost(post: post, award: award, context: context);
  }

  void navigateToUser(BuildContext context) {
    Routemaster.of(context).push('/u/${post.uid}');
  }

  void navigateToCommunity(BuildContext context) {
    Routemaster.of(context).push('/r/${post.communityName}');
  }

  void navigateToComment(BuildContext context) {
    Routemaster.of(context).push('/post/${post.id}/comments');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTypeImage = post.type == 'image';
    final isTypeText = post.type == 'text';
    final isTypeLink = post.type == 'link';
    final user = ref.watch(userProvider)!;
    final isGuest = !user.isAuthenticated;

    return Responsive(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: const BoxDecoration(color: Colors.black54),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Row with avatar, community name and delete icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween, // push apart
                  children: [
                    // 👇 Left side: Avatar + Community/User name
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => navigateToCommunity(context),
                          child: CircleAvatar(
                            backgroundImage: NetworkImage(
                              post.communityProfilePic,
                            ),
                            radius: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'r/${post.communityName}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => navigateToUser(context),
                              child: Text(
                                'u/${post.userName}',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
      
                    if (post.uid == user.uid)
                      IconButton(
                        onPressed: () => deletePost(ref, context),
                        icon: Icon(Icons.delete, color: Pallete.redColor),
                      ),
                  ],
                ),
      
                if (post.awards.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  SizedBox(
                    height: 25,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: post.awards.length,
                      itemBuilder: (BuildContext context, int index) {
                        final award = post.awards[index];
                        return Image.asset(Constants.awards[award]!, height: 23,);
                      },
                    ),
                  ),
                ],
      
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Text(
                    post.title,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (isTypeImage)
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.35,
                    width: double.infinity,
                    child: Image.network(post.link!, fit: BoxFit.cover),
                  ),
      
                if (isTypeLink)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18),
                    child: AnyLinkPreview(
                      displayDirection: UIDirection.uiDirectionHorizontal,
                      link: post.link!,
                    ),
                  ),
      
                if (isTypeText)
                  Container(
                    alignment: Alignment.bottomLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: Text(
                      post.description!,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
      
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: isGuest? (){} : () => upvotePost(ref),
                          icon: Icon(
                            Icons.arrow_upward,
                            size: 30,
                            color: post.upvotes.contains(user.uid)
                                ? Pallete.redColor
                                : null,
                          ),
                        ),
      
                        Text(
                          '${post.upvotes.length - post.downvotes.length == 0 ? 'Vote' : post.upvotes.length - post.downvotes.length}',
                          style: const TextStyle(fontSize: 17),
                        ),
      
                        IconButton(
                          onPressed: isGuest? (){} : () => downvotePost(ref),
                          icon: Icon(
                            Icons.arrow_downward,
                            size: 30,
                            color: post.downvotes.contains(user.uid)
                                ? Pallete.blueColor
                                : null,
                          ),
                        ),
                      ],
                    ),
      
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => navigateToComment(context),
                          icon: const Icon(Icons.comment),
                        ),
                        Text(
                          '${post.commentCount == 0 ? 'Comment' : post.commentCount}',
                          style: const TextStyle(fontSize: 17),
                        ),
                      ],
                    ),
                    ref
                        .watch(getCommunityByNameProvider(post.communityName))
                        .when(
                          data: (data) {
                            if (data.mods.contains(user.uid)) {
                              return IconButton(
                                onPressed: () => deletePost(ref, context),
                                icon: const Icon(Icons.admin_panel_settings),
                              );
                            }
                            return const SizedBox();
                          },
                          error: (error, stackTrace) =>
                              ErrorText(error: error.toString()),
                          loading: () => const Loader(),
                        ),
                    IconButton(
                      onPressed: isGuest? () {} : () {
                        showDialog(
                          context: context,
                          builder: (context) => Dialog(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: GridView.builder(
                                shrinkWrap: true,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 4,
                                    ),
                                itemCount: user.awards.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final award = user.awards[index];
                                  return GestureDetector(
                                    onTap: () => awardPost(ref, award, context),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Image.asset(
                                        Constants.awards[award]!,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.card_giftcard_outlined),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}





// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:reddit_clone/features/auth/controller/auth_controller.dart';
// import 'package:reddit_clone/models/post_model.dart';
// import 'package:reddit_clone/theme/pallete.dart';

// class PostCard extends ConsumerWidget {
//   final Post post;
//   const PostCard({super.key, required this.post});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final isTypeImage = post.type == 'image';
//     final isTypeText = post.type == 'text';
//     final isTypeLink = post.type == 'link';
//     final user = ref.watch(userProvider)!;

//     return Card(
//       margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       elevation: 3,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // 🔹 HEADER
//           Container(
//             decoration: BoxDecoration(
//               color: Colors.grey[900],
//               borderRadius: const BorderRadius.only(
//                 topLeft: Radius.circular(12),
//                 topRight: Radius.circular(12),
//               ),
//             ),
//             padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 // Left side (community avatar + name + user)
//                 Row(
//                   children: [
//                     CircleAvatar(
//                       backgroundImage: NetworkImage(post.communityProfilePic),
//                       radius: 16,
//                     ),
//                     const SizedBox(width: 8),
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'r/${post.communityName}',
//                           style: const TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         Text(
//                           'u/${post.userName}',
//                           style: const TextStyle(fontSize: 12),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),

//                 // Right side (delete button for owner)
//                 if (post.uid == user.uid)
//                   IconButton(
//                     onPressed: () {},
//                     icon:  Icon(Icons.delete, color: Pallete.redColor),
//                   ),
//               ],
//             ),
//           ),

//           // 🔹 BODY (content depending on type)
//           if (isTypeText)
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Text(
//                 post.description ?? "",
//                 style: const TextStyle(fontSize: 14),
//               ),
//             ),

//           if (isTypeImage)
//             ClipRRect(
//               borderRadius: BorderRadius.circular(8),
//               child: Image.network(
//                 post.link ?? "",
//                 fit: BoxFit.cover,
//                 width: double.infinity,
//                 height: 200,
//               ),
//             ),

//           if (isTypeLink)
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Row(
//                 children: [
//                   const Icon(Icons.link, color: Colors.blue),
//                   const SizedBox(width: 8),
//                   Expanded(
//                     child: Text(
//                       post.link ?? "",
//                       style: const TextStyle(
//                         fontSize: 14,
//                         color: Colors.blue,
//                         decoration: TextDecoration.underline,
//                       ),
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//           // 🔹 FOOTER (upvote, comments, etc. – you can add later)
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//             child: Row(
//               children: [
//                 IconButton(
//                   onPressed: () {},
//                   icon: const Icon(Icons.arrow_upward),
//                 ),
//                 IconButton(
//                   onPressed: () {},
//                   icon: const Icon(Icons.arrow_downward),
//                 ),
//                 const SizedBox(width: 16),
//                 IconButton(
//                   onPressed: () {},
//                   icon: const Icon(Icons.comment_outlined),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }



