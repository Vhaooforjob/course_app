import 'package:flutter/material.dart';
import 'package:course_app/models/users.model.dart';
import 'package:course_app/services/api_user_services.dart';

class EditProfileUserPage extends StatefulWidget {
  final String userId;

  const EditProfileUserPage({required this.userId, Key? key}) : super(key: key);

  @override
  _EditProfileUserPageState createState() => _EditProfileUserPageState();
}

class _EditProfileUserPageState extends State<EditProfileUserPage> {
  late TextEditingController _usernameController;
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _specialtyController;
  late TextEditingController _imageUrlController;
  late Future<User> _futureUser;

  @override
  void initState() {
    super.initState();
    _futureUser = fetchUserInfo(widget.userId);
    _usernameController = TextEditingController();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _specialtyController = TextEditingController();
    _imageUrlController = TextEditingController();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _specialtyController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
      ),
      body: FutureBuilder<User>(
        future: _futureUser,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final user = snapshot.data!;
            _usernameController.text = user.username;
            _nameController.text = user.fullName;
            _emailController.text = user.email;
            _specialtyController.text = user.specialty ?? '';
            _imageUrlController.text = user.imageUrl ?? '';

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    if (user.imageUrl != null && user.imageUrl!.isNotEmpty)
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: user.imageUrl != null
                            ? NetworkImage(user.imageUrl!)
                            : const ExactAssetImage(
                                    'assets/images/profile_picture.png')
                                as ImageProvider,
                      ),
                    TextField(
                      controller: _usernameController,
                      decoration:
                          const InputDecoration(labelText: 'Tên tài khoản'),
                    ),
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Họ và tên'),
                    ),
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                    ),
                    // TextField(
                    //   controller: _specialtyController,
                    //   decoration: const InputDecoration(labelText: 'Specialty'),
                    // ),
                    TextField(
                      controller: _imageUrlController,
                      decoration: const InputDecoration(labelText: 'Image URL'),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        final updatedUser = User(
                          id: user.id,
                          username: _usernameController.text,
                          email: _emailController.text,
                          fullName: _nameController.text,
                          joinDate: user.joinDate,
                          imageUrl: _imageUrlController.text,
                          specialty: _specialtyController.text,
                        );
                        updateUser(updatedUser).then((success) {
                          if (success) {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('THÔNG BÁO'),
                                  content:
                                      const Text('Đã cập nhật thành công!'),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        Navigator.of(context).pop(true);
                                      },
                                      child: const Text('OK'),
                                    ),
                                  ],
                                );
                              },
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Failed to update user')),
                            );
                          }
                        });
                      },
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return const Center(child: Text('No user data'));
          }
        },
      ),
    );
  }
}
