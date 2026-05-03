class Recipe {
  const Recipe({
    required this.id,
    required this.title,
    required this.ingredients,
    required this.steps,
    required this.estimatedCost,
    required this.servings,
    required this.difficulty,
    this.imageUrl,
    this.relatedProductIds = const [],
  });

  final String id;
  final String title;
  final List<String> ingredients;
  final List<String> steps;
  final int estimatedCost;
  final int servings;
  final String difficulty;
  final String? imageUrl;
  final List<String> relatedProductIds;

  factory Recipe.fromMap(String id, Map<String, dynamic> data) {
    return Recipe(
      id: id,
      title: data['title'] as String? ?? '',
      ingredients: List<String>.from(data['ingredients'] as List? ?? const []),
      steps: List<String>.from(data['steps'] as List? ?? const []),
      estimatedCost: data['estimatedCost'] as int? ?? 0,
      servings: data['servings'] as int? ?? 1,
      difficulty: data['difficulty'] as String? ?? '',
      imageUrl: data['imageUrl'] as String?,
      relatedProductIds:
          List<String>.from(data['relatedProductIds'] as List? ?? const []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'ingredients': ingredients,
      'steps': steps,
      'estimatedCost': estimatedCost,
      'servings': servings,
      'difficulty': difficulty,
      'imageUrl': imageUrl,
      'relatedProductIds': relatedProductIds,
    };
  }
}
