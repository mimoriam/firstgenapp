import 'package:flutter/material.dart';
import 'package:firstgenapp/constants/appColors.dart';
import 'package:iconly/iconly.dart';

class YourMatchesScreen extends StatefulWidget {
  const YourMatchesScreen({super.key});

  @override
  State<YourMatchesScreen> createState() => _YourMatchesScreenState();
}

class _YourMatchesScreenState extends State<YourMatchesScreen> {
  // Mock data for user matches
  final List<Map<String, String>> _matches = [
    {
      "avatar": "https://randomuser.me/api/portraits/women/4.jpg",
      "name": "James Rana",
      "age": "20",
      "interests": "Love Music, Love Coffee",
    },
    {
      "avatar": "https://randomuser.me/api/portraits/women/5.jpg",
      "name": "James Rana",
      "age": "20",
      "interests": "Love Music, Love Coffee",
    },
    {
      "avatar": "https://randomuser.me/api/portraits/women/6.jpg",
      "name": "James Rana",
      "age": "20",
      "interests": "Love Music, Love Coffee",
    },
    {
      "avatar": "https://randomuser.me/api/portraits/men/3.jpg",
      "name": "James Rana",
      "age": "20",
      "interests": "Love Music, Love Coffee",
    },
    {
      "avatar": "https://randomuser.me/api/portraits/women/7.jpg",
      "name": "James Rana",
      "age": "20",
      "interests": "Love Music, Love Coffee",
    },
  ];

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
        title: RichText(
          text: TextSpan(
            // UPDATED: Inherited from theme
            style: textTheme.headlineSmall,
            children: [
              const TextSpan(text: 'Your Matches: '),
              TextSpan(
                text: _matches.length.toString(),
                // UPDATED: Inherited from theme
                style: textTheme.headlineSmall?.copyWith(
                  color: AppColors.primaryRed,
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              // Icons.search,
              IconlyLight.search,
              color: AppColors.textSecondary,
              size: 22,
            ),
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        itemCount: _matches.length,
        itemBuilder: (context, index) {
          return _buildMatchItem(_matches[index], textTheme);
        },
        // UPDATED: Used SizedBox for cleaner spacing
        separatorBuilder: (context, index) => const SizedBox(height: 8),
      ),
    );
  }

  /// Builds a single match item.
  Widget _buildMatchItem(Map<String, String> match, TextTheme textTheme) {
    return ListTile(
      // UPDATED: Compacted ListTile
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      leading: CircleAvatar(
        // UPDATED: Reduced size
        radius: 26,
        backgroundImage: NetworkImage(match['avatar']!),
      ),
      title: Text(
        '${match['name']}, ${match['age']}',
        // UPDATED: Inherited from theme with smaller font
        style: textTheme.labelLarge?.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        match['interests']!,
        // UPDATED: Inherited from theme
        style: textTheme.bodySmall,
      ),
      trailing: const Icon(
        IconlyLight.message,
        color: AppColors.primaryRed,
        size: 20,
      ),
      onTap: () {
        // Handle tap on match item
      },
    );
  }
}
