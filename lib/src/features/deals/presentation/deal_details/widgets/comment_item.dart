import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../common_widgets/user_profile_dialog.dart';
import '../../../../../helpers/context_extensions.dart';
import '../../../../../helpers/date_time_helper.dart';
import '../../../../auth/presentation/user_controller.dart';
import '../../../../settings/presentation/locale_controller.dart';
import '../../../domain/comment.dart';
import 'report_comment_dialog.dart';

enum _CommentPopup { reportComment }

class CommentItem extends ConsumerWidget {
  const CommentItem({required this.comment, super.key});

  final Comment comment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeControllerProvider);
    final poster = comment.postedBy!;
    final user = ref.watch(userProvider)!;

    return Card(
      color: context.isLightMode ? Colors.grey.shade200 : Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        horizontalTitleGap: 8,
        minVerticalPadding: 16,
        leading: GestureDetector(
          onTap: () => showDialog<void>(
            context: context,
            builder: (_) => UserProfileDialog(userId: poster.id!),
          ),
          child: CachedNetworkImage(
            imageUrl: poster.avatar!,
            imageBuilder: (_, imageProvider) =>
                CircleAvatar(backgroundImage: imageProvider, radius: 16),
            placeholder: (_, __) => const CircleAvatar(radius: 16),
          ),
        ),
        title: Wrap(
          spacing: 8,
          children: [
            GestureDetector(
              onTap: () => showDialog<void>(
                context: context,
                builder: (_) => UserProfileDialog(userId: poster.id!),
              ),
              child: Text(poster.nickname!, style: context.textTheme.subtitle2),
            ),
            Text(
              '•',
              style: context.textTheme.bodyText2!.copyWith(
                color: context.isLightMode ? Colors.black54 : Colors.grey,
              ),
            ),
            Text(
              formatDateTime(comment.createdAt!, locale: locale),
              style: context.textTheme.bodyText2!.copyWith(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ],
        ),
        subtitle: SelectableText(comment.message),
        trailing:
            poster.uid != user.uid ? _PopupMenuButton(comment: comment) : null,
      ),
    );
  }
}

class _PopupMenuButton extends StatelessWidget {
  const _PopupMenuButton({required this.comment});

  final Comment comment;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_CommentPopup>(
      child: SizedBox.square(
        dimension: 32,
        child: Icon(
          Icons.more_vert,
          color: Colors.grey.shade600,
          size: 16,
        ),
      ),
      itemBuilder: (context) => [
        PopupMenuItem<_CommentPopup>(
          value: _CommentPopup.reportComment,
          child: Text(context.l.reportComment),
        )
      ],
      onSelected: (result) {
        switch (result) {
          case _CommentPopup.reportComment:
            showDialog<void>(
              context: context,
              builder: (_) => ReportCommentDialog(
                dealId: comment.dealId!,
                commentId: comment.id!,
              ),
            );
            break;
        }
      },
    );
  }
}
