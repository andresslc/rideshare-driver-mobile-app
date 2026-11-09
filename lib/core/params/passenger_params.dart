class PassengerParams {
  final String id;

  const PassengerParams({required this.id});

  Map<String, dynamic> toJson() {
    return {"id": id};
  }
}
