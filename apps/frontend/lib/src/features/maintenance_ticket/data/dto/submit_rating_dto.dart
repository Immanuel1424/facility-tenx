class SubmitRatingDto {
  const SubmitRatingDto({
    required this.rating,
    this.comment,
  });

  final int rating;
  final String? comment;

  Map<String, dynamic> toJson() {
    return {
      'rating': rating,
      if (comment != null && comment!.isNotEmpty) 'comment': comment,
    };
  }
}

