import 'package:flutter/material.dart';
import 'package:talksy/services/firestore_service.dart';

void showSearchDialog(BuildContext context) {
  final controller = TextEditingController();
  final service = FirestoreService.instance;

  showDialog(
    context: context,
    builder: (_) {
      Map<String, dynamic>? userData;
      bool loading = false;
      bool searched = false;

      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Search by Email'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: controller),

                const SizedBox(height: 12),

                if (loading) const CircularProgressIndicator(),

                if (searched && userData == null && !loading)
                  const Text('No user found'),

                if (userData != null)
                  ListTile(
                    leading: CircleAvatar(
                      child: Text(userData!['name'][0].toUpperCase()),
                    ),
                    title: Text(userData!['name']),
                    subtitle: Text(userData!['email']),
                    trailing: IconButton(
                      icon: const Icon(Icons.person_add),
                      color: Colors.green,
                      tooltip: "Request chat",
                      onPressed: () {
                        Navigator.pop(context);

                        // TODO: send request / open chat
                      },
                    ),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  setState(() {
                    loading = true;
                    searched = true;
                  });

                  userData = await service.getUserProfileByEmail(
                    controller.text.trim(),
                  );

                  setState(() => loading = false);
                },
                child: const Text('Search'),
              ),
            ],
          );
        },
      );
    },
  );
}
