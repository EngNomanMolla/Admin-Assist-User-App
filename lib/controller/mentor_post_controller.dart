import 'dart:convert';
import 'package:flutter_widgets/provider/mentor_provider.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';

class MentorPostController extends GetxController {
  final MentorProvider _mentorProvider = MentorProvider();
  final _storage = GetStorage();
  
  List<Map<String, dynamic>> postList = [];
  var isLoading = false.obs;
  var hasNewPosts = false.obs;

  static const String _lastSeenKey = 'last_seen_post_id';

  @override
  void onInit() {
    super.onInit();
    fetchPosts();
  }

  Future<void> fetchPosts() async {
    try {
      isLoading.value = true;
      final response = await _mentorProvider.getMentorPosts();
      isLoading.value = false;

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        
        postList = data.map((post) {
          final DateTime createdAt = DateTime.parse(post['created_at']);
          final String formattedDate = DateFormat('MMMM d, yyyy').format(createdAt);
          
          return {
            'id': post['id'],
            'type': post['type'],
            'title': post['title'],
            'subtitle': post['content'],
            'date': formattedDate,
            'imageUrl': post['type'] == 'image' ? post['file_url'] : null,
            'videoUrl': post['type'] == 'video' ? post['file_url'] : null,
            'videoThumbnail': post['type'] == 'video' ? 'assets/images/postpic.png' : null, 
          };
        }).toList();

        // Check for new posts
        if (postList.isNotEmpty) {
          int latestId = int.tryParse(postList.first['id'].toString()) ?? 0;
          int lastSeenId = _storage.read(_lastSeenKey) ?? 0;
          
          if (latestId > lastSeenId) {
            hasNewPosts.value = true;
          } else {
            hasNewPosts.value = false;
          }
        }
        
        update();
      } else {
        Get.snackbar("Error", "Failed to fetch posts");
      }
    } catch (e) {
      isLoading.value = false;
      print("Error fetching mentor posts: $e");
      Get.snackbar("Error", "Something went wrong while loading posts");
    }
  }

  void markPostsAsSeen() {
    if (postList.isNotEmpty) {
      int latestId = int.tryParse(postList.first['id'].toString()) ?? 0;
      _storage.write(_lastSeenKey, latestId);
      hasNewPosts.value = false;
      update();
    }
  }

  void addPost(Map<String, dynamic> newPost) {
    postList.insert(0, newPost);
    update();
  }
}
