class ReviewsRequestParams {
  final int page;
  final int limit;

  ReviewsRequestParams({this.page = 1, this.limit = 10});

  // toJsone
  Map<String, dynamic> toJson() {
    return {"page": page, "limit": limit};
  }
}
