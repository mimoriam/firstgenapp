import 'package:flutter/material.dart';
import 'package:firstgenapp/constants/appColors.dart';
import 'package:firstgenapp/common/gradient_btn.dart';

class CreateCommunityScreen extends StatefulWidget {
  const CreateCommunityScreen({super.key});

  @override
  State<CreateCommunityScreen> createState() => _CreateCommunityScreenState();
}

class _CreateCommunityScreenState extends State<CreateCommunityScreen> {
  bool _isInviteOnly = false;

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
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Create Community',
          // UPDATED: Inherited from theme
          style: textTheme.headlineSmall,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(label: 'Name', hint: 'Enter Community Name'),
            _buildTextField(
              label: 'Write a Short Bio',
              hint: 'Enter your detail here',
              maxLines: 4,
            ),
            _buildTextField(
              label: 'What is this community for?',
              hint: 'Enter your detail here',
              maxLines: 4,
            ),
            _buildTextField(
              label: 'What will you gain from this community?',
              hint: 'Enter your detail here',
              maxLines: 4,
            ),
            _buildTextField(
              label: 'Community Rules',
              hint: 'Enter your detail here',
              maxLines: 4,
            ),
            _buildImageUploadSection(),
            const SizedBox(height: 8),
            _buildInviteOnlyCheckbox(),
            const SizedBox(height: 16),
            GradientButton(
              text: 'Create Community',
              onPressed: () {},
              // UPDATED: Compacted button
              fontSize: 15,
              insets: 14,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            // UPDATED: Inherited from theme
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          TextField(
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hint,
              // UPDATED: Compacted field
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
          // UPDATED: Inherited from theme
          style: Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _buildImagePlaceholder(isUploaded: true),
            _buildImagePlaceholder(),
            _buildImagePlaceholder(),
            _buildImagePlaceholder(),
          ],
        ),
      ],
    );
  }

  Widget _buildImagePlaceholder({bool isUploaded = false}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.inputBorder),
        image: isUploaded
            ? const DecorationImage(
                image: NetworkImage(
                  'https://images.unsplash.com/photo-1511690656952-34342bb7c2f2?w=500&q=80',
                ),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: isUploaded
          ? null
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.camera_alt_outlined,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(height: 4),
                Text(
                  'Upload from gallery',
                  // UPDATED: Inherited from theme
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
    );
  }

  Widget _buildInviteOnlyCheckbox() {
    // UPDATED: Wrapped in Transform.translate to align checkbox to the left
    return Transform.translate(
      offset: const Offset(-10, 0),
      child: CheckboxListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(
          'Invite or request only',
          // UPDATED: Inherited from theme
          style: Theme.of(context).textTheme.labelLarge,
        ),
        value: _isInviteOnly,
        onChanged: (bool? value) {
          setState(() {
            _isInviteOnly = value ?? false;
          });
        },
        controlAffinity: ListTileControlAffinity.leading,
        activeColor: AppColors.primaryRed,
        // UPDATED: Made tile more compact
        dense: true,
      ),
    );
  }
}
