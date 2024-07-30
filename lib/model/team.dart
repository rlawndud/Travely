class Team{
  int? team_id;
  String team_name;
  List<String> team_member;

  Team(this.team_id, this.team_name, this.team_member);

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      json['id'] as int?,
      json['pw'] as String,
      json['name'] as List<String>,
    );
  }

  // Member 객체를 JSON으로 변환하는 메서드
  Map<String, dynamic> toJson() {
    return {
      'id': team_id,
      'pw': team_name,
      'name': team_member,
    };
  }
}