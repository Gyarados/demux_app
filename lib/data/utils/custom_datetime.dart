import 'package:intl/intl.dart';

class RelativeDateTime {
  final DateTime _dateTime;

  RelativeDateTime.fromDateTime(this._dateTime);

  static RelativeDateTime now() {
    return RelativeDateTime.fromDateTime(DateTime.now());
  }

  factory RelativeDateTime.fromJson(Map<String, dynamic> json) {
    return RelativeDateTime.fromDateTime(DateTime.parse(json['dateTime']));
  }

  Map<String, dynamic> toJson() {
    return {'dateTime': _dateTime.toIso8601String()};
  }

  RelativeDateTime toLocal() {
    return RelativeDateTime.fromDateTime(_dateTime.toLocal());
  }

  String timeAgo() {
    final currentTime = DateTime.now();
    final difference = currentTime.difference(_dateTime);
    final dateFormat = DateFormat('yyyy/MM/dd');

    if (difference.inDays > 30) {
      return dateFormat.format(_dateTime);
    } else if (difference.inDays > 0) {
      return "${difference.inDays}d ago";
    } else if (difference.inHours > 0) {
      return "${difference.inHours}h ago";
    } else if (difference.inMinutes > 0) {
      return "${difference.inMinutes}m ago";
    } else {
      return "${difference.inSeconds}s ago";
    }
  }
}
