class CustomerModel {
  final int id;
  final String name;
  final String status;

  const CustomerModel({
    required this.id,
    required this.name,
    required this.status,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'] as int,
      name: json['name'] as String,
      status: json['status'] as String? ?? 'active',
    );
  }
}
