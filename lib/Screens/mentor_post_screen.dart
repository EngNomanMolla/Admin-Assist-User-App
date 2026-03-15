// import 'package:flutter/material.dart';
// import 'package:flutter_widgets/controller/mentor_post_controller.dart';
// import 'package:get/get.dart';

// class MentorPostScreen extends StatelessWidget {
//   const MentorPostScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     // কন্ট্রোলারটি মেমরিতে রাখার জন্য put করা হলো
//     Get.put(MentorPostController());

//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black87),
//           onPressed: () => Get.back(),
//         ),
//         title: const Text(
//           "Mentor Assist Post",
//           style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
//         ),
//         centerTitle: true,
//       ),
//       // Obx এর পরিবর্তে GetBuilder ব্যবহার করা হয়েছে
//       body: GetBuilder<MentorPostController>(
//         builder: (controller) {
//           return ListView.builder(
//             padding: const EdgeInsets.all(16),
//             itemCount: controller.postList.length,
//             itemBuilder: (context, index) {
//               var post = controller.postList[index];
//               return _buildPostCard(post);
//             },
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildPostCard(Map<String, dynamic> post) {
//     return Container(

//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Padding(
//             padding: const EdgeInsets.symmetric(vertical: 10),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   post['title'],
//                   style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 5),
//                 Text(
//                   post['subtitle'],
//                   style: const TextStyle(color: Colors.grey, fontSize: 14),
//                 ),
//                 const SizedBox(height: 5),
//                 Text(
//                   post['date'],
//                   style: const TextStyle(color: Colors.black38, fontSize: 12),
//                 ),
//               ],
//             ),
//           ),

//           // ইমেজ পোস্টের জন্য
//           if (post['type'] == 'image')
//             ClipRRect(
//               borderRadius: BorderRadius.circular(12),
//               child: Image.network(
//                 "https://via.placeholder.com/350x180",
//                 fit: BoxFit.cover,
//                 width: double.infinity,
//               ),
//             ),

//           // ভিডিও পোস্টের জন্য (ইমেজের ওপর প্লে বাটন)
//           if (post['type'] == 'video')
//             Stack(
//               alignment: Alignment.center,
//               children: [
//                 ClipRRect(
//                   borderRadius: BorderRadius.circular(12),
//                   child: Image.network(
//                     "https://via.placeholder.com/350x180",
//                     fit: BoxFit.cover,
//                     width: double.infinity,
//                   ),
//                 ),
//                 const CircleAvatar(
//                   backgroundColor: Colors.white,
//                   child: Icon(Icons.play_arrow, color: Colors.blue),
//                 ),
//               ],
//             ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_widgets/controller/mentor_post_controller.dart';
import 'package:get/get.dart';

class MentorPostScreen extends StatelessWidget {
  const MentorPostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // কন্ট্রোলারটি ইনজেক্ট করা হলো
    // যদি আগে কোথাও put করা না থাকে তবে এখানে করা যাবে
    final MentorPostController controller = Get.put(MentorPostController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "Mentor Assist Post",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      // GetBuilder ব্যবহার করা হয়েছে পারফরম্যান্সের জন্য
      body: GetBuilder<MentorPostController>(
        builder: (controller) {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.postList.length,
            itemBuilder: (context, index) {
              var post = controller.postList[index];
              return _buildPostCard(post);
            },
          );
        },
      ),
    );
  }

  // পোস্ট কার্ড উইজেট যা ক্লাসের ভেতরে থাকবে
  Widget _buildPostCard(Map<String, dynamic> post) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // পোস্টের টেক্সট অংশ
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post['title'] ?? '',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                post['subtitle'] ?? '',
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                post['date'] ?? '',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ইমেজ পোস্টের জন্য কন্ডিশনাল উইজেট
          if (post['type'] == 'image')
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.network(
                post['imageUrl'] ?? "assets/images/postpic.png",

                fit: BoxFit.cover,
                width: double.infinity,
                height: 180,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 180,
                  color: Colors.grey[200],
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                ),
              ),
            ),

          if (post['type'] == 'video')
            Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(
                    post['videoThumbnail'] ?? "assets/images/postpic.png",

                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 180,
                  ),
                ),

                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.black26, blurRadius: 10),
                    ],
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    color: Color(0xFF7B42FF),
                    size: 30,
                  ),
                ),
              ],
            ),

          const SizedBox(height: 10),
          Divider(color: Colors.grey.shade200, thickness: 1),
        ],
      ),
    );
  }
}
