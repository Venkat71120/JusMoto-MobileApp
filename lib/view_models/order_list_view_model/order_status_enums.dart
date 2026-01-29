import 'package:car_service/helper/local_keys.g.dart';

enum StatusType {
  all,
  booking,
  payment,
}

enum BookingStatus {
  pending,
  accepted,
  inProgress,
  complete,
  canceled,
}

enum PaymentStatus {
  pending,
  complete,
}

final typeValues = EnumValues({
  LocalKeys.all: StatusType.all,
  LocalKeys.booking: StatusType.booking,
  LocalKeys.payment: StatusType.payment
});

final bookingStatusValues = EnumValues({
  LocalKeys.pending: BookingStatus.pending,
  LocalKeys.accepted: BookingStatus.accepted,
  LocalKeys.inProgress: BookingStatus.inProgress,
  LocalKeys.complete: BookingStatus.complete,
  LocalKeys.canceled: BookingStatus.canceled,
});

final paymentStatusValues = EnumValues({
  LocalKeys.pending: PaymentStatus.pending,
  LocalKeys.complete: PaymentStatus.complete,
});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
