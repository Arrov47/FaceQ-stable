class UserWithLog {
  final String id;
  final String name;
  final String surname;
  final String fathersName;
  final String group;
  final List<dynamic> log;

  UserWithLog({
    required this.id,
    required this.name,
    required this.surname,
    required this.fathersName,
    required this.group,
    required this.log,
  });

  factory UserWithLog.fromJson(Map<String, dynamic> json) {
    return UserWithLog(
        id: json['id'],
        name: json['name'],
        surname: json['surname'],
        fathersName: json['fathersName'],
        group: json['group'],
        log: json['log']);
  }
}

class Log {
  final String time;
  final String type;

  Log({
    required this.time,
    required this.type,
  });

  factory Log.fromJson(Map<String, dynamic> json) {
    return Log(time: json['time'], type: 'type');
  }

  Map<String, dynamic> toJson() {
    return {
      'time': time,
      'type': type,
    };
  }
}
