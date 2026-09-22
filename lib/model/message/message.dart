import 'dart:developer';

import 'package:agro/model/message/created.dart';
import 'package:intl/intl.dart';

class Message extends Created {
  int? id, readed, tenderId;
  String? type, title, message;

  Message.fromJson(Map<String, dynamic> json) {
    id = int.tryParse(json['id'].toString());
    readed = int.tryParse(json['readed'].toString());
    tenderId = int.tryParse(json['tender_id'].toString());

    type = json['type'].toString();
    title = json['title'].toString();
    message = json['message'].toString();

    DateFormat format = DateFormat('dd.MM.yyyy HH:mm');
    createdAt = format.parse(json['created_human']);
  }

  bool get isRead => readed == 1;
}

List<Message> parseMessagesPayload(dynamic data) {
  final List<dynamic> raw;

  if (data is List) {
    raw = data;
  } else if (data is Map && data['payload'] is List) {
    raw = data['payload'] as List;
  } else {
    raw = const [];
  }

  final parsed = <Message>[];
  for (final item in raw) {
    try {
      if (item is Map<String, dynamic>) {
        parsed.add(Message.fromJson(item));
      } else if (item is Map) {
        parsed.add(Message.fromJson(Map<String, dynamic>.from(item)));
      }
    } catch (e) {
      log(
        'parseMessagesPayload skip item: $e, item=$item',
        name: 'InformMessages',
      );
    }
  }

  return parsed;
}
