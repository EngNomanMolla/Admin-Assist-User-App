import 'package:get/get.dart';

class MentorPostController extends GetxController {
  List<Map<String, dynamic>> postList = [
    {
      'type': 'text',
      'title': 'Welcome to Mentor Assist',
      'subtitle':
          'We are excited to introduce Mentor Assist, your dedicated learning companion...',
      'date': 'February 10, 2026',
    },
    {
      'type': 'image',
      'title': 'Welcome to Mentor Assist',
      'subtitle':
          'We are excited to introduce Mentor Assist, your dedicated learning companion...',
      'date': 'February 10, 2026',
      'imageUrl': 'assets/images/postpic.png',
    },
    {
      'type': 'video',
      'title': 'Welcome to Mentor Assist',
      'subtitle':
          'We are excited to introduce Mentor Assist, your dedicated learning companion...',
      'date': 'February 10, 2026',
      'videoThumbnail': 'assets/images/postpic.png',
    },
  ];

  void addPost(Map<String, dynamic> newPost) {
    postList.add(newPost);
    update();
  }
}
