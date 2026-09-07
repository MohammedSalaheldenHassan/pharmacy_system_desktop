// Canonical supplier model shared by the Suppliers screen and (once built)
// the Purchases screen, which links purchase orders back to a supplier id.

class SupplierModel {
  final String id;
  final String name;
  final String contactPerson;
  final String phone;
  final String email;
  final String address;

  const SupplierModel({
    required this.id,
    required this.name,
    required this.contactPerson,
    required this.phone,
    required this.email,
    required this.address,
  });

  SupplierModel copyWith({
    String? name,
    String? contactPerson,
    String? phone,
    String? email,
    String? address,
  }) {
    return SupplierModel(
      id: id,
      name: name ?? this.name,
      contactPerson: contactPerson ?? this.contactPerson,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
    );
  }
}
