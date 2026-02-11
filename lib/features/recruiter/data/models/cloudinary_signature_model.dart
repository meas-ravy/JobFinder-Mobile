class CloudinarySignatureModel {
  final String signature;
  final int timestamp;
  final String apiKey;
  final String cloudName;
  final String folder;
  final String transformation;

  CloudinarySignatureModel({
    required this.signature,
    required this.timestamp,
    required this.apiKey,
    required this.cloudName,
    required this.folder,
    required this.transformation,
  });

  factory CloudinarySignatureModel.fromJson(Map<String, dynamic> json) {
    return CloudinarySignatureModel(
      signature: json['signature'],
      timestamp: json['timestamp'],
      apiKey: json['apiKey'],
      cloudName: json['cloudName'],
      folder: json['folder'],
      transformation: json['transformation'],
    );
  }
}
