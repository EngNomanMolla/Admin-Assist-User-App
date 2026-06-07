import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class JoinCommunityScreen extends StatelessWidget {
  const JoinCommunityScreen({super.key});

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        Get.snackbar(
          'Error',
          'Could not launch $url',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Invalid link or browser not available.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> socialLinks = [
      {
        'name': 'Official Website',
        'subtitle': 'Explore our platform and features',
        'url': 'https://mentorassist.online',
        'icon': Icons.public_rounded,
        'color': const Color(0xFF7B39FD),
        'bgGradient': const LinearGradient(
          colors: [Color(0xFF7B39FD), Color(0xFF9E6CFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      },
      {
        'name': 'Facebook Community',
        'subtitle': 'Join our active Facebook group & page',
        'url': 'https://www.facebook.com/mentorassist',
        'icon': Icons.facebook_rounded,
        'color': const Color(0xFF1877F2),
        'bgGradient': const LinearGradient(
          colors: [Color(0xFF1877F2), Color(0xFF4A94FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      },
      {
        'name': 'YouTube Channel',
        'subtitle': 'Watch tutorials and masterclasses',
        'url': 'https://www.youtube.com/@mentorassist',
        'icon': Icons.play_circle_fill_rounded,
        'color': const Color(0xFFFF0000),
        'bgGradient': const LinearGradient(
          colors: [Color(0xFFFF0000), Color(0xFFFF4D4D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      },
      {
        'name': 'LinkedIn Network',
        'subtitle': 'Connect with professionals & mentors',
        'url': 'https://www.linkedin.com/company/mentorassist',
        'icon': Icons.business_center_rounded,
        'color': const Color(0xFF0A66C2),
        'bgGradient': const LinearGradient(
          colors: [Color(0xFF0A66C2), Color(0xFF358FE6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      },
      {
        'name': 'X / Twitter',
        'subtitle': 'Get quick updates and industry news',
        'url': 'https://x.com/mentorassist',
        'icon': Icons.close_rounded,
        'color': const Color(0xFF0F1419),
        'bgGradient': const LinearGradient(
          colors: [Color(0xFF0F1419), Color(0xFF333333)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      },
      {
        'name': 'TikTok Channel',
        'subtitle': 'Quick tips and interesting stories',
        'url': 'https://www.tiktok.com/@mentorassist',
        'icon': Icons.music_note_rounded,
        'color': const Color(0xFF010101),
        'bgGradient': const LinearGradient(
          colors: [Color(0xFF010101), Color(0xFF25F4EE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      },
      {
        'name': 'WhatsApp Group',
        'subtitle': 'Get real-time updates and discussions',
        'url': 'https://chat.whatsapp.com/mentorassist', // Placeholder WhatsApp group
        'icon': Icons.chat_bubble_rounded,
        'color': const Color(0xFF25D366),
        'bgGradient': const LinearGradient(
          colors: [Color(0xFF25D366), Color(0xFF4ADE80)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text(
          'Join Community',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Center(
          child: GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Color(0xFF7B39FD),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 14),
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x05000000),
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7B39FD).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.groups_rounded,
                      color: Color(0xFF7B39FD),
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Be part of our family!',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111827),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Stay connected, receive updates, learn directly from expert mentors, and scale your skills and finance together.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF4B5563),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: socialLinks.length,
                separatorBuilder: (context, index) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final link = socialLinks[index];
                  final gradient = link['bgGradient'] as Gradient;

                  return GestureDetector(
                    onTap: () => _launchURL(link['url']),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: (link['color'] as Color).withOpacity(0.04),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                        border: Border.all(
                          color: const Color(0xFFE5E7EB),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              gradient: gradient,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              link['icon'] as IconData,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  link['name'] as String,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF111827),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  link['subtitle'] as String,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 14,
                              color: Color(0xFF9CA3AF),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
