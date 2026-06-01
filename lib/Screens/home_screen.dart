import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_widgets/controller/home_controller.dart';
import 'package:flutter_widgets/controller/mentor_post_controller.dart';
import 'package:flutter_widgets/screens/career_update/job_circular_screen.dart';
import 'package:flutter_widgets/screens/mentor_assist_post/mentor_post_screen.dart';
import 'package:flutter_widgets/screens/payment_reminder/payment_remainder_screen.dart';
import 'package:flutter_widgets/screens/finance_planner/finance_planner_screen.dart';
import 'package:flutter_widgets/screens/targetbox_product/targetbox_product.dart';
import 'package:flutter_widgets/screens/todo_list_screen/todo_list_screen.dart';
import 'package:flutter_widgets/screens/calculator_screen/calculator_screen.dart';
import 'package:flutter_widgets/screens/finance_planner/budget/budget_screen.dart';
import 'package:get/get.dart';
import 'package:marquee/marquee.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.put(HomeController());
    Get.put(MentorPostController()); // Initialize to track new posts

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark, // dark icons for Android
        statusBarBrightness: Brightness.light, // dark icons for iOS
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        body: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
                child: _buildTopBar(),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => controller.fetchDashboardData(),
                  color: const Color(0xFF7B39FD),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 110),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Obx(() => _buildLiveBox(controller)),
                        const SizedBox(height: 20),
                        Obx(() => ImageSliderCustom(banners: controller.banners.value, isLoading: controller.isLoading.value)),
                        const SizedBox(height: 24),
                        _buildSectionHeader('Quick Access'),
                        const SizedBox(height: 16),
                        _buildGridView(context),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          'assets/images/logo.png',
          height: 32,
          width: 32,
          fit: BoxFit.contain,
        ),
        const SizedBox(width: 8),
        RichText(
          text: const TextSpan(
            style: TextStyle(
              fontSize: 26,
              letterSpacing: -0.5,
            ),
            children: [
              TextSpan(
                text: 'Mentor ',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF111827),
                ),
              ),
              TextSpan(
                text: 'Assist',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF7B39FD),
                ),
              ),
            ],
          ),
        ),
      ],
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

  Widget _buildLiveBox(HomeController controller) {
    if (controller.isLoading.value && controller.notices.isEmpty) {
      return Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          height: 50,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      );
    }

    if (controller.notices.isEmpty) return const SizedBox.shrink();

    String allNotices = controller.notices.map((n) => n['notice_text']).join(' | ');

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
                text: allNotices,
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
    final MentorPostController mentorController = Get.find<MentorPostController>();
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
        'title': 'Personal\nFinance',
        'icon': Icons.account_balance_wallet_rounded,
        'color': const Color(0xFF10B981),
      },
      {
        'title': 'Budget\nPlanner',
        'icon': Icons.pie_chart_rounded,
        'color': const Color(0xFFF97316),
      },
      {
        'title': 'Simple\nCalculator',
        'icon': Icons.calculate_rounded,
        'color': const Color(0xFFF59E0B),
      },
      {
        'title': 'Essential\nProducts',
        'icon': Icons.shopping_bag_rounded,
        'color': const Color(0xFFEC4899),
      },
      {
        'title': 'Job\nCirculars',
        'icon': Icons.work_rounded,
        'color': const Color(0xFF10B981),
      },
      {
        'title': 'Mentor\nPost',
        'icon': Icons.support_agent_rounded,
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
        final title = items[index]['title'] as String;
        
        return GestureDetector(
          onTap: () {
            if (title.contains('Payment')) {
              Get.to(() => PaymentRemainderScreen());
            } else if (title.contains('To Do')) {
              Get.to(() => const TodoListScreen());
            } else if (title.contains('Personal')) {
              Get.to(() => const FinancePlannerScreen());
            } else if (title.contains('Budget')) {
              Get.to(() => const BudgetScreen());
            } else if (title.contains('Calculator')) {
              Get.to(() => CalculatorScreen());
            } else if (title.contains('Products')) {
              Get.to(() => ProductScreen());
            } else if (title.contains('Job')) {
              Get.to(() => JobCircularScreen());
            } else if (title.contains('Mentor')) {
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
                Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: itemColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(items[index]['icon'], size: 22, color: itemColor),
                    ),
                    if (title.contains('Mentor'))
                      Obx(() => mentorController.hasNewPosts.value
                          ? Positioned(
                              top: 2,
                              right: 2,
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                              ),
                            )
                          : const SizedBox.shrink()),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  title,
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
  final List<Map<String, dynamic>> banners;
  final bool isLoading;
  const ImageSliderCustom({super.key, required this.banners, required this.isLoading});

  @override
  State<ImageSliderCustom> createState() => _ImageSliderCustomState();
}

class _ImageSliderCustomState extends State<ImageSliderCustom> {
  final PageController _controller = PageController();
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    if (widget.banners.isNotEmpty) {
      _timer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
        if (_currentPage < widget.banners.length - 1) {
          _currentPage++;
        } else {
          _currentPage = 0;
        }
        if (_controller.hasClients) {
          _controller.animateToPage(
            _currentPage,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOutCubic,
          );
        }
      });
    }
  }

  @override
  void didUpdateWidget(ImageSliderCustom oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.banners.length != oldWidget.banners.length) {
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading && widget.banners.isEmpty) {
      return Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          height: 170,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      );
    }

    if (widget.banners.isEmpty) return const SizedBox.shrink();

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
            itemCount: widget.banners.length,
            itemBuilder: (context, index) {
              final banner = widget.banners[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: CachedNetworkImage(
                    imageUrl: banner['image'] ?? '',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    placeholder: (context, url) => Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        color: Colors.white,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: const Color(0xFFF3F4F6),
                      child: const Icon(Icons.broken_image_rounded, color: Color(0xFF9CA3AF), size: 40),
                    ),
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
            widget.banners.length,
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
