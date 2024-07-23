import 'package:intl/intl.dart';

String formatCommentDate(DateTime commentDate) {
  final vietnamTimeZoneOffset = Duration(hours: 7);

  final vietnamTime = commentDate.toUtc().add(vietnamTimeZoneOffset);

  final now = DateTime.now().toUtc().add(vietnamTimeZoneOffset);
  final difference = now.difference(vietnamTime);

  final dateFormat = DateFormat('dd/MM/yyyy');
  final timeFormat = DateFormat('HH:mm');

  if (difference.inHours > 24) {
    return dateFormat.format(vietnamTime);
  } else {
    return '${timeFormat.format(vietnamTime)} hôm nay';
  }
}
