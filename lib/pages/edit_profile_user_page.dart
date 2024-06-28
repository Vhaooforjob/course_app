import 'package:course_app/models/specialty.model.dart';
import 'package:course_app/services/api_specialty_services.dart';
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
  late TextEditingController _imageUrlController;
  late Future<User> _futureUser;
  late Future<List<Specialty>> _futureSpecialties;
  Future<Specialty>? _futureSelectedSpecialty;
  Specialty? selectedSpecialty;
  // ignore: unused_field
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _futureUser = fetchUserInfo(widget.userId);
    _futureSpecialties = ApiSpecialtyServices.fetchSpecialties();
    _usernameController = TextEditingController();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _imageUrlController = TextEditingController();
    _futureUser.then((user) {
      if (user.specialty != null) {
        _futureSelectedSpecialty =
            ApiSpecialtyServices.fetchSpecialtyById(user.specialty!.id);
      } else {
        _futureSelectedSpecialty = ApiSpecialtyServices.fetchSpecialtyById('');
      }
    }).catchError((error) {
      print('Error loading user information: $error');
      _futureSelectedSpecialty = ApiSpecialtyServices.fetchSpecialtyById('');
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _nameController.dispose();
    _emailController.dispose();
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
            // _specialtyController.text = user.specialty ?? '';
            // _selectedSpecialtyId = user.specialty?.id;
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
                            ? NetworkImage(
                                user.imageUrl!,
                                scale: 1.0,
                              )
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
                    FutureBuilder<List<Specialty>>(
                      future: _futureSpecialties,
                      builder: (context, specialtySnapshot) {
                        if (specialtySnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (specialtySnapshot.hasError) {
                          return Text('Error: ${specialtySnapshot.error}');
                        } else if (specialtySnapshot.hasData) {
                          final specialties = specialtySnapshot.data!;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              DropdownButtonFormField<String>(
                                value: user.specialty?.id,
                                decoration: const InputDecoration(
                                    labelText: 'Chức nghiệp'),
                                items: specialties.map((Specialty specialty) {
                                  return DropdownMenuItem<String>(
                                    value: specialty.id,
                                    child: Text(specialty.specialtyName),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _isLoading = true;
                                    _futureSelectedSpecialty =
                                        ApiSpecialtyServices.fetchSpecialtyById(
                                            value!);
                                  });
                                },
                              ),
                              const SizedBox(height: 10),
                              // Text(
                              //   'Selected Specialty ID: ${_selectedSpecialtyId ?? "None"}',
                              //   style: const TextStyle(fontSize: 16),
                              // ),
                              // if (!_isLoading)
                              //   FutureBuilder<Specialty>(
                              //     future: _futureSelectedSpecialty,
                              //     builder: (context, snapshot) {
                              //       if (snapshot.connectionState ==
                              //           ConnectionState.waiting) {
                              //         return const CircularProgressIndicator();
                              //       } else if (snapshot.hasError) {
                              //         return Text('Error: ${snapshot.error}');
                              //       } else if (snapshot.hasData) {
                              //         final selectedSpecialty = snapshot.data!;
                              //         return Text(
                              //           'Selected Specialty Name: ${selectedSpecialty.specialtyName}',
                              //           style: const TextStyle(fontSize: 16),
                              //         );
                              //       } else {
                              //         return const Text(
                              //             'Selected Specialty not found');
                              //       }
                              //     },
                              //   ),
                            ],
                          );
                        } else {
                          return const Text('No specialties found');
                        }
                      },
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
                      onPressed: () async {
                        _futureSelectedSpecialty ??=
                            ApiSpecialtyServices.fetchSpecialtyById(
                                user.specialty!.id);
                        final selectedSpecialty =
                            await _futureSelectedSpecialty;

                        final updatedUser = User(
                          id: user.id,
                          username: _usernameController.text,
                          email: _emailController.text,
                          fullName: _nameController.text,
                          joinDate: user.joinDate,
                          imageUrl: _imageUrlController.text,
                          specialty: selectedSpecialty,
                        );

                        bool success = await updateUser(updatedUser);
                        if (success) {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Thông báo'),
                                content: const Text(
                                    'Bạn đã cập nhật thông tin thành công!'),
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
                              content: Text('Cập nhật thất bại'),
                            ),
                          );
                        }
                      },
                      child: const Text('Cập nhật'),
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
