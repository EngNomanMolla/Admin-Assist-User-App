import 'package:flutter_widgets/provider/api_provider.dart';
import 'package:http/http.dart' as http;

class MentorProvider extends ApiProvider {
  // Fetch mentor posts
  Future<http.Response> getMentorPosts() => getRequest('/mentor_posts');

  // Create a new mentor post
  Future<http.Response> createMentorPost(Map<String, dynamic> data) => postRequest('/mentor_posts', data);
}
