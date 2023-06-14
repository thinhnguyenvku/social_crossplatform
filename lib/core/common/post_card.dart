import 'package:any_link_preview/any_link_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:routemaster/routemaster.dart';
import 'package:social_crossplatform/core/common/error_text.dart';
import 'package:social_crossplatform/core/common/loader.dart';
import 'package:social_crossplatform/core/constants/constants.dart';
import 'package:social_crossplatform/features/auth/controller/auth_controller.dart';
import 'package:social_crossplatform/features/community/controller/community_controller.dart';
import 'package:social_crossplatform/features/post/controller/post_controller.dart';
import 'package:social_crossplatform/models/post_model.dart';
import 'package:social_crossplatform/responsive/responsive.dart';
import 'package:social_crossplatform/theme/pallete.dart';

class PostCard extends ConsumerWidget {
  final Post post;

  const PostCard({
    super.key,
    required this.post,
  });

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
    Routemaster.of(context).push('/c/${post.communityName}');
  }

  void navigateToComments(BuildContext context) {
    Routemaster.of(context).push('/post/${post.id}/comments');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTypeImage = post.type == 'image';
    final isTypeText = post.type == 'text';
    final isTypeLink = post.type == 'link';

    final currentTheme = ref.watch(themeNotifierProvider);
    final user = ref.watch(userProvider)!;
    final isGuest = !user.isAuthenticated;

    return Responsive(
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: currentTheme.drawerTheme.backgroundColor,
            ),
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 16,
                        ).copyWith(right: 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () => navigateToCommunity(context),
                                  child: CircleAvatar(
                                    backgroundImage:
                                        NetworkImage(post.communityProfilePic),
                                    radius: 16,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'c/${post.communityName}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      GestureDetector(
                                        onTap: () => navigateToUser(context),
                                        child: Text(
                                          'u/${post.username}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        DateFormat('dd-MM-yyyy HH:mm:ss')
                                            .format(post.createdAt),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                ref.watch(getUserDataProvider(user.uid)).when(
                                      data: (data) {
                                        if (data.uid == post.uid) {
                                          return IconButton(
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return AlertDialog(
                                                    title: const Text(
                                                        'Confirm Delete'),
                                                    content: const Text(
                                                        'Are you sure you want to delete this post?'),
                                                    actions: <Widget>[
                                                      TextButton(
                                                        child: const Text(
                                                            'Cancel'),
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                      ),
                                                      TextButton(
                                                        child: const Text(
                                                            'Delete'),
                                                        onPressed: () {
                                                          deletePost(
                                                              ref, context);
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            },
                                            icon: const Icon(
                                              Icons.delete_forever_outlined,
                                              color: Colors.red,
                                            ),
                                          );
                                        }
                                        return const SizedBox();
                                      },
                                      error: (error, stackTrace) =>
                                          ErrorText(error: error.toString()),
                                      loading: () => const Loader(),
                                    )
                              ],
                            ),
                            if (post.awards.isNotEmpty) ...[
                              const SizedBox(height: 5),
                              SizedBox(
                                height: 25,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: post.awards.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    final award = post.awards[index];
                                    return Image.asset(
                                      Constants.awards[award]!,
                                      height: 23,
                                    );
                                  },
                                ),
                              ),
                            ],
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
                            if (isTypeImage && kIsWeb)
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.40,
                                width: double.infinity,
                                child: Image.network(
                                  post.link!,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            if (isTypeImage && !kIsWeb)
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.28,
                                width: double.infinity,
                                child: Image.network(
                                  post.link!,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            if (isTypeLink)
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 18),
                                child: AnyLinkPreview(
                                  displayDirection:
                                      UIDirection.uiDirectionHorizontal,
                                  link: post.link!,
                                ),
                              ),
                            if (isTypeText)
                              Container(
                                alignment: Alignment.bottomLeft,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15.0),
                                child: Text(
                                  post.description!,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: isGuest
                                          ? () {}
                                          : () => upvotePost(ref),
                                      icon: Icon(
                                        Icons.thumb_up_alt_outlined,
                                        size: 30,
                                        color: post.upvotes.contains(user.uid)
                                            ? Pallete.blueColor
                                            : null,
                                      ),
                                    ),
                                    Text(
                                      '${post.upvotes.length - post.downvotes.length == 0 ? '0' : post.upvotes.length - post.downvotes.length}',
                                      style: const TextStyle(fontSize: 17),
                                    ),
                                    IconButton(
                                      onPressed: isGuest
                                          ? () {}
                                          : () => downvotePost(ref),
                                      icon: Icon(
                                        Icons.thumb_down_alt_outlined,
                                        size: 30,
                                        color: post.downvotes.contains(user.uid)
                                            ? Pallete.redColor
                                            : null,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () =>
                                          navigateToComments(context),
                                      icon: const Icon(
                                        Icons.comment,
                                      ),
                                    ),
                                    Text(
                                      '${post.commentCount == 0 ? 'Comment' : post.commentCount}',
                                      style: const TextStyle(fontSize: 17),
                                    ),
                                  ],
                                ),
                                ref
                                    .watch(getCommunityByNameProvider(
                                        post.communityName))
                                    .when(
                                      data: (data) {
                                        if (data.mods.contains(user.uid)) {
                                          return IconButton(
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return AlertDialog(
                                                    title: const Text(
                                                        'Confirm Delete'),
                                                    content: const Text(
                                                        'Are you sure you want to delete this post?'),
                                                    actions: <Widget>[
                                                      TextButton(
                                                        child: const Text(
                                                            'Cancel'),
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                      ),
                                                      TextButton(
                                                        child: const Text(
                                                            'Delete'),
                                                        onPressed: () {
                                                          deletePost(
                                                              ref, context);
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            },
                                            icon: const Icon(
                                              Icons.admin_panel_settings,
                                            ),
                                          );
                                        }
                                        return const SizedBox();
                                      },
                                      error: (error, stackTrace) =>
                                          ErrorText(error: error.toString()),
                                      loading: () => const Loader(),
                                    ),
                                IconButton(
                                  onPressed: isGuest
                                      ? () {}
                                      : () {
                                          showDialog(
                                            context: context,
                                            builder: (context) => Dialog(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(20),
                                                child: GridView.builder(
                                                  shrinkWrap: true,
                                                  gridDelegate:
                                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                                    crossAxisCount: 4,
                                                  ),
                                                  itemCount: user.awards.length,
                                                  itemBuilder:
                                                      (BuildContext context,
                                                          int index) {
                                                    final award =
                                                        user.awards[index];
                                                    return GestureDetector(
                                                      onTap: () => awardPost(
                                                          ref, award, context),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Image.asset(
                                                            Constants.awards[
                                                                award]!),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                  icon:
                                      const Icon(Icons.card_giftcard_outlined),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
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
