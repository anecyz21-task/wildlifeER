// A StatelessWidget that represents the user's profile page.
// 
// This page provides an overview of the user's profile information
// and includes options for navigation to different sub function 
// such as the knowledge test, identification, logoff, and more. 
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'identification.dart';
import 'knowledgeTest.dart';
import '../providers/user_provider.dart'; // Replace with actual import
import 'login.dart'; // Import the login page

// A widget representing the Profile Page.
class ProfilePage extends StatelessWidget {
  // The theme data for customizing the appearance of the profile page.
  final ThemeData theme;

  // Constructs a ProfilePage widget.
  const ProfilePage({Key? key, required this.theme}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Page'),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          )
        ],
      ),
      body: ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.orange,
                  child: Text('Image', style: TextStyle(fontSize: 12)),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          _editUIDDialog(context, userProvider);
                        },
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                userProvider.user?.username ?? 'Username',
                                style: const TextStyle(fontSize: 15),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Icon(Icons.edit, size: 16),
                          ],
                        ),
                      ),
                      Text(
                        userProvider.user?.email ?? 'Email',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.quiz, color: theme.iconTheme.color),
            title: Text('Knowledge Test', style: theme.textTheme.titleMedium),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => KnowledgeTestPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.card_membership, color: theme.iconTheme.color),
            title: Text('Volunteer/Professional Identification', style: theme.textTheme.titleMedium),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => IdentificationPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.post_add, color: theme.iconTheme.color),
            title: Text('My Posts', style: theme.textTheme.titleMedium),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.logout, color: theme.iconTheme.color),
            title: Text('Logoff', style: theme.textTheme.titleMedium),
            onTap: () {
              // Clear user data from provider
              userProvider.clearLocalData();

              // Navigate to the Login Page
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
                (route) => false,
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.download, color: theme.iconTheme.color),
            title: Text('Download data', style: theme.textTheme.titleMedium),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  // This dialog allows the user to input a new username and updates
  void _editUIDDialog(BuildContext context, UserProvider userProvider) {
    final TextEditingController uidController =
        TextEditingController(text: userProvider.user?.uid ?? '');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit UID'),
          content: TextField(
            controller: uidController,
            decoration: const InputDecoration(labelText: 'Enter new UID'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Update UID in userProvider
                userProvider.updateName(uidController.text);
                Navigator.of(context). pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
