// import 'package:flutter/material.dart';
// import 'package:flutter_widgets/controller/job_controller.dart';
// import 'package:get/get.dart';

// class JobCircularScreen extends StatelessWidget {
//   const JobCircularScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final JobController controller = Get.put(JobController());

//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black54),
//           onPressed: () => Get.back(),
//         ),
//         title: const Text(
//           "Bangladesh Jobs Circular",
//           style: TextStyle(
//             color: Colors.black87,
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.search, color: Colors.black54),
//             onPressed: () {},
//           ),
//         ],
//         centerTitle: false,
//       ),
//       body: Obx(
//         () => ListView.builder(
//           padding: const EdgeInsets.only(top: 10, bottom: 20),
//           itemCount: controller.jobList.length,
//           itemBuilder: (context, index) {
//             return _buildJobCard(controller.jobList[index]);
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildJobCard(Map<String, dynamic> job) {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: const Color(0xFFF9FAFB),
//         borderRadius: BorderRadius.circular(25),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       job['title'],
//                       style: const TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Color(0xFF374151),
//                       ),
//                     ),
//                     const SizedBox(height: 10),
//                     Text(
//                       "Post: ${job['post']}",
//                       style: const TextStyle(color: Colors.grey, fontSize: 14),
//                     ),
//                     Text(
//                       "Educational: ${job['edu']}",
//                       style: const TextStyle(color: Colors.grey, fontSize: 14),
//                     ),
//                   ],
//                 ),
//               ),

//               Container(
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFEBE5FF),
//                   shape: BoxShape.circle,
//                 ),
//                 child: const Icon(
//                   Icons.north_east,
//                   size: 20,
//                   color: Color(0xFF6C40FE),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 25),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 20,
//                   vertical: 8,
//                 ),
//                 decoration: BoxDecoration(
//                   color: Colors.black.withOpacity(0.05),
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: const Text(
//                   "Circular",
//                   style: TextStyle(
//                     color: Colors.black54,
//                     fontSize: 12,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ),

//               Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 8,
//                 ),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFFFEBEE),
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Text(
//                   "Deadline: ${job['deadline']}",
//                   style: const TextStyle(
//                     color: Color(0xFFEF4444),
//                     fontSize: 12,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_widgets/controller/job_controller.dart';
import 'package:get/get.dart';

class JobCircularScreen extends StatelessWidget {
  const JobCircularScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final JobController controller = Get.put(JobController());

    final RxInt selectedIndex = 0.obs;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black54),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "Bangladesh Jobs Circular",
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black54),
            onPressed: () {},
          ),
        ],
        centerTitle: false,
      ),
      body: Obx(
        () => ListView.builder(
          padding: const EdgeInsets.only(top: 10, bottom: 20),
          itemCount: controller.jobList.length,
          itemBuilder: (context, index) {
            return _buildJobCard(controller.jobList[index]);
          },
        ),
      ),

      // --- Bottom Navigation Bar ---
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,

          selectedItemColor: const Color(0xFF6C40FE),

          unselectedItemColor: Colors.grey.shade400,

          showUnselectedLabels: true,
          currentIndex: selectedIndex.value,
          selectedFontSize: 12,
          unselectedFontSize: 12,

          onTap: (index) {
            selectedIndex.value = index;
          },

          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calculate_outlined),
              activeIcon: Icon(Icons.calculate),
              label: 'Calculator',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_outlined),
              activeIcon: Icon(Icons.add_box),
              label: 'Post',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications_none),
              activeIcon: Icon(Icons.notifications),
              label: 'Notification',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobCard(Map<String, dynamic> job) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job['title'] ?? '',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF374151),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Post: ${job['post'] ?? ''}",
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    Text(
                      "Educational: ${job['edu'] ?? ''}",
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFFEBE5FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.north_east,
                  size: 20,
                  color: Color(0xFF6C40FE),
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "Circular",
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "Deadline: ${job['deadline'] ?? ''}",
                  style: const TextStyle(
                    color: Color(0xFFEF4444),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
