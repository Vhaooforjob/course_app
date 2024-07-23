import 'dart:convert';

import 'package:course_app/configs/configs.dart';
import 'package:course_app/models/comment.model.dart';
import 'package:course_app/models/users.model.dart';
import 'package:course_app/services/api_comment_services.dart';
import 'package:course_app/services/api_user_services.dart';
import 'package:course_app/styles/styles.dart';
import 'package:course_app/widgets/format_date.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../models/episodes.model.dart';
import '../../services/api_episode_services.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:http/http.dart' as http;

class PlayEpisodePage extends StatefulWidget {
  final String episodeId;
  final List<Episode> episodes;
  final String userId;

  const PlayEpisodePage({
    required this.episodeId,
    required this.episodes,
    required this.userId,
    Key? key,
  }) : super(key: key);

  @override
  State<PlayEpisodePage> createState() => _PlayEpisodePageState();
}

Future<List<Comment>> fetchCommentsByEpisodeId(String episodeId) async {
  try {
    final comments =
        await ApiCommentServices().getCommentsByEpisodeId(episodeId);
    return comments;
  } catch (e) {
    throw Exception('Failed to load comments: $e');
  }
}

class _PlayEpisodePageState extends State<PlayEpisodePage>
    with SingleTickerProviderStateMixin {
  late Future<Episode> _episodeFuture;
  late Future<List<Comment>> _commentsFuture;
  YoutubePlayerController? _youtubeController;
  String? _selectedEpisodeId;
  bool _isFullScreen = false;
  late TabController _tabController;
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedEpisodeId = widget.episodeId;
    _episodeFuture = fetchEpisodeById(widget.episodeId);
    _commentsFuture = fetchCommentsByEpisodeId(widget.episodeId);
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _youtubeController?.dispose();
    _resetOrientation();
    _tabController.dispose();
    super.dispose();
  }

  void _resetOrientation() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  void _onEpisodeSelected(String episodeId) {
    setState(() {
      _selectedEpisodeId = episodeId;
      _episodeFuture = fetchEpisodeById(episodeId);
      _commentsFuture = fetchCommentsByEpisodeId(episodeId);
      _youtubeController?.dispose();
    });
  }

  void _initializeYoutubeController(String videoUrl) {
    _youtubeController = YoutubePlayerController(
      initialVideoId: YoutubePlayer.convertUrlToId(videoUrl) ?? '',
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
      ),
    )..addListener(_youtubeListener);
  }

  void _youtubeListener() {
    if (_youtubeController != null &&
        _youtubeController!.value.isFullScreen != _isFullScreen) {
      setState(() {
        _isFullScreen = _youtubeController!.value.isFullScreen;
        if (_isFullScreen) {
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
        } else {
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
        }
      });
    }
  }

  Future<void> _submitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    try {
      final comment = Comment(
        userId: widget.userId,
        episodeId: widget.episodeId,
        review: text,
        ratingDate: DateTime.now(),
      );
      await ApiCommentServices().createComment(comment);
      setState(() {
        _commentsFuture = fetchCommentsByEpisodeId(widget.episodeId);
        _commentController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.white,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Bạn đã bình luận thành công!',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          padding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(
                Icons.remove_circle,
                color: Colors.white,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Bình luận thất bại',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          padding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _isFullScreen
          ? null
          : AppBar(
              title:
                  const Text('Chi tiết phần học', style: AppStyles.headerText),
              centerTitle: true,
              backgroundColor: Colors.white,
              iconTheme: const IconThemeData(color: Colors.black),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                color: Colors.black,
                iconSize: 20,
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
      body: FutureBuilder<Episode>(
        future: _episodeFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final episode = snapshot.data!;
            _initializeYoutubeController(episode.videoUrl);

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  YoutubePlayer(
                    controller: _youtubeController!,
                    showVideoProgressIndicator: true,
                    onReady: () {
                      _youtubeController!.addListener(_youtubeListener);
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ExpandableText(
                          episode.title,
                          expandText: 'Xem thêm',
                          collapseText: 'Thu gọn',
                          maxLines: 2,
                          linkColor: Colors.blue,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                          expandOnTextTap: true,
                          collapseOnTextTap: true,
                          linkStyle: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(height: 8.0),
                      ],
                    ),
                  ),
                  TabBar(
                    controller: _tabController,
                    tabs: const [
                      Tab(text: 'Bình luận'),
                      Tab(text: 'Phần học'),
                    ],
                    labelColor: Colors.black,
                    indicatorColor: Colors.black,
                  ),
                  SizedBox(
                    height: 600,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // Comments Tab
                        Column(
                          children: [
                            const SizedBox(height: 10),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  const SizedBox(width: 8.0),
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(30),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.2),
                                            spreadRadius: 2,
                                            blurRadius: 2,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: TextField(
                                        controller: _commentController,
                                        decoration: const InputDecoration(
                                            hintText:
                                                'Nhập bình luận của bạn...',
                                            border: InputBorder.none,
                                            contentPadding: EdgeInsets.only(
                                                left: 30,
                                                right: 0,
                                                top: 10,
                                                bottom: 10)),
                                        maxLines: 1,
                                        textInputAction: TextInputAction.done,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.send,
                                        color: Colors.blue),
                                    onPressed: _submitComment,
                                    tooltip: 'Gửi bình luận',
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Expanded(
                              child: FutureBuilder<List<Comment>>(
                                future: _commentsFuture,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  } else if (snapshot.hasError) {
                                    return const Center(
                                        child: Text(
                                            'Chưa có bình luận nào cho video này'));
                                  } else if (snapshot.hasData) {
                                    final comments = snapshot.data ?? [];
                                    return ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: comments.length,
                                      itemBuilder: (context, index) {
                                        final comment = comments[index];
                                        return _buildCommentItem(comment);
                                      },
                                    );
                                  } else {
                                    return const Center(
                                        child: Text('No comments available'));
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        // Episode List Tab
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: widget.episodes.length,
                          itemBuilder: (context, index) {
                            final episode = widget.episodes[index];
                            return Card(
                              color: episode.id == _selectedEpisodeId
                                  ? Colors.grey[400]
                                  : const Color.fromARGB(255, 255, 255, 255),
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 4.0),
                              child: ListTile(
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(5),
                                  child: Image.network(
                                    episode.imageUrl,
                                    width: 100,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                title: Text(
                                  episode.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600),
                                ),
                                subtitle: Text(
                                    'Thời lượng: ${episode.duration ~/ 60} phút'),
                                trailing: Icon(
                                  episode.id == _selectedEpisodeId
                                      ? Icons.pause
                                      : Icons.play_arrow,
                                ),
                                onTap: () => _onEpisodeSelected(episode.id),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          } else {
            return const Center(child: Text('No data available'));
          }
        },
      ),
    );
  }

  Future<void> _showEditOrDeleteDialog(Comment comment) async {
    final isCurrentUser = comment.userId == widget.userId;
    if (!isCurrentUser) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: const Text(
      //         'Bạn không có quyền chỉnh sửa hoặc xóa bình luận này.'),
      //     backgroundColor: Colors.red,
      //     behavior: SnackBarBehavior.floating,
      //     padding: const EdgeInsets.all(16),
      //     shape: RoundedRectangleBorder(
      //       borderRadius: BorderRadius.circular(20),
      //     ),
      //   ),
      // );
      return;
    }

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chỉnh sửa hoặc Xóa bình luận'),
        content: const Text('Chọn hành động bạn muốn thực hiện.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'edit'),
            child: const Text('Chỉnh sửa'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'delete'),
            child: const Text('Xóa'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'cancel'),
            child: const Text('Hủy'),
          ),
        ],
      ),
    );

    switch (result) {
      case 'edit':
        await _showEditCommentDialog(comment);
        break;
      case 'delete':
        await _deleteComment(comment.id);
        break;
      case 'cancel':
      default:
        break;
    }
  }

  Future<void> _showEditCommentDialog(Comment comment) async {
    final TextEditingController editController =
        TextEditingController(text: comment.review);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chỉnh sửa bình luận'),
        content: TextField(
          controller: editController,
          decoration: const InputDecoration(
            hintText: 'Nhập bình luận mới...',
          ),
          maxLines: null,
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final updatedComment = Comment(
                userId: comment.userId,
                episodeId: comment.episodeId,
                review: editController.text.trim(),
                ratingDate: comment.ratingDate,
              );
              try {
                await updateComment(comment.id, updatedComment);
                setState(() {
                  _commentsFuture = fetchCommentsByEpisodeId(widget.episodeId);
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.white),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Bình luận đã được cập nhật thành công!',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                );
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Row(
                      children: [
                        Icon(Icons.remove_circle, color: Colors.white),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Không thể cập nhật bình luận.',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                );
              }
            },
            child: const Text('Lưu'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteComment(String? id) async {
    if (id == null) return;
    try {
      final responseDelete = await http.delete(Uri.parse('$comments$id'));
      setState(() {
        _commentsFuture = fetchCommentsByEpisodeId(widget.episodeId);
      });
      if (responseDelete.statusCode != 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Đã xoá bình luận thành công!',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            padding: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.remove_circle, color: Colors.white),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Không thể xoá bình luận.',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          padding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      );
    }
  }

  Future<Comment> updateComment(String? id, Comment comment) async {
    if (id == null) throw Exception('Comment ID cannot be null');
    final responseUpdate = await http.put(
      Uri.parse('$comments$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(comment.toJson()),
    );

    if (responseUpdate.statusCode == 200) {
      return Comment.fromJson(json.decode(responseUpdate.body));
    } else if (responseUpdate.statusCode == 404) {
      throw Exception('Comment not found');
    } else {
      throw Exception('Failed to update comment');
    }
  }

  Widget _buildCommentItem(Comment comment) {
    final formattedDate =
        formatCommentDate(comment.ratingDate ?? DateTime.now());
    return FutureBuilder<User>(
      future: fetchUserInfo(comment.userId),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const ListTile(
            leading: CircularProgressIndicator(),
            title: Text('Đang tải...'),
          );
        } else if (userSnapshot.hasError) {
          return ListTile(
            leading: const Icon(Icons.error),
            title: Text('Error: ${userSnapshot.error}'),
          );
        } else if (userSnapshot.hasData) {
          final user = userSnapshot.data!;
          return GestureDetector(
            onLongPress: () => _showEditOrDeleteDialog(comment),
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    leading: CircleAvatar(
                      backgroundImage: user.imageUrl != null
                          ? NetworkImage(user.imageUrl!)
                          : const AssetImage(
                              'assets/images/profile_picture.png'),
                    ),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.fullName),
                        Text(
                          formattedDate,
                          style: const TextStyle(
                              fontSize: 12.0, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(74, 0, 30, 16),
                    child: RichText(
                      textAlign: TextAlign.justify,
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 16.0,
                          color: Colors.black,
                        ),
                        children: [
                          WidgetSpan(
                            child: ExpandableText(
                              comment.review ??
                                  'Người dùng không viết nhận xét',
                              expandText: 'Xem thêm',
                              collapseText: 'Thu gọn',
                              maxLines: 3,
                              linkColor: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          return const ListTile(
            title: Text('Không có thông tin người dùng'),
          );
        }
      },
    );
  }
}
