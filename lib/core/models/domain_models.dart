enum RequestStatus {
  draft,
  sent,
  read,
  accepted,
  rejected,
  counterProposed,
  expired,
  cancelled,
}

enum ExpenseStatus { sent, accepted, disputed, paid, overdue }

enum HandoverStatus {
  planned,
  onTheWay,
  arrived,
  completed,
  delayed,
  missed,
  disputed,
}

class ChildProfile {
  const ChildProfile({
    required this.id,
    required this.fullName,
    required this.ageLabel,
    required this.school,
  });

  final String id;
  final String fullName;
  final String ageLabel;
  final String school;
}

class CustodyEvent {
  const CustodyEvent({
    required this.id,
    required this.childName,
    required this.title,
    required this.startAt,
    required this.endAt,
    required this.assignedParent,
    required this.location,
    required this.status,
  });

  final String id;
  final String childName;
  final String title;
  final DateTime startAt;
  final DateTime endAt;
  final String assignedParent;
  final String location;
  final HandoverStatus status;
}

class MessageThread {
  const MessageThread({
    required this.id,
    required this.topic,
    required this.title,
    required this.lastMessage,
    required this.updatedAt,
    required this.unreadCount,
  });

  final String id;
  final String topic;
  final String title;
  final String lastMessage;
  final DateTime updatedAt;
  final int unreadCount;
}

class ExpenseItem {
  const ExpenseItem({
    required this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.requestedShare,
    required this.status,
    required this.date,
  });

  final String id;
  final String title;
  final String category;
  final double amount;
  final double requestedShare;
  final ExpenseStatus status;
  final DateTime date;
}
