import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_widgets/screens/job_circular_screen.dart';
import 'package:flutter_widgets/screens/mentor_post_screen.dart';
import 'package:flutter_widgets/screens/payment_reminder/payment_remainder_screen.dart';
import 'package:flutter_widgets/screens/targetbox_product/targetbox_product.dart';
import 'package:flutter_widgets/screens/todo_list_screen/todo_list_screen.dart';
import 'package:get/get.dart';
import 'package:marquee/marquee.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 50),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopBar(),
              const SizedBox(height: 12),
              _buildLiveBox(),
              const SizedBox(height: 20),
              const ImageSliderCustom(),
              const SizedBox(height: 24),
              _buildSectionHeader('Quick Access'),
              const SizedBox(height: 16),
              _buildGridView(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return const Text(
      'Mentor Assist',
      style: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w800,
        color: Color(0xFF111827),
        letterSpacing: -0.5,
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Color(0xFF111827),
      ),
    );
  }

  Widget _buildLiveBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7B39FD).withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          const LiveTag(),
          const SizedBox(width: 10),
          Expanded(
            child: SizedBox(
              height: 20,
              child: Marquee(
                text: 'Hello designer, how are you today? We have a new upcoming session scheduled for you. Please check your dashboard for more details.',
                style: const TextStyle(
                  color: Color(0xFF374151),
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
                scrollAxis: Axis.horizontal,
                crossAxisAlignment: CrossAxisAlignment.center,
                blankSpace: 40.0,
                velocity: 40.0,
                pauseAfterRound: const Duration(seconds: 2),
                showFadingOnlyWhenScrolling: true,
                fadingEdgeStartFraction: 0.1,
                fadingEdgeEndFraction: 0.1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridView(BuildContext context) {
    final List<Map<String, dynamic>> items = [
      {
        'title': 'Payment\nReminder',
        'icon': Icons.credit_card_rounded,
        'color': const Color(0xFF7B39FD),
      },
      {
        'title': 'To Do List\nPlanner',
        'icon': Icons.checklist_rounded,
        'color': const Color(0xFF3B82F6),
      },
      {
        'title': 'Simple\nCalculator',
        'icon': Icons.calculate_rounded,
        'color': const Color(0xFFF59E0B),
      },
      {
        'title': 'Target Box\nProducts',
        'icon': Icons.podcasts_rounded,
        'color': const Color(0xFFEC4899),
      },
      {
        'title': 'Career\nUpdates',
        'icon': Icons.work_rounded,
        'color': const Color(0xFF10B981),
      },
      {
        'title': 'Add Mentor\nPost',
        'icon': Icons.add_rounded,
        'color': const Color(0xFF6366F1),
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.85,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final itemColor = items[index]['color'] as Color;
        return GestureDetector(
          onTap: () {
            if (index == 0) {
              Get.to(() => PaymentRemainderScreen());
            } else if (index == 1) {
              Get.to(() => const TodoListScreen());
            } else if (index == 3) {
              Get.to(() => ProductScreen());
            } else if (index == 4) {
              Get.to(() => JobCircularScreen());
            } else if (index == 5) {
              Get.to(() => const MentorPostScreen());
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: itemColor.withOpacity(0.08),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
              border: Border.all(color: itemColor.withOpacity(0.1)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: itemColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(items[index]['icon'], size: 22, color: itemColor),
                ),
                const SizedBox(height: 12),
                Text(
                  items[index]['title'],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF374151),
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ImageSliderCustom extends StatefulWidget {
  const ImageSliderCustom({super.key});

  @override
  State<ImageSliderCustom> createState() => _ImageSliderCustomState();
}

class _ImageSliderCustomState extends State<ImageSliderCustom> {
  final PageController _controller = PageController();
  int _currentPage = 0;
  Timer? _timer;

  final List<String> sliderImages = [
    'assets/images/firstpic.png',
    'assets/images/secondpic.png',
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (_currentPage < sliderImages.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      if (_controller.hasClients) {
        _controller.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeIn,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 170,
          child: PageView.builder(
            controller: _controller,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: sliderImages.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                  image: DecorationImage(
                    image: AssetImage(sliderImages[index]),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            sliderImages.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(right: 6),
              height: 8,
              width: _currentPage == index ? 24 : 8,
              decoration: BoxDecoration(
                color:
                    _currentPage == index
                        ? const Color(0xFF7B39FD)
                        : const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class LiveTag extends StatelessWidget {
  const LiveTag({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF7B39FD).withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Color(0xFF7B39FD),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          const Text(
            'Live',
            style: TextStyle(
              color: Color(0xFF7B39FD),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
