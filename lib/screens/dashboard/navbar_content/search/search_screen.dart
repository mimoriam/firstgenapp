import 'package:firstgenapp/constants/appColors.dart';
import 'package:firstgenapp/screens/dashboard/navbar_content/chats/conversation/conversation_screen.dart';
import 'package:firstgenapp/screens/dashboard/navbar_content/search/match_detail_for_search/match_detail_for_search_screen.dart';
import 'package:firstgenapp/services/firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late Future<Map<String, dynamic>> _searchFuture;

  @override
  void initState() {
    super.initState();
    _searchFuture = _fetchPreferencesAndSearch();
  }

  Future<Map<String, dynamic>> _fetchPreferencesAndSearch() async {
    if (!mounted) return {};

    final firebaseService = Provider.of<FirebaseService>(
      context,
      listen: false,
    );
    final userProfile = await firebaseService.getUserProfile();

    if (userProfile == null || !userProfile.exists) {
      throw Exception('Could not load your profile to perform search.');
    }

    final userData = userProfile.data()!;

    final String? continent = userData['regionFocus'];
    final String? generation = userData['lookingForGeneration'];
    final String? gender = userData['searchGender'];
    final int minAge = userData['searchMinAge'] ?? 18;
    final int maxAge = userData['searchMaxAge'] ?? 100;
    final List<String> languages = List<String>.from(
      userData['searchLanguages'] ?? [],
    );
    final List<String> professions = List<String>.from(
      userData['searchProfessions'] ?? [],
    );
    final List<String> interests = List<String>.from(
      userData['searchInterests'] ?? [],
    );

    return {
      'continent': continent,
      'generation': generation,
      'gender': gender,
      'minAge': minAge,
      'maxAge': maxAge,
      'languages': languages,
      'professions': professions,
      'interests': interests,
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _searchFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: AppColors.secondaryBackground,
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Error: ${snapshot.error}\nPlease ensure your search preferences are set in your profile.',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Could not load preferences.'));
        }

        final searchParams = snapshot.data!;

        return MatchDetailForSearchScreen(
          continent: searchParams['continent'],
          generation: searchParams['generation'],
          gender: searchParams['gender'],
          minAge: searchParams['minAge'],
          maxAge: searchParams['maxAge'],
          languages: searchParams['languages'],
          professions: searchParams['professions'],
          interests: searchParams['interests'],
          // FIX: Updated onUserSelected to correctly handle chat navigation.
          onUserSelected: (user) async {
            final firebaseService = Provider.of<FirebaseService>(
              context,
              listen: false,
            );
            // Add to recent matches
            firebaseService.addRecentUser(user.uid);

            // Get or create the conversation
            final conversation = await firebaseService.getOrCreateConversation(
              user.uid,
            );

            // Navigate to the conversation screen
            if (context.mounted) {
              PersistentNavBarNavigator.pushNewScreen(
                context,
                screen: ConversationScreen(conversation: conversation),
                withNavBar: false,
              );
            }
          },
        );
      },
    );
  }
}
