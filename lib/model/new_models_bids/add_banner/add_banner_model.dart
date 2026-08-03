class AdBannerModel {
  final String image;
  final String? phone;

  const AdBannerModel({
    required this.image,
    this.phone,
  });

  factory AdBannerModel.fromJson(Map<String, dynamic> json) {
    return AdBannerModel(
      image: json['image'] ?? '',
      phone: json['phone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'image': image,
      'phone': phone,
    };
  }
}
class OpenContactsAdResponse {
  final bool status;
  final String message;
  final AdBannerModel? adBanner;

  OpenContactsAdResponse({
    required this.status,
    required this.message,
    this.adBanner,
  });

  factory OpenContactsAdResponse.fromJson(Map<String, dynamic> json) {
    return OpenContactsAdResponse(
      status: json['status'] == true,
      message: json['message'] ?? '',
      adBanner: json['ad_banner'] != null
          ? AdBannerModel.fromJson(json['ad_banner'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status,
        'message': message,
        'ad_banner': adBanner?.toJson(),
      };
}