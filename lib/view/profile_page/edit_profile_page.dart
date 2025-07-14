// File: edit_profile_page.dart

import 'dart:io';

import 'package:aplikasi_absensi/api/api_service.dart';
import 'package:aplikasi_absensi/api/endpoint.dart';
import 'package:aplikasi_absensi/constant/app_color.dart';
import 'package:aplikasi_absensi/models/profile_model.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  String? _selectedGender;
  final List<String> _genders = ['Laki-laki', 'Perempuan'];

  Batch? _selectedBatch;
  List<Batch> _batches = [];

  Training? _selectedTraining;
  List<Training> _trainings = [];

  String _profileImageUrl =
      'https://placehold.co/100x100/007bff/ffffff?text=User';
  ProfileData? _currentUserProfile;
  final AuthService _authService = AuthService();
  bool _isLoading = true;
  bool _isSaving = false;

  File? _pickedImage;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);
    try {
      final profileResponse = await _authService.fetchUserProfile();
      if (!mounted) return;

      if (profileResponse.data != null) {
        _currentUserProfile = profileResponse.data;
        _nameController.text = _currentUserProfile!.name;
        _emailController.text = _currentUserProfile!.email;

        _selectedGender = _formatGenderForDropdown(
          _currentUserProfile!.jenisKelamin,
        );

        if (_currentUserProfile!.profilePhoto != null &&
            _currentUserProfile!.profilePhoto!.isNotEmpty) {
          _profileImageUrl =
              _currentUserProfile!.profilePhoto!.startsWith('http')
                  ? _currentUserProfile!.profilePhoto!
                  : '${Endpoint.baseUrl}/public/${_currentUserProfile!.profilePhoto!}';
        }
      }

      _batches = await _authService.fetchBatches();
      _trainings = await _authService.fetchTrainings();

      if (!mounted) return;

      if (_currentUserProfile != null) {
        final int? currentBatchId = int.tryParse(
          _currentUserProfile!.batchId.toString(),
        );
        final int? currentTrainingId = int.tryParse(
          _currentUserProfile!.trainingId.toString(),
        );

        _selectedBatch = _batches.firstWhereOrNull(
          (batch) => batch.id == currentBatchId,
        );
        _selectedTraining = _trainings.firstWhereOrNull(
          (training) => training.id == currentTrainingId,
        );
      }
    } catch (e) {
      if (!mounted) return;
      _showMessage(context, 'Gagal memuat data: $e', color: Colors.red);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String? _formatGenderForDropdown(String? genderCode) {
    switch (genderCode?.toUpperCase()) {
      case 'L':
        return 'Laki-laki';
      case 'P':
        return 'Perempuan';
      default:
        return null;
    }
  }

  void _showMessage(
    BuildContext context,
    String message, {
    Color color = Colors.black,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 4),
        backgroundColor: color,
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
        _profileImageUrl = pickedFile.path;
      });
      await _uploadProfilePhoto();
    }
  }

  Future<void> _uploadProfilePhoto() async {
    if (_pickedImage == null) return;

    setState(() => _isSaving = true);
    try {
      final response = await _authService.updateProfilePhotoBase64(
        imageFile: _pickedImage!,
      );
      if (!mounted) return;

      if (response.data != null) {
        _showMessage(context, response.message, color: Colors.green);
        setState(() => _profileImageUrl = response.data!.profilePhotoUrl);
      } else {
        _showMessage(context, response.message, color: Colors.red);
      }
    } catch (e) {
      if (mounted)
        _showMessage(context, 'Gagal upload foto: $e', color: Colors.red);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _saveChanges() async {
    if (_isSaving || _currentUserProfile == null) return;

    setState(() => _isSaving = true);
    try {
      final response = await _authService.updateUserProfile(
        name: _nameController.text,
        email: _emailController.text,
        jenisKelamin: _currentUserProfile!.jenisKelamin,
        batchId: _currentUserProfile!.batchId,
        trainingId: _currentUserProfile!.trainingId,
        onesignalPlayerId: _currentUserProfile!.onesignalPlayerId,
      );

      if (!mounted) return;

      if (response.data != null) {
        _showMessage(context, response.message, color: Colors.green);
        Navigator.pop(context, true);
      } else {
        _showMessage(context, response.message, color: Colors.red);
      }
    } catch (e) {
      if (mounted)
        _showMessage(context, 'Error saat menyimpan: $e', color: Colors.red);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.neutral,
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text('Ubah Profil'),
        backgroundColor: AppColor.myblue,
        centerTitle: true,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage:
                          _pickedImage != null
                              ? FileImage(_pickedImage!)
                              : NetworkImage(_profileImageUrl) as ImageProvider,
                    ),
                    TextButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text("Ubah Foto"),
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      _nameController,
                      'Nama Lengkap',
                      Icons.person,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      _emailController,
                      'Email',
                      Icons.email,
                      readOnly: true,
                    ),
                    const SizedBox(height: 16),
                    _buildDropdown(
                      _selectedGender,
                      _genders,
                      'Jenis Kelamin',
                      Icons.wc,
                    ),
                    const SizedBox(height: 16),
                    _buildDropdownItem<Batch>(
                      _selectedBatch,
                      _batches,
                      'Batch',
                      Icons.group,
                    ),
                    const SizedBox(height: 16),
                    _buildDropdownItem<Training>(
                      _selectedTraining,
                      _trainings,
                      'Training',
                      Icons.school,
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _isSaving ? null : _saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.myblue,
                        minimumSize: const Size.fromHeight(50),
                      ),
                      child:
                          _isSaving
                              ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                              : const Text(
                                'Simpan Perubahan',
                                style: TextStyle(color: Colors.white),
                              ),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    IconData icon, {
    bool readOnly = false,
  }) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildDropdown(
    String? value,
    List<String> items,
    String hint,
    IconData icon,
  ) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      items:
          items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: null, // Disabled
      disabledHint: value != null ? Text(value) : Text(hint),
    );
  }

  Widget _buildDropdownItem<T>(
    T? value,
    List<T> items,
    String hint,
    IconData icon,
  ) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      items:
          items
              .map((e) => DropdownMenuItem(value: e, child: Text(e.toString())))
              .toList(),
      onChanged: null, // Disabled
      disabledHint: value != null ? Text(value.toString()) : Text(hint),
    );
  }
}

extension FirstWhereOrNullExtension<E> on Iterable<E> {
  E? firstWhereOrNull(bool Function(E element) test) {
    for (var element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}
