class CharacterModel {
  final String? id;
  final String? name;
  final String? avatar;
  final String? crew;
  final String? role;
  final num? bounty;
  final String? devilFruit;

  CharacterModel({
    this.id,
    this.name,
    this.avatar,
    this.crew,
    this.role,
    this.bounty,
    this.devilFruit = 'None',
  });

  factory CharacterModel.fromJson(Map<String, dynamic> json) => CharacterModel(
        id: json['id'] as String?,
        name: json['name'] as String?,
        avatar: json['avatar'] as String?,
        crew: json['crew'] as String?,
        role: json['role'] as String?,
        bounty: json['bounty'] as num?,
        devilFruit: json['devilFruit'] as String? ?? 'None',
      );

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'name': name,
        'avatar': avatar,
        'crew': crew,
        'role': role,
        'bounty': bounty,
        'devilFruit': devilFruit,
      };
}
