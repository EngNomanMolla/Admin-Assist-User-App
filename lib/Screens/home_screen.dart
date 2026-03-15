import 'package:flutter/material.dart';
import 'package:flutter_widgets/Screens/JobCircularScreen.dart';
import 'package:flutter_widgets/Screens/mentor_post_screen.dart';
import 'package:flutter_widgets/Screens/targetbox_product/targetbox_product.dart';

import 'package:flutter_widgets/Screens/todo_list_screen/todo_list_screen.dart';
import 'package:get/get.dart';

import 'package:flutter_widgets/Screens/payment_reminder/payment_remainder.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Mentor Assist',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildLiveBox(),
              const SizedBox(height: 20),

              const ImageSliderCustom(),

              const SizedBox(height: 25),
              _buildHeader(),
              const SizedBox(height: 15),
              _buildGridView(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: const [
        Text(
          'Quick Access',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text('See all', style: TextStyle(color: Colors.grey, fontSize: 13)),
      ],
    );
  }

  Widget _buildLiveBox() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5),
        ],
      ),
      child: Row(
        children: const [
          LiveTag(),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Hello designer, how are you today...',
              style: TextStyle(color: Colors.grey, fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridView(BuildContext context) {
    final List<Map<String, dynamic>> items = [
      {'title': 'Payment\nReminder', 'icon': Icons.credit_card},
      {'title': 'To Do List\nPlanner', 'icon': Icons.checklist},
      {'title': 'Simple\nCalculator', 'icon': Icons.calculate},
      {'title': 'Target Box\nProducts', 'icon': Icons.podcasts},
      {'title': 'Career\nUpdates', 'icon': Icons.work},
      {'title': 'Add Mentor\nAssist Post', 'icon': Icons.add},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            if (index == 0) {
              Get.to(() => PaymentRemainder());
            } else if (index == 1) {
              Get.to(() => const TodoListScreen());
            } else if (index == 3) {
              Get.to(() => ProductScreen());
            } else if (index == 4) {
              Get.to(() => const JobCircularScreen());
            } else if (index == 5) {
              Get.to(() => const MentorPostScreen());
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: index == 0
                  ? const Color(0xFF7B42FF)
                  : const Color(0xFFF2F2F2),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  items[index]['icon'],
                  size: 24,
                  color: index == 0 ? Colors.white : Colors.black54,
                ),
                const SizedBox(height: 10),
                Text(
                  items[index]['title'],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: index == 0 ? Colors.white : Colors.black87,
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

  final List<String> sliderImages = [
    'assets/images/firstpic.png',
    'assets/images/secondpic.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 160,
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
                  borderRadius: BorderRadius.circular(15),
                  image: DecorationImage(
                    image: NetworkImage(sliderImages[index]),
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
              margin: const EdgeInsets.only(right: 5),
              height: 8,
              width: _currentPage == index ? 20 : 8,
              decoration: BoxDecoration(
                color: _currentPage == index
                    ? const Color(0xFF7B42FF)
                    : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(5),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF7B42FF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        'Live',
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
