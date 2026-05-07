import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'mock_catalog.dart';

const _openRecipeAssetPath = 'assets/data/open_recipes_seed.json';

Future<List<RecipeSuggestion>> loadOpenRecipeSuggestions() async {
  try {
    final payload = await rootBundle.loadString(_openRecipeAssetPath);
    final decoded = jsonDecode(payload) as List<dynamic>;
    final recipes = decoded
        .whereType<Map<String, dynamic>>()
        .map(RecipeSuggestion.fromJson)
        .where((recipe) => recipe.title.isNotEmpty)
        .where((recipe) => recipe.ingredients.isNotEmpty)
        .where((recipe) => recipe.steps.isNotEmpty)
        .toList();

    return [...recipeSuggestions, ...recipes];
  } on FlutterError {
    return recipeSuggestions;
  } on FormatException {
    return recipeSuggestions;
  }
}
