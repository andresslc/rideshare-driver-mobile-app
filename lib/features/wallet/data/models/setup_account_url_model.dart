import '../../domain/entities/setup_account_url_entity.dart';

class SetupAccountUrlModel extends SetupAccountUrlEntity {
  const SetupAccountUrlModel({required super.url});

  factory SetupAccountUrlModel.fromResponse(Map<String, dynamic> json) {
    final data = json['data'];

    if (data is Map<String, dynamic>) {
      final url = data['url'];
      if (url is String && url.isNotEmpty) {
        return SetupAccountUrlModel(url: url);
      }
    }

    if (data is String && data.isNotEmpty) {
      return SetupAccountUrlModel(url: data);
    }

    throw const FormatException('Setup account URL not found in response');
  }
}
