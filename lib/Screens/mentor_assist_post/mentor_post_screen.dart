import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_widgets/controller/mentor_post_controller.dart';
import 'package:get/get.dart';

class MentorPostScreen extends StatelessWidget {
  const MentorPostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final MentorPostController controller = Get.put(MentorPostController());

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF7B39FD),
        elevation: 0,
        centerTitle: true,
        leadingWidth: 56,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16, top: 10, bottom: 10),
          child: InkWell(
            onTap: () => Get.back(),
            customBorder: const CircleBorder(),
            child: ClipOval(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16),
                ),
              ),
            ),
          ),
        ),
        title: const Text(
          "Mentor Assist Post",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: GetBuilder<MentorPostController>(
        builder: (controller) {
          return Obx(() {
            if (controller.isLoading.value && controller.postList.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF7B39FD)),
              );
            }

            if (controller.postList.isEmpty) {
              return const Center(
                child: Text(
                  "No posts available",
                  style: TextStyle(color: Color(0xFF6B7280), fontSize: 16),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => controller.fetchPosts(),
              color: const Color(0xFF7B39FD),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: controller.postList.length,
                itemBuilder: (context, index) {
                  var post = controller.postList[index];
                  return MentorPostCard(post: post);
                },
              ),
            );
          });
        },
      ),
    );
  }

}

class MentorPostCard extends StatefulWidget {
  final Map<String, dynamic> post;

  const MentorPostCard({super.key, required this.post});

  @override
  State<MentorPostCard> createState() => _MentorPostCardState();
}

class _MentorPostCardState extends State<MentorPostCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    var post = widget.post;
    String subtitle = post['subtitle'] ?? '';
    bool isLongText = subtitle.length > 100;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7B39FD).withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.event_note_rounded, size: 14, color: Color(0xFF6B7280)),
                          const SizedBox(width: 6),
                          Text(
                            post['date'] ?? '',
                            style: const TextStyle(
                              color: Color(0xFF4B5563),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  post['title'] ?? '',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF4B5563),
                        fontSize: 14,
                        height: 1.5,
                      ),
                      maxLines: _isExpanded ? null : 3,
                      overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                    ),
                    if (isLongText && !_isExpanded)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isExpanded = true;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Row(
                            children: [
                              const Icon(Icons.sentiment_satisfied_alt_rounded, color: Color(0xFF7B39FD), size: 18),
                              const SizedBox(width: 4),
                              const Text(
                                "Read more",
                                style: TextStyle(
                                  color: Color(0xFF7B39FD),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                              const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF7B39FD), size: 20),
                            ],
                          ),
                        ),
                      ),
                    if (isLongText && _isExpanded)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isExpanded = false;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Row(
                            children: [
                              const Icon(Icons.sentiment_satisfied_alt_rounded, color: Color(0xFF7B39FD), size: 18),
                              const SizedBox(width: 4),
                              const Text(
                                "Show less",
                                style: TextStyle(
                                  color: Color(0xFF7B39FD),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                              const Icon(Icons.keyboard_arrow_up_rounded, color: Color(0xFF7B39FD), size: 20),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          
          if (post['type'] == 'image' && post['imageUrl'] != null) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  post['imageUrl'],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 180,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 180,
                      width: double.infinity,
                      color: const Color(0xFFF3F4F6),
                      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 180,
                    width: double.infinity,
                    color: const Color(0xFFF3F4F6),
                    child: const Icon(Icons.image_not_supported_rounded, color: Color(0xFF9CA3AF), size: 40),
                  ),
                ),
              ),
            ),
          ],

          if (post['type'] == 'video') ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      height: 180,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF3F4F6),
                        image: DecorationImage(
                          image: AssetImage('assets/images/postpic.png'),
                          fit: BoxFit.cover,
                          opacity: 0.6,
                        ),
                      ),
                    ),
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.play_arrow_rounded, color: Color(0xFF7B39FD), size: 28),
                    ),
                    Positioned(
                      bottom: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          "VIDEO",
                          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
