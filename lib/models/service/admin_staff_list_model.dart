class AdminStaffListModel {
  final List<Staff> staffs;

  AdminStaffListModel({
    required this.staffs,
  });

  factory AdminStaffListModel.fromJson(Map json) => AdminStaffListModel(
        staffs: json["all_staffs"] == null
            ? []
            : List<Staff>.from(
                json["all_staffs"].map((x) => Staff.fromJson(x))),
      );
}

class Staff {
  final dynamic id;
  final dynamic providerId;
  final dynamic adminId;
  final String? fullname;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phone;
  final String? about;
  final dynamic status;
  final dynamic image;

  Staff({
    this.id,
    this.providerId,
    this.adminId,
    this.fullname,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.about,
    this.status,
    this.image,
  });

  factory Staff.fromJson(Map<String, dynamic> json) => Staff(
        id: json["id"],
        providerId: json["provider_id"],
        adminId: json["admin_id"],
        fullname: json["fullname"],
        firstName: json["first_name"],
        lastName: json["last_name"],
        email: json["email"],
        phone: json["phone"],
        about: json["about"],
        status: json["status"],
        image: json["image"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "provider_id": providerId,
        "admin_id": adminId,
        "fullname": fullname,
        "first_name": firstName,
        "last_name": lastName,
        "email": email,
        "phone": phone,
        "about": about,
        "status": status,
        "image": image,
      };
  Map<String, dynamic> toMinimizedJson() => {
        "id": id,
        "fullname": fullname,
        "first_name": firstName,
        "last_name": lastName,
        "image": image,
      };
}
