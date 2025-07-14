import 'package:aplikasi_absensi/api/api_service.dart';
import 'package:aplikasi_absensi/constant/app_color.dart';
import 'package:aplikasi_absensi/helper/share_pref.dart';
import 'package:aplikasi_absensi/models/profile_model.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  static const String id = "/register_page";

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final AuthService _authService = AuthService();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _isFetchingDropdownData = true;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _selectedGender;
  final List<String> _genders = ['Laki-laki', 'Perempuan'];

  Batch? _selectedBatch;
  List<Batch> _batches = [];

  Training? _selectedTraining;
  List<Training> _trainings = [];

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _fetchDropdownData();
  }

  Future<void> _fetchDropdownData() async {
    setState(() {
      _isFetchingDropdownData = true;
    });
    try {
      final fetchedBatches = await _authService.fetchBatches();
      final fetchedTrainings = await _authService.fetchTrainings();

      setState(() {
        _batches = fetchedBatches;
        _trainings = fetchedTrainings;
        // Optionally pre-select the first item if lists are not empty
        // _selectedBatch = _batches.isNotEmpty ? _batches.first : null;
        // _selectedTraining = _trainings.isNotEmpty ? _trainings.first : null;
      });
    } catch (e) {
      _showMessage(
        'Gagal memuat data Batch atau Training: $e',
        color: Colors.red,
      );
    } finally {
      setState(() {
        _isFetchingDropdownData = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showMessage(String message, {Color color = Colors.black}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 5),
        backgroundColor: color,
      ),
    );
  }

  void _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Pastikan batch dan training sudah dipilih
    if (_selectedBatch == null) {
      _showMessage('Silakan pilih Batch.', color: Colors.red);
      return;
    }
    if (_selectedTraining == null) {
      _showMessage('Silakan pilih Training.', color: Colors.red);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Konversi _selectedGender ke 'L' atau 'P'
    String genderForApi = '';
    if (_selectedGender == 'Laki-laki') {
      genderForApi = 'L';
    } else if (_selectedGender == 'Perempuan') {
      genderForApi = 'P';
    } else {
      // Ini seharusnya tidak tercapai jika validator sudah bekerja
      _showMessage('Jenis kelamin tidak valid.', color: Colors.red);
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final response = await _authService.register(
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        jenisKelamin: genderForApi,
        batchId: _selectedBatch!.id, // Send selected batch ID
        trainingId: _selectedTraining!.id, // Send selected training ID
      );

      if (response.data != null) {
        _showMessage(
          'Pendaftaran berhasil! Silakan masuk.',
          color: Colors.green,
        );
        await SharedPreferencesUtil.saveAuthToken(response.data!.token);
        await SharedPreferencesUtil.saveUserData(response.data!.user);
        Navigator.pop(context);
      } else {
        String errorMessage = response.message;
        if (response.errors != null) {
          response.errors!.forEach((key, value) {
            errorMessage +=
                '\n${key.toUpperCase()}: ${(value as List).join(', ')}';
          });
        }
        _showMessage(errorMessage, color: Colors.red);
      }
    } catch (e) {
      _showMessage('Terjadi kesalahan tak terduga: $e', color: Colors.red);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.neutral,
      appBar: AppBar(
        title: const Text(
          'Daftar Akun Baru',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColor.myblue2,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          "Daftar Akun Baru",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColor.myblue,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      _buildTitle("Email"),
                      const SizedBox(height: 12),
                      _buildTextField(
                        hintText: "Masukkan email Anda",
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email tidak boleh kosong';
                          }
                          if (!value.contains('@') || !value.contains('.')) {
                            return 'Masukkan email yang valid';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildTitle("Nama Lengkap"),
                      const SizedBox(height: 12),
                      _buildTextField(
                        hintText: "Masukkan nama lengkap Anda",
                        controller: _nameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Nama tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      _buildTitle("Jenis Kelamin"),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _selectedGender,
                        decoration: InputDecoration(
                          hintText: 'Pilih jenis kelamin Anda',
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 16.0,
                            horizontal: 16.0,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: Colors.grey,
                              width: 1.0,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: AppColor.myblue,
                              width: 2.0,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Colors.red,
                              width: 2.0,
                            ),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Colors.red,
                              width: 2.0,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                        items:
                            _genders.map((String gender) {
                              return DropdownMenuItem<String>(
                                value: gender,
                                child: Text(gender),
                              );
                            }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedGender = newValue;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Jenis kelamin tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Dropdown Batch
                      _buildTitle("Batch"),
                      const SizedBox(height: 12),
                      _isFetchingDropdownData
                          ? const Center(child: CircularProgressIndicator())
                          : DropdownButtonFormField<Batch>(
                            value: _selectedBatch,
                            decoration: InputDecoration(
                              hintText: 'Pilih Batch Anda',
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 16.0,
                                horizontal: 16.0,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.grey,
                                  width: 1.0,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: AppColor.myblue,
                                  width: 2.0,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Colors.red,
                                  width: 2.0,
                                ),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Colors.red,
                                  width: 2.0,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.grey[100],
                            ),
                            items:
                                _batches.map((Batch batch) {
                                  return DropdownMenuItem<Batch>(
                                    value: batch,
                                    child: Text(
                                      'Batch ${batch.batchKe} (${batch.startDate} - ${batch.endDate})',
                                    ),
                                  );
                                }).toList(),
                            onChanged: (Batch? newValue) {
                              setState(() {
                                _selectedBatch = newValue;
                              });
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Batch tidak boleh kosong';
                              }
                              return null;
                            },
                          ),
                      const SizedBox(height: 20),

                      // Dropdown Training
                      _buildTitle("Training"),
                      const SizedBox(height: 12),
                      _isFetchingDropdownData
                          ? const Center(child: CircularProgressIndicator())
                          : DropdownButtonFormField<Training>(
                            value: _selectedTraining,
                            decoration: InputDecoration(
                              hintText: 'Pilih Training Anda',
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 16.0,
                                horizontal: 16.0,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.grey,
                                  width: 1.0,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: AppColor.myblue,
                                  width: 2.0,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Colors.red,
                                  width: 2.0,
                                ),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Colors.red,
                                  width: 2.0,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.grey[100],
                            ),
                            items:
                                _trainings.map((Training training) {
                                  return DropdownMenuItem<Training>(
                                    value: training,
                                    child: Text(training.title),
                                  );
                                }).toList(),
                            onChanged: (Training? newValue) {
                              setState(() {
                                _selectedTraining = newValue;
                              });
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Training tidak boleh kosong';
                              }
                              return null;
                            },
                          ),
                      const SizedBox(height: 20),

                      _buildTitle("Kata Sandi"),
                      const SizedBox(height: 12),
                      _buildTextField(
                        hintText: "Masukkan kata sandi Anda",
                        controller: _passwordController,
                        isPassword: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Kata sandi tidak boleh kosong';
                          }
                          if (value.length < 6) {
                            return 'Kata sandi minimal 6 karakter';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 32),

                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed:
                              _isLoading || _isFetchingDropdownData
                                  ? null
                                  : _register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.myblue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 4,
                          ),
                          child:
                              _isLoading || _isFetchingDropdownData
                                  ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                  : const Text(
                                    "Daftar",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Sudah punya akun?",
                            style: TextStyle(
                              fontSize: 15,
                              color: AppColor.gray88,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              "Masuk",
                              style: TextStyle(
                                color: AppColor.myblue,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    String? hintText,
    bool isPassword = false,
    required TextEditingController controller,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      obscureText: isPassword ? !_isPasswordVisible : false,
      decoration: InputDecoration(
        hintText: hintText,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16.0,
          horizontal: 16.0,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColor.myblue, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red, width: 2.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red, width: 2.0),
        ),
        filled: true,
        fillColor: Colors.grey[100],
        suffixIcon:
            isPassword
                ? IconButton(
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: AppColor.gray88,
                  ),
                )
                : null,
      ),
    );
  }

  Widget _buildTitle(String text) {
    return Row(
      children: [
        Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColor.myblue,
          ),
        ),
      ],
    );
  }
}
