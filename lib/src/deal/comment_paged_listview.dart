import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:loggy/loggy.dart' show NetworkLoggy;

import '../models/comment.dart';
import '../utils/error_indicator_util.dart';
import 'comment_item.dart';

class CommentPagedListView extends StatefulWidget {
  const CommentPagedListView({
    Key? key,
    required this.commentFuture,
    required this.noCommentsFound,
    this.pageSize = 20,
    this.pagingController,
  }) : super(key: key);

  final Future<List<Comment>?> Function(int page, int size) commentFuture;
  final Widget noCommentsFound;
  final int pageSize;
  final PagingController<int, Comment>? pagingController;

  @override
  _CommentPagedListViewState createState() => _CommentPagedListViewState();
}

class _CommentPagedListViewState extends State<CommentPagedListView>
    with NetworkLoggy {
  late final PagingController<int, Comment> _pagingController;

  @override
  void initState() {
    _pagingController = widget.pagingController ??
        PagingController<int, Comment>(firstPageKey: 0);
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    super.initState();
  }

  @override
  void dispose() {
    if (widget.pagingController == null) {
      _pagingController.dispose();
    }
    super.dispose();
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final newItems = await widget.commentFuture(pageKey, widget.pageSize);
      final isLastPage = newItems!.length < widget.pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + 1;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      loggy.error(error);
      _pagingController.error = error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PagedListView.separated(
      pagingController: _pagingController,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      builderDelegate: PagedChildBuilderDelegate<Comment>(
        animateTransitions: true,
        itemBuilder: (context, comment, index) => CommentItem(comment: comment),
        firstPageErrorIndicatorBuilder: (context) =>
            ErrorIndicatorUtil.buildFirstPageError(
          context,
          onTryAgain: () => _pagingController.refresh(),
        ),
        newPageErrorIndicatorBuilder: (context) =>
            ErrorIndicatorUtil.buildNewPageError(
          context,
          onTryAgain: () => _pagingController.refresh(),
        ),
        noItemsFoundIndicatorBuilder: (context) => widget.noCommentsFound,
      ),
      separatorBuilder: (context, index) => const SizedBox(height: 10),
    );
  }
}
