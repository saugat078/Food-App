import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfileWidget extends StatelessWidget {
  final String userId;

  const UserProfileWidget({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('riders').doc(userId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (snapshot.hasError) {
          return const Icon(Icons.error);
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Icon(Icons.person);
        }

        Map<String, dynamic> riderData = snapshot.data!.data() as Map<String, dynamic>;
        String name = riderData['name'] ?? 'N/A';
        String initials = name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?';

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UserProfileScreen(riderData: riderData),
              ),
            );
          },
          child: CircleAvatar(
            backgroundColor: Colors.teal,
            child: Text(
              initials,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
    );
  }
}

class UserProfileScreen extends StatelessWidget {
  final Map<String, dynamic> riderData;

  const UserProfileScreen({Key? key, required this.riderData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rider Profile'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${riderData['name'] ?? 'N/A'}', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('Email: ${riderData['email'] ?? 'N/A'}', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('Phone: ${riderData['phone'] ?? 'N/A'}', style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}