// class RideHistoryRequestParams {
//   final int page;

//   RideHistoryRequestParams({this.page = 1});
// }

class RideHistoryRequestParams {
  final int page;
  final String? status;
  final String? cancelledBy;

  RideHistoryRequestParams({this.page = 1, this.status, this.cancelledBy});
}
