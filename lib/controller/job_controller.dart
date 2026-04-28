import 'package:get/get.dart';

class JobController extends GetxController {
  var jobList = <Map<String, dynamic>>[
    {
      "id": 9,
      "organization_name": "Resource Integration Center",
      "post_title": "Senior Flutter Developer",
      "required_education": "BSc in CSE",
      "vacancy": 5,
      "deadline": "2026-04-26T00:00:00.000000Z",
      "job_description": "We are looking for an experienced Flutter developer to join our team and build cross-platform mobile applications. You should have deep knowledge of GetX, animations, and premium UI designs. Excellent problem-solving skills are required.",
      "application_link": "https://example.com/apply",
      "status": "active"
    },
    {
      "id": 10,
      "organization_name": "Tech Solutions Ltd.",
      "post_title": "Backend Engineer",
      "required_education": "MSc in CS",
      "vacancy": 2,
      "deadline": "2026-05-10T00:00:00.000000Z",
      "job_description": "Join our backend team to scale our microservices. Requirements include Node.js, PostgreSQL, and AWS experience. You will be responsible for maintaining high availability and optimizing query performance.",
      "application_link": null,
      "status": "active"
    },
    {
      "id": 11,
      "organization_name": "Creative Design Agency",
      "post_title": "UI/UX Designer",
      "required_education": "Bachelor of Arts",
      "vacancy": 1,
      "deadline": "2026-06-01T00:00:00.000000Z",
      "job_description": "Design stunning user interfaces for our global clients. Figma proficiency is a must. You will work closely with the development team to ensure pixel-perfect implementation of your designs.",
      "application_link": "https://example.com/apply/uiux",
      "status": "closed"
    }
  ].obs;
}
