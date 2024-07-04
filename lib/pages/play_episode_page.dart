import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../models/episodes.model.dart';
import '../services/api_episode_services.dart';
import 'package:expandable_text/expandable_text.dart';

class PlayEpisodePage extends StatefulWidget {
  final String episodeId;
  final List<Episode> episodes;

  const PlayEpisodePage({
    required this.episodeId,
    required this.episodes,
    Key? key,
  }) : super(key: key);

  @override
  State<PlayEpisodePage> createState() => _PlayEpisodePageState();
}

class _PlayEpisodePageState extends State<PlayEpisodePage>
    with SingleTickerProviderStateMixin {
  late Future<Episode> _episodeFuture;
  YoutubePlayerController? _youtubeController;
  String? _selectedEpisodeId;
  bool _isFullScreen = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _selectedEpisodeId = widget.episodeId;
    _episodeFuture = fetchEpisodeById(widget.episodeId);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _isFullScreen
          ? null
          : AppBar(
              title: const Text(
                'Chi tiết phần học',
                style: TextStyle(color: Colors.black),
              ),
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
                              fontSize: 16,
                              fontWeight: FontWeight
                                  .w600), // Ensure font size is set here
                          expandOnTextTap: true,
                          collapseOnTextTap: true,
                          linkStyle: TextStyle(
                              fontSize:
                                  12), // Smaller font size for expand/collapse text
                        ),
                        const SizedBox(height: 8.0),
                      ],
                    ),
                  ),
                  TabBar(
                    controller: _tabController,
                    tabs: const [
                      Tab(text: 'Nội dung khoá học'),
                      Tab(text: 'Phần học'),
                    ],
                    labelColor: Colors.black,
                    indicatorColor: Colors.black,
                  ),
                  SizedBox(
                    height: 400, // Adjust height as needed
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // Course Content Tab
                        const Center(
                          child: Text(
                            'Nội dung khoá học',
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ),
                        // Episode List Tab
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: widget.episodes.length,
                          itemBuilder: (context, index) {
                            final episode = widget.episodes[index];
                            return Card(
                              color: episode.id == _selectedEpisodeId
                                  ? const Color.fromRGBO(135, 147, 255, 1)
                                  : const Color.fromARGB(255, 255, 255, 255),
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 8.0),
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
                                trailing: const Icon(Icons.play_arrow),
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
}
