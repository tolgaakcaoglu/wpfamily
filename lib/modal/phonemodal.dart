class Phone {
  final int id;
  final String number, label, status, countryCode;
  final List<Activite> activities;
  final DateTime created;
  final bool notificationEnabled;

  Phone(
      {this.id,
      this.number,
      this.countryCode,
      this.label,
      this.status,
      this.activities,
      this.notificationEnabled,
      this.created});

  factory Phone.build(Map<String, dynamic> json) {
    List<Activite> activities(list) {
      List<Activite> hasList = [];
      List copy =
          list.asMap().entries.map((e) => Activite.build(e.value)).toList();
      for (Activite c in copy) {
        hasList.add(c);
      }
      return hasList;
    }

    return Phone(
      number: json['number'],
      countryCode: json['countryCode'],
      label: json['label'],
      status: json['status'],
      activities: activities(json['activities']),
      created: DateTime.parse(json['created']),
      notificationEnabled: json['notificationEnabled'],
    );
  }
}

class Activite {
  final String transactionDate, startingTime, endTime;

  Activite({this.transactionDate, this.startingTime, this.endTime});

  factory Activite.build(Map<String, dynamic> map) {
    return Activite(
      transactionDate: map['transactionDate'],
      startingTime: map['startingTime'],
      endTime: map['endTime'],
    );
  }
}
