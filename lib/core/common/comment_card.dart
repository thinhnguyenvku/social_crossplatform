import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_crossplatform/core/common/error_text.dart';
import 'package:social_crossplatform/core/common/loader.dart';
import 'package:social_crossplatform/features/auth/controller/auth_controller.dart';
import 'package:social_crossplatform/features/post/controller/post_controller.dart';
import 'package:social_crossplatform/models/comment_model.dart';
import 'package:social_crossplatform/responsive/responsive.dart';

class CommentCard extends ConsumerWidget {
  final Comment comment;

  const CommentCard({
    super.key,
    required this.comment,
  });

  void deleteComment(WidgetRef ref, BuildContext context) async {
    ref.read(postControllerProvider.notifier).deleteComment(comment, context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider)!;
    return Responsive(
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 4,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(comment.profilePic),
                  radius: 18,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'u/${comment.username}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(comment.text),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                ref.watch(getUserDataProvider(user.uid)).when(
                      data: (data) {
                        if (data.uid == comment.uid) {
                          return Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 20.0),
                                child: IconButton(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Confirm Delete'),
                                          content: const Text(
                                              'Are you sure you want to delete this comment?'),
                                          actions: <Widget>[
                                            TextButton(
                                              child: const Text('Cancel'),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                            TextButton(
                                              child: const Text('Delete'),
                                              onPressed: () {
                                                deleteComment(ref, context);
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  icon: const Icon(Icons.delete_sweep_outlined),
                                ),
                              ),
                              const Text('Delete'),
                            ],
                          );
                        } else {
                          return const SizedBox();
                        }
                      },
                      error: (error, stackTrace) =>
                          ErrorText(error: error.toString()),
                      loading: () => const Loader(),
                    )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
