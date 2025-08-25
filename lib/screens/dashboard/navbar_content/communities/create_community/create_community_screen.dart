import 'dart:io';
import 'package:firstgenapp/common/gradient_btn.dart';
import 'package:firstgenapp/constants/appColors.dart';
import 'package:firstgenapp/services/firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:iconly/iconly.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class CreateCommunityScreen extends StatefulWidget {
  const CreateCommunityScreen({super.key});

  @override
  State<CreateCommunityScreen> createState() => _CreateCommunityScreenState();
}

class _CreateCommunityScreenState extends State<CreateCommunityScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  List<File> _images = [];
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage(
      imageQuality: 70,
      maxWidth: 800,
    );
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _images = pickedFiles
            .map((pickedFile) => File(pickedFile.path))
            .toList();
      });
    }
  }

  void _createCommunity() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      if (_images.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please upload at least one image.')),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      final firebaseService = Provider.of<FirebaseService>(
        context,
        listen: false,
      );
      final userId = firebaseService.currentUser?.uid;

      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You must be logged in to create a community.'),
          ),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final formData = _formKey.currentState!.value;

      try {
        await firebaseService.createCommunity(
          name: formData['name'],
          description: formData['bio'],
          creatorId: userId,
          images: _images,
          whoFor: formData['whoFor'],
          whatToGain: formData['whatToGain'],
          rules: formData['rules'],
          isInviteOnly: formData['isInviteOnly'] ?? false,
        );
        if (mounted) {
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to create community: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textSecondary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Create Community', style: textTheme.headlineSmall),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: FormBuilder(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(
                label: 'Name',
                hint: 'Enter Community Name',
                name: 'name',
              ),
              _buildTextField(
                label: 'Short Bio/Detail',
                hint: 'Enter your detail here',
                maxLines: 4,
                name: 'bio',
              ),
              _buildTextField(
                label: 'Who is this community for?',
                hint: 'e.g., "This community is for..."',
                maxLines: 3,
                name: 'whoFor',
              ),
              _buildTextField(
                label: 'What will you gain from this community?',
                hint: 'e.g., "You will gain..."',
                maxLines: 3,
                name: 'whatToGain',
              ),
              _buildTextField(
                label: 'Community Rules',
                hint: 'e.g., "1. Be respectful..."',
                maxLines: 5,
                name: 'rules',
              ),
              _buildImageUploadSection(),
              const SizedBox(height: 8),
              _buildInviteOnlyCheckbox(),
              const SizedBox(height: 16),
              GradientButton(
                text: 'Create Community',
                onPressed: _isLoading ? null : _createCommunity,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.0,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required String name,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          FormBuilderTextField(
            name: name,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upload Images',
          style: Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFEEEEEE),
              borderRadius: BorderRadius.circular(12),
            ),
            child: _images.isEmpty
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        IconlyLight.camera,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Upload from gallery',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(4),
                    itemCount: _images.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 4,
                          mainAxisSpacing: 4,
                        ),
                    itemBuilder: (context, index) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(_images[index], fit: BoxFit.cover),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildInviteOnlyCheckbox() {
    return Transform.translate(
      offset: const Offset(-10, 0),
      child: FormBuilderCheckbox(
        name: 'isInviteOnly',
        initialValue: false,
        title: Text(
          'Invite or request only',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        controlAffinity: ListTileControlAffinity.leading,
        activeColor: AppColors.primaryRed,
      ),
    );
  }
}
