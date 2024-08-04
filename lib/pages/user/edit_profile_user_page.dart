import 'dart:io';

import 'package:course_app/models/specialty.model.dart';
import 'package:course_app/services/api_specialty_services.dart';
import 'package:flutter/material.dart';
import 'package:course_app/models/users.model.dart';
import 'package:course_app/services/api_user_services.dart';
import 'package:image_picker/image_picker.dart';

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
  bool _isLoading = false;
  File? _imageFile;

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

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  InputDecoration _buildInputDecoration(String labelText) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: const TextStyle(color: Color(0xFFC1C1C1)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFC1C1C1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFC1C1C1)),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText) {
    return TextField(
      controller: controller,
      decoration: _buildInputDecoration(labelText),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          color: Colors.black,
          iconSize: 20,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
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
            _imageUrlController.text = user.imageUrl ?? '';

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: _imageFile == null
                              ? (user.imageUrl != null
                                  ? NetworkImage(user.imageUrl!)
                                  : const AssetImage(
                                          'assets/images/profile_picture.png')
                                      as ImageProvider)
                              : FileImage(_imageFile!) as ImageProvider,
                        ),
                        Positioned(
                          top: 65,
                          left: 60,
                          child: IconButton(
                            icon: const Icon(Icons.image,
                                color: Color(0xFF004FCA)),
                            onPressed: _pickImage,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(_usernameController, 'Tên tài khoản'),
                    const SizedBox(height: 20),
                    _buildTextField(_nameController, 'Họ và tên'),
                    const SizedBox(height: 20),
                    _buildTextField(_emailController, 'Email'),
                    const SizedBox(height: 20),
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
                          return DropdownButtonFormField<String>(
                            value: user.specialty?.id,
                            decoration: _buildInputDecoration('Chức nghiệp'),
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
                          );
                        } else {
                          return const Text('No specialties found');
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(_imageUrlController, 'Image URL'),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
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
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Bạn đã cập nhật thông tin thành công!',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                                backgroundColor: Colors.green,
                                behavior: SnackBarBehavior.floating,
                                padding: const EdgeInsets.all(16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            );
                            Navigator.pop(context, true);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Row(
                                  children: [
                                    Icon(
                                      Icons.remove_circle,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Cập nhật thất bại',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                                backgroundColor: Colors.red,
                                behavior: SnackBarBehavior.floating,
                                padding: const EdgeInsets.all(16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF004FCA),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9),
                          ),
                        ),
                        child: const Text('CẬP NHẬT',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ),
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
