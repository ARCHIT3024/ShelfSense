// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $BeatsTable extends Beats with TableInfo<$BeatsTable, Beat> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BeatsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _repNameMeta = const VerificationMeta(
    'repName',
  );
  @override
  late final GeneratedColumn<String> repName = GeneratedColumn<String>(
    'rep_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, code, name, repName, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'beats';
  @override
  VerificationContext validateIntegrity(
    Insertable<Beat> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('rep_name')) {
      context.handle(
        _repNameMeta,
        repName.isAcceptableOrUnknown(data['rep_name']!, _repNameMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Beat map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Beat(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      repName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rep_name'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $BeatsTable createAlias(String alias) {
    return $BeatsTable(attachedDatabase, alias);
  }
}

class Beat extends DataClass implements Insertable<Beat> {
  final String id;
  final String code;
  final String name;
  final String? repName;
  final int createdAt;
  const Beat({
    required this.id,
    required this.code,
    required this.name,
    this.repName,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['code'] = Variable<String>(code);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || repName != null) {
      map['rep_name'] = Variable<String>(repName);
    }
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  BeatsCompanion toCompanion(bool nullToAbsent) {
    return BeatsCompanion(
      id: Value(id),
      code: Value(code),
      name: Value(name),
      repName: repName == null && nullToAbsent
          ? const Value.absent()
          : Value(repName),
      createdAt: Value(createdAt),
    );
  }

  factory Beat.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Beat(
      id: serializer.fromJson<String>(json['id']),
      code: serializer.fromJson<String>(json['code']),
      name: serializer.fromJson<String>(json['name']),
      repName: serializer.fromJson<String?>(json['repName']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'code': serializer.toJson<String>(code),
      'name': serializer.toJson<String>(name),
      'repName': serializer.toJson<String?>(repName),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  Beat copyWith({
    String? id,
    String? code,
    String? name,
    Value<String?> repName = const Value.absent(),
    int? createdAt,
  }) => Beat(
    id: id ?? this.id,
    code: code ?? this.code,
    name: name ?? this.name,
    repName: repName.present ? repName.value : this.repName,
    createdAt: createdAt ?? this.createdAt,
  );
  Beat copyWithCompanion(BeatsCompanion data) {
    return Beat(
      id: data.id.present ? data.id.value : this.id,
      code: data.code.present ? data.code.value : this.code,
      name: data.name.present ? data.name.value : this.name,
      repName: data.repName.present ? data.repName.value : this.repName,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Beat(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('repName: $repName, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, code, name, repName, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Beat &&
          other.id == this.id &&
          other.code == this.code &&
          other.name == this.name &&
          other.repName == this.repName &&
          other.createdAt == this.createdAt);
}

class BeatsCompanion extends UpdateCompanion<Beat> {
  final Value<String> id;
  final Value<String> code;
  final Value<String> name;
  final Value<String?> repName;
  final Value<int> createdAt;
  final Value<int> rowid;
  const BeatsCompanion({
    this.id = const Value.absent(),
    this.code = const Value.absent(),
    this.name = const Value.absent(),
    this.repName = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BeatsCompanion.insert({
    required String id,
    required String code,
    required String name,
    this.repName = const Value.absent(),
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       code = Value(code),
       name = Value(name),
       createdAt = Value(createdAt);
  static Insertable<Beat> custom({
    Expression<String>? id,
    Expression<String>? code,
    Expression<String>? name,
    Expression<String>? repName,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (code != null) 'code': code,
      if (name != null) 'name': name,
      if (repName != null) 'rep_name': repName,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BeatsCompanion copyWith({
    Value<String>? id,
    Value<String>? code,
    Value<String>? name,
    Value<String?>? repName,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return BeatsCompanion(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      repName: repName ?? this.repName,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (repName.present) {
      map['rep_name'] = Variable<String>(repName.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BeatsCompanion(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('repName: $repName, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StoresTable extends Stores with TableInfo<$StoresTable, Store> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StoresTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _beatIdMeta = const VerificationMeta('beatId');
  @override
  late final GeneratedColumn<String> beatId = GeneratedColumn<String>(
    'beat_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES beats (id)',
    ),
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ownerNameMeta = const VerificationMeta(
    'ownerName',
  );
  @override
  late final GeneratedColumn<String> ownerName = GeneratedColumn<String>(
    'owner_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _latMeta = const VerificationMeta('lat');
  @override
  late final GeneratedColumn<double> lat = GeneratedColumn<double>(
    'lat',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lngMeta = const VerificationMeta('lng');
  @override
  late final GeneratedColumn<double> lng = GeneratedColumn<double>(
    'lng',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sequenceMeta = const VerificationMeta(
    'sequence',
  );
  @override
  late final GeneratedColumn<int> sequence = GeneratedColumn<int>(
    'sequence',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    code,
    name,
    beatId,
    address,
    ownerName,
    phone,
    lat,
    lng,
    sequence,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stores';
  @override
  VerificationContext validateIntegrity(
    Insertable<Store> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('beat_id')) {
      context.handle(
        _beatIdMeta,
        beatId.isAcceptableOrUnknown(data['beat_id']!, _beatIdMeta),
      );
    } else if (isInserting) {
      context.missing(_beatIdMeta);
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    if (data.containsKey('owner_name')) {
      context.handle(
        _ownerNameMeta,
        ownerName.isAcceptableOrUnknown(data['owner_name']!, _ownerNameMeta),
      );
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('lat')) {
      context.handle(
        _latMeta,
        lat.isAcceptableOrUnknown(data['lat']!, _latMeta),
      );
    }
    if (data.containsKey('lng')) {
      context.handle(
        _lngMeta,
        lng.isAcceptableOrUnknown(data['lng']!, _lngMeta),
      );
    }
    if (data.containsKey('sequence')) {
      context.handle(
        _sequenceMeta,
        sequence.isAcceptableOrUnknown(data['sequence']!, _sequenceMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Store map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Store(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      beatId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}beat_id'],
      )!,
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      ),
      ownerName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_name'],
      ),
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      lat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lat'],
      ),
      lng: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lng'],
      ),
      sequence: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sequence'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $StoresTable createAlias(String alias) {
    return $StoresTable(attachedDatabase, alias);
  }
}

class Store extends DataClass implements Insertable<Store> {
  final String id;
  final String code;
  final String name;
  final String beatId;
  final String? address;
  final String? ownerName;
  final String? phone;
  final double? lat;
  final double? lng;
  final int sequence;
  final int createdAt;
  const Store({
    required this.id,
    required this.code,
    required this.name,
    required this.beatId,
    this.address,
    this.ownerName,
    this.phone,
    this.lat,
    this.lng,
    required this.sequence,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['code'] = Variable<String>(code);
    map['name'] = Variable<String>(name);
    map['beat_id'] = Variable<String>(beatId);
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    if (!nullToAbsent || ownerName != null) {
      map['owner_name'] = Variable<String>(ownerName);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || lat != null) {
      map['lat'] = Variable<double>(lat);
    }
    if (!nullToAbsent || lng != null) {
      map['lng'] = Variable<double>(lng);
    }
    map['sequence'] = Variable<int>(sequence);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  StoresCompanion toCompanion(bool nullToAbsent) {
    return StoresCompanion(
      id: Value(id),
      code: Value(code),
      name: Value(name),
      beatId: Value(beatId),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      ownerName: ownerName == null && nullToAbsent
          ? const Value.absent()
          : Value(ownerName),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      lat: lat == null && nullToAbsent ? const Value.absent() : Value(lat),
      lng: lng == null && nullToAbsent ? const Value.absent() : Value(lng),
      sequence: Value(sequence),
      createdAt: Value(createdAt),
    );
  }

  factory Store.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Store(
      id: serializer.fromJson<String>(json['id']),
      code: serializer.fromJson<String>(json['code']),
      name: serializer.fromJson<String>(json['name']),
      beatId: serializer.fromJson<String>(json['beatId']),
      address: serializer.fromJson<String?>(json['address']),
      ownerName: serializer.fromJson<String?>(json['ownerName']),
      phone: serializer.fromJson<String?>(json['phone']),
      lat: serializer.fromJson<double?>(json['lat']),
      lng: serializer.fromJson<double?>(json['lng']),
      sequence: serializer.fromJson<int>(json['sequence']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'code': serializer.toJson<String>(code),
      'name': serializer.toJson<String>(name),
      'beatId': serializer.toJson<String>(beatId),
      'address': serializer.toJson<String?>(address),
      'ownerName': serializer.toJson<String?>(ownerName),
      'phone': serializer.toJson<String?>(phone),
      'lat': serializer.toJson<double?>(lat),
      'lng': serializer.toJson<double?>(lng),
      'sequence': serializer.toJson<int>(sequence),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  Store copyWith({
    String? id,
    String? code,
    String? name,
    String? beatId,
    Value<String?> address = const Value.absent(),
    Value<String?> ownerName = const Value.absent(),
    Value<String?> phone = const Value.absent(),
    Value<double?> lat = const Value.absent(),
    Value<double?> lng = const Value.absent(),
    int? sequence,
    int? createdAt,
  }) => Store(
    id: id ?? this.id,
    code: code ?? this.code,
    name: name ?? this.name,
    beatId: beatId ?? this.beatId,
    address: address.present ? address.value : this.address,
    ownerName: ownerName.present ? ownerName.value : this.ownerName,
    phone: phone.present ? phone.value : this.phone,
    lat: lat.present ? lat.value : this.lat,
    lng: lng.present ? lng.value : this.lng,
    sequence: sequence ?? this.sequence,
    createdAt: createdAt ?? this.createdAt,
  );
  Store copyWithCompanion(StoresCompanion data) {
    return Store(
      id: data.id.present ? data.id.value : this.id,
      code: data.code.present ? data.code.value : this.code,
      name: data.name.present ? data.name.value : this.name,
      beatId: data.beatId.present ? data.beatId.value : this.beatId,
      address: data.address.present ? data.address.value : this.address,
      ownerName: data.ownerName.present ? data.ownerName.value : this.ownerName,
      phone: data.phone.present ? data.phone.value : this.phone,
      lat: data.lat.present ? data.lat.value : this.lat,
      lng: data.lng.present ? data.lng.value : this.lng,
      sequence: data.sequence.present ? data.sequence.value : this.sequence,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Store(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('beatId: $beatId, ')
          ..write('address: $address, ')
          ..write('ownerName: $ownerName, ')
          ..write('phone: $phone, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('sequence: $sequence, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    code,
    name,
    beatId,
    address,
    ownerName,
    phone,
    lat,
    lng,
    sequence,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Store &&
          other.id == this.id &&
          other.code == this.code &&
          other.name == this.name &&
          other.beatId == this.beatId &&
          other.address == this.address &&
          other.ownerName == this.ownerName &&
          other.phone == this.phone &&
          other.lat == this.lat &&
          other.lng == this.lng &&
          other.sequence == this.sequence &&
          other.createdAt == this.createdAt);
}

class StoresCompanion extends UpdateCompanion<Store> {
  final Value<String> id;
  final Value<String> code;
  final Value<String> name;
  final Value<String> beatId;
  final Value<String?> address;
  final Value<String?> ownerName;
  final Value<String?> phone;
  final Value<double?> lat;
  final Value<double?> lng;
  final Value<int> sequence;
  final Value<int> createdAt;
  final Value<int> rowid;
  const StoresCompanion({
    this.id = const Value.absent(),
    this.code = const Value.absent(),
    this.name = const Value.absent(),
    this.beatId = const Value.absent(),
    this.address = const Value.absent(),
    this.ownerName = const Value.absent(),
    this.phone = const Value.absent(),
    this.lat = const Value.absent(),
    this.lng = const Value.absent(),
    this.sequence = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StoresCompanion.insert({
    required String id,
    required String code,
    required String name,
    required String beatId,
    this.address = const Value.absent(),
    this.ownerName = const Value.absent(),
    this.phone = const Value.absent(),
    this.lat = const Value.absent(),
    this.lng = const Value.absent(),
    this.sequence = const Value.absent(),
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       code = Value(code),
       name = Value(name),
       beatId = Value(beatId),
       createdAt = Value(createdAt);
  static Insertable<Store> custom({
    Expression<String>? id,
    Expression<String>? code,
    Expression<String>? name,
    Expression<String>? beatId,
    Expression<String>? address,
    Expression<String>? ownerName,
    Expression<String>? phone,
    Expression<double>? lat,
    Expression<double>? lng,
    Expression<int>? sequence,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (code != null) 'code': code,
      if (name != null) 'name': name,
      if (beatId != null) 'beat_id': beatId,
      if (address != null) 'address': address,
      if (ownerName != null) 'owner_name': ownerName,
      if (phone != null) 'phone': phone,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      if (sequence != null) 'sequence': sequence,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StoresCompanion copyWith({
    Value<String>? id,
    Value<String>? code,
    Value<String>? name,
    Value<String>? beatId,
    Value<String?>? address,
    Value<String?>? ownerName,
    Value<String?>? phone,
    Value<double?>? lat,
    Value<double?>? lng,
    Value<int>? sequence,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return StoresCompanion(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      beatId: beatId ?? this.beatId,
      address: address ?? this.address,
      ownerName: ownerName ?? this.ownerName,
      phone: phone ?? this.phone,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      sequence: sequence ?? this.sequence,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (beatId.present) {
      map['beat_id'] = Variable<String>(beatId.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (ownerName.present) {
      map['owner_name'] = Variable<String>(ownerName.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (lat.present) {
      map['lat'] = Variable<double>(lat.value);
    }
    if (lng.present) {
      map['lng'] = Variable<double>(lng.value);
    }
    if (sequence.present) {
      map['sequence'] = Variable<int>(sequence.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StoresCompanion(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('beatId: $beatId, ')
          ..write('address: $address, ')
          ..write('ownerName: $ownerName, ')
          ..write('phone: $phone, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('sequence: $sequence, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SkusTable extends Skus with TableInfo<$SkusTable, SkusData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SkusTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _brandMeta = const VerificationMeta('brand');
  @override
  late final GeneratedColumn<String> brand = GeneratedColumn<String>(
    'brand',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _grammageValueMeta = const VerificationMeta(
    'grammageValue',
  );
  @override
  late final GeneratedColumn<double> grammageValue = GeneratedColumn<double>(
    'grammage_value',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _grammageUnitMeta = const VerificationMeta(
    'grammageUnit',
  );
  @override
  late final GeneratedColumn<String> grammageUnit = GeneratedColumn<String>(
    'grammage_unit',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _variantMeta = const VerificationMeta(
    'variant',
  );
  @override
  late final GeneratedColumn<String> variant = GeneratedColumn<String>(
    'variant',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mrpPaiseMeta = const VerificationMeta(
    'mrpPaise',
  );
  @override
  late final GeneratedColumn<int> mrpPaise = GeneratedColumn<int>(
    'mrp_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _caseSizeMeta = const VerificationMeta(
    'caseSize',
  );
  @override
  late final GeneratedColumn<int> caseSize = GeneratedColumn<int>(
    'case_size',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _isEnrolledMeta = const VerificationMeta(
    'isEnrolled',
  );
  @override
  late final GeneratedColumn<bool> isEnrolled = GeneratedColumn<bool>(
    'is_enrolled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_enrolled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    code,
    name,
    brand,
    category,
    grammageValue,
    grammageUnit,
    variant,
    mrpPaise,
    caseSize,
    isEnrolled,
    isActive,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'skus';
  @override
  VerificationContext validateIntegrity(
    Insertable<SkusData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('brand')) {
      context.handle(
        _brandMeta,
        brand.isAcceptableOrUnknown(data['brand']!, _brandMeta),
      );
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('grammage_value')) {
      context.handle(
        _grammageValueMeta,
        grammageValue.isAcceptableOrUnknown(
          data['grammage_value']!,
          _grammageValueMeta,
        ),
      );
    }
    if (data.containsKey('grammage_unit')) {
      context.handle(
        _grammageUnitMeta,
        grammageUnit.isAcceptableOrUnknown(
          data['grammage_unit']!,
          _grammageUnitMeta,
        ),
      );
    }
    if (data.containsKey('variant')) {
      context.handle(
        _variantMeta,
        variant.isAcceptableOrUnknown(data['variant']!, _variantMeta),
      );
    }
    if (data.containsKey('mrp_paise')) {
      context.handle(
        _mrpPaiseMeta,
        mrpPaise.isAcceptableOrUnknown(data['mrp_paise']!, _mrpPaiseMeta),
      );
    }
    if (data.containsKey('case_size')) {
      context.handle(
        _caseSizeMeta,
        caseSize.isAcceptableOrUnknown(data['case_size']!, _caseSizeMeta),
      );
    }
    if (data.containsKey('is_enrolled')) {
      context.handle(
        _isEnrolledMeta,
        isEnrolled.isAcceptableOrUnknown(data['is_enrolled']!, _isEnrolledMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SkusData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SkusData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      brand: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}brand'],
      ),
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      ),
      grammageValue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}grammage_value'],
      ),
      grammageUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}grammage_unit'],
      ),
      variant: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}variant'],
      ),
      mrpPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}mrp_paise'],
      )!,
      caseSize: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}case_size'],
      )!,
      isEnrolled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_enrolled'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $SkusTable createAlias(String alias) {
    return $SkusTable(attachedDatabase, alias);
  }
}

class SkusData extends DataClass implements Insertable<SkusData> {
  final String id;
  final String code;
  final String name;
  final String? brand;
  final String? category;
  final double? grammageValue;
  final String? grammageUnit;
  final String? variant;
  final int mrpPaise;
  final int caseSize;
  final bool isEnrolled;
  final bool isActive;
  final int createdAt;
  const SkusData({
    required this.id,
    required this.code,
    required this.name,
    this.brand,
    this.category,
    this.grammageValue,
    this.grammageUnit,
    this.variant,
    required this.mrpPaise,
    required this.caseSize,
    required this.isEnrolled,
    required this.isActive,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['code'] = Variable<String>(code);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || brand != null) {
      map['brand'] = Variable<String>(brand);
    }
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    if (!nullToAbsent || grammageValue != null) {
      map['grammage_value'] = Variable<double>(grammageValue);
    }
    if (!nullToAbsent || grammageUnit != null) {
      map['grammage_unit'] = Variable<String>(grammageUnit);
    }
    if (!nullToAbsent || variant != null) {
      map['variant'] = Variable<String>(variant);
    }
    map['mrp_paise'] = Variable<int>(mrpPaise);
    map['case_size'] = Variable<int>(caseSize);
    map['is_enrolled'] = Variable<bool>(isEnrolled);
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  SkusCompanion toCompanion(bool nullToAbsent) {
    return SkusCompanion(
      id: Value(id),
      code: Value(code),
      name: Value(name),
      brand: brand == null && nullToAbsent
          ? const Value.absent()
          : Value(brand),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      grammageValue: grammageValue == null && nullToAbsent
          ? const Value.absent()
          : Value(grammageValue),
      grammageUnit: grammageUnit == null && nullToAbsent
          ? const Value.absent()
          : Value(grammageUnit),
      variant: variant == null && nullToAbsent
          ? const Value.absent()
          : Value(variant),
      mrpPaise: Value(mrpPaise),
      caseSize: Value(caseSize),
      isEnrolled: Value(isEnrolled),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
    );
  }

  factory SkusData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SkusData(
      id: serializer.fromJson<String>(json['id']),
      code: serializer.fromJson<String>(json['code']),
      name: serializer.fromJson<String>(json['name']),
      brand: serializer.fromJson<String?>(json['brand']),
      category: serializer.fromJson<String?>(json['category']),
      grammageValue: serializer.fromJson<double?>(json['grammageValue']),
      grammageUnit: serializer.fromJson<String?>(json['grammageUnit']),
      variant: serializer.fromJson<String?>(json['variant']),
      mrpPaise: serializer.fromJson<int>(json['mrpPaise']),
      caseSize: serializer.fromJson<int>(json['caseSize']),
      isEnrolled: serializer.fromJson<bool>(json['isEnrolled']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'code': serializer.toJson<String>(code),
      'name': serializer.toJson<String>(name),
      'brand': serializer.toJson<String?>(brand),
      'category': serializer.toJson<String?>(category),
      'grammageValue': serializer.toJson<double?>(grammageValue),
      'grammageUnit': serializer.toJson<String?>(grammageUnit),
      'variant': serializer.toJson<String?>(variant),
      'mrpPaise': serializer.toJson<int>(mrpPaise),
      'caseSize': serializer.toJson<int>(caseSize),
      'isEnrolled': serializer.toJson<bool>(isEnrolled),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  SkusData copyWith({
    String? id,
    String? code,
    String? name,
    Value<String?> brand = const Value.absent(),
    Value<String?> category = const Value.absent(),
    Value<double?> grammageValue = const Value.absent(),
    Value<String?> grammageUnit = const Value.absent(),
    Value<String?> variant = const Value.absent(),
    int? mrpPaise,
    int? caseSize,
    bool? isEnrolled,
    bool? isActive,
    int? createdAt,
  }) => SkusData(
    id: id ?? this.id,
    code: code ?? this.code,
    name: name ?? this.name,
    brand: brand.present ? brand.value : this.brand,
    category: category.present ? category.value : this.category,
    grammageValue: grammageValue.present
        ? grammageValue.value
        : this.grammageValue,
    grammageUnit: grammageUnit.present ? grammageUnit.value : this.grammageUnit,
    variant: variant.present ? variant.value : this.variant,
    mrpPaise: mrpPaise ?? this.mrpPaise,
    caseSize: caseSize ?? this.caseSize,
    isEnrolled: isEnrolled ?? this.isEnrolled,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
  );
  SkusData copyWithCompanion(SkusCompanion data) {
    return SkusData(
      id: data.id.present ? data.id.value : this.id,
      code: data.code.present ? data.code.value : this.code,
      name: data.name.present ? data.name.value : this.name,
      brand: data.brand.present ? data.brand.value : this.brand,
      category: data.category.present ? data.category.value : this.category,
      grammageValue: data.grammageValue.present
          ? data.grammageValue.value
          : this.grammageValue,
      grammageUnit: data.grammageUnit.present
          ? data.grammageUnit.value
          : this.grammageUnit,
      variant: data.variant.present ? data.variant.value : this.variant,
      mrpPaise: data.mrpPaise.present ? data.mrpPaise.value : this.mrpPaise,
      caseSize: data.caseSize.present ? data.caseSize.value : this.caseSize,
      isEnrolled: data.isEnrolled.present
          ? data.isEnrolled.value
          : this.isEnrolled,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SkusData(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('brand: $brand, ')
          ..write('category: $category, ')
          ..write('grammageValue: $grammageValue, ')
          ..write('grammageUnit: $grammageUnit, ')
          ..write('variant: $variant, ')
          ..write('mrpPaise: $mrpPaise, ')
          ..write('caseSize: $caseSize, ')
          ..write('isEnrolled: $isEnrolled, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    code,
    name,
    brand,
    category,
    grammageValue,
    grammageUnit,
    variant,
    mrpPaise,
    caseSize,
    isEnrolled,
    isActive,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SkusData &&
          other.id == this.id &&
          other.code == this.code &&
          other.name == this.name &&
          other.brand == this.brand &&
          other.category == this.category &&
          other.grammageValue == this.grammageValue &&
          other.grammageUnit == this.grammageUnit &&
          other.variant == this.variant &&
          other.mrpPaise == this.mrpPaise &&
          other.caseSize == this.caseSize &&
          other.isEnrolled == this.isEnrolled &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt);
}

class SkusCompanion extends UpdateCompanion<SkusData> {
  final Value<String> id;
  final Value<String> code;
  final Value<String> name;
  final Value<String?> brand;
  final Value<String?> category;
  final Value<double?> grammageValue;
  final Value<String?> grammageUnit;
  final Value<String?> variant;
  final Value<int> mrpPaise;
  final Value<int> caseSize;
  final Value<bool> isEnrolled;
  final Value<bool> isActive;
  final Value<int> createdAt;
  final Value<int> rowid;
  const SkusCompanion({
    this.id = const Value.absent(),
    this.code = const Value.absent(),
    this.name = const Value.absent(),
    this.brand = const Value.absent(),
    this.category = const Value.absent(),
    this.grammageValue = const Value.absent(),
    this.grammageUnit = const Value.absent(),
    this.variant = const Value.absent(),
    this.mrpPaise = const Value.absent(),
    this.caseSize = const Value.absent(),
    this.isEnrolled = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SkusCompanion.insert({
    required String id,
    required String code,
    required String name,
    this.brand = const Value.absent(),
    this.category = const Value.absent(),
    this.grammageValue = const Value.absent(),
    this.grammageUnit = const Value.absent(),
    this.variant = const Value.absent(),
    this.mrpPaise = const Value.absent(),
    this.caseSize = const Value.absent(),
    this.isEnrolled = const Value.absent(),
    this.isActive = const Value.absent(),
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       code = Value(code),
       name = Value(name),
       createdAt = Value(createdAt);
  static Insertable<SkusData> custom({
    Expression<String>? id,
    Expression<String>? code,
    Expression<String>? name,
    Expression<String>? brand,
    Expression<String>? category,
    Expression<double>? grammageValue,
    Expression<String>? grammageUnit,
    Expression<String>? variant,
    Expression<int>? mrpPaise,
    Expression<int>? caseSize,
    Expression<bool>? isEnrolled,
    Expression<bool>? isActive,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (code != null) 'code': code,
      if (name != null) 'name': name,
      if (brand != null) 'brand': brand,
      if (category != null) 'category': category,
      if (grammageValue != null) 'grammage_value': grammageValue,
      if (grammageUnit != null) 'grammage_unit': grammageUnit,
      if (variant != null) 'variant': variant,
      if (mrpPaise != null) 'mrp_paise': mrpPaise,
      if (caseSize != null) 'case_size': caseSize,
      if (isEnrolled != null) 'is_enrolled': isEnrolled,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SkusCompanion copyWith({
    Value<String>? id,
    Value<String>? code,
    Value<String>? name,
    Value<String?>? brand,
    Value<String?>? category,
    Value<double?>? grammageValue,
    Value<String?>? grammageUnit,
    Value<String?>? variant,
    Value<int>? mrpPaise,
    Value<int>? caseSize,
    Value<bool>? isEnrolled,
    Value<bool>? isActive,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return SkusCompanion(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      category: category ?? this.category,
      grammageValue: grammageValue ?? this.grammageValue,
      grammageUnit: grammageUnit ?? this.grammageUnit,
      variant: variant ?? this.variant,
      mrpPaise: mrpPaise ?? this.mrpPaise,
      caseSize: caseSize ?? this.caseSize,
      isEnrolled: isEnrolled ?? this.isEnrolled,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (brand.present) {
      map['brand'] = Variable<String>(brand.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (grammageValue.present) {
      map['grammage_value'] = Variable<double>(grammageValue.value);
    }
    if (grammageUnit.present) {
      map['grammage_unit'] = Variable<String>(grammageUnit.value);
    }
    if (variant.present) {
      map['variant'] = Variable<String>(variant.value);
    }
    if (mrpPaise.present) {
      map['mrp_paise'] = Variable<int>(mrpPaise.value);
    }
    if (caseSize.present) {
      map['case_size'] = Variable<int>(caseSize.value);
    }
    if (isEnrolled.present) {
      map['is_enrolled'] = Variable<bool>(isEnrolled.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SkusCompanion(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('brand: $brand, ')
          ..write('category: $category, ')
          ..write('grammageValue: $grammageValue, ')
          ..write('grammageUnit: $grammageUnit, ')
          ..write('variant: $variant, ')
          ..write('mrpPaise: $mrpPaise, ')
          ..write('caseSize: $caseSize, ')
          ..write('isEnrolled: $isEnrolled, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SkuEmbeddingsTable extends SkuEmbeddings
    with TableInfo<$SkuEmbeddingsTable, SkuEmbedding> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SkuEmbeddingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _skuIdMeta = const VerificationMeta('skuId');
  @override
  late final GeneratedColumn<String> skuId = GeneratedColumn<String>(
    'sku_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES skus (id)',
    ),
  );
  static const VerificationMeta _vectorMeta = const VerificationMeta('vector');
  @override
  late final GeneratedColumn<Uint8List> vector = GeneratedColumn<Uint8List>(
    'vector',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceImagePathMeta = const VerificationMeta(
    'sourceImagePath',
  );
  @override
  late final GeneratedColumn<String> sourceImagePath = GeneratedColumn<String>(
    'source_image_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _captureContextMeta = const VerificationMeta(
    'captureContext',
  );
  @override
  late final GeneratedColumn<String> captureContext = GeneratedColumn<String>(
    'capture_context',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    skuId,
    vector,
    sourceImagePath,
    captureContext,
    isActive,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sku_embeddings';
  @override
  VerificationContext validateIntegrity(
    Insertable<SkuEmbedding> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('sku_id')) {
      context.handle(
        _skuIdMeta,
        skuId.isAcceptableOrUnknown(data['sku_id']!, _skuIdMeta),
      );
    } else if (isInserting) {
      context.missing(_skuIdMeta);
    }
    if (data.containsKey('vector')) {
      context.handle(
        _vectorMeta,
        vector.isAcceptableOrUnknown(data['vector']!, _vectorMeta),
      );
    } else if (isInserting) {
      context.missing(_vectorMeta);
    }
    if (data.containsKey('source_image_path')) {
      context.handle(
        _sourceImagePathMeta,
        sourceImagePath.isAcceptableOrUnknown(
          data['source_image_path']!,
          _sourceImagePathMeta,
        ),
      );
    }
    if (data.containsKey('capture_context')) {
      context.handle(
        _captureContextMeta,
        captureContext.isAcceptableOrUnknown(
          data['capture_context']!,
          _captureContextMeta,
        ),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SkuEmbedding map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SkuEmbedding(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      skuId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sku_id'],
      )!,
      vector: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}vector'],
      )!,
      sourceImagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_image_path'],
      ),
      captureContext: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}capture_context'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $SkuEmbeddingsTable createAlias(String alias) {
    return $SkuEmbeddingsTable(attachedDatabase, alias);
  }
}

class SkuEmbedding extends DataClass implements Insertable<SkuEmbedding> {
  final String id;
  final String skuId;
  final Uint8List vector;
  final String? sourceImagePath;
  final String? captureContext;
  final bool isActive;
  final int createdAt;
  const SkuEmbedding({
    required this.id,
    required this.skuId,
    required this.vector,
    this.sourceImagePath,
    this.captureContext,
    required this.isActive,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['sku_id'] = Variable<String>(skuId);
    map['vector'] = Variable<Uint8List>(vector);
    if (!nullToAbsent || sourceImagePath != null) {
      map['source_image_path'] = Variable<String>(sourceImagePath);
    }
    if (!nullToAbsent || captureContext != null) {
      map['capture_context'] = Variable<String>(captureContext);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  SkuEmbeddingsCompanion toCompanion(bool nullToAbsent) {
    return SkuEmbeddingsCompanion(
      id: Value(id),
      skuId: Value(skuId),
      vector: Value(vector),
      sourceImagePath: sourceImagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceImagePath),
      captureContext: captureContext == null && nullToAbsent
          ? const Value.absent()
          : Value(captureContext),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
    );
  }

  factory SkuEmbedding.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SkuEmbedding(
      id: serializer.fromJson<String>(json['id']),
      skuId: serializer.fromJson<String>(json['skuId']),
      vector: serializer.fromJson<Uint8List>(json['vector']),
      sourceImagePath: serializer.fromJson<String?>(json['sourceImagePath']),
      captureContext: serializer.fromJson<String?>(json['captureContext']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'skuId': serializer.toJson<String>(skuId),
      'vector': serializer.toJson<Uint8List>(vector),
      'sourceImagePath': serializer.toJson<String?>(sourceImagePath),
      'captureContext': serializer.toJson<String?>(captureContext),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  SkuEmbedding copyWith({
    String? id,
    String? skuId,
    Uint8List? vector,
    Value<String?> sourceImagePath = const Value.absent(),
    Value<String?> captureContext = const Value.absent(),
    bool? isActive,
    int? createdAt,
  }) => SkuEmbedding(
    id: id ?? this.id,
    skuId: skuId ?? this.skuId,
    vector: vector ?? this.vector,
    sourceImagePath: sourceImagePath.present
        ? sourceImagePath.value
        : this.sourceImagePath,
    captureContext: captureContext.present
        ? captureContext.value
        : this.captureContext,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
  );
  SkuEmbedding copyWithCompanion(SkuEmbeddingsCompanion data) {
    return SkuEmbedding(
      id: data.id.present ? data.id.value : this.id,
      skuId: data.skuId.present ? data.skuId.value : this.skuId,
      vector: data.vector.present ? data.vector.value : this.vector,
      sourceImagePath: data.sourceImagePath.present
          ? data.sourceImagePath.value
          : this.sourceImagePath,
      captureContext: data.captureContext.present
          ? data.captureContext.value
          : this.captureContext,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SkuEmbedding(')
          ..write('id: $id, ')
          ..write('skuId: $skuId, ')
          ..write('vector: $vector, ')
          ..write('sourceImagePath: $sourceImagePath, ')
          ..write('captureContext: $captureContext, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    skuId,
    $driftBlobEquality.hash(vector),
    sourceImagePath,
    captureContext,
    isActive,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SkuEmbedding &&
          other.id == this.id &&
          other.skuId == this.skuId &&
          $driftBlobEquality.equals(other.vector, this.vector) &&
          other.sourceImagePath == this.sourceImagePath &&
          other.captureContext == this.captureContext &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt);
}

class SkuEmbeddingsCompanion extends UpdateCompanion<SkuEmbedding> {
  final Value<String> id;
  final Value<String> skuId;
  final Value<Uint8List> vector;
  final Value<String?> sourceImagePath;
  final Value<String?> captureContext;
  final Value<bool> isActive;
  final Value<int> createdAt;
  final Value<int> rowid;
  const SkuEmbeddingsCompanion({
    this.id = const Value.absent(),
    this.skuId = const Value.absent(),
    this.vector = const Value.absent(),
    this.sourceImagePath = const Value.absent(),
    this.captureContext = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SkuEmbeddingsCompanion.insert({
    required String id,
    required String skuId,
    required Uint8List vector,
    this.sourceImagePath = const Value.absent(),
    this.captureContext = const Value.absent(),
    this.isActive = const Value.absent(),
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       skuId = Value(skuId),
       vector = Value(vector),
       createdAt = Value(createdAt);
  static Insertable<SkuEmbedding> custom({
    Expression<String>? id,
    Expression<String>? skuId,
    Expression<Uint8List>? vector,
    Expression<String>? sourceImagePath,
    Expression<String>? captureContext,
    Expression<bool>? isActive,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (skuId != null) 'sku_id': skuId,
      if (vector != null) 'vector': vector,
      if (sourceImagePath != null) 'source_image_path': sourceImagePath,
      if (captureContext != null) 'capture_context': captureContext,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SkuEmbeddingsCompanion copyWith({
    Value<String>? id,
    Value<String>? skuId,
    Value<Uint8List>? vector,
    Value<String?>? sourceImagePath,
    Value<String?>? captureContext,
    Value<bool>? isActive,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return SkuEmbeddingsCompanion(
      id: id ?? this.id,
      skuId: skuId ?? this.skuId,
      vector: vector ?? this.vector,
      sourceImagePath: sourceImagePath ?? this.sourceImagePath,
      captureContext: captureContext ?? this.captureContext,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (skuId.present) {
      map['sku_id'] = Variable<String>(skuId.value);
    }
    if (vector.present) {
      map['vector'] = Variable<Uint8List>(vector.value);
    }
    if (sourceImagePath.present) {
      map['source_image_path'] = Variable<String>(sourceImagePath.value);
    }
    if (captureContext.present) {
      map['capture_context'] = Variable<String>(captureContext.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SkuEmbeddingsCompanion(')
          ..write('id: $id, ')
          ..write('skuId: $skuId, ')
          ..write('vector: $vector, ')
          ..write('sourceImagePath: $sourceImagePath, ')
          ..write('captureContext: $captureContext, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlanogramEntriesTable extends PlanogramEntries
    with TableInfo<$PlanogramEntriesTable, PlanogramEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlanogramEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _storeIdMeta = const VerificationMeta(
    'storeId',
  );
  @override
  late final GeneratedColumn<String> storeId = GeneratedColumn<String>(
    'store_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES stores (id)',
    ),
  );
  static const VerificationMeta _skuIdMeta = const VerificationMeta('skuId');
  @override
  late final GeneratedColumn<String> skuId = GeneratedColumn<String>(
    'sku_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES skus (id)',
    ),
  );
  static const VerificationMeta _targetFacingsMeta = const VerificationMeta(
    'targetFacings',
  );
  @override
  late final GeneratedColumn<int> targetFacings = GeneratedColumn<int>(
    'target_facings',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _shelfRowMeta = const VerificationMeta(
    'shelfRow',
  );
  @override
  late final GeneratedColumn<int> shelfRow = GeneratedColumn<int>(
    'shelf_row',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    storeId,
    skuId,
    targetFacings,
    shelfRow,
    source,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'planogram_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlanogramEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('store_id')) {
      context.handle(
        _storeIdMeta,
        storeId.isAcceptableOrUnknown(data['store_id']!, _storeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_storeIdMeta);
    }
    if (data.containsKey('sku_id')) {
      context.handle(
        _skuIdMeta,
        skuId.isAcceptableOrUnknown(data['sku_id']!, _skuIdMeta),
      );
    } else if (isInserting) {
      context.missing(_skuIdMeta);
    }
    if (data.containsKey('target_facings')) {
      context.handle(
        _targetFacingsMeta,
        targetFacings.isAcceptableOrUnknown(
          data['target_facings']!,
          _targetFacingsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetFacingsMeta);
    }
    if (data.containsKey('shelf_row')) {
      context.handle(
        _shelfRowMeta,
        shelfRow.isAcceptableOrUnknown(data['shelf_row']!, _shelfRowMeta),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {storeId, skuId},
  ];
  @override
  PlanogramEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlanogramEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      storeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}store_id'],
      )!,
      skuId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sku_id'],
      )!,
      targetFacings: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_facings'],
      )!,
      shelfRow: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}shelf_row'],
      ),
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $PlanogramEntriesTable createAlias(String alias) {
    return $PlanogramEntriesTable(attachedDatabase, alias);
  }
}

class PlanogramEntry extends DataClass implements Insertable<PlanogramEntry> {
  final String id;
  final String storeId;
  final String skuId;
  final int targetFacings;
  final int? shelfRow;
  final String source;
  final int updatedAt;
  const PlanogramEntry({
    required this.id,
    required this.storeId,
    required this.skuId,
    required this.targetFacings,
    this.shelfRow,
    required this.source,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['store_id'] = Variable<String>(storeId);
    map['sku_id'] = Variable<String>(skuId);
    map['target_facings'] = Variable<int>(targetFacings);
    if (!nullToAbsent || shelfRow != null) {
      map['shelf_row'] = Variable<int>(shelfRow);
    }
    map['source'] = Variable<String>(source);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  PlanogramEntriesCompanion toCompanion(bool nullToAbsent) {
    return PlanogramEntriesCompanion(
      id: Value(id),
      storeId: Value(storeId),
      skuId: Value(skuId),
      targetFacings: Value(targetFacings),
      shelfRow: shelfRow == null && nullToAbsent
          ? const Value.absent()
          : Value(shelfRow),
      source: Value(source),
      updatedAt: Value(updatedAt),
    );
  }

  factory PlanogramEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlanogramEntry(
      id: serializer.fromJson<String>(json['id']),
      storeId: serializer.fromJson<String>(json['storeId']),
      skuId: serializer.fromJson<String>(json['skuId']),
      targetFacings: serializer.fromJson<int>(json['targetFacings']),
      shelfRow: serializer.fromJson<int?>(json['shelfRow']),
      source: serializer.fromJson<String>(json['source']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'storeId': serializer.toJson<String>(storeId),
      'skuId': serializer.toJson<String>(skuId),
      'targetFacings': serializer.toJson<int>(targetFacings),
      'shelfRow': serializer.toJson<int?>(shelfRow),
      'source': serializer.toJson<String>(source),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  PlanogramEntry copyWith({
    String? id,
    String? storeId,
    String? skuId,
    int? targetFacings,
    Value<int?> shelfRow = const Value.absent(),
    String? source,
    int? updatedAt,
  }) => PlanogramEntry(
    id: id ?? this.id,
    storeId: storeId ?? this.storeId,
    skuId: skuId ?? this.skuId,
    targetFacings: targetFacings ?? this.targetFacings,
    shelfRow: shelfRow.present ? shelfRow.value : this.shelfRow,
    source: source ?? this.source,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  PlanogramEntry copyWithCompanion(PlanogramEntriesCompanion data) {
    return PlanogramEntry(
      id: data.id.present ? data.id.value : this.id,
      storeId: data.storeId.present ? data.storeId.value : this.storeId,
      skuId: data.skuId.present ? data.skuId.value : this.skuId,
      targetFacings: data.targetFacings.present
          ? data.targetFacings.value
          : this.targetFacings,
      shelfRow: data.shelfRow.present ? data.shelfRow.value : this.shelfRow,
      source: data.source.present ? data.source.value : this.source,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlanogramEntry(')
          ..write('id: $id, ')
          ..write('storeId: $storeId, ')
          ..write('skuId: $skuId, ')
          ..write('targetFacings: $targetFacings, ')
          ..write('shelfRow: $shelfRow, ')
          ..write('source: $source, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    storeId,
    skuId,
    targetFacings,
    shelfRow,
    source,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlanogramEntry &&
          other.id == this.id &&
          other.storeId == this.storeId &&
          other.skuId == this.skuId &&
          other.targetFacings == this.targetFacings &&
          other.shelfRow == this.shelfRow &&
          other.source == this.source &&
          other.updatedAt == this.updatedAt);
}

class PlanogramEntriesCompanion extends UpdateCompanion<PlanogramEntry> {
  final Value<String> id;
  final Value<String> storeId;
  final Value<String> skuId;
  final Value<int> targetFacings;
  final Value<int?> shelfRow;
  final Value<String> source;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const PlanogramEntriesCompanion({
    this.id = const Value.absent(),
    this.storeId = const Value.absent(),
    this.skuId = const Value.absent(),
    this.targetFacings = const Value.absent(),
    this.shelfRow = const Value.absent(),
    this.source = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlanogramEntriesCompanion.insert({
    required String id,
    required String storeId,
    required String skuId,
    required int targetFacings,
    this.shelfRow = const Value.absent(),
    required String source,
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       storeId = Value(storeId),
       skuId = Value(skuId),
       targetFacings = Value(targetFacings),
       source = Value(source),
       updatedAt = Value(updatedAt);
  static Insertable<PlanogramEntry> custom({
    Expression<String>? id,
    Expression<String>? storeId,
    Expression<String>? skuId,
    Expression<int>? targetFacings,
    Expression<int>? shelfRow,
    Expression<String>? source,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (storeId != null) 'store_id': storeId,
      if (skuId != null) 'sku_id': skuId,
      if (targetFacings != null) 'target_facings': targetFacings,
      if (shelfRow != null) 'shelf_row': shelfRow,
      if (source != null) 'source': source,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlanogramEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? storeId,
    Value<String>? skuId,
    Value<int>? targetFacings,
    Value<int?>? shelfRow,
    Value<String>? source,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return PlanogramEntriesCompanion(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      skuId: skuId ?? this.skuId,
      targetFacings: targetFacings ?? this.targetFacings,
      shelfRow: shelfRow ?? this.shelfRow,
      source: source ?? this.source,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (storeId.present) {
      map['store_id'] = Variable<String>(storeId.value);
    }
    if (skuId.present) {
      map['sku_id'] = Variable<String>(skuId.value);
    }
    if (targetFacings.present) {
      map['target_facings'] = Variable<int>(targetFacings.value);
    }
    if (shelfRow.present) {
      map['shelf_row'] = Variable<int>(shelfRow.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlanogramEntriesCompanion(')
          ..write('id: $id, ')
          ..write('storeId: $storeId, ')
          ..write('skuId: $skuId, ')
          ..write('targetFacings: $targetFacings, ')
          ..write('shelfRow: $shelfRow, ')
          ..write('source: $source, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VisitsTable extends Visits with TableInfo<$VisitsTable, Visit> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VisitsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _storeIdMeta = const VerificationMeta(
    'storeId',
  );
  @override
  late final GeneratedColumn<String> storeId = GeneratedColumn<String>(
    'store_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES stores (id)',
    ),
  );
  static const VerificationMeta _beatIdMeta = const VerificationMeta('beatId');
  @override
  late final GeneratedColumn<String> beatId = GeneratedColumn<String>(
    'beat_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES beats (id)',
    ),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('draft'),
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<int> startedAt = GeneratedColumn<int>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _confirmedAtMeta = const VerificationMeta(
    'confirmedAt',
  );
  @override
  late final GeneratedColumn<int> confirmedAt = GeneratedColumn<int>(
    'confirmed_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _latMeta = const VerificationMeta('lat');
  @override
  late final GeneratedColumn<double> lat = GeneratedColumn<double>(
    'lat',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lngMeta = const VerificationMeta('lng');
  @override
  late final GeneratedColumn<double> lng = GeneratedColumn<double>(
    'lng',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gpsAccuracyMMeta = const VerificationMeta(
    'gpsAccuracyM',
  );
  @override
  late final GeneratedColumn<double> gpsAccuracyM = GeneratedColumn<double>(
    'gps_accuracy_m',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _wasOfflineMeta = const VerificationMeta(
    'wasOffline',
  );
  @override
  late final GeneratedColumn<bool> wasOffline = GeneratedColumn<bool>(
    'was_offline',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("was_offline" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _noteAudioPathMeta = const VerificationMeta(
    'noteAudioPath',
  );
  @override
  late final GeneratedColumn<String> noteAudioPath = GeneratedColumn<String>(
    'note_audio_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteTranscriptMeta = const VerificationMeta(
    'noteTranscript',
  );
  @override
  late final GeneratedColumn<String> noteTranscript = GeneratedColumn<String>(
    'note_transcript',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _llmSummaryMeta = const VerificationMeta(
    'llmSummary',
  );
  @override
  late final GeneratedColumn<String> llmSummary = GeneratedColumn<String>(
    'llm_summary',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _llmRationaleMeta = const VerificationMeta(
    'llmRationale',
  );
  @override
  late final GeneratedColumn<String> llmRationale = GeneratedColumn<String>(
    'llm_rationale',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _llmModelIdMeta = const VerificationMeta(
    'llmModelId',
  );
  @override
  late final GeneratedColumn<String> llmModelId = GeneratedColumn<String>(
    'llm_model_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    storeId,
    beatId,
    status,
    startedAt,
    confirmedAt,
    lat,
    lng,
    gpsAccuracyM,
    wasOffline,
    noteAudioPath,
    noteTranscript,
    llmSummary,
    llmRationale,
    llmModelId,
    durationMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'visits';
  @override
  VerificationContext validateIntegrity(
    Insertable<Visit> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('store_id')) {
      context.handle(
        _storeIdMeta,
        storeId.isAcceptableOrUnknown(data['store_id']!, _storeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_storeIdMeta);
    }
    if (data.containsKey('beat_id')) {
      context.handle(
        _beatIdMeta,
        beatId.isAcceptableOrUnknown(data['beat_id']!, _beatIdMeta),
      );
    } else if (isInserting) {
      context.missing(_beatIdMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('confirmed_at')) {
      context.handle(
        _confirmedAtMeta,
        confirmedAt.isAcceptableOrUnknown(
          data['confirmed_at']!,
          _confirmedAtMeta,
        ),
      );
    }
    if (data.containsKey('lat')) {
      context.handle(
        _latMeta,
        lat.isAcceptableOrUnknown(data['lat']!, _latMeta),
      );
    }
    if (data.containsKey('lng')) {
      context.handle(
        _lngMeta,
        lng.isAcceptableOrUnknown(data['lng']!, _lngMeta),
      );
    }
    if (data.containsKey('gps_accuracy_m')) {
      context.handle(
        _gpsAccuracyMMeta,
        gpsAccuracyM.isAcceptableOrUnknown(
          data['gps_accuracy_m']!,
          _gpsAccuracyMMeta,
        ),
      );
    }
    if (data.containsKey('was_offline')) {
      context.handle(
        _wasOfflineMeta,
        wasOffline.isAcceptableOrUnknown(data['was_offline']!, _wasOfflineMeta),
      );
    }
    if (data.containsKey('note_audio_path')) {
      context.handle(
        _noteAudioPathMeta,
        noteAudioPath.isAcceptableOrUnknown(
          data['note_audio_path']!,
          _noteAudioPathMeta,
        ),
      );
    }
    if (data.containsKey('note_transcript')) {
      context.handle(
        _noteTranscriptMeta,
        noteTranscript.isAcceptableOrUnknown(
          data['note_transcript']!,
          _noteTranscriptMeta,
        ),
      );
    }
    if (data.containsKey('llm_summary')) {
      context.handle(
        _llmSummaryMeta,
        llmSummary.isAcceptableOrUnknown(data['llm_summary']!, _llmSummaryMeta),
      );
    }
    if (data.containsKey('llm_rationale')) {
      context.handle(
        _llmRationaleMeta,
        llmRationale.isAcceptableOrUnknown(
          data['llm_rationale']!,
          _llmRationaleMeta,
        ),
      );
    }
    if (data.containsKey('llm_model_id')) {
      context.handle(
        _llmModelIdMeta,
        llmModelId.isAcceptableOrUnknown(
          data['llm_model_id']!,
          _llmModelIdMeta,
        ),
      );
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Visit map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Visit(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      storeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}store_id'],
      )!,
      beatId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}beat_id'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}started_at'],
      )!,
      confirmedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}confirmed_at'],
      ),
      lat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lat'],
      ),
      lng: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lng'],
      ),
      gpsAccuracyM: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}gps_accuracy_m'],
      ),
      wasOffline: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}was_offline'],
      )!,
      noteAudioPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note_audio_path'],
      ),
      noteTranscript: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note_transcript'],
      ),
      llmSummary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}llm_summary'],
      ),
      llmRationale: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}llm_rationale'],
      ),
      llmModelId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}llm_model_id'],
      ),
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      ),
    );
  }

  @override
  $VisitsTable createAlias(String alias) {
    return $VisitsTable(attachedDatabase, alias);
  }
}

class Visit extends DataClass implements Insertable<Visit> {
  final String id;
  final String storeId;
  final String beatId;
  final String status;
  final int startedAt;
  final int? confirmedAt;
  final double? lat;
  final double? lng;
  final double? gpsAccuracyM;
  final bool wasOffline;
  final String? noteAudioPath;
  final String? noteTranscript;
  final String? llmSummary;
  final String? llmRationale;
  final String? llmModelId;
  final int? durationMs;
  const Visit({
    required this.id,
    required this.storeId,
    required this.beatId,
    required this.status,
    required this.startedAt,
    this.confirmedAt,
    this.lat,
    this.lng,
    this.gpsAccuracyM,
    required this.wasOffline,
    this.noteAudioPath,
    this.noteTranscript,
    this.llmSummary,
    this.llmRationale,
    this.llmModelId,
    this.durationMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['store_id'] = Variable<String>(storeId);
    map['beat_id'] = Variable<String>(beatId);
    map['status'] = Variable<String>(status);
    map['started_at'] = Variable<int>(startedAt);
    if (!nullToAbsent || confirmedAt != null) {
      map['confirmed_at'] = Variable<int>(confirmedAt);
    }
    if (!nullToAbsent || lat != null) {
      map['lat'] = Variable<double>(lat);
    }
    if (!nullToAbsent || lng != null) {
      map['lng'] = Variable<double>(lng);
    }
    if (!nullToAbsent || gpsAccuracyM != null) {
      map['gps_accuracy_m'] = Variable<double>(gpsAccuracyM);
    }
    map['was_offline'] = Variable<bool>(wasOffline);
    if (!nullToAbsent || noteAudioPath != null) {
      map['note_audio_path'] = Variable<String>(noteAudioPath);
    }
    if (!nullToAbsent || noteTranscript != null) {
      map['note_transcript'] = Variable<String>(noteTranscript);
    }
    if (!nullToAbsent || llmSummary != null) {
      map['llm_summary'] = Variable<String>(llmSummary);
    }
    if (!nullToAbsent || llmRationale != null) {
      map['llm_rationale'] = Variable<String>(llmRationale);
    }
    if (!nullToAbsent || llmModelId != null) {
      map['llm_model_id'] = Variable<String>(llmModelId);
    }
    if (!nullToAbsent || durationMs != null) {
      map['duration_ms'] = Variable<int>(durationMs);
    }
    return map;
  }

  VisitsCompanion toCompanion(bool nullToAbsent) {
    return VisitsCompanion(
      id: Value(id),
      storeId: Value(storeId),
      beatId: Value(beatId),
      status: Value(status),
      startedAt: Value(startedAt),
      confirmedAt: confirmedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(confirmedAt),
      lat: lat == null && nullToAbsent ? const Value.absent() : Value(lat),
      lng: lng == null && nullToAbsent ? const Value.absent() : Value(lng),
      gpsAccuracyM: gpsAccuracyM == null && nullToAbsent
          ? const Value.absent()
          : Value(gpsAccuracyM),
      wasOffline: Value(wasOffline),
      noteAudioPath: noteAudioPath == null && nullToAbsent
          ? const Value.absent()
          : Value(noteAudioPath),
      noteTranscript: noteTranscript == null && nullToAbsent
          ? const Value.absent()
          : Value(noteTranscript),
      llmSummary: llmSummary == null && nullToAbsent
          ? const Value.absent()
          : Value(llmSummary),
      llmRationale: llmRationale == null && nullToAbsent
          ? const Value.absent()
          : Value(llmRationale),
      llmModelId: llmModelId == null && nullToAbsent
          ? const Value.absent()
          : Value(llmModelId),
      durationMs: durationMs == null && nullToAbsent
          ? const Value.absent()
          : Value(durationMs),
    );
  }

  factory Visit.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Visit(
      id: serializer.fromJson<String>(json['id']),
      storeId: serializer.fromJson<String>(json['storeId']),
      beatId: serializer.fromJson<String>(json['beatId']),
      status: serializer.fromJson<String>(json['status']),
      startedAt: serializer.fromJson<int>(json['startedAt']),
      confirmedAt: serializer.fromJson<int?>(json['confirmedAt']),
      lat: serializer.fromJson<double?>(json['lat']),
      lng: serializer.fromJson<double?>(json['lng']),
      gpsAccuracyM: serializer.fromJson<double?>(json['gpsAccuracyM']),
      wasOffline: serializer.fromJson<bool>(json['wasOffline']),
      noteAudioPath: serializer.fromJson<String?>(json['noteAudioPath']),
      noteTranscript: serializer.fromJson<String?>(json['noteTranscript']),
      llmSummary: serializer.fromJson<String?>(json['llmSummary']),
      llmRationale: serializer.fromJson<String?>(json['llmRationale']),
      llmModelId: serializer.fromJson<String?>(json['llmModelId']),
      durationMs: serializer.fromJson<int?>(json['durationMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'storeId': serializer.toJson<String>(storeId),
      'beatId': serializer.toJson<String>(beatId),
      'status': serializer.toJson<String>(status),
      'startedAt': serializer.toJson<int>(startedAt),
      'confirmedAt': serializer.toJson<int?>(confirmedAt),
      'lat': serializer.toJson<double?>(lat),
      'lng': serializer.toJson<double?>(lng),
      'gpsAccuracyM': serializer.toJson<double?>(gpsAccuracyM),
      'wasOffline': serializer.toJson<bool>(wasOffline),
      'noteAudioPath': serializer.toJson<String?>(noteAudioPath),
      'noteTranscript': serializer.toJson<String?>(noteTranscript),
      'llmSummary': serializer.toJson<String?>(llmSummary),
      'llmRationale': serializer.toJson<String?>(llmRationale),
      'llmModelId': serializer.toJson<String?>(llmModelId),
      'durationMs': serializer.toJson<int?>(durationMs),
    };
  }

  Visit copyWith({
    String? id,
    String? storeId,
    String? beatId,
    String? status,
    int? startedAt,
    Value<int?> confirmedAt = const Value.absent(),
    Value<double?> lat = const Value.absent(),
    Value<double?> lng = const Value.absent(),
    Value<double?> gpsAccuracyM = const Value.absent(),
    bool? wasOffline,
    Value<String?> noteAudioPath = const Value.absent(),
    Value<String?> noteTranscript = const Value.absent(),
    Value<String?> llmSummary = const Value.absent(),
    Value<String?> llmRationale = const Value.absent(),
    Value<String?> llmModelId = const Value.absent(),
    Value<int?> durationMs = const Value.absent(),
  }) => Visit(
    id: id ?? this.id,
    storeId: storeId ?? this.storeId,
    beatId: beatId ?? this.beatId,
    status: status ?? this.status,
    startedAt: startedAt ?? this.startedAt,
    confirmedAt: confirmedAt.present ? confirmedAt.value : this.confirmedAt,
    lat: lat.present ? lat.value : this.lat,
    lng: lng.present ? lng.value : this.lng,
    gpsAccuracyM: gpsAccuracyM.present ? gpsAccuracyM.value : this.gpsAccuracyM,
    wasOffline: wasOffline ?? this.wasOffline,
    noteAudioPath: noteAudioPath.present
        ? noteAudioPath.value
        : this.noteAudioPath,
    noteTranscript: noteTranscript.present
        ? noteTranscript.value
        : this.noteTranscript,
    llmSummary: llmSummary.present ? llmSummary.value : this.llmSummary,
    llmRationale: llmRationale.present ? llmRationale.value : this.llmRationale,
    llmModelId: llmModelId.present ? llmModelId.value : this.llmModelId,
    durationMs: durationMs.present ? durationMs.value : this.durationMs,
  );
  Visit copyWithCompanion(VisitsCompanion data) {
    return Visit(
      id: data.id.present ? data.id.value : this.id,
      storeId: data.storeId.present ? data.storeId.value : this.storeId,
      beatId: data.beatId.present ? data.beatId.value : this.beatId,
      status: data.status.present ? data.status.value : this.status,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      confirmedAt: data.confirmedAt.present
          ? data.confirmedAt.value
          : this.confirmedAt,
      lat: data.lat.present ? data.lat.value : this.lat,
      lng: data.lng.present ? data.lng.value : this.lng,
      gpsAccuracyM: data.gpsAccuracyM.present
          ? data.gpsAccuracyM.value
          : this.gpsAccuracyM,
      wasOffline: data.wasOffline.present
          ? data.wasOffline.value
          : this.wasOffline,
      noteAudioPath: data.noteAudioPath.present
          ? data.noteAudioPath.value
          : this.noteAudioPath,
      noteTranscript: data.noteTranscript.present
          ? data.noteTranscript.value
          : this.noteTranscript,
      llmSummary: data.llmSummary.present
          ? data.llmSummary.value
          : this.llmSummary,
      llmRationale: data.llmRationale.present
          ? data.llmRationale.value
          : this.llmRationale,
      llmModelId: data.llmModelId.present
          ? data.llmModelId.value
          : this.llmModelId,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Visit(')
          ..write('id: $id, ')
          ..write('storeId: $storeId, ')
          ..write('beatId: $beatId, ')
          ..write('status: $status, ')
          ..write('startedAt: $startedAt, ')
          ..write('confirmedAt: $confirmedAt, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('gpsAccuracyM: $gpsAccuracyM, ')
          ..write('wasOffline: $wasOffline, ')
          ..write('noteAudioPath: $noteAudioPath, ')
          ..write('noteTranscript: $noteTranscript, ')
          ..write('llmSummary: $llmSummary, ')
          ..write('llmRationale: $llmRationale, ')
          ..write('llmModelId: $llmModelId, ')
          ..write('durationMs: $durationMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    storeId,
    beatId,
    status,
    startedAt,
    confirmedAt,
    lat,
    lng,
    gpsAccuracyM,
    wasOffline,
    noteAudioPath,
    noteTranscript,
    llmSummary,
    llmRationale,
    llmModelId,
    durationMs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Visit &&
          other.id == this.id &&
          other.storeId == this.storeId &&
          other.beatId == this.beatId &&
          other.status == this.status &&
          other.startedAt == this.startedAt &&
          other.confirmedAt == this.confirmedAt &&
          other.lat == this.lat &&
          other.lng == this.lng &&
          other.gpsAccuracyM == this.gpsAccuracyM &&
          other.wasOffline == this.wasOffline &&
          other.noteAudioPath == this.noteAudioPath &&
          other.noteTranscript == this.noteTranscript &&
          other.llmSummary == this.llmSummary &&
          other.llmRationale == this.llmRationale &&
          other.llmModelId == this.llmModelId &&
          other.durationMs == this.durationMs);
}

class VisitsCompanion extends UpdateCompanion<Visit> {
  final Value<String> id;
  final Value<String> storeId;
  final Value<String> beatId;
  final Value<String> status;
  final Value<int> startedAt;
  final Value<int?> confirmedAt;
  final Value<double?> lat;
  final Value<double?> lng;
  final Value<double?> gpsAccuracyM;
  final Value<bool> wasOffline;
  final Value<String?> noteAudioPath;
  final Value<String?> noteTranscript;
  final Value<String?> llmSummary;
  final Value<String?> llmRationale;
  final Value<String?> llmModelId;
  final Value<int?> durationMs;
  final Value<int> rowid;
  const VisitsCompanion({
    this.id = const Value.absent(),
    this.storeId = const Value.absent(),
    this.beatId = const Value.absent(),
    this.status = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.confirmedAt = const Value.absent(),
    this.lat = const Value.absent(),
    this.lng = const Value.absent(),
    this.gpsAccuracyM = const Value.absent(),
    this.wasOffline = const Value.absent(),
    this.noteAudioPath = const Value.absent(),
    this.noteTranscript = const Value.absent(),
    this.llmSummary = const Value.absent(),
    this.llmRationale = const Value.absent(),
    this.llmModelId = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VisitsCompanion.insert({
    required String id,
    required String storeId,
    required String beatId,
    this.status = const Value.absent(),
    required int startedAt,
    this.confirmedAt = const Value.absent(),
    this.lat = const Value.absent(),
    this.lng = const Value.absent(),
    this.gpsAccuracyM = const Value.absent(),
    this.wasOffline = const Value.absent(),
    this.noteAudioPath = const Value.absent(),
    this.noteTranscript = const Value.absent(),
    this.llmSummary = const Value.absent(),
    this.llmRationale = const Value.absent(),
    this.llmModelId = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       storeId = Value(storeId),
       beatId = Value(beatId),
       startedAt = Value(startedAt);
  static Insertable<Visit> custom({
    Expression<String>? id,
    Expression<String>? storeId,
    Expression<String>? beatId,
    Expression<String>? status,
    Expression<int>? startedAt,
    Expression<int>? confirmedAt,
    Expression<double>? lat,
    Expression<double>? lng,
    Expression<double>? gpsAccuracyM,
    Expression<bool>? wasOffline,
    Expression<String>? noteAudioPath,
    Expression<String>? noteTranscript,
    Expression<String>? llmSummary,
    Expression<String>? llmRationale,
    Expression<String>? llmModelId,
    Expression<int>? durationMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (storeId != null) 'store_id': storeId,
      if (beatId != null) 'beat_id': beatId,
      if (status != null) 'status': status,
      if (startedAt != null) 'started_at': startedAt,
      if (confirmedAt != null) 'confirmed_at': confirmedAt,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      if (gpsAccuracyM != null) 'gps_accuracy_m': gpsAccuracyM,
      if (wasOffline != null) 'was_offline': wasOffline,
      if (noteAudioPath != null) 'note_audio_path': noteAudioPath,
      if (noteTranscript != null) 'note_transcript': noteTranscript,
      if (llmSummary != null) 'llm_summary': llmSummary,
      if (llmRationale != null) 'llm_rationale': llmRationale,
      if (llmModelId != null) 'llm_model_id': llmModelId,
      if (durationMs != null) 'duration_ms': durationMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VisitsCompanion copyWith({
    Value<String>? id,
    Value<String>? storeId,
    Value<String>? beatId,
    Value<String>? status,
    Value<int>? startedAt,
    Value<int?>? confirmedAt,
    Value<double?>? lat,
    Value<double?>? lng,
    Value<double?>? gpsAccuracyM,
    Value<bool>? wasOffline,
    Value<String?>? noteAudioPath,
    Value<String?>? noteTranscript,
    Value<String?>? llmSummary,
    Value<String?>? llmRationale,
    Value<String?>? llmModelId,
    Value<int?>? durationMs,
    Value<int>? rowid,
  }) {
    return VisitsCompanion(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      beatId: beatId ?? this.beatId,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      confirmedAt: confirmedAt ?? this.confirmedAt,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      gpsAccuracyM: gpsAccuracyM ?? this.gpsAccuracyM,
      wasOffline: wasOffline ?? this.wasOffline,
      noteAudioPath: noteAudioPath ?? this.noteAudioPath,
      noteTranscript: noteTranscript ?? this.noteTranscript,
      llmSummary: llmSummary ?? this.llmSummary,
      llmRationale: llmRationale ?? this.llmRationale,
      llmModelId: llmModelId ?? this.llmModelId,
      durationMs: durationMs ?? this.durationMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (storeId.present) {
      map['store_id'] = Variable<String>(storeId.value);
    }
    if (beatId.present) {
      map['beat_id'] = Variable<String>(beatId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<int>(startedAt.value);
    }
    if (confirmedAt.present) {
      map['confirmed_at'] = Variable<int>(confirmedAt.value);
    }
    if (lat.present) {
      map['lat'] = Variable<double>(lat.value);
    }
    if (lng.present) {
      map['lng'] = Variable<double>(lng.value);
    }
    if (gpsAccuracyM.present) {
      map['gps_accuracy_m'] = Variable<double>(gpsAccuracyM.value);
    }
    if (wasOffline.present) {
      map['was_offline'] = Variable<bool>(wasOffline.value);
    }
    if (noteAudioPath.present) {
      map['note_audio_path'] = Variable<String>(noteAudioPath.value);
    }
    if (noteTranscript.present) {
      map['note_transcript'] = Variable<String>(noteTranscript.value);
    }
    if (llmSummary.present) {
      map['llm_summary'] = Variable<String>(llmSummary.value);
    }
    if (llmRationale.present) {
      map['llm_rationale'] = Variable<String>(llmRationale.value);
    }
    if (llmModelId.present) {
      map['llm_model_id'] = Variable<String>(llmModelId.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VisitsCompanion(')
          ..write('id: $id, ')
          ..write('storeId: $storeId, ')
          ..write('beatId: $beatId, ')
          ..write('status: $status, ')
          ..write('startedAt: $startedAt, ')
          ..write('confirmedAt: $confirmedAt, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('gpsAccuracyM: $gpsAccuracyM, ')
          ..write('wasOffline: $wasOffline, ')
          ..write('noteAudioPath: $noteAudioPath, ')
          ..write('noteTranscript: $noteTranscript, ')
          ..write('llmSummary: $llmSummary, ')
          ..write('llmRationale: $llmRationale, ')
          ..write('llmModelId: $llmModelId, ')
          ..write('durationMs: $durationMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VisitPhotosTable extends VisitPhotos
    with TableInfo<$VisitPhotosTable, VisitPhoto> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VisitPhotosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _visitIdMeta = const VerificationMeta(
    'visitId',
  );
  @override
  late final GeneratedColumn<String> visitId = GeneratedColumn<String>(
    'visit_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES visits (id)',
    ),
  );
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _widthMeta = const VerificationMeta('width');
  @override
  late final GeneratedColumn<int> width = GeneratedColumn<int>(
    'width',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _heightMeta = const VerificationMeta('height');
  @override
  late final GeneratedColumn<int> height = GeneratedColumn<int>(
    'height',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _detectLatencyMsMeta = const VerificationMeta(
    'detectLatencyMs',
  );
  @override
  late final GeneratedColumn<int> detectLatencyMs = GeneratedColumn<int>(
    'detect_latency_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _capturedAtMeta = const VerificationMeta(
    'capturedAt',
  );
  @override
  late final GeneratedColumn<int> capturedAt = GeneratedColumn<int>(
    'captured_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    visitId,
    filePath,
    width,
    height,
    detectLatencyMs,
    capturedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'visit_photos';
  @override
  VerificationContext validateIntegrity(
    Insertable<VisitPhoto> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('visit_id')) {
      context.handle(
        _visitIdMeta,
        visitId.isAcceptableOrUnknown(data['visit_id']!, _visitIdMeta),
      );
    } else if (isInserting) {
      context.missing(_visitIdMeta);
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('width')) {
      context.handle(
        _widthMeta,
        width.isAcceptableOrUnknown(data['width']!, _widthMeta),
      );
    } else if (isInserting) {
      context.missing(_widthMeta);
    }
    if (data.containsKey('height')) {
      context.handle(
        _heightMeta,
        height.isAcceptableOrUnknown(data['height']!, _heightMeta),
      );
    } else if (isInserting) {
      context.missing(_heightMeta);
    }
    if (data.containsKey('detect_latency_ms')) {
      context.handle(
        _detectLatencyMsMeta,
        detectLatencyMs.isAcceptableOrUnknown(
          data['detect_latency_ms']!,
          _detectLatencyMsMeta,
        ),
      );
    }
    if (data.containsKey('captured_at')) {
      context.handle(
        _capturedAtMeta,
        capturedAt.isAcceptableOrUnknown(data['captured_at']!, _capturedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_capturedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VisitPhoto map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VisitPhoto(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      visitId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}visit_id'],
      )!,
      filePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_path'],
      )!,
      width: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}width'],
      )!,
      height: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}height'],
      )!,
      detectLatencyMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}detect_latency_ms'],
      ),
      capturedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}captured_at'],
      )!,
    );
  }

  @override
  $VisitPhotosTable createAlias(String alias) {
    return $VisitPhotosTable(attachedDatabase, alias);
  }
}

class VisitPhoto extends DataClass implements Insertable<VisitPhoto> {
  final String id;
  final String visitId;
  final String filePath;
  final int width;
  final int height;
  final int? detectLatencyMs;
  final int capturedAt;
  const VisitPhoto({
    required this.id,
    required this.visitId,
    required this.filePath,
    required this.width,
    required this.height,
    this.detectLatencyMs,
    required this.capturedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['visit_id'] = Variable<String>(visitId);
    map['file_path'] = Variable<String>(filePath);
    map['width'] = Variable<int>(width);
    map['height'] = Variable<int>(height);
    if (!nullToAbsent || detectLatencyMs != null) {
      map['detect_latency_ms'] = Variable<int>(detectLatencyMs);
    }
    map['captured_at'] = Variable<int>(capturedAt);
    return map;
  }

  VisitPhotosCompanion toCompanion(bool nullToAbsent) {
    return VisitPhotosCompanion(
      id: Value(id),
      visitId: Value(visitId),
      filePath: Value(filePath),
      width: Value(width),
      height: Value(height),
      detectLatencyMs: detectLatencyMs == null && nullToAbsent
          ? const Value.absent()
          : Value(detectLatencyMs),
      capturedAt: Value(capturedAt),
    );
  }

  factory VisitPhoto.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VisitPhoto(
      id: serializer.fromJson<String>(json['id']),
      visitId: serializer.fromJson<String>(json['visitId']),
      filePath: serializer.fromJson<String>(json['filePath']),
      width: serializer.fromJson<int>(json['width']),
      height: serializer.fromJson<int>(json['height']),
      detectLatencyMs: serializer.fromJson<int?>(json['detectLatencyMs']),
      capturedAt: serializer.fromJson<int>(json['capturedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'visitId': serializer.toJson<String>(visitId),
      'filePath': serializer.toJson<String>(filePath),
      'width': serializer.toJson<int>(width),
      'height': serializer.toJson<int>(height),
      'detectLatencyMs': serializer.toJson<int?>(detectLatencyMs),
      'capturedAt': serializer.toJson<int>(capturedAt),
    };
  }

  VisitPhoto copyWith({
    String? id,
    String? visitId,
    String? filePath,
    int? width,
    int? height,
    Value<int?> detectLatencyMs = const Value.absent(),
    int? capturedAt,
  }) => VisitPhoto(
    id: id ?? this.id,
    visitId: visitId ?? this.visitId,
    filePath: filePath ?? this.filePath,
    width: width ?? this.width,
    height: height ?? this.height,
    detectLatencyMs: detectLatencyMs.present
        ? detectLatencyMs.value
        : this.detectLatencyMs,
    capturedAt: capturedAt ?? this.capturedAt,
  );
  VisitPhoto copyWithCompanion(VisitPhotosCompanion data) {
    return VisitPhoto(
      id: data.id.present ? data.id.value : this.id,
      visitId: data.visitId.present ? data.visitId.value : this.visitId,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      width: data.width.present ? data.width.value : this.width,
      height: data.height.present ? data.height.value : this.height,
      detectLatencyMs: data.detectLatencyMs.present
          ? data.detectLatencyMs.value
          : this.detectLatencyMs,
      capturedAt: data.capturedAt.present
          ? data.capturedAt.value
          : this.capturedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VisitPhoto(')
          ..write('id: $id, ')
          ..write('visitId: $visitId, ')
          ..write('filePath: $filePath, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('detectLatencyMs: $detectLatencyMs, ')
          ..write('capturedAt: $capturedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    visitId,
    filePath,
    width,
    height,
    detectLatencyMs,
    capturedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VisitPhoto &&
          other.id == this.id &&
          other.visitId == this.visitId &&
          other.filePath == this.filePath &&
          other.width == this.width &&
          other.height == this.height &&
          other.detectLatencyMs == this.detectLatencyMs &&
          other.capturedAt == this.capturedAt);
}

class VisitPhotosCompanion extends UpdateCompanion<VisitPhoto> {
  final Value<String> id;
  final Value<String> visitId;
  final Value<String> filePath;
  final Value<int> width;
  final Value<int> height;
  final Value<int?> detectLatencyMs;
  final Value<int> capturedAt;
  final Value<int> rowid;
  const VisitPhotosCompanion({
    this.id = const Value.absent(),
    this.visitId = const Value.absent(),
    this.filePath = const Value.absent(),
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    this.detectLatencyMs = const Value.absent(),
    this.capturedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VisitPhotosCompanion.insert({
    required String id,
    required String visitId,
    required String filePath,
    required int width,
    required int height,
    this.detectLatencyMs = const Value.absent(),
    required int capturedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       visitId = Value(visitId),
       filePath = Value(filePath),
       width = Value(width),
       height = Value(height),
       capturedAt = Value(capturedAt);
  static Insertable<VisitPhoto> custom({
    Expression<String>? id,
    Expression<String>? visitId,
    Expression<String>? filePath,
    Expression<int>? width,
    Expression<int>? height,
    Expression<int>? detectLatencyMs,
    Expression<int>? capturedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (visitId != null) 'visit_id': visitId,
      if (filePath != null) 'file_path': filePath,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      if (detectLatencyMs != null) 'detect_latency_ms': detectLatencyMs,
      if (capturedAt != null) 'captured_at': capturedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VisitPhotosCompanion copyWith({
    Value<String>? id,
    Value<String>? visitId,
    Value<String>? filePath,
    Value<int>? width,
    Value<int>? height,
    Value<int?>? detectLatencyMs,
    Value<int>? capturedAt,
    Value<int>? rowid,
  }) {
    return VisitPhotosCompanion(
      id: id ?? this.id,
      visitId: visitId ?? this.visitId,
      filePath: filePath ?? this.filePath,
      width: width ?? this.width,
      height: height ?? this.height,
      detectLatencyMs: detectLatencyMs ?? this.detectLatencyMs,
      capturedAt: capturedAt ?? this.capturedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (visitId.present) {
      map['visit_id'] = Variable<String>(visitId.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (width.present) {
      map['width'] = Variable<int>(width.value);
    }
    if (height.present) {
      map['height'] = Variable<int>(height.value);
    }
    if (detectLatencyMs.present) {
      map['detect_latency_ms'] = Variable<int>(detectLatencyMs.value);
    }
    if (capturedAt.present) {
      map['captured_at'] = Variable<int>(capturedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VisitPhotosCompanion(')
          ..write('id: $id, ')
          ..write('visitId: $visitId, ')
          ..write('filePath: $filePath, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('detectLatencyMs: $detectLatencyMs, ')
          ..write('capturedAt: $capturedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DetectionsTable extends Detections
    with TableInfo<$DetectionsTable, Detection> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DetectionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _visitIdMeta = const VerificationMeta(
    'visitId',
  );
  @override
  late final GeneratedColumn<String> visitId = GeneratedColumn<String>(
    'visit_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES visits (id)',
    ),
  );
  static const VerificationMeta _photoIdMeta = const VerificationMeta(
    'photoId',
  );
  @override
  late final GeneratedColumn<String> photoId = GeneratedColumn<String>(
    'photo_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES visit_photos (id)',
    ),
  );
  static const VerificationMeta _x1Meta = const VerificationMeta('x1');
  @override
  late final GeneratedColumn<double> x1 = GeneratedColumn<double>(
    'x1',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _y1Meta = const VerificationMeta('y1');
  @override
  late final GeneratedColumn<double> y1 = GeneratedColumn<double>(
    'y1',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _x2Meta = const VerificationMeta('x2');
  @override
  late final GeneratedColumn<double> x2 = GeneratedColumn<double>(
    'x2',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _y2Meta = const VerificationMeta('y2');
  @override
  late final GeneratedColumn<double> y2 = GeneratedColumn<double>(
    'y2',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _detConfidenceMeta = const VerificationMeta(
    'detConfidence',
  );
  @override
  late final GeneratedColumn<double> detConfidence = GeneratedColumn<double>(
    'det_confidence',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _skuIdMeta = const VerificationMeta('skuId');
  @override
  late final GeneratedColumn<String> skuId = GeneratedColumn<String>(
    'sku_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES skus (id)',
    ),
  );
  static const VerificationMeta _matchConfidenceMeta = const VerificationMeta(
    'matchConfidence',
  );
  @override
  late final GeneratedColumn<double> matchConfidence = GeneratedColumn<double>(
    'match_confidence',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _matchMethodMeta = const VerificationMeta(
    'matchMethod',
  );
  @override
  late final GeneratedColumn<String> matchMethod = GeneratedColumn<String>(
    'match_method',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('unmatched'),
  );
  static const VerificationMeta _shelfRowMeta = const VerificationMeta(
    'shelfRow',
  );
  @override
  late final GeneratedColumn<int> shelfRow = GeneratedColumn<int>(
    'shelf_row',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isGapMeta = const VerificationMeta('isGap');
  @override
  late final GeneratedColumn<bool> isGap = GeneratedColumn<bool>(
    'is_gap',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_gap" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _wasCorrectedMeta = const VerificationMeta(
    'wasCorrected',
  );
  @override
  late final GeneratedColumn<bool> wasCorrected = GeneratedColumn<bool>(
    'was_corrected',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("was_corrected" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _embeddingMeta = const VerificationMeta(
    'embedding',
  );
  @override
  late final GeneratedColumn<Uint8List> embedding = GeneratedColumn<Uint8List>(
    'embedding',
    aliasedName,
    true,
    type: DriftSqlType.blob,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    visitId,
    photoId,
    x1,
    y1,
    x2,
    y2,
    detConfidence,
    skuId,
    matchConfidence,
    matchMethod,
    shelfRow,
    isGap,
    wasCorrected,
    embedding,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'detections';
  @override
  VerificationContext validateIntegrity(
    Insertable<Detection> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('visit_id')) {
      context.handle(
        _visitIdMeta,
        visitId.isAcceptableOrUnknown(data['visit_id']!, _visitIdMeta),
      );
    } else if (isInserting) {
      context.missing(_visitIdMeta);
    }
    if (data.containsKey('photo_id')) {
      context.handle(
        _photoIdMeta,
        photoId.isAcceptableOrUnknown(data['photo_id']!, _photoIdMeta),
      );
    } else if (isInserting) {
      context.missing(_photoIdMeta);
    }
    if (data.containsKey('x1')) {
      context.handle(_x1Meta, x1.isAcceptableOrUnknown(data['x1']!, _x1Meta));
    } else if (isInserting) {
      context.missing(_x1Meta);
    }
    if (data.containsKey('y1')) {
      context.handle(_y1Meta, y1.isAcceptableOrUnknown(data['y1']!, _y1Meta));
    } else if (isInserting) {
      context.missing(_y1Meta);
    }
    if (data.containsKey('x2')) {
      context.handle(_x2Meta, x2.isAcceptableOrUnknown(data['x2']!, _x2Meta));
    } else if (isInserting) {
      context.missing(_x2Meta);
    }
    if (data.containsKey('y2')) {
      context.handle(_y2Meta, y2.isAcceptableOrUnknown(data['y2']!, _y2Meta));
    } else if (isInserting) {
      context.missing(_y2Meta);
    }
    if (data.containsKey('det_confidence')) {
      context.handle(
        _detConfidenceMeta,
        detConfidence.isAcceptableOrUnknown(
          data['det_confidence']!,
          _detConfidenceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_detConfidenceMeta);
    }
    if (data.containsKey('sku_id')) {
      context.handle(
        _skuIdMeta,
        skuId.isAcceptableOrUnknown(data['sku_id']!, _skuIdMeta),
      );
    }
    if (data.containsKey('match_confidence')) {
      context.handle(
        _matchConfidenceMeta,
        matchConfidence.isAcceptableOrUnknown(
          data['match_confidence']!,
          _matchConfidenceMeta,
        ),
      );
    }
    if (data.containsKey('match_method')) {
      context.handle(
        _matchMethodMeta,
        matchMethod.isAcceptableOrUnknown(
          data['match_method']!,
          _matchMethodMeta,
        ),
      );
    }
    if (data.containsKey('shelf_row')) {
      context.handle(
        _shelfRowMeta,
        shelfRow.isAcceptableOrUnknown(data['shelf_row']!, _shelfRowMeta),
      );
    }
    if (data.containsKey('is_gap')) {
      context.handle(
        _isGapMeta,
        isGap.isAcceptableOrUnknown(data['is_gap']!, _isGapMeta),
      );
    }
    if (data.containsKey('was_corrected')) {
      context.handle(
        _wasCorrectedMeta,
        wasCorrected.isAcceptableOrUnknown(
          data['was_corrected']!,
          _wasCorrectedMeta,
        ),
      );
    }
    if (data.containsKey('embedding')) {
      context.handle(
        _embeddingMeta,
        embedding.isAcceptableOrUnknown(data['embedding']!, _embeddingMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Detection map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Detection(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      visitId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}visit_id'],
      )!,
      photoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_id'],
      )!,
      x1: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}x1'],
      )!,
      y1: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}y1'],
      )!,
      x2: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}x2'],
      )!,
      y2: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}y2'],
      )!,
      detConfidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}det_confidence'],
      )!,
      skuId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sku_id'],
      ),
      matchConfidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}match_confidence'],
      ),
      matchMethod: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}match_method'],
      )!,
      shelfRow: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}shelf_row'],
      ),
      isGap: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_gap'],
      )!,
      wasCorrected: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}was_corrected'],
      )!,
      embedding: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}embedding'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $DetectionsTable createAlias(String alias) {
    return $DetectionsTable(attachedDatabase, alias);
  }
}

class Detection extends DataClass implements Insertable<Detection> {
  final String id;
  final String visitId;
  final String photoId;
  final double x1;
  final double y1;
  final double x2;
  final double y2;
  final double detConfidence;
  final String? skuId;
  final double? matchConfidence;
  final String matchMethod;
  final int? shelfRow;
  final bool isGap;
  final bool wasCorrected;
  final Uint8List? embedding;
  final int createdAt;
  const Detection({
    required this.id,
    required this.visitId,
    required this.photoId,
    required this.x1,
    required this.y1,
    required this.x2,
    required this.y2,
    required this.detConfidence,
    this.skuId,
    this.matchConfidence,
    required this.matchMethod,
    this.shelfRow,
    required this.isGap,
    required this.wasCorrected,
    this.embedding,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['visit_id'] = Variable<String>(visitId);
    map['photo_id'] = Variable<String>(photoId);
    map['x1'] = Variable<double>(x1);
    map['y1'] = Variable<double>(y1);
    map['x2'] = Variable<double>(x2);
    map['y2'] = Variable<double>(y2);
    map['det_confidence'] = Variable<double>(detConfidence);
    if (!nullToAbsent || skuId != null) {
      map['sku_id'] = Variable<String>(skuId);
    }
    if (!nullToAbsent || matchConfidence != null) {
      map['match_confidence'] = Variable<double>(matchConfidence);
    }
    map['match_method'] = Variable<String>(matchMethod);
    if (!nullToAbsent || shelfRow != null) {
      map['shelf_row'] = Variable<int>(shelfRow);
    }
    map['is_gap'] = Variable<bool>(isGap);
    map['was_corrected'] = Variable<bool>(wasCorrected);
    if (!nullToAbsent || embedding != null) {
      map['embedding'] = Variable<Uint8List>(embedding);
    }
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  DetectionsCompanion toCompanion(bool nullToAbsent) {
    return DetectionsCompanion(
      id: Value(id),
      visitId: Value(visitId),
      photoId: Value(photoId),
      x1: Value(x1),
      y1: Value(y1),
      x2: Value(x2),
      y2: Value(y2),
      detConfidence: Value(detConfidence),
      skuId: skuId == null && nullToAbsent
          ? const Value.absent()
          : Value(skuId),
      matchConfidence: matchConfidence == null && nullToAbsent
          ? const Value.absent()
          : Value(matchConfidence),
      matchMethod: Value(matchMethod),
      shelfRow: shelfRow == null && nullToAbsent
          ? const Value.absent()
          : Value(shelfRow),
      isGap: Value(isGap),
      wasCorrected: Value(wasCorrected),
      embedding: embedding == null && nullToAbsent
          ? const Value.absent()
          : Value(embedding),
      createdAt: Value(createdAt),
    );
  }

  factory Detection.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Detection(
      id: serializer.fromJson<String>(json['id']),
      visitId: serializer.fromJson<String>(json['visitId']),
      photoId: serializer.fromJson<String>(json['photoId']),
      x1: serializer.fromJson<double>(json['x1']),
      y1: serializer.fromJson<double>(json['y1']),
      x2: serializer.fromJson<double>(json['x2']),
      y2: serializer.fromJson<double>(json['y2']),
      detConfidence: serializer.fromJson<double>(json['detConfidence']),
      skuId: serializer.fromJson<String?>(json['skuId']),
      matchConfidence: serializer.fromJson<double?>(json['matchConfidence']),
      matchMethod: serializer.fromJson<String>(json['matchMethod']),
      shelfRow: serializer.fromJson<int?>(json['shelfRow']),
      isGap: serializer.fromJson<bool>(json['isGap']),
      wasCorrected: serializer.fromJson<bool>(json['wasCorrected']),
      embedding: serializer.fromJson<Uint8List?>(json['embedding']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'visitId': serializer.toJson<String>(visitId),
      'photoId': serializer.toJson<String>(photoId),
      'x1': serializer.toJson<double>(x1),
      'y1': serializer.toJson<double>(y1),
      'x2': serializer.toJson<double>(x2),
      'y2': serializer.toJson<double>(y2),
      'detConfidence': serializer.toJson<double>(detConfidence),
      'skuId': serializer.toJson<String?>(skuId),
      'matchConfidence': serializer.toJson<double?>(matchConfidence),
      'matchMethod': serializer.toJson<String>(matchMethod),
      'shelfRow': serializer.toJson<int?>(shelfRow),
      'isGap': serializer.toJson<bool>(isGap),
      'wasCorrected': serializer.toJson<bool>(wasCorrected),
      'embedding': serializer.toJson<Uint8List?>(embedding),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  Detection copyWith({
    String? id,
    String? visitId,
    String? photoId,
    double? x1,
    double? y1,
    double? x2,
    double? y2,
    double? detConfidence,
    Value<String?> skuId = const Value.absent(),
    Value<double?> matchConfidence = const Value.absent(),
    String? matchMethod,
    Value<int?> shelfRow = const Value.absent(),
    bool? isGap,
    bool? wasCorrected,
    Value<Uint8List?> embedding = const Value.absent(),
    int? createdAt,
  }) => Detection(
    id: id ?? this.id,
    visitId: visitId ?? this.visitId,
    photoId: photoId ?? this.photoId,
    x1: x1 ?? this.x1,
    y1: y1 ?? this.y1,
    x2: x2 ?? this.x2,
    y2: y2 ?? this.y2,
    detConfidence: detConfidence ?? this.detConfidence,
    skuId: skuId.present ? skuId.value : this.skuId,
    matchConfidence: matchConfidence.present
        ? matchConfidence.value
        : this.matchConfidence,
    matchMethod: matchMethod ?? this.matchMethod,
    shelfRow: shelfRow.present ? shelfRow.value : this.shelfRow,
    isGap: isGap ?? this.isGap,
    wasCorrected: wasCorrected ?? this.wasCorrected,
    embedding: embedding.present ? embedding.value : this.embedding,
    createdAt: createdAt ?? this.createdAt,
  );
  Detection copyWithCompanion(DetectionsCompanion data) {
    return Detection(
      id: data.id.present ? data.id.value : this.id,
      visitId: data.visitId.present ? data.visitId.value : this.visitId,
      photoId: data.photoId.present ? data.photoId.value : this.photoId,
      x1: data.x1.present ? data.x1.value : this.x1,
      y1: data.y1.present ? data.y1.value : this.y1,
      x2: data.x2.present ? data.x2.value : this.x2,
      y2: data.y2.present ? data.y2.value : this.y2,
      detConfidence: data.detConfidence.present
          ? data.detConfidence.value
          : this.detConfidence,
      skuId: data.skuId.present ? data.skuId.value : this.skuId,
      matchConfidence: data.matchConfidence.present
          ? data.matchConfidence.value
          : this.matchConfidence,
      matchMethod: data.matchMethod.present
          ? data.matchMethod.value
          : this.matchMethod,
      shelfRow: data.shelfRow.present ? data.shelfRow.value : this.shelfRow,
      isGap: data.isGap.present ? data.isGap.value : this.isGap,
      wasCorrected: data.wasCorrected.present
          ? data.wasCorrected.value
          : this.wasCorrected,
      embedding: data.embedding.present ? data.embedding.value : this.embedding,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Detection(')
          ..write('id: $id, ')
          ..write('visitId: $visitId, ')
          ..write('photoId: $photoId, ')
          ..write('x1: $x1, ')
          ..write('y1: $y1, ')
          ..write('x2: $x2, ')
          ..write('y2: $y2, ')
          ..write('detConfidence: $detConfidence, ')
          ..write('skuId: $skuId, ')
          ..write('matchConfidence: $matchConfidence, ')
          ..write('matchMethod: $matchMethod, ')
          ..write('shelfRow: $shelfRow, ')
          ..write('isGap: $isGap, ')
          ..write('wasCorrected: $wasCorrected, ')
          ..write('embedding: $embedding, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    visitId,
    photoId,
    x1,
    y1,
    x2,
    y2,
    detConfidence,
    skuId,
    matchConfidence,
    matchMethod,
    shelfRow,
    isGap,
    wasCorrected,
    $driftBlobEquality.hash(embedding),
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Detection &&
          other.id == this.id &&
          other.visitId == this.visitId &&
          other.photoId == this.photoId &&
          other.x1 == this.x1 &&
          other.y1 == this.y1 &&
          other.x2 == this.x2 &&
          other.y2 == this.y2 &&
          other.detConfidence == this.detConfidence &&
          other.skuId == this.skuId &&
          other.matchConfidence == this.matchConfidence &&
          other.matchMethod == this.matchMethod &&
          other.shelfRow == this.shelfRow &&
          other.isGap == this.isGap &&
          other.wasCorrected == this.wasCorrected &&
          $driftBlobEquality.equals(other.embedding, this.embedding) &&
          other.createdAt == this.createdAt);
}

class DetectionsCompanion extends UpdateCompanion<Detection> {
  final Value<String> id;
  final Value<String> visitId;
  final Value<String> photoId;
  final Value<double> x1;
  final Value<double> y1;
  final Value<double> x2;
  final Value<double> y2;
  final Value<double> detConfidence;
  final Value<String?> skuId;
  final Value<double?> matchConfidence;
  final Value<String> matchMethod;
  final Value<int?> shelfRow;
  final Value<bool> isGap;
  final Value<bool> wasCorrected;
  final Value<Uint8List?> embedding;
  final Value<int> createdAt;
  final Value<int> rowid;
  const DetectionsCompanion({
    this.id = const Value.absent(),
    this.visitId = const Value.absent(),
    this.photoId = const Value.absent(),
    this.x1 = const Value.absent(),
    this.y1 = const Value.absent(),
    this.x2 = const Value.absent(),
    this.y2 = const Value.absent(),
    this.detConfidence = const Value.absent(),
    this.skuId = const Value.absent(),
    this.matchConfidence = const Value.absent(),
    this.matchMethod = const Value.absent(),
    this.shelfRow = const Value.absent(),
    this.isGap = const Value.absent(),
    this.wasCorrected = const Value.absent(),
    this.embedding = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DetectionsCompanion.insert({
    required String id,
    required String visitId,
    required String photoId,
    required double x1,
    required double y1,
    required double x2,
    required double y2,
    required double detConfidence,
    this.skuId = const Value.absent(),
    this.matchConfidence = const Value.absent(),
    this.matchMethod = const Value.absent(),
    this.shelfRow = const Value.absent(),
    this.isGap = const Value.absent(),
    this.wasCorrected = const Value.absent(),
    this.embedding = const Value.absent(),
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       visitId = Value(visitId),
       photoId = Value(photoId),
       x1 = Value(x1),
       y1 = Value(y1),
       x2 = Value(x2),
       y2 = Value(y2),
       detConfidence = Value(detConfidence),
       createdAt = Value(createdAt);
  static Insertable<Detection> custom({
    Expression<String>? id,
    Expression<String>? visitId,
    Expression<String>? photoId,
    Expression<double>? x1,
    Expression<double>? y1,
    Expression<double>? x2,
    Expression<double>? y2,
    Expression<double>? detConfidence,
    Expression<String>? skuId,
    Expression<double>? matchConfidence,
    Expression<String>? matchMethod,
    Expression<int>? shelfRow,
    Expression<bool>? isGap,
    Expression<bool>? wasCorrected,
    Expression<Uint8List>? embedding,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (visitId != null) 'visit_id': visitId,
      if (photoId != null) 'photo_id': photoId,
      if (x1 != null) 'x1': x1,
      if (y1 != null) 'y1': y1,
      if (x2 != null) 'x2': x2,
      if (y2 != null) 'y2': y2,
      if (detConfidence != null) 'det_confidence': detConfidence,
      if (skuId != null) 'sku_id': skuId,
      if (matchConfidence != null) 'match_confidence': matchConfidence,
      if (matchMethod != null) 'match_method': matchMethod,
      if (shelfRow != null) 'shelf_row': shelfRow,
      if (isGap != null) 'is_gap': isGap,
      if (wasCorrected != null) 'was_corrected': wasCorrected,
      if (embedding != null) 'embedding': embedding,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DetectionsCompanion copyWith({
    Value<String>? id,
    Value<String>? visitId,
    Value<String>? photoId,
    Value<double>? x1,
    Value<double>? y1,
    Value<double>? x2,
    Value<double>? y2,
    Value<double>? detConfidence,
    Value<String?>? skuId,
    Value<double?>? matchConfidence,
    Value<String>? matchMethod,
    Value<int?>? shelfRow,
    Value<bool>? isGap,
    Value<bool>? wasCorrected,
    Value<Uint8List?>? embedding,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return DetectionsCompanion(
      id: id ?? this.id,
      visitId: visitId ?? this.visitId,
      photoId: photoId ?? this.photoId,
      x1: x1 ?? this.x1,
      y1: y1 ?? this.y1,
      x2: x2 ?? this.x2,
      y2: y2 ?? this.y2,
      detConfidence: detConfidence ?? this.detConfidence,
      skuId: skuId ?? this.skuId,
      matchConfidence: matchConfidence ?? this.matchConfidence,
      matchMethod: matchMethod ?? this.matchMethod,
      shelfRow: shelfRow ?? this.shelfRow,
      isGap: isGap ?? this.isGap,
      wasCorrected: wasCorrected ?? this.wasCorrected,
      embedding: embedding ?? this.embedding,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (visitId.present) {
      map['visit_id'] = Variable<String>(visitId.value);
    }
    if (photoId.present) {
      map['photo_id'] = Variable<String>(photoId.value);
    }
    if (x1.present) {
      map['x1'] = Variable<double>(x1.value);
    }
    if (y1.present) {
      map['y1'] = Variable<double>(y1.value);
    }
    if (x2.present) {
      map['x2'] = Variable<double>(x2.value);
    }
    if (y2.present) {
      map['y2'] = Variable<double>(y2.value);
    }
    if (detConfidence.present) {
      map['det_confidence'] = Variable<double>(detConfidence.value);
    }
    if (skuId.present) {
      map['sku_id'] = Variable<String>(skuId.value);
    }
    if (matchConfidence.present) {
      map['match_confidence'] = Variable<double>(matchConfidence.value);
    }
    if (matchMethod.present) {
      map['match_method'] = Variable<String>(matchMethod.value);
    }
    if (shelfRow.present) {
      map['shelf_row'] = Variable<int>(shelfRow.value);
    }
    if (isGap.present) {
      map['is_gap'] = Variable<bool>(isGap.value);
    }
    if (wasCorrected.present) {
      map['was_corrected'] = Variable<bool>(wasCorrected.value);
    }
    if (embedding.present) {
      map['embedding'] = Variable<Uint8List>(embedding.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DetectionsCompanion(')
          ..write('id: $id, ')
          ..write('visitId: $visitId, ')
          ..write('photoId: $photoId, ')
          ..write('x1: $x1, ')
          ..write('y1: $y1, ')
          ..write('x2: $x2, ')
          ..write('y2: $y2, ')
          ..write('detConfidence: $detConfidence, ')
          ..write('skuId: $skuId, ')
          ..write('matchConfidence: $matchConfidence, ')
          ..write('matchMethod: $matchMethod, ')
          ..write('shelfRow: $shelfRow, ')
          ..write('isGap: $isGap, ')
          ..write('wasCorrected: $wasCorrected, ')
          ..write('embedding: $embedding, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ShelfFactsTable extends ShelfFacts
    with TableInfo<$ShelfFactsTable, ShelfFact> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ShelfFactsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _visitIdMeta = const VerificationMeta(
    'visitId',
  );
  @override
  late final GeneratedColumn<String> visitId = GeneratedColumn<String>(
    'visit_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES visits (id)',
    ),
  );
  static const VerificationMeta _skuIdMeta = const VerificationMeta('skuId');
  @override
  late final GeneratedColumn<String> skuId = GeneratedColumn<String>(
    'sku_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES skus (id)',
    ),
  );
  static const VerificationMeta _detectedFacingsMeta = const VerificationMeta(
    'detectedFacings',
  );
  @override
  late final GeneratedColumn<int> detectedFacings = GeneratedColumn<int>(
    'detected_facings',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetFacingsMeta = const VerificationMeta(
    'targetFacings',
  );
  @override
  late final GeneratedColumn<int> targetFacings = GeneratedColumn<int>(
    'target_facings',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _computedAtMeta = const VerificationMeta(
    'computedAt',
  );
  @override
  late final GeneratedColumn<int> computedAt = GeneratedColumn<int>(
    'computed_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    visitId,
    skuId,
    detectedFacings,
    targetFacings,
    status,
    computedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'shelf_facts';
  @override
  VerificationContext validateIntegrity(
    Insertable<ShelfFact> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('visit_id')) {
      context.handle(
        _visitIdMeta,
        visitId.isAcceptableOrUnknown(data['visit_id']!, _visitIdMeta),
      );
    } else if (isInserting) {
      context.missing(_visitIdMeta);
    }
    if (data.containsKey('sku_id')) {
      context.handle(
        _skuIdMeta,
        skuId.isAcceptableOrUnknown(data['sku_id']!, _skuIdMeta),
      );
    } else if (isInserting) {
      context.missing(_skuIdMeta);
    }
    if (data.containsKey('detected_facings')) {
      context.handle(
        _detectedFacingsMeta,
        detectedFacings.isAcceptableOrUnknown(
          data['detected_facings']!,
          _detectedFacingsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_detectedFacingsMeta);
    }
    if (data.containsKey('target_facings')) {
      context.handle(
        _targetFacingsMeta,
        targetFacings.isAcceptableOrUnknown(
          data['target_facings']!,
          _targetFacingsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetFacingsMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('computed_at')) {
      context.handle(
        _computedAtMeta,
        computedAt.isAcceptableOrUnknown(data['computed_at']!, _computedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_computedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {visitId, skuId},
  ];
  @override
  ShelfFact map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ShelfFact(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      visitId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}visit_id'],
      )!,
      skuId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sku_id'],
      )!,
      detectedFacings: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}detected_facings'],
      )!,
      targetFacings: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_facings'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      computedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}computed_at'],
      )!,
    );
  }

  @override
  $ShelfFactsTable createAlias(String alias) {
    return $ShelfFactsTable(attachedDatabase, alias);
  }
}

class ShelfFact extends DataClass implements Insertable<ShelfFact> {
  final String id;
  final String visitId;
  final String skuId;
  final int detectedFacings;
  final int targetFacings;
  final String status;
  final int computedAt;
  const ShelfFact({
    required this.id,
    required this.visitId,
    required this.skuId,
    required this.detectedFacings,
    required this.targetFacings,
    required this.status,
    required this.computedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['visit_id'] = Variable<String>(visitId);
    map['sku_id'] = Variable<String>(skuId);
    map['detected_facings'] = Variable<int>(detectedFacings);
    map['target_facings'] = Variable<int>(targetFacings);
    map['status'] = Variable<String>(status);
    map['computed_at'] = Variable<int>(computedAt);
    return map;
  }

  ShelfFactsCompanion toCompanion(bool nullToAbsent) {
    return ShelfFactsCompanion(
      id: Value(id),
      visitId: Value(visitId),
      skuId: Value(skuId),
      detectedFacings: Value(detectedFacings),
      targetFacings: Value(targetFacings),
      status: Value(status),
      computedAt: Value(computedAt),
    );
  }

  factory ShelfFact.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ShelfFact(
      id: serializer.fromJson<String>(json['id']),
      visitId: serializer.fromJson<String>(json['visitId']),
      skuId: serializer.fromJson<String>(json['skuId']),
      detectedFacings: serializer.fromJson<int>(json['detectedFacings']),
      targetFacings: serializer.fromJson<int>(json['targetFacings']),
      status: serializer.fromJson<String>(json['status']),
      computedAt: serializer.fromJson<int>(json['computedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'visitId': serializer.toJson<String>(visitId),
      'skuId': serializer.toJson<String>(skuId),
      'detectedFacings': serializer.toJson<int>(detectedFacings),
      'targetFacings': serializer.toJson<int>(targetFacings),
      'status': serializer.toJson<String>(status),
      'computedAt': serializer.toJson<int>(computedAt),
    };
  }

  ShelfFact copyWith({
    String? id,
    String? visitId,
    String? skuId,
    int? detectedFacings,
    int? targetFacings,
    String? status,
    int? computedAt,
  }) => ShelfFact(
    id: id ?? this.id,
    visitId: visitId ?? this.visitId,
    skuId: skuId ?? this.skuId,
    detectedFacings: detectedFacings ?? this.detectedFacings,
    targetFacings: targetFacings ?? this.targetFacings,
    status: status ?? this.status,
    computedAt: computedAt ?? this.computedAt,
  );
  ShelfFact copyWithCompanion(ShelfFactsCompanion data) {
    return ShelfFact(
      id: data.id.present ? data.id.value : this.id,
      visitId: data.visitId.present ? data.visitId.value : this.visitId,
      skuId: data.skuId.present ? data.skuId.value : this.skuId,
      detectedFacings: data.detectedFacings.present
          ? data.detectedFacings.value
          : this.detectedFacings,
      targetFacings: data.targetFacings.present
          ? data.targetFacings.value
          : this.targetFacings,
      status: data.status.present ? data.status.value : this.status,
      computedAt: data.computedAt.present
          ? data.computedAt.value
          : this.computedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ShelfFact(')
          ..write('id: $id, ')
          ..write('visitId: $visitId, ')
          ..write('skuId: $skuId, ')
          ..write('detectedFacings: $detectedFacings, ')
          ..write('targetFacings: $targetFacings, ')
          ..write('status: $status, ')
          ..write('computedAt: $computedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    visitId,
    skuId,
    detectedFacings,
    targetFacings,
    status,
    computedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ShelfFact &&
          other.id == this.id &&
          other.visitId == this.visitId &&
          other.skuId == this.skuId &&
          other.detectedFacings == this.detectedFacings &&
          other.targetFacings == this.targetFacings &&
          other.status == this.status &&
          other.computedAt == this.computedAt);
}

class ShelfFactsCompanion extends UpdateCompanion<ShelfFact> {
  final Value<String> id;
  final Value<String> visitId;
  final Value<String> skuId;
  final Value<int> detectedFacings;
  final Value<int> targetFacings;
  final Value<String> status;
  final Value<int> computedAt;
  final Value<int> rowid;
  const ShelfFactsCompanion({
    this.id = const Value.absent(),
    this.visitId = const Value.absent(),
    this.skuId = const Value.absent(),
    this.detectedFacings = const Value.absent(),
    this.targetFacings = const Value.absent(),
    this.status = const Value.absent(),
    this.computedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ShelfFactsCompanion.insert({
    required String id,
    required String visitId,
    required String skuId,
    required int detectedFacings,
    required int targetFacings,
    required String status,
    required int computedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       visitId = Value(visitId),
       skuId = Value(skuId),
       detectedFacings = Value(detectedFacings),
       targetFacings = Value(targetFacings),
       status = Value(status),
       computedAt = Value(computedAt);
  static Insertable<ShelfFact> custom({
    Expression<String>? id,
    Expression<String>? visitId,
    Expression<String>? skuId,
    Expression<int>? detectedFacings,
    Expression<int>? targetFacings,
    Expression<String>? status,
    Expression<int>? computedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (visitId != null) 'visit_id': visitId,
      if (skuId != null) 'sku_id': skuId,
      if (detectedFacings != null) 'detected_facings': detectedFacings,
      if (targetFacings != null) 'target_facings': targetFacings,
      if (status != null) 'status': status,
      if (computedAt != null) 'computed_at': computedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ShelfFactsCompanion copyWith({
    Value<String>? id,
    Value<String>? visitId,
    Value<String>? skuId,
    Value<int>? detectedFacings,
    Value<int>? targetFacings,
    Value<String>? status,
    Value<int>? computedAt,
    Value<int>? rowid,
  }) {
    return ShelfFactsCompanion(
      id: id ?? this.id,
      visitId: visitId ?? this.visitId,
      skuId: skuId ?? this.skuId,
      detectedFacings: detectedFacings ?? this.detectedFacings,
      targetFacings: targetFacings ?? this.targetFacings,
      status: status ?? this.status,
      computedAt: computedAt ?? this.computedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (visitId.present) {
      map['visit_id'] = Variable<String>(visitId.value);
    }
    if (skuId.present) {
      map['sku_id'] = Variable<String>(skuId.value);
    }
    if (detectedFacings.present) {
      map['detected_facings'] = Variable<int>(detectedFacings.value);
    }
    if (targetFacings.present) {
      map['target_facings'] = Variable<int>(targetFacings.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (computedAt.present) {
      map['computed_at'] = Variable<int>(computedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ShelfFactsCompanion(')
          ..write('id: $id, ')
          ..write('visitId: $visitId, ')
          ..write('skuId: $skuId, ')
          ..write('detectedFacings: $detectedFacings, ')
          ..write('targetFacings: $targetFacings, ')
          ..write('status: $status, ')
          ..write('computedAt: $computedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OrderLinesTable extends OrderLines
    with TableInfo<$OrderLinesTable, OrderLine> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OrderLinesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _visitIdMeta = const VerificationMeta(
    'visitId',
  );
  @override
  late final GeneratedColumn<String> visitId = GeneratedColumn<String>(
    'visit_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES visits (id)',
    ),
  );
  static const VerificationMeta _skuIdMeta = const VerificationMeta('skuId');
  @override
  late final GeneratedColumn<String> skuId = GeneratedColumn<String>(
    'sku_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES skus (id)',
    ),
  );
  static const VerificationMeta _suggestedQtyMeta = const VerificationMeta(
    'suggestedQty',
  );
  @override
  late final GeneratedColumn<int> suggestedQty = GeneratedColumn<int>(
    'suggested_qty',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _finalQtyMeta = const VerificationMeta(
    'finalQty',
  );
  @override
  late final GeneratedColumn<int> finalQty = GeneratedColumn<int>(
    'final_qty',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('piece'),
  );
  static const VerificationMeta _valuePaiseMeta = const VerificationMeta(
    'valuePaise',
  );
  @override
  late final GeneratedColumn<int> valuePaise = GeneratedColumn<int>(
    'value_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _wasOverriddenMeta = const VerificationMeta(
    'wasOverridden',
  );
  @override
  late final GeneratedColumn<bool> wasOverridden = GeneratedColumn<bool>(
    'was_overridden',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("was_overridden" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    visitId,
    skuId,
    suggestedQty,
    finalQty,
    unit,
    valuePaise,
    wasOverridden,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'order_lines';
  @override
  VerificationContext validateIntegrity(
    Insertable<OrderLine> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('visit_id')) {
      context.handle(
        _visitIdMeta,
        visitId.isAcceptableOrUnknown(data['visit_id']!, _visitIdMeta),
      );
    } else if (isInserting) {
      context.missing(_visitIdMeta);
    }
    if (data.containsKey('sku_id')) {
      context.handle(
        _skuIdMeta,
        skuId.isAcceptableOrUnknown(data['sku_id']!, _skuIdMeta),
      );
    } else if (isInserting) {
      context.missing(_skuIdMeta);
    }
    if (data.containsKey('suggested_qty')) {
      context.handle(
        _suggestedQtyMeta,
        suggestedQty.isAcceptableOrUnknown(
          data['suggested_qty']!,
          _suggestedQtyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_suggestedQtyMeta);
    }
    if (data.containsKey('final_qty')) {
      context.handle(
        _finalQtyMeta,
        finalQty.isAcceptableOrUnknown(data['final_qty']!, _finalQtyMeta),
      );
    } else if (isInserting) {
      context.missing(_finalQtyMeta);
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    }
    if (data.containsKey('value_paise')) {
      context.handle(
        _valuePaiseMeta,
        valuePaise.isAcceptableOrUnknown(data['value_paise']!, _valuePaiseMeta),
      );
    } else if (isInserting) {
      context.missing(_valuePaiseMeta);
    }
    if (data.containsKey('was_overridden')) {
      context.handle(
        _wasOverriddenMeta,
        wasOverridden.isAcceptableOrUnknown(
          data['was_overridden']!,
          _wasOverriddenMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {visitId, skuId},
  ];
  @override
  OrderLine map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OrderLine(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      visitId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}visit_id'],
      )!,
      skuId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sku_id'],
      )!,
      suggestedQty: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}suggested_qty'],
      )!,
      finalQty: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}final_qty'],
      )!,
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      )!,
      valuePaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}value_paise'],
      )!,
      wasOverridden: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}was_overridden'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $OrderLinesTable createAlias(String alias) {
    return $OrderLinesTable(attachedDatabase, alias);
  }
}

class OrderLine extends DataClass implements Insertable<OrderLine> {
  final String id;
  final String visitId;
  final String skuId;
  final int suggestedQty;
  final int finalQty;
  final String unit;
  final int valuePaise;
  final bool wasOverridden;
  final int createdAt;
  const OrderLine({
    required this.id,
    required this.visitId,
    required this.skuId,
    required this.suggestedQty,
    required this.finalQty,
    required this.unit,
    required this.valuePaise,
    required this.wasOverridden,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['visit_id'] = Variable<String>(visitId);
    map['sku_id'] = Variable<String>(skuId);
    map['suggested_qty'] = Variable<int>(suggestedQty);
    map['final_qty'] = Variable<int>(finalQty);
    map['unit'] = Variable<String>(unit);
    map['value_paise'] = Variable<int>(valuePaise);
    map['was_overridden'] = Variable<bool>(wasOverridden);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  OrderLinesCompanion toCompanion(bool nullToAbsent) {
    return OrderLinesCompanion(
      id: Value(id),
      visitId: Value(visitId),
      skuId: Value(skuId),
      suggestedQty: Value(suggestedQty),
      finalQty: Value(finalQty),
      unit: Value(unit),
      valuePaise: Value(valuePaise),
      wasOverridden: Value(wasOverridden),
      createdAt: Value(createdAt),
    );
  }

  factory OrderLine.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OrderLine(
      id: serializer.fromJson<String>(json['id']),
      visitId: serializer.fromJson<String>(json['visitId']),
      skuId: serializer.fromJson<String>(json['skuId']),
      suggestedQty: serializer.fromJson<int>(json['suggestedQty']),
      finalQty: serializer.fromJson<int>(json['finalQty']),
      unit: serializer.fromJson<String>(json['unit']),
      valuePaise: serializer.fromJson<int>(json['valuePaise']),
      wasOverridden: serializer.fromJson<bool>(json['wasOverridden']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'visitId': serializer.toJson<String>(visitId),
      'skuId': serializer.toJson<String>(skuId),
      'suggestedQty': serializer.toJson<int>(suggestedQty),
      'finalQty': serializer.toJson<int>(finalQty),
      'unit': serializer.toJson<String>(unit),
      'valuePaise': serializer.toJson<int>(valuePaise),
      'wasOverridden': serializer.toJson<bool>(wasOverridden),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  OrderLine copyWith({
    String? id,
    String? visitId,
    String? skuId,
    int? suggestedQty,
    int? finalQty,
    String? unit,
    int? valuePaise,
    bool? wasOverridden,
    int? createdAt,
  }) => OrderLine(
    id: id ?? this.id,
    visitId: visitId ?? this.visitId,
    skuId: skuId ?? this.skuId,
    suggestedQty: suggestedQty ?? this.suggestedQty,
    finalQty: finalQty ?? this.finalQty,
    unit: unit ?? this.unit,
    valuePaise: valuePaise ?? this.valuePaise,
    wasOverridden: wasOverridden ?? this.wasOverridden,
    createdAt: createdAt ?? this.createdAt,
  );
  OrderLine copyWithCompanion(OrderLinesCompanion data) {
    return OrderLine(
      id: data.id.present ? data.id.value : this.id,
      visitId: data.visitId.present ? data.visitId.value : this.visitId,
      skuId: data.skuId.present ? data.skuId.value : this.skuId,
      suggestedQty: data.suggestedQty.present
          ? data.suggestedQty.value
          : this.suggestedQty,
      finalQty: data.finalQty.present ? data.finalQty.value : this.finalQty,
      unit: data.unit.present ? data.unit.value : this.unit,
      valuePaise: data.valuePaise.present
          ? data.valuePaise.value
          : this.valuePaise,
      wasOverridden: data.wasOverridden.present
          ? data.wasOverridden.value
          : this.wasOverridden,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OrderLine(')
          ..write('id: $id, ')
          ..write('visitId: $visitId, ')
          ..write('skuId: $skuId, ')
          ..write('suggestedQty: $suggestedQty, ')
          ..write('finalQty: $finalQty, ')
          ..write('unit: $unit, ')
          ..write('valuePaise: $valuePaise, ')
          ..write('wasOverridden: $wasOverridden, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    visitId,
    skuId,
    suggestedQty,
    finalQty,
    unit,
    valuePaise,
    wasOverridden,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OrderLine &&
          other.id == this.id &&
          other.visitId == this.visitId &&
          other.skuId == this.skuId &&
          other.suggestedQty == this.suggestedQty &&
          other.finalQty == this.finalQty &&
          other.unit == this.unit &&
          other.valuePaise == this.valuePaise &&
          other.wasOverridden == this.wasOverridden &&
          other.createdAt == this.createdAt);
}

class OrderLinesCompanion extends UpdateCompanion<OrderLine> {
  final Value<String> id;
  final Value<String> visitId;
  final Value<String> skuId;
  final Value<int> suggestedQty;
  final Value<int> finalQty;
  final Value<String> unit;
  final Value<int> valuePaise;
  final Value<bool> wasOverridden;
  final Value<int> createdAt;
  final Value<int> rowid;
  const OrderLinesCompanion({
    this.id = const Value.absent(),
    this.visitId = const Value.absent(),
    this.skuId = const Value.absent(),
    this.suggestedQty = const Value.absent(),
    this.finalQty = const Value.absent(),
    this.unit = const Value.absent(),
    this.valuePaise = const Value.absent(),
    this.wasOverridden = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OrderLinesCompanion.insert({
    required String id,
    required String visitId,
    required String skuId,
    required int suggestedQty,
    required int finalQty,
    this.unit = const Value.absent(),
    required int valuePaise,
    this.wasOverridden = const Value.absent(),
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       visitId = Value(visitId),
       skuId = Value(skuId),
       suggestedQty = Value(suggestedQty),
       finalQty = Value(finalQty),
       valuePaise = Value(valuePaise),
       createdAt = Value(createdAt);
  static Insertable<OrderLine> custom({
    Expression<String>? id,
    Expression<String>? visitId,
    Expression<String>? skuId,
    Expression<int>? suggestedQty,
    Expression<int>? finalQty,
    Expression<String>? unit,
    Expression<int>? valuePaise,
    Expression<bool>? wasOverridden,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (visitId != null) 'visit_id': visitId,
      if (skuId != null) 'sku_id': skuId,
      if (suggestedQty != null) 'suggested_qty': suggestedQty,
      if (finalQty != null) 'final_qty': finalQty,
      if (unit != null) 'unit': unit,
      if (valuePaise != null) 'value_paise': valuePaise,
      if (wasOverridden != null) 'was_overridden': wasOverridden,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OrderLinesCompanion copyWith({
    Value<String>? id,
    Value<String>? visitId,
    Value<String>? skuId,
    Value<int>? suggestedQty,
    Value<int>? finalQty,
    Value<String>? unit,
    Value<int>? valuePaise,
    Value<bool>? wasOverridden,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return OrderLinesCompanion(
      id: id ?? this.id,
      visitId: visitId ?? this.visitId,
      skuId: skuId ?? this.skuId,
      suggestedQty: suggestedQty ?? this.suggestedQty,
      finalQty: finalQty ?? this.finalQty,
      unit: unit ?? this.unit,
      valuePaise: valuePaise ?? this.valuePaise,
      wasOverridden: wasOverridden ?? this.wasOverridden,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (visitId.present) {
      map['visit_id'] = Variable<String>(visitId.value);
    }
    if (skuId.present) {
      map['sku_id'] = Variable<String>(skuId.value);
    }
    if (suggestedQty.present) {
      map['suggested_qty'] = Variable<int>(suggestedQty.value);
    }
    if (finalQty.present) {
      map['final_qty'] = Variable<int>(finalQty.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (valuePaise.present) {
      map['value_paise'] = Variable<int>(valuePaise.value);
    }
    if (wasOverridden.present) {
      map['was_overridden'] = Variable<bool>(wasOverridden.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OrderLinesCompanion(')
          ..write('id: $id, ')
          ..write('visitId: $visitId, ')
          ..write('skuId: $skuId, ')
          ..write('suggestedQty: $suggestedQty, ')
          ..write('finalQty: $finalQty, ')
          ..write('unit: $unit, ')
          ..write('valuePaise: $valuePaise, ')
          ..write('wasOverridden: $wasOverridden, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OverrideEventsTable extends OverrideEvents
    with TableInfo<$OverrideEventsTable, OverrideEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OverrideEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _visitIdMeta = const VerificationMeta(
    'visitId',
  );
  @override
  late final GeneratedColumn<String> visitId = GeneratedColumn<String>(
    'visit_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityMeta = const VerificationMeta('entity');
  @override
  late final GeneratedColumn<String> entity = GeneratedColumn<String>(
    'entity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fieldMeta = const VerificationMeta('field');
  @override
  late final GeneratedColumn<String> field = GeneratedColumn<String>(
    'field',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _oldValueMeta = const VerificationMeta(
    'oldValue',
  );
  @override
  late final GeneratedColumn<String> oldValue = GeneratedColumn<String>(
    'old_value',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _newValueMeta = const VerificationMeta(
    'newValue',
  );
  @override
  late final GeneratedColumn<String> newValue = GeneratedColumn<String>(
    'new_value',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    visitId,
    entity,
    entityId,
    field,
    oldValue,
    newValue,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'override_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<OverrideEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('visit_id')) {
      context.handle(
        _visitIdMeta,
        visitId.isAcceptableOrUnknown(data['visit_id']!, _visitIdMeta),
      );
    } else if (isInserting) {
      context.missing(_visitIdMeta);
    }
    if (data.containsKey('entity')) {
      context.handle(
        _entityMeta,
        entity.isAcceptableOrUnknown(data['entity']!, _entityMeta),
      );
    } else if (isInserting) {
      context.missing(_entityMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('field')) {
      context.handle(
        _fieldMeta,
        field.isAcceptableOrUnknown(data['field']!, _fieldMeta),
      );
    } else if (isInserting) {
      context.missing(_fieldMeta);
    }
    if (data.containsKey('old_value')) {
      context.handle(
        _oldValueMeta,
        oldValue.isAcceptableOrUnknown(data['old_value']!, _oldValueMeta),
      );
    }
    if (data.containsKey('new_value')) {
      context.handle(
        _newValueMeta,
        newValue.isAcceptableOrUnknown(data['new_value']!, _newValueMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OverrideEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OverrideEvent(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      visitId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}visit_id'],
      )!,
      entity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      field: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}field'],
      )!,
      oldValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}old_value'],
      ),
      newValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}new_value'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $OverrideEventsTable createAlias(String alias) {
    return $OverrideEventsTable(attachedDatabase, alias);
  }
}

class OverrideEvent extends DataClass implements Insertable<OverrideEvent> {
  final String id;
  final String visitId;
  final String entity;
  final String entityId;
  final String field;
  final String? oldValue;
  final String? newValue;
  final int createdAt;
  const OverrideEvent({
    required this.id,
    required this.visitId,
    required this.entity,
    required this.entityId,
    required this.field,
    this.oldValue,
    this.newValue,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['visit_id'] = Variable<String>(visitId);
    map['entity'] = Variable<String>(entity);
    map['entity_id'] = Variable<String>(entityId);
    map['field'] = Variable<String>(field);
    if (!nullToAbsent || oldValue != null) {
      map['old_value'] = Variable<String>(oldValue);
    }
    if (!nullToAbsent || newValue != null) {
      map['new_value'] = Variable<String>(newValue);
    }
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  OverrideEventsCompanion toCompanion(bool nullToAbsent) {
    return OverrideEventsCompanion(
      id: Value(id),
      visitId: Value(visitId),
      entity: Value(entity),
      entityId: Value(entityId),
      field: Value(field),
      oldValue: oldValue == null && nullToAbsent
          ? const Value.absent()
          : Value(oldValue),
      newValue: newValue == null && nullToAbsent
          ? const Value.absent()
          : Value(newValue),
      createdAt: Value(createdAt),
    );
  }

  factory OverrideEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OverrideEvent(
      id: serializer.fromJson<String>(json['id']),
      visitId: serializer.fromJson<String>(json['visitId']),
      entity: serializer.fromJson<String>(json['entity']),
      entityId: serializer.fromJson<String>(json['entityId']),
      field: serializer.fromJson<String>(json['field']),
      oldValue: serializer.fromJson<String?>(json['oldValue']),
      newValue: serializer.fromJson<String?>(json['newValue']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'visitId': serializer.toJson<String>(visitId),
      'entity': serializer.toJson<String>(entity),
      'entityId': serializer.toJson<String>(entityId),
      'field': serializer.toJson<String>(field),
      'oldValue': serializer.toJson<String?>(oldValue),
      'newValue': serializer.toJson<String?>(newValue),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  OverrideEvent copyWith({
    String? id,
    String? visitId,
    String? entity,
    String? entityId,
    String? field,
    Value<String?> oldValue = const Value.absent(),
    Value<String?> newValue = const Value.absent(),
    int? createdAt,
  }) => OverrideEvent(
    id: id ?? this.id,
    visitId: visitId ?? this.visitId,
    entity: entity ?? this.entity,
    entityId: entityId ?? this.entityId,
    field: field ?? this.field,
    oldValue: oldValue.present ? oldValue.value : this.oldValue,
    newValue: newValue.present ? newValue.value : this.newValue,
    createdAt: createdAt ?? this.createdAt,
  );
  OverrideEvent copyWithCompanion(OverrideEventsCompanion data) {
    return OverrideEvent(
      id: data.id.present ? data.id.value : this.id,
      visitId: data.visitId.present ? data.visitId.value : this.visitId,
      entity: data.entity.present ? data.entity.value : this.entity,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      field: data.field.present ? data.field.value : this.field,
      oldValue: data.oldValue.present ? data.oldValue.value : this.oldValue,
      newValue: data.newValue.present ? data.newValue.value : this.newValue,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OverrideEvent(')
          ..write('id: $id, ')
          ..write('visitId: $visitId, ')
          ..write('entity: $entity, ')
          ..write('entityId: $entityId, ')
          ..write('field: $field, ')
          ..write('oldValue: $oldValue, ')
          ..write('newValue: $newValue, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    visitId,
    entity,
    entityId,
    field,
    oldValue,
    newValue,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OverrideEvent &&
          other.id == this.id &&
          other.visitId == this.visitId &&
          other.entity == this.entity &&
          other.entityId == this.entityId &&
          other.field == this.field &&
          other.oldValue == this.oldValue &&
          other.newValue == this.newValue &&
          other.createdAt == this.createdAt);
}

class OverrideEventsCompanion extends UpdateCompanion<OverrideEvent> {
  final Value<String> id;
  final Value<String> visitId;
  final Value<String> entity;
  final Value<String> entityId;
  final Value<String> field;
  final Value<String?> oldValue;
  final Value<String?> newValue;
  final Value<int> createdAt;
  final Value<int> rowid;
  const OverrideEventsCompanion({
    this.id = const Value.absent(),
    this.visitId = const Value.absent(),
    this.entity = const Value.absent(),
    this.entityId = const Value.absent(),
    this.field = const Value.absent(),
    this.oldValue = const Value.absent(),
    this.newValue = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OverrideEventsCompanion.insert({
    required String id,
    required String visitId,
    required String entity,
    required String entityId,
    required String field,
    this.oldValue = const Value.absent(),
    this.newValue = const Value.absent(),
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       visitId = Value(visitId),
       entity = Value(entity),
       entityId = Value(entityId),
       field = Value(field),
       createdAt = Value(createdAt);
  static Insertable<OverrideEvent> custom({
    Expression<String>? id,
    Expression<String>? visitId,
    Expression<String>? entity,
    Expression<String>? entityId,
    Expression<String>? field,
    Expression<String>? oldValue,
    Expression<String>? newValue,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (visitId != null) 'visit_id': visitId,
      if (entity != null) 'entity': entity,
      if (entityId != null) 'entity_id': entityId,
      if (field != null) 'field': field,
      if (oldValue != null) 'old_value': oldValue,
      if (newValue != null) 'new_value': newValue,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OverrideEventsCompanion copyWith({
    Value<String>? id,
    Value<String>? visitId,
    Value<String>? entity,
    Value<String>? entityId,
    Value<String>? field,
    Value<String?>? oldValue,
    Value<String?>? newValue,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return OverrideEventsCompanion(
      id: id ?? this.id,
      visitId: visitId ?? this.visitId,
      entity: entity ?? this.entity,
      entityId: entityId ?? this.entityId,
      field: field ?? this.field,
      oldValue: oldValue ?? this.oldValue,
      newValue: newValue ?? this.newValue,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (visitId.present) {
      map['visit_id'] = Variable<String>(visitId.value);
    }
    if (entity.present) {
      map['entity'] = Variable<String>(entity.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (field.present) {
      map['field'] = Variable<String>(field.value);
    }
    if (oldValue.present) {
      map['old_value'] = Variable<String>(oldValue.value);
    }
    if (newValue.present) {
      map['new_value'] = Variable<String>(newValue.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OverrideEventsCompanion(')
          ..write('id: $id, ')
          ..write('visitId: $visitId, ')
          ..write('entity: $entity, ')
          ..write('entityId: $entityId, ')
          ..write('field: $field, ')
          ..write('oldValue: $oldValue, ')
          ..write('newValue: $newValue, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExportBatchesTable extends ExportBatches
    with TableInfo<$ExportBatchesTable, ExportBatche> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExportBatchesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _beatIdMeta = const VerificationMeta('beatId');
  @override
  late final GeneratedColumn<String> beatId = GeneratedColumn<String>(
    'beat_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES beats (id)',
    ),
  );
  static const VerificationMeta _visitCountMeta = const VerificationMeta(
    'visitCount',
  );
  @override
  late final GeneratedColumn<int> visitCount = GeneratedColumn<int>(
    'visit_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lineCountMeta = const VerificationMeta(
    'lineCount',
  );
  @override
  late final GeneratedColumn<int> lineCount = GeneratedColumn<int>(
    'line_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalValuePaiseMeta = const VerificationMeta(
    'totalValuePaise',
  );
  @override
  late final GeneratedColumn<int> totalValuePaise = GeneratedColumn<int>(
    'total_value_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _xlsxPathMeta = const VerificationMeta(
    'xlsxPath',
  );
  @override
  late final GeneratedColumn<String> xlsxPath = GeneratedColumn<String>(
    'xlsx_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _csvPathMeta = const VerificationMeta(
    'csvPath',
  );
  @override
  late final GeneratedColumn<String> csvPath = GeneratedColumn<String>(
    'csv_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pdfPathMeta = const VerificationMeta(
    'pdfPath',
  );
  @override
  late final GeneratedColumn<String> pdfPath = GeneratedColumn<String>(
    'pdf_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    beatId,
    visitCount,
    lineCount,
    totalValuePaise,
    xlsxPath,
    csvPath,
    pdfPath,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'export_batches';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExportBatche> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('beat_id')) {
      context.handle(
        _beatIdMeta,
        beatId.isAcceptableOrUnknown(data['beat_id']!, _beatIdMeta),
      );
    } else if (isInserting) {
      context.missing(_beatIdMeta);
    }
    if (data.containsKey('visit_count')) {
      context.handle(
        _visitCountMeta,
        visitCount.isAcceptableOrUnknown(data['visit_count']!, _visitCountMeta),
      );
    } else if (isInserting) {
      context.missing(_visitCountMeta);
    }
    if (data.containsKey('line_count')) {
      context.handle(
        _lineCountMeta,
        lineCount.isAcceptableOrUnknown(data['line_count']!, _lineCountMeta),
      );
    } else if (isInserting) {
      context.missing(_lineCountMeta);
    }
    if (data.containsKey('total_value_paise')) {
      context.handle(
        _totalValuePaiseMeta,
        totalValuePaise.isAcceptableOrUnknown(
          data['total_value_paise']!,
          _totalValuePaiseMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalValuePaiseMeta);
    }
    if (data.containsKey('xlsx_path')) {
      context.handle(
        _xlsxPathMeta,
        xlsxPath.isAcceptableOrUnknown(data['xlsx_path']!, _xlsxPathMeta),
      );
    }
    if (data.containsKey('csv_path')) {
      context.handle(
        _csvPathMeta,
        csvPath.isAcceptableOrUnknown(data['csv_path']!, _csvPathMeta),
      );
    }
    if (data.containsKey('pdf_path')) {
      context.handle(
        _pdfPathMeta,
        pdfPath.isAcceptableOrUnknown(data['pdf_path']!, _pdfPathMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExportBatche map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExportBatche(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      beatId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}beat_id'],
      )!,
      visitCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}visit_count'],
      )!,
      lineCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}line_count'],
      )!,
      totalValuePaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_value_paise'],
      )!,
      xlsxPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}xlsx_path'],
      ),
      csvPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}csv_path'],
      ),
      pdfPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pdf_path'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ExportBatchesTable createAlias(String alias) {
    return $ExportBatchesTable(attachedDatabase, alias);
  }
}

class ExportBatche extends DataClass implements Insertable<ExportBatche> {
  final String id;
  final String beatId;
  final int visitCount;
  final int lineCount;
  final int totalValuePaise;
  final String? xlsxPath;
  final String? csvPath;
  final String? pdfPath;
  final int createdAt;
  const ExportBatche({
    required this.id,
    required this.beatId,
    required this.visitCount,
    required this.lineCount,
    required this.totalValuePaise,
    this.xlsxPath,
    this.csvPath,
    this.pdfPath,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['beat_id'] = Variable<String>(beatId);
    map['visit_count'] = Variable<int>(visitCount);
    map['line_count'] = Variable<int>(lineCount);
    map['total_value_paise'] = Variable<int>(totalValuePaise);
    if (!nullToAbsent || xlsxPath != null) {
      map['xlsx_path'] = Variable<String>(xlsxPath);
    }
    if (!nullToAbsent || csvPath != null) {
      map['csv_path'] = Variable<String>(csvPath);
    }
    if (!nullToAbsent || pdfPath != null) {
      map['pdf_path'] = Variable<String>(pdfPath);
    }
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  ExportBatchesCompanion toCompanion(bool nullToAbsent) {
    return ExportBatchesCompanion(
      id: Value(id),
      beatId: Value(beatId),
      visitCount: Value(visitCount),
      lineCount: Value(lineCount),
      totalValuePaise: Value(totalValuePaise),
      xlsxPath: xlsxPath == null && nullToAbsent
          ? const Value.absent()
          : Value(xlsxPath),
      csvPath: csvPath == null && nullToAbsent
          ? const Value.absent()
          : Value(csvPath),
      pdfPath: pdfPath == null && nullToAbsent
          ? const Value.absent()
          : Value(pdfPath),
      createdAt: Value(createdAt),
    );
  }

  factory ExportBatche.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExportBatche(
      id: serializer.fromJson<String>(json['id']),
      beatId: serializer.fromJson<String>(json['beatId']),
      visitCount: serializer.fromJson<int>(json['visitCount']),
      lineCount: serializer.fromJson<int>(json['lineCount']),
      totalValuePaise: serializer.fromJson<int>(json['totalValuePaise']),
      xlsxPath: serializer.fromJson<String?>(json['xlsxPath']),
      csvPath: serializer.fromJson<String?>(json['csvPath']),
      pdfPath: serializer.fromJson<String?>(json['pdfPath']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'beatId': serializer.toJson<String>(beatId),
      'visitCount': serializer.toJson<int>(visitCount),
      'lineCount': serializer.toJson<int>(lineCount),
      'totalValuePaise': serializer.toJson<int>(totalValuePaise),
      'xlsxPath': serializer.toJson<String?>(xlsxPath),
      'csvPath': serializer.toJson<String?>(csvPath),
      'pdfPath': serializer.toJson<String?>(pdfPath),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  ExportBatche copyWith({
    String? id,
    String? beatId,
    int? visitCount,
    int? lineCount,
    int? totalValuePaise,
    Value<String?> xlsxPath = const Value.absent(),
    Value<String?> csvPath = const Value.absent(),
    Value<String?> pdfPath = const Value.absent(),
    int? createdAt,
  }) => ExportBatche(
    id: id ?? this.id,
    beatId: beatId ?? this.beatId,
    visitCount: visitCount ?? this.visitCount,
    lineCount: lineCount ?? this.lineCount,
    totalValuePaise: totalValuePaise ?? this.totalValuePaise,
    xlsxPath: xlsxPath.present ? xlsxPath.value : this.xlsxPath,
    csvPath: csvPath.present ? csvPath.value : this.csvPath,
    pdfPath: pdfPath.present ? pdfPath.value : this.pdfPath,
    createdAt: createdAt ?? this.createdAt,
  );
  ExportBatche copyWithCompanion(ExportBatchesCompanion data) {
    return ExportBatche(
      id: data.id.present ? data.id.value : this.id,
      beatId: data.beatId.present ? data.beatId.value : this.beatId,
      visitCount: data.visitCount.present
          ? data.visitCount.value
          : this.visitCount,
      lineCount: data.lineCount.present ? data.lineCount.value : this.lineCount,
      totalValuePaise: data.totalValuePaise.present
          ? data.totalValuePaise.value
          : this.totalValuePaise,
      xlsxPath: data.xlsxPath.present ? data.xlsxPath.value : this.xlsxPath,
      csvPath: data.csvPath.present ? data.csvPath.value : this.csvPath,
      pdfPath: data.pdfPath.present ? data.pdfPath.value : this.pdfPath,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExportBatche(')
          ..write('id: $id, ')
          ..write('beatId: $beatId, ')
          ..write('visitCount: $visitCount, ')
          ..write('lineCount: $lineCount, ')
          ..write('totalValuePaise: $totalValuePaise, ')
          ..write('xlsxPath: $xlsxPath, ')
          ..write('csvPath: $csvPath, ')
          ..write('pdfPath: $pdfPath, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    beatId,
    visitCount,
    lineCount,
    totalValuePaise,
    xlsxPath,
    csvPath,
    pdfPath,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExportBatche &&
          other.id == this.id &&
          other.beatId == this.beatId &&
          other.visitCount == this.visitCount &&
          other.lineCount == this.lineCount &&
          other.totalValuePaise == this.totalValuePaise &&
          other.xlsxPath == this.xlsxPath &&
          other.csvPath == this.csvPath &&
          other.pdfPath == this.pdfPath &&
          other.createdAt == this.createdAt);
}

class ExportBatchesCompanion extends UpdateCompanion<ExportBatche> {
  final Value<String> id;
  final Value<String> beatId;
  final Value<int> visitCount;
  final Value<int> lineCount;
  final Value<int> totalValuePaise;
  final Value<String?> xlsxPath;
  final Value<String?> csvPath;
  final Value<String?> pdfPath;
  final Value<int> createdAt;
  final Value<int> rowid;
  const ExportBatchesCompanion({
    this.id = const Value.absent(),
    this.beatId = const Value.absent(),
    this.visitCount = const Value.absent(),
    this.lineCount = const Value.absent(),
    this.totalValuePaise = const Value.absent(),
    this.xlsxPath = const Value.absent(),
    this.csvPath = const Value.absent(),
    this.pdfPath = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExportBatchesCompanion.insert({
    required String id,
    required String beatId,
    required int visitCount,
    required int lineCount,
    required int totalValuePaise,
    this.xlsxPath = const Value.absent(),
    this.csvPath = const Value.absent(),
    this.pdfPath = const Value.absent(),
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       beatId = Value(beatId),
       visitCount = Value(visitCount),
       lineCount = Value(lineCount),
       totalValuePaise = Value(totalValuePaise),
       createdAt = Value(createdAt);
  static Insertable<ExportBatche> custom({
    Expression<String>? id,
    Expression<String>? beatId,
    Expression<int>? visitCount,
    Expression<int>? lineCount,
    Expression<int>? totalValuePaise,
    Expression<String>? xlsxPath,
    Expression<String>? csvPath,
    Expression<String>? pdfPath,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (beatId != null) 'beat_id': beatId,
      if (visitCount != null) 'visit_count': visitCount,
      if (lineCount != null) 'line_count': lineCount,
      if (totalValuePaise != null) 'total_value_paise': totalValuePaise,
      if (xlsxPath != null) 'xlsx_path': xlsxPath,
      if (csvPath != null) 'csv_path': csvPath,
      if (pdfPath != null) 'pdf_path': pdfPath,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExportBatchesCompanion copyWith({
    Value<String>? id,
    Value<String>? beatId,
    Value<int>? visitCount,
    Value<int>? lineCount,
    Value<int>? totalValuePaise,
    Value<String?>? xlsxPath,
    Value<String?>? csvPath,
    Value<String?>? pdfPath,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return ExportBatchesCompanion(
      id: id ?? this.id,
      beatId: beatId ?? this.beatId,
      visitCount: visitCount ?? this.visitCount,
      lineCount: lineCount ?? this.lineCount,
      totalValuePaise: totalValuePaise ?? this.totalValuePaise,
      xlsxPath: xlsxPath ?? this.xlsxPath,
      csvPath: csvPath ?? this.csvPath,
      pdfPath: pdfPath ?? this.pdfPath,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (beatId.present) {
      map['beat_id'] = Variable<String>(beatId.value);
    }
    if (visitCount.present) {
      map['visit_count'] = Variable<int>(visitCount.value);
    }
    if (lineCount.present) {
      map['line_count'] = Variable<int>(lineCount.value);
    }
    if (totalValuePaise.present) {
      map['total_value_paise'] = Variable<int>(totalValuePaise.value);
    }
    if (xlsxPath.present) {
      map['xlsx_path'] = Variable<String>(xlsxPath.value);
    }
    if (csvPath.present) {
      map['csv_path'] = Variable<String>(csvPath.value);
    }
    if (pdfPath.present) {
      map['pdf_path'] = Variable<String>(pdfPath.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExportBatchesCompanion(')
          ..write('id: $id, ')
          ..write('beatId: $beatId, ')
          ..write('visitCount: $visitCount, ')
          ..write('lineCount: $lineCount, ')
          ..write('totalValuePaise: $totalValuePaise, ')
          ..write('xlsxPath: $xlsxPath, ')
          ..write('csvPath: $csvPath, ')
          ..write('pdfPath: $pdfPath, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ModelRegistryTable extends ModelRegistry
    with TableInfo<$ModelRegistryTable, ModelRegistryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ModelRegistryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _assetPathMeta = const VerificationMeta(
    'assetPath',
  );
  @override
  late final GeneratedColumn<String> assetPath = GeneratedColumn<String>(
    'asset_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _loadedOkMeta = const VerificationMeta(
    'loadedOk',
  );
  @override
  late final GeneratedColumn<bool> loadedOk = GeneratedColumn<bool>(
    'loaded_ok',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("loaded_ok" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _loadMsMeta = const VerificationMeta('loadMs');
  @override
  late final GeneratedColumn<int> loadMs = GeneratedColumn<int>(
    'load_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _meanLatencyMsMeta = const VerificationMeta(
    'meanLatencyMs',
  );
  @override
  late final GeneratedColumn<double> meanLatencyMs = GeneratedColumn<double>(
    'mean_latency_ms',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _runCountMeta = const VerificationMeta(
    'runCount',
  );
  @override
  late final GeneratedColumn<int> runCount = GeneratedColumn<int>(
    'run_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    kind,
    label,
    assetPath,
    loadedOk,
    loadMs,
    meanLatencyMs,
    runCount,
    lastError,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'model_registry';
  @override
  VerificationContext validateIntegrity(
    Insertable<ModelRegistryData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('asset_path')) {
      context.handle(
        _assetPathMeta,
        assetPath.isAcceptableOrUnknown(data['asset_path']!, _assetPathMeta),
      );
    } else if (isInserting) {
      context.missing(_assetPathMeta);
    }
    if (data.containsKey('loaded_ok')) {
      context.handle(
        _loadedOkMeta,
        loadedOk.isAcceptableOrUnknown(data['loaded_ok']!, _loadedOkMeta),
      );
    }
    if (data.containsKey('load_ms')) {
      context.handle(
        _loadMsMeta,
        loadMs.isAcceptableOrUnknown(data['load_ms']!, _loadMsMeta),
      );
    }
    if (data.containsKey('mean_latency_ms')) {
      context.handle(
        _meanLatencyMsMeta,
        meanLatencyMs.isAcceptableOrUnknown(
          data['mean_latency_ms']!,
          _meanLatencyMsMeta,
        ),
      );
    }
    if (data.containsKey('run_count')) {
      context.handle(
        _runCountMeta,
        runCount.isAcceptableOrUnknown(data['run_count']!, _runCountMeta),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ModelRegistryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ModelRegistryData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      assetPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}asset_path'],
      )!,
      loadedOk: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}loaded_ok'],
      )!,
      loadMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}load_ms'],
      ),
      meanLatencyMs: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}mean_latency_ms'],
      ),
      runCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}run_count'],
      )!,
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
    );
  }

  @override
  $ModelRegistryTable createAlias(String alias) {
    return $ModelRegistryTable(attachedDatabase, alias);
  }
}

class ModelRegistryData extends DataClass
    implements Insertable<ModelRegistryData> {
  final String id;
  final String kind;
  final String label;
  final String assetPath;
  final bool loadedOk;
  final int? loadMs;
  final double? meanLatencyMs;
  final int runCount;
  final String? lastError;
  const ModelRegistryData({
    required this.id,
    required this.kind,
    required this.label,
    required this.assetPath,
    required this.loadedOk,
    this.loadMs,
    this.meanLatencyMs,
    required this.runCount,
    this.lastError,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['kind'] = Variable<String>(kind);
    map['label'] = Variable<String>(label);
    map['asset_path'] = Variable<String>(assetPath);
    map['loaded_ok'] = Variable<bool>(loadedOk);
    if (!nullToAbsent || loadMs != null) {
      map['load_ms'] = Variable<int>(loadMs);
    }
    if (!nullToAbsent || meanLatencyMs != null) {
      map['mean_latency_ms'] = Variable<double>(meanLatencyMs);
    }
    map['run_count'] = Variable<int>(runCount);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    return map;
  }

  ModelRegistryCompanion toCompanion(bool nullToAbsent) {
    return ModelRegistryCompanion(
      id: Value(id),
      kind: Value(kind),
      label: Value(label),
      assetPath: Value(assetPath),
      loadedOk: Value(loadedOk),
      loadMs: loadMs == null && nullToAbsent
          ? const Value.absent()
          : Value(loadMs),
      meanLatencyMs: meanLatencyMs == null && nullToAbsent
          ? const Value.absent()
          : Value(meanLatencyMs),
      runCount: Value(runCount),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
    );
  }

  factory ModelRegistryData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ModelRegistryData(
      id: serializer.fromJson<String>(json['id']),
      kind: serializer.fromJson<String>(json['kind']),
      label: serializer.fromJson<String>(json['label']),
      assetPath: serializer.fromJson<String>(json['assetPath']),
      loadedOk: serializer.fromJson<bool>(json['loadedOk']),
      loadMs: serializer.fromJson<int?>(json['loadMs']),
      meanLatencyMs: serializer.fromJson<double?>(json['meanLatencyMs']),
      runCount: serializer.fromJson<int>(json['runCount']),
      lastError: serializer.fromJson<String?>(json['lastError']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'kind': serializer.toJson<String>(kind),
      'label': serializer.toJson<String>(label),
      'assetPath': serializer.toJson<String>(assetPath),
      'loadedOk': serializer.toJson<bool>(loadedOk),
      'loadMs': serializer.toJson<int?>(loadMs),
      'meanLatencyMs': serializer.toJson<double?>(meanLatencyMs),
      'runCount': serializer.toJson<int>(runCount),
      'lastError': serializer.toJson<String?>(lastError),
    };
  }

  ModelRegistryData copyWith({
    String? id,
    String? kind,
    String? label,
    String? assetPath,
    bool? loadedOk,
    Value<int?> loadMs = const Value.absent(),
    Value<double?> meanLatencyMs = const Value.absent(),
    int? runCount,
    Value<String?> lastError = const Value.absent(),
  }) => ModelRegistryData(
    id: id ?? this.id,
    kind: kind ?? this.kind,
    label: label ?? this.label,
    assetPath: assetPath ?? this.assetPath,
    loadedOk: loadedOk ?? this.loadedOk,
    loadMs: loadMs.present ? loadMs.value : this.loadMs,
    meanLatencyMs: meanLatencyMs.present
        ? meanLatencyMs.value
        : this.meanLatencyMs,
    runCount: runCount ?? this.runCount,
    lastError: lastError.present ? lastError.value : this.lastError,
  );
  ModelRegistryData copyWithCompanion(ModelRegistryCompanion data) {
    return ModelRegistryData(
      id: data.id.present ? data.id.value : this.id,
      kind: data.kind.present ? data.kind.value : this.kind,
      label: data.label.present ? data.label.value : this.label,
      assetPath: data.assetPath.present ? data.assetPath.value : this.assetPath,
      loadedOk: data.loadedOk.present ? data.loadedOk.value : this.loadedOk,
      loadMs: data.loadMs.present ? data.loadMs.value : this.loadMs,
      meanLatencyMs: data.meanLatencyMs.present
          ? data.meanLatencyMs.value
          : this.meanLatencyMs,
      runCount: data.runCount.present ? data.runCount.value : this.runCount,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ModelRegistryData(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('label: $label, ')
          ..write('assetPath: $assetPath, ')
          ..write('loadedOk: $loadedOk, ')
          ..write('loadMs: $loadMs, ')
          ..write('meanLatencyMs: $meanLatencyMs, ')
          ..write('runCount: $runCount, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    kind,
    label,
    assetPath,
    loadedOk,
    loadMs,
    meanLatencyMs,
    runCount,
    lastError,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ModelRegistryData &&
          other.id == this.id &&
          other.kind == this.kind &&
          other.label == this.label &&
          other.assetPath == this.assetPath &&
          other.loadedOk == this.loadedOk &&
          other.loadMs == this.loadMs &&
          other.meanLatencyMs == this.meanLatencyMs &&
          other.runCount == this.runCount &&
          other.lastError == this.lastError);
}

class ModelRegistryCompanion extends UpdateCompanion<ModelRegistryData> {
  final Value<String> id;
  final Value<String> kind;
  final Value<String> label;
  final Value<String> assetPath;
  final Value<bool> loadedOk;
  final Value<int?> loadMs;
  final Value<double?> meanLatencyMs;
  final Value<int> runCount;
  final Value<String?> lastError;
  final Value<int> rowid;
  const ModelRegistryCompanion({
    this.id = const Value.absent(),
    this.kind = const Value.absent(),
    this.label = const Value.absent(),
    this.assetPath = const Value.absent(),
    this.loadedOk = const Value.absent(),
    this.loadMs = const Value.absent(),
    this.meanLatencyMs = const Value.absent(),
    this.runCount = const Value.absent(),
    this.lastError = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ModelRegistryCompanion.insert({
    required String id,
    required String kind,
    required String label,
    required String assetPath,
    this.loadedOk = const Value.absent(),
    this.loadMs = const Value.absent(),
    this.meanLatencyMs = const Value.absent(),
    this.runCount = const Value.absent(),
    this.lastError = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       kind = Value(kind),
       label = Value(label),
       assetPath = Value(assetPath);
  static Insertable<ModelRegistryData> custom({
    Expression<String>? id,
    Expression<String>? kind,
    Expression<String>? label,
    Expression<String>? assetPath,
    Expression<bool>? loadedOk,
    Expression<int>? loadMs,
    Expression<double>? meanLatencyMs,
    Expression<int>? runCount,
    Expression<String>? lastError,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (kind != null) 'kind': kind,
      if (label != null) 'label': label,
      if (assetPath != null) 'asset_path': assetPath,
      if (loadedOk != null) 'loaded_ok': loadedOk,
      if (loadMs != null) 'load_ms': loadMs,
      if (meanLatencyMs != null) 'mean_latency_ms': meanLatencyMs,
      if (runCount != null) 'run_count': runCount,
      if (lastError != null) 'last_error': lastError,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ModelRegistryCompanion copyWith({
    Value<String>? id,
    Value<String>? kind,
    Value<String>? label,
    Value<String>? assetPath,
    Value<bool>? loadedOk,
    Value<int?>? loadMs,
    Value<double?>? meanLatencyMs,
    Value<int>? runCount,
    Value<String?>? lastError,
    Value<int>? rowid,
  }) {
    return ModelRegistryCompanion(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      label: label ?? this.label,
      assetPath: assetPath ?? this.assetPath,
      loadedOk: loadedOk ?? this.loadedOk,
      loadMs: loadMs ?? this.loadMs,
      meanLatencyMs: meanLatencyMs ?? this.meanLatencyMs,
      runCount: runCount ?? this.runCount,
      lastError: lastError ?? this.lastError,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (assetPath.present) {
      map['asset_path'] = Variable<String>(assetPath.value);
    }
    if (loadedOk.present) {
      map['loaded_ok'] = Variable<bool>(loadedOk.value);
    }
    if (loadMs.present) {
      map['load_ms'] = Variable<int>(loadMs.value);
    }
    if (meanLatencyMs.present) {
      map['mean_latency_ms'] = Variable<double>(meanLatencyMs.value);
    }
    if (runCount.present) {
      map['run_count'] = Variable<int>(runCount.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ModelRegistryCompanion(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('label: $label, ')
          ..write('assetPath: $assetPath, ')
          ..write('loadedOk: $loadedOk, ')
          ..write('loadMs: $loadMs, ')
          ..write('meanLatencyMs: $meanLatencyMs, ')
          ..write('runCount: $runCount, ')
          ..write('lastError: $lastError, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final String key;
  final String value;
  final int updatedAt;
  const AppSetting({
    required this.key,
    required this.value,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(
      key: Value(key),
      value: Value(value),
      updatedAt: Value(updatedAt),
    );
  }

  factory AppSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  AppSetting copyWith({String? key, String? value, int? updatedAt}) =>
      AppSetting(
        key: key ?? this.key,
        value: value ?? this.value,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.key == this.key &&
          other.value == this.value &&
          other.updatedAt == this.updatedAt);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    required String value,
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value),
       updatedAt = Value(updatedAt);
  static Insertable<AppSetting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $BeatsTable beats = $BeatsTable(this);
  late final $StoresTable stores = $StoresTable(this);
  late final $SkusTable skus = $SkusTable(this);
  late final $SkuEmbeddingsTable skuEmbeddings = $SkuEmbeddingsTable(this);
  late final $PlanogramEntriesTable planogramEntries = $PlanogramEntriesTable(
    this,
  );
  late final $VisitsTable visits = $VisitsTable(this);
  late final $VisitPhotosTable visitPhotos = $VisitPhotosTable(this);
  late final $DetectionsTable detections = $DetectionsTable(this);
  late final $ShelfFactsTable shelfFacts = $ShelfFactsTable(this);
  late final $OrderLinesTable orderLines = $OrderLinesTable(this);
  late final $OverrideEventsTable overrideEvents = $OverrideEventsTable(this);
  late final $ExportBatchesTable exportBatches = $ExportBatchesTable(this);
  late final $ModelRegistryTable modelRegistry = $ModelRegistryTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    beats,
    stores,
    skus,
    skuEmbeddings,
    planogramEntries,
    visits,
    visitPhotos,
    detections,
    shelfFacts,
    orderLines,
    overrideEvents,
    exportBatches,
    modelRegistry,
    appSettings,
  ];
}

typedef $$BeatsTableCreateCompanionBuilder =
    BeatsCompanion Function({
      required String id,
      required String code,
      required String name,
      Value<String?> repName,
      required int createdAt,
      Value<int> rowid,
    });
typedef $$BeatsTableUpdateCompanionBuilder =
    BeatsCompanion Function({
      Value<String> id,
      Value<String> code,
      Value<String> name,
      Value<String?> repName,
      Value<int> createdAt,
      Value<int> rowid,
    });

final class $$BeatsTableReferences
    extends BaseReferences<_$AppDatabase, $BeatsTable, Beat> {
  $$BeatsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$StoresTable, List<Store>> _storesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.stores,
    aliasName: 'beats__id__stores__beat_id',
  );

  $$StoresTableProcessedTableManager get storesRefs {
    final manager = $$StoresTableTableManager(
      $_db,
      $_db.stores,
    ).filter((f) => f.beatId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_storesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$VisitsTable, List<Visit>> _visitsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.visits,
    aliasName: 'beats__id__visits__beat_id',
  );

  $$VisitsTableProcessedTableManager get visitsRefs {
    final manager = $$VisitsTableTableManager(
      $_db,
      $_db.visits,
    ).filter((f) => f.beatId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_visitsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ExportBatchesTable, List<ExportBatche>>
  _exportBatchesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.exportBatches,
    aliasName: 'beats__id__export_batches__beat_id',
  );

  $$ExportBatchesTableProcessedTableManager get exportBatchesRefs {
    final manager = $$ExportBatchesTableTableManager(
      $_db,
      $_db.exportBatches,
    ).filter((f) => f.beatId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_exportBatchesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$BeatsTableFilterComposer extends Composer<_$AppDatabase, $BeatsTable> {
  $$BeatsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get repName => $composableBuilder(
    column: $table.repName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> storesRefs(
    Expression<bool> Function($$StoresTableFilterComposer f) f,
  ) {
    final $$StoresTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.stores,
      getReferencedColumn: (t) => t.beatId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StoresTableFilterComposer(
            $db: $db,
            $table: $db.stores,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> visitsRefs(
    Expression<bool> Function($$VisitsTableFilterComposer f) f,
  ) {
    final $$VisitsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.visits,
      getReferencedColumn: (t) => t.beatId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VisitsTableFilterComposer(
            $db: $db,
            $table: $db.visits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> exportBatchesRefs(
    Expression<bool> Function($$ExportBatchesTableFilterComposer f) f,
  ) {
    final $$ExportBatchesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exportBatches,
      getReferencedColumn: (t) => t.beatId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExportBatchesTableFilterComposer(
            $db: $db,
            $table: $db.exportBatches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BeatsTableOrderingComposer
    extends Composer<_$AppDatabase, $BeatsTable> {
  $$BeatsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get repName => $composableBuilder(
    column: $table.repName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BeatsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BeatsTable> {
  $$BeatsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get repName =>
      $composableBuilder(column: $table.repName, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> storesRefs<T extends Object>(
    Expression<T> Function($$StoresTableAnnotationComposer a) f,
  ) {
    final $$StoresTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.stores,
      getReferencedColumn: (t) => t.beatId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StoresTableAnnotationComposer(
            $db: $db,
            $table: $db.stores,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> visitsRefs<T extends Object>(
    Expression<T> Function($$VisitsTableAnnotationComposer a) f,
  ) {
    final $$VisitsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.visits,
      getReferencedColumn: (t) => t.beatId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VisitsTableAnnotationComposer(
            $db: $db,
            $table: $db.visits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> exportBatchesRefs<T extends Object>(
    Expression<T> Function($$ExportBatchesTableAnnotationComposer a) f,
  ) {
    final $$ExportBatchesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exportBatches,
      getReferencedColumn: (t) => t.beatId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExportBatchesTableAnnotationComposer(
            $db: $db,
            $table: $db.exportBatches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BeatsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BeatsTable,
          Beat,
          $$BeatsTableFilterComposer,
          $$BeatsTableOrderingComposer,
          $$BeatsTableAnnotationComposer,
          $$BeatsTableCreateCompanionBuilder,
          $$BeatsTableUpdateCompanionBuilder,
          (Beat, $$BeatsTableReferences),
          Beat,
          PrefetchHooks Function({
            bool storesRefs,
            bool visitsRefs,
            bool exportBatchesRefs,
          })
        > {
  $$BeatsTableTableManager(_$AppDatabase db, $BeatsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BeatsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BeatsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BeatsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> code = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> repName = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BeatsCompanion(
                id: id,
                code: code,
                name: name,
                repName: repName,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String code,
                required String name,
                Value<String?> repName = const Value.absent(),
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => BeatsCompanion.insert(
                id: id,
                code: code,
                name: name,
                repName: repName,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BeatsTable, Beat>(table),
                  $$BeatsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                storesRefs = false,
                visitsRefs = false,
                exportBatchesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (storesRefs) db.stores,
                    if (visitsRefs) db.visits,
                    if (exportBatchesRefs) db.exportBatches,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (storesRefs)
                        await $_getPrefetchedData<Beat, $BeatsTable, Store>(
                          currentTable: table,
                          referencedTable: $$BeatsTableReferences
                              ._storesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BeatsTableReferences(db, table, p0).storesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.beatId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (visitsRefs)
                        await $_getPrefetchedData<Beat, $BeatsTable, Visit>(
                          currentTable: table,
                          referencedTable: $$BeatsTableReferences
                              ._visitsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BeatsTableReferences(db, table, p0).visitsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.beatId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (exportBatchesRefs)
                        await $_getPrefetchedData<
                          Beat,
                          $BeatsTable,
                          ExportBatche
                        >(
                          currentTable: table,
                          referencedTable: $$BeatsTableReferences
                              ._exportBatchesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BeatsTableReferences(
                                db,
                                table,
                                p0,
                              ).exportBatchesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.beatId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$BeatsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BeatsTable,
      Beat,
      $$BeatsTableFilterComposer,
      $$BeatsTableOrderingComposer,
      $$BeatsTableAnnotationComposer,
      $$BeatsTableCreateCompanionBuilder,
      $$BeatsTableUpdateCompanionBuilder,
      (Beat, $$BeatsTableReferences),
      Beat,
      PrefetchHooks Function({
        bool storesRefs,
        bool visitsRefs,
        bool exportBatchesRefs,
      })
    >;
typedef $$StoresTableCreateCompanionBuilder =
    StoresCompanion Function({
      required String id,
      required String code,
      required String name,
      required String beatId,
      Value<String?> address,
      Value<String?> ownerName,
      Value<String?> phone,
      Value<double?> lat,
      Value<double?> lng,
      Value<int> sequence,
      required int createdAt,
      Value<int> rowid,
    });
typedef $$StoresTableUpdateCompanionBuilder =
    StoresCompanion Function({
      Value<String> id,
      Value<String> code,
      Value<String> name,
      Value<String> beatId,
      Value<String?> address,
      Value<String?> ownerName,
      Value<String?> phone,
      Value<double?> lat,
      Value<double?> lng,
      Value<int> sequence,
      Value<int> createdAt,
      Value<int> rowid,
    });

final class $$StoresTableReferences
    extends BaseReferences<_$AppDatabase, $StoresTable, Store> {
  $$StoresTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $BeatsTable _beatIdTable(_$AppDatabase db) =>
      db.beats.createAlias('stores__beat_id__beats__id');

  $$BeatsTableProcessedTableManager get beatId {
    final $_column = $_itemColumn<String>('beat_id')!;

    final manager = $$BeatsTableTableManager(
      $_db,
      $_db.beats,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_beatIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$PlanogramEntriesTable, List<PlanogramEntry>>
  _planogramEntriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.planogramEntries,
    aliasName: 'stores__id__planogram_entries__store_id',
  );

  $$PlanogramEntriesTableProcessedTableManager get planogramEntriesRefs {
    final manager = $$PlanogramEntriesTableTableManager(
      $_db,
      $_db.planogramEntries,
    ).filter((f) => f.storeId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _planogramEntriesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$VisitsTable, List<Visit>> _visitsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.visits,
    aliasName: 'stores__id__visits__store_id',
  );

  $$VisitsTableProcessedTableManager get visitsRefs {
    final manager = $$VisitsTableTableManager(
      $_db,
      $_db.visits,
    ).filter((f) => f.storeId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_visitsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$StoresTableFilterComposer
    extends Composer<_$AppDatabase, $StoresTable> {
  $$StoresTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerName => $composableBuilder(
    column: $table.ownerName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lng => $composableBuilder(
    column: $table.lng,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sequence => $composableBuilder(
    column: $table.sequence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$BeatsTableFilterComposer get beatId {
    final $$BeatsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.beatId,
      referencedTable: $db.beats,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BeatsTableFilterComposer(
            $db: $db,
            $table: $db.beats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> planogramEntriesRefs(
    Expression<bool> Function($$PlanogramEntriesTableFilterComposer f) f,
  ) {
    final $$PlanogramEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.planogramEntries,
      getReferencedColumn: (t) => t.storeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlanogramEntriesTableFilterComposer(
            $db: $db,
            $table: $db.planogramEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> visitsRefs(
    Expression<bool> Function($$VisitsTableFilterComposer f) f,
  ) {
    final $$VisitsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.visits,
      getReferencedColumn: (t) => t.storeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VisitsTableFilterComposer(
            $db: $db,
            $table: $db.visits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$StoresTableOrderingComposer
    extends Composer<_$AppDatabase, $StoresTable> {
  $$StoresTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerName => $composableBuilder(
    column: $table.ownerName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lng => $composableBuilder(
    column: $table.lng,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sequence => $composableBuilder(
    column: $table.sequence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$BeatsTableOrderingComposer get beatId {
    final $$BeatsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.beatId,
      referencedTable: $db.beats,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BeatsTableOrderingComposer(
            $db: $db,
            $table: $db.beats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StoresTableAnnotationComposer
    extends Composer<_$AppDatabase, $StoresTable> {
  $$StoresTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get ownerName =>
      $composableBuilder(column: $table.ownerName, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<double> get lat =>
      $composableBuilder(column: $table.lat, builder: (column) => column);

  GeneratedColumn<double> get lng =>
      $composableBuilder(column: $table.lng, builder: (column) => column);

  GeneratedColumn<int> get sequence =>
      $composableBuilder(column: $table.sequence, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$BeatsTableAnnotationComposer get beatId {
    final $$BeatsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.beatId,
      referencedTable: $db.beats,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BeatsTableAnnotationComposer(
            $db: $db,
            $table: $db.beats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> planogramEntriesRefs<T extends Object>(
    Expression<T> Function($$PlanogramEntriesTableAnnotationComposer a) f,
  ) {
    final $$PlanogramEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.planogramEntries,
      getReferencedColumn: (t) => t.storeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlanogramEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.planogramEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> visitsRefs<T extends Object>(
    Expression<T> Function($$VisitsTableAnnotationComposer a) f,
  ) {
    final $$VisitsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.visits,
      getReferencedColumn: (t) => t.storeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VisitsTableAnnotationComposer(
            $db: $db,
            $table: $db.visits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$StoresTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StoresTable,
          Store,
          $$StoresTableFilterComposer,
          $$StoresTableOrderingComposer,
          $$StoresTableAnnotationComposer,
          $$StoresTableCreateCompanionBuilder,
          $$StoresTableUpdateCompanionBuilder,
          (Store, $$StoresTableReferences),
          Store,
          PrefetchHooks Function({
            bool beatId,
            bool planogramEntriesRefs,
            bool visitsRefs,
          })
        > {
  $$StoresTableTableManager(_$AppDatabase db, $StoresTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StoresTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StoresTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StoresTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> code = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> beatId = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> ownerName = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<double?> lat = const Value.absent(),
                Value<double?> lng = const Value.absent(),
                Value<int> sequence = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StoresCompanion(
                id: id,
                code: code,
                name: name,
                beatId: beatId,
                address: address,
                ownerName: ownerName,
                phone: phone,
                lat: lat,
                lng: lng,
                sequence: sequence,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String code,
                required String name,
                required String beatId,
                Value<String?> address = const Value.absent(),
                Value<String?> ownerName = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<double?> lat = const Value.absent(),
                Value<double?> lng = const Value.absent(),
                Value<int> sequence = const Value.absent(),
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => StoresCompanion.insert(
                id: id,
                code: code,
                name: name,
                beatId: beatId,
                address: address,
                ownerName: ownerName,
                phone: phone,
                lat: lat,
                lng: lng,
                sequence: sequence,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$StoresTable, Store>(table),
                  $$StoresTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                beatId = false,
                planogramEntriesRefs = false,
                visitsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (planogramEntriesRefs) db.planogramEntries,
                    if (visitsRefs) db.visits,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (beatId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.beatId,
                                    referencedTable: $$StoresTableReferences
                                        ._beatIdTable(db),
                                    referencedColumn: $$StoresTableReferences
                                        ._beatIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (planogramEntriesRefs)
                        await $_getPrefetchedData<
                          Store,
                          $StoresTable,
                          PlanogramEntry
                        >(
                          currentTable: table,
                          referencedTable: $$StoresTableReferences
                              ._planogramEntriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$StoresTableReferences(
                                db,
                                table,
                                p0,
                              ).planogramEntriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.storeId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (visitsRefs)
                        await $_getPrefetchedData<Store, $StoresTable, Visit>(
                          currentTable: table,
                          referencedTable: $$StoresTableReferences
                              ._visitsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$StoresTableReferences(db, table, p0).visitsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.storeId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$StoresTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StoresTable,
      Store,
      $$StoresTableFilterComposer,
      $$StoresTableOrderingComposer,
      $$StoresTableAnnotationComposer,
      $$StoresTableCreateCompanionBuilder,
      $$StoresTableUpdateCompanionBuilder,
      (Store, $$StoresTableReferences),
      Store,
      PrefetchHooks Function({
        bool beatId,
        bool planogramEntriesRefs,
        bool visitsRefs,
      })
    >;
typedef $$SkusTableCreateCompanionBuilder =
    SkusCompanion Function({
      required String id,
      required String code,
      required String name,
      Value<String?> brand,
      Value<String?> category,
      Value<double?> grammageValue,
      Value<String?> grammageUnit,
      Value<String?> variant,
      Value<int> mrpPaise,
      Value<int> caseSize,
      Value<bool> isEnrolled,
      Value<bool> isActive,
      required int createdAt,
      Value<int> rowid,
    });
typedef $$SkusTableUpdateCompanionBuilder =
    SkusCompanion Function({
      Value<String> id,
      Value<String> code,
      Value<String> name,
      Value<String?> brand,
      Value<String?> category,
      Value<double?> grammageValue,
      Value<String?> grammageUnit,
      Value<String?> variant,
      Value<int> mrpPaise,
      Value<int> caseSize,
      Value<bool> isEnrolled,
      Value<bool> isActive,
      Value<int> createdAt,
      Value<int> rowid,
    });

final class $$SkusTableReferences
    extends BaseReferences<_$AppDatabase, $SkusTable, SkusData> {
  $$SkusTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SkuEmbeddingsTable, List<SkuEmbedding>>
  _skuEmbeddingsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.skuEmbeddings,
    aliasName: 'skus__id__sku_embeddings__sku_id',
  );

  $$SkuEmbeddingsTableProcessedTableManager get skuEmbeddingsRefs {
    final manager = $$SkuEmbeddingsTableTableManager(
      $_db,
      $_db.skuEmbeddings,
    ).filter((f) => f.skuId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_skuEmbeddingsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PlanogramEntriesTable, List<PlanogramEntry>>
  _planogramEntriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.planogramEntries,
    aliasName: 'skus__id__planogram_entries__sku_id',
  );

  $$PlanogramEntriesTableProcessedTableManager get planogramEntriesRefs {
    final manager = $$PlanogramEntriesTableTableManager(
      $_db,
      $_db.planogramEntries,
    ).filter((f) => f.skuId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _planogramEntriesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$DetectionsTable, List<Detection>>
  _detectionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.detections,
    aliasName: 'skus__id__detections__sku_id',
  );

  $$DetectionsTableProcessedTableManager get detectionsRefs {
    final manager = $$DetectionsTableTableManager(
      $_db,
      $_db.detections,
    ).filter((f) => f.skuId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_detectionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ShelfFactsTable, List<ShelfFact>>
  _shelfFactsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.shelfFacts,
    aliasName: 'skus__id__shelf_facts__sku_id',
  );

  $$ShelfFactsTableProcessedTableManager get shelfFactsRefs {
    final manager = $$ShelfFactsTableTableManager(
      $_db,
      $_db.shelfFacts,
    ).filter((f) => f.skuId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_shelfFactsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$OrderLinesTable, List<OrderLine>>
  _orderLinesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.orderLines,
    aliasName: 'skus__id__order_lines__sku_id',
  );

  $$OrderLinesTableProcessedTableManager get orderLinesRefs {
    final manager = $$OrderLinesTableTableManager(
      $_db,
      $_db.orderLines,
    ).filter((f) => f.skuId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_orderLinesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SkusTableFilterComposer extends Composer<_$AppDatabase, $SkusTable> {
  $$SkusTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get grammageValue => $composableBuilder(
    column: $table.grammageValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get grammageUnit => $composableBuilder(
    column: $table.grammageUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get variant => $composableBuilder(
    column: $table.variant,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get mrpPaise => $composableBuilder(
    column: $table.mrpPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get caseSize => $composableBuilder(
    column: $table.caseSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isEnrolled => $composableBuilder(
    column: $table.isEnrolled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> skuEmbeddingsRefs(
    Expression<bool> Function($$SkuEmbeddingsTableFilterComposer f) f,
  ) {
    final $$SkuEmbeddingsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.skuEmbeddings,
      getReferencedColumn: (t) => t.skuId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SkuEmbeddingsTableFilterComposer(
            $db: $db,
            $table: $db.skuEmbeddings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> planogramEntriesRefs(
    Expression<bool> Function($$PlanogramEntriesTableFilterComposer f) f,
  ) {
    final $$PlanogramEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.planogramEntries,
      getReferencedColumn: (t) => t.skuId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlanogramEntriesTableFilterComposer(
            $db: $db,
            $table: $db.planogramEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> detectionsRefs(
    Expression<bool> Function($$DetectionsTableFilterComposer f) f,
  ) {
    final $$DetectionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.detections,
      getReferencedColumn: (t) => t.skuId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DetectionsTableFilterComposer(
            $db: $db,
            $table: $db.detections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> shelfFactsRefs(
    Expression<bool> Function($$ShelfFactsTableFilterComposer f) f,
  ) {
    final $$ShelfFactsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.shelfFacts,
      getReferencedColumn: (t) => t.skuId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShelfFactsTableFilterComposer(
            $db: $db,
            $table: $db.shelfFacts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> orderLinesRefs(
    Expression<bool> Function($$OrderLinesTableFilterComposer f) f,
  ) {
    final $$OrderLinesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.orderLines,
      getReferencedColumn: (t) => t.skuId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrderLinesTableFilterComposer(
            $db: $db,
            $table: $db.orderLines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SkusTableOrderingComposer extends Composer<_$AppDatabase, $SkusTable> {
  $$SkusTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get grammageValue => $composableBuilder(
    column: $table.grammageValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get grammageUnit => $composableBuilder(
    column: $table.grammageUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get variant => $composableBuilder(
    column: $table.variant,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get mrpPaise => $composableBuilder(
    column: $table.mrpPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get caseSize => $composableBuilder(
    column: $table.caseSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isEnrolled => $composableBuilder(
    column: $table.isEnrolled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SkusTableAnnotationComposer
    extends Composer<_$AppDatabase, $SkusTable> {
  $$SkusTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get brand =>
      $composableBuilder(column: $table.brand, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<double> get grammageValue => $composableBuilder(
    column: $table.grammageValue,
    builder: (column) => column,
  );

  GeneratedColumn<String> get grammageUnit => $composableBuilder(
    column: $table.grammageUnit,
    builder: (column) => column,
  );

  GeneratedColumn<String> get variant =>
      $composableBuilder(column: $table.variant, builder: (column) => column);

  GeneratedColumn<int> get mrpPaise =>
      $composableBuilder(column: $table.mrpPaise, builder: (column) => column);

  GeneratedColumn<int> get caseSize =>
      $composableBuilder(column: $table.caseSize, builder: (column) => column);

  GeneratedColumn<bool> get isEnrolled => $composableBuilder(
    column: $table.isEnrolled,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> skuEmbeddingsRefs<T extends Object>(
    Expression<T> Function($$SkuEmbeddingsTableAnnotationComposer a) f,
  ) {
    final $$SkuEmbeddingsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.skuEmbeddings,
      getReferencedColumn: (t) => t.skuId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SkuEmbeddingsTableAnnotationComposer(
            $db: $db,
            $table: $db.skuEmbeddings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> planogramEntriesRefs<T extends Object>(
    Expression<T> Function($$PlanogramEntriesTableAnnotationComposer a) f,
  ) {
    final $$PlanogramEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.planogramEntries,
      getReferencedColumn: (t) => t.skuId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlanogramEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.planogramEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> detectionsRefs<T extends Object>(
    Expression<T> Function($$DetectionsTableAnnotationComposer a) f,
  ) {
    final $$DetectionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.detections,
      getReferencedColumn: (t) => t.skuId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DetectionsTableAnnotationComposer(
            $db: $db,
            $table: $db.detections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> shelfFactsRefs<T extends Object>(
    Expression<T> Function($$ShelfFactsTableAnnotationComposer a) f,
  ) {
    final $$ShelfFactsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.shelfFacts,
      getReferencedColumn: (t) => t.skuId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShelfFactsTableAnnotationComposer(
            $db: $db,
            $table: $db.shelfFacts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> orderLinesRefs<T extends Object>(
    Expression<T> Function($$OrderLinesTableAnnotationComposer a) f,
  ) {
    final $$OrderLinesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.orderLines,
      getReferencedColumn: (t) => t.skuId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrderLinesTableAnnotationComposer(
            $db: $db,
            $table: $db.orderLines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SkusTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SkusTable,
          SkusData,
          $$SkusTableFilterComposer,
          $$SkusTableOrderingComposer,
          $$SkusTableAnnotationComposer,
          $$SkusTableCreateCompanionBuilder,
          $$SkusTableUpdateCompanionBuilder,
          (SkusData, $$SkusTableReferences),
          SkusData,
          PrefetchHooks Function({
            bool skuEmbeddingsRefs,
            bool planogramEntriesRefs,
            bool detectionsRefs,
            bool shelfFactsRefs,
            bool orderLinesRefs,
          })
        > {
  $$SkusTableTableManager(_$AppDatabase db, $SkusTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SkusTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SkusTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SkusTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> code = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> brand = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<double?> grammageValue = const Value.absent(),
                Value<String?> grammageUnit = const Value.absent(),
                Value<String?> variant = const Value.absent(),
                Value<int> mrpPaise = const Value.absent(),
                Value<int> caseSize = const Value.absent(),
                Value<bool> isEnrolled = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SkusCompanion(
                id: id,
                code: code,
                name: name,
                brand: brand,
                category: category,
                grammageValue: grammageValue,
                grammageUnit: grammageUnit,
                variant: variant,
                mrpPaise: mrpPaise,
                caseSize: caseSize,
                isEnrolled: isEnrolled,
                isActive: isActive,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String code,
                required String name,
                Value<String?> brand = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<double?> grammageValue = const Value.absent(),
                Value<String?> grammageUnit = const Value.absent(),
                Value<String?> variant = const Value.absent(),
                Value<int> mrpPaise = const Value.absent(),
                Value<int> caseSize = const Value.absent(),
                Value<bool> isEnrolled = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => SkusCompanion.insert(
                id: id,
                code: code,
                name: name,
                brand: brand,
                category: category,
                grammageValue: grammageValue,
                grammageUnit: grammageUnit,
                variant: variant,
                mrpPaise: mrpPaise,
                caseSize: caseSize,
                isEnrolled: isEnrolled,
                isActive: isActive,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SkusTable, SkusData>(table),
                  $$SkusTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                skuEmbeddingsRefs = false,
                planogramEntriesRefs = false,
                detectionsRefs = false,
                shelfFactsRefs = false,
                orderLinesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (skuEmbeddingsRefs) db.skuEmbeddings,
                    if (planogramEntriesRefs) db.planogramEntries,
                    if (detectionsRefs) db.detections,
                    if (shelfFactsRefs) db.shelfFacts,
                    if (orderLinesRefs) db.orderLines,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (skuEmbeddingsRefs)
                        await $_getPrefetchedData<
                          SkusData,
                          $SkusTable,
                          SkuEmbedding
                        >(
                          currentTable: table,
                          referencedTable: $$SkusTableReferences
                              ._skuEmbeddingsRefsTable(db),
                          managerFromTypedResult: (p0) => $$SkusTableReferences(
                            db,
                            table,
                            p0,
                          ).skuEmbeddingsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.skuId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (planogramEntriesRefs)
                        await $_getPrefetchedData<
                          SkusData,
                          $SkusTable,
                          PlanogramEntry
                        >(
                          currentTable: table,
                          referencedTable: $$SkusTableReferences
                              ._planogramEntriesRefsTable(db),
                          managerFromTypedResult: (p0) => $$SkusTableReferences(
                            db,
                            table,
                            p0,
                          ).planogramEntriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.skuId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (detectionsRefs)
                        await $_getPrefetchedData<
                          SkusData,
                          $SkusTable,
                          Detection
                        >(
                          currentTable: table,
                          referencedTable: $$SkusTableReferences
                              ._detectionsRefsTable(db),
                          managerFromTypedResult: (p0) => $$SkusTableReferences(
                            db,
                            table,
                            p0,
                          ).detectionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.skuId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (shelfFactsRefs)
                        await $_getPrefetchedData<
                          SkusData,
                          $SkusTable,
                          ShelfFact
                        >(
                          currentTable: table,
                          referencedTable: $$SkusTableReferences
                              ._shelfFactsRefsTable(db),
                          managerFromTypedResult: (p0) => $$SkusTableReferences(
                            db,
                            table,
                            p0,
                          ).shelfFactsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.skuId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (orderLinesRefs)
                        await $_getPrefetchedData<
                          SkusData,
                          $SkusTable,
                          OrderLine
                        >(
                          currentTable: table,
                          referencedTable: $$SkusTableReferences
                              ._orderLinesRefsTable(db),
                          managerFromTypedResult: (p0) => $$SkusTableReferences(
                            db,
                            table,
                            p0,
                          ).orderLinesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.skuId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$SkusTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SkusTable,
      SkusData,
      $$SkusTableFilterComposer,
      $$SkusTableOrderingComposer,
      $$SkusTableAnnotationComposer,
      $$SkusTableCreateCompanionBuilder,
      $$SkusTableUpdateCompanionBuilder,
      (SkusData, $$SkusTableReferences),
      SkusData,
      PrefetchHooks Function({
        bool skuEmbeddingsRefs,
        bool planogramEntriesRefs,
        bool detectionsRefs,
        bool shelfFactsRefs,
        bool orderLinesRefs,
      })
    >;
typedef $$SkuEmbeddingsTableCreateCompanionBuilder =
    SkuEmbeddingsCompanion Function({
      required String id,
      required String skuId,
      required Uint8List vector,
      Value<String?> sourceImagePath,
      Value<String?> captureContext,
      Value<bool> isActive,
      required int createdAt,
      Value<int> rowid,
    });
typedef $$SkuEmbeddingsTableUpdateCompanionBuilder =
    SkuEmbeddingsCompanion Function({
      Value<String> id,
      Value<String> skuId,
      Value<Uint8List> vector,
      Value<String?> sourceImagePath,
      Value<String?> captureContext,
      Value<bool> isActive,
      Value<int> createdAt,
      Value<int> rowid,
    });

final class $$SkuEmbeddingsTableReferences
    extends BaseReferences<_$AppDatabase, $SkuEmbeddingsTable, SkuEmbedding> {
  $$SkuEmbeddingsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SkusTable _skuIdTable(_$AppDatabase db) =>
      db.skus.createAlias('sku_embeddings__sku_id__skus__id');

  $$SkusTableProcessedTableManager get skuId {
    final $_column = $_itemColumn<String>('sku_id')!;

    final manager = $$SkusTableTableManager(
      $_db,
      $_db.skus,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_skuIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SkuEmbeddingsTableFilterComposer
    extends Composer<_$AppDatabase, $SkuEmbeddingsTable> {
  $$SkuEmbeddingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get vector => $composableBuilder(
    column: $table.vector,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceImagePath => $composableBuilder(
    column: $table.sourceImagePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get captureContext => $composableBuilder(
    column: $table.captureContext,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$SkusTableFilterComposer get skuId {
    final $$SkusTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.skuId,
      referencedTable: $db.skus,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SkusTableFilterComposer(
            $db: $db,
            $table: $db.skus,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SkuEmbeddingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SkuEmbeddingsTable> {
  $$SkuEmbeddingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get vector => $composableBuilder(
    column: $table.vector,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceImagePath => $composableBuilder(
    column: $table.sourceImagePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get captureContext => $composableBuilder(
    column: $table.captureContext,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$SkusTableOrderingComposer get skuId {
    final $$SkusTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.skuId,
      referencedTable: $db.skus,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SkusTableOrderingComposer(
            $db: $db,
            $table: $db.skus,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SkuEmbeddingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SkuEmbeddingsTable> {
  $$SkuEmbeddingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<Uint8List> get vector =>
      $composableBuilder(column: $table.vector, builder: (column) => column);

  GeneratedColumn<String> get sourceImagePath => $composableBuilder(
    column: $table.sourceImagePath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get captureContext => $composableBuilder(
    column: $table.captureContext,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$SkusTableAnnotationComposer get skuId {
    final $$SkusTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.skuId,
      referencedTable: $db.skus,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SkusTableAnnotationComposer(
            $db: $db,
            $table: $db.skus,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SkuEmbeddingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SkuEmbeddingsTable,
          SkuEmbedding,
          $$SkuEmbeddingsTableFilterComposer,
          $$SkuEmbeddingsTableOrderingComposer,
          $$SkuEmbeddingsTableAnnotationComposer,
          $$SkuEmbeddingsTableCreateCompanionBuilder,
          $$SkuEmbeddingsTableUpdateCompanionBuilder,
          (SkuEmbedding, $$SkuEmbeddingsTableReferences),
          SkuEmbedding,
          PrefetchHooks Function({bool skuId})
        > {
  $$SkuEmbeddingsTableTableManager(_$AppDatabase db, $SkuEmbeddingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SkuEmbeddingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SkuEmbeddingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SkuEmbeddingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> skuId = const Value.absent(),
                Value<Uint8List> vector = const Value.absent(),
                Value<String?> sourceImagePath = const Value.absent(),
                Value<String?> captureContext = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SkuEmbeddingsCompanion(
                id: id,
                skuId: skuId,
                vector: vector,
                sourceImagePath: sourceImagePath,
                captureContext: captureContext,
                isActive: isActive,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String skuId,
                required Uint8List vector,
                Value<String?> sourceImagePath = const Value.absent(),
                Value<String?> captureContext = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => SkuEmbeddingsCompanion.insert(
                id: id,
                skuId: skuId,
                vector: vector,
                sourceImagePath: sourceImagePath,
                captureContext: captureContext,
                isActive: isActive,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SkuEmbeddingsTable, SkuEmbedding>(table),
                  $$SkuEmbeddingsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({skuId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (skuId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.skuId,
                                referencedTable: $$SkuEmbeddingsTableReferences
                                    ._skuIdTable(db),
                                referencedColumn: $$SkuEmbeddingsTableReferences
                                    ._skuIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SkuEmbeddingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SkuEmbeddingsTable,
      SkuEmbedding,
      $$SkuEmbeddingsTableFilterComposer,
      $$SkuEmbeddingsTableOrderingComposer,
      $$SkuEmbeddingsTableAnnotationComposer,
      $$SkuEmbeddingsTableCreateCompanionBuilder,
      $$SkuEmbeddingsTableUpdateCompanionBuilder,
      (SkuEmbedding, $$SkuEmbeddingsTableReferences),
      SkuEmbedding,
      PrefetchHooks Function({bool skuId})
    >;
typedef $$PlanogramEntriesTableCreateCompanionBuilder =
    PlanogramEntriesCompanion Function({
      required String id,
      required String storeId,
      required String skuId,
      required int targetFacings,
      Value<int?> shelfRow,
      required String source,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $$PlanogramEntriesTableUpdateCompanionBuilder =
    PlanogramEntriesCompanion Function({
      Value<String> id,
      Value<String> storeId,
      Value<String> skuId,
      Value<int> targetFacings,
      Value<int?> shelfRow,
      Value<String> source,
      Value<int> updatedAt,
      Value<int> rowid,
    });

final class $$PlanogramEntriesTableReferences
    extends
        BaseReferences<_$AppDatabase, $PlanogramEntriesTable, PlanogramEntry> {
  $$PlanogramEntriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $StoresTable _storeIdTable(_$AppDatabase db) =>
      db.stores.createAlias('planogram_entries__store_id__stores__id');

  $$StoresTableProcessedTableManager get storeId {
    final $_column = $_itemColumn<String>('store_id')!;

    final manager = $$StoresTableTableManager(
      $_db,
      $_db.stores,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_storeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $SkusTable _skuIdTable(_$AppDatabase db) =>
      db.skus.createAlias('planogram_entries__sku_id__skus__id');

  $$SkusTableProcessedTableManager get skuId {
    final $_column = $_itemColumn<String>('sku_id')!;

    final manager = $$SkusTableTableManager(
      $_db,
      $_db.skus,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_skuIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PlanogramEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $PlanogramEntriesTable> {
  $$PlanogramEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetFacings => $composableBuilder(
    column: $table.targetFacings,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get shelfRow => $composableBuilder(
    column: $table.shelfRow,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$StoresTableFilterComposer get storeId {
    final $$StoresTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.storeId,
      referencedTable: $db.stores,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StoresTableFilterComposer(
            $db: $db,
            $table: $db.stores,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SkusTableFilterComposer get skuId {
    final $$SkusTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.skuId,
      referencedTable: $db.skus,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SkusTableFilterComposer(
            $db: $db,
            $table: $db.skus,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlanogramEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $PlanogramEntriesTable> {
  $$PlanogramEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetFacings => $composableBuilder(
    column: $table.targetFacings,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get shelfRow => $composableBuilder(
    column: $table.shelfRow,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$StoresTableOrderingComposer get storeId {
    final $$StoresTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.storeId,
      referencedTable: $db.stores,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StoresTableOrderingComposer(
            $db: $db,
            $table: $db.stores,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SkusTableOrderingComposer get skuId {
    final $$SkusTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.skuId,
      referencedTable: $db.skus,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SkusTableOrderingComposer(
            $db: $db,
            $table: $db.skus,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlanogramEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlanogramEntriesTable> {
  $$PlanogramEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get targetFacings => $composableBuilder(
    column: $table.targetFacings,
    builder: (column) => column,
  );

  GeneratedColumn<int> get shelfRow =>
      $composableBuilder(column: $table.shelfRow, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$StoresTableAnnotationComposer get storeId {
    final $$StoresTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.storeId,
      referencedTable: $db.stores,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StoresTableAnnotationComposer(
            $db: $db,
            $table: $db.stores,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SkusTableAnnotationComposer get skuId {
    final $$SkusTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.skuId,
      referencedTable: $db.skus,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SkusTableAnnotationComposer(
            $db: $db,
            $table: $db.skus,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlanogramEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlanogramEntriesTable,
          PlanogramEntry,
          $$PlanogramEntriesTableFilterComposer,
          $$PlanogramEntriesTableOrderingComposer,
          $$PlanogramEntriesTableAnnotationComposer,
          $$PlanogramEntriesTableCreateCompanionBuilder,
          $$PlanogramEntriesTableUpdateCompanionBuilder,
          (PlanogramEntry, $$PlanogramEntriesTableReferences),
          PlanogramEntry,
          PrefetchHooks Function({bool storeId, bool skuId})
        > {
  $$PlanogramEntriesTableTableManager(
    _$AppDatabase db,
    $PlanogramEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlanogramEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlanogramEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlanogramEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> storeId = const Value.absent(),
                Value<String> skuId = const Value.absent(),
                Value<int> targetFacings = const Value.absent(),
                Value<int?> shelfRow = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlanogramEntriesCompanion(
                id: id,
                storeId: storeId,
                skuId: skuId,
                targetFacings: targetFacings,
                shelfRow: shelfRow,
                source: source,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String storeId,
                required String skuId,
                required int targetFacings,
                Value<int?> shelfRow = const Value.absent(),
                required String source,
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => PlanogramEntriesCompanion.insert(
                id: id,
                storeId: storeId,
                skuId: skuId,
                targetFacings: targetFacings,
                shelfRow: shelfRow,
                source: source,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PlanogramEntriesTable, PlanogramEntry>(table),
                  $$PlanogramEntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({storeId = false, skuId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (storeId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.storeId,
                                referencedTable:
                                    $$PlanogramEntriesTableReferences
                                        ._storeIdTable(db),
                                referencedColumn:
                                    $$PlanogramEntriesTableReferences
                                        ._storeIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (skuId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.skuId,
                                referencedTable:
                                    $$PlanogramEntriesTableReferences
                                        ._skuIdTable(db),
                                referencedColumn:
                                    $$PlanogramEntriesTableReferences
                                        ._skuIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PlanogramEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlanogramEntriesTable,
      PlanogramEntry,
      $$PlanogramEntriesTableFilterComposer,
      $$PlanogramEntriesTableOrderingComposer,
      $$PlanogramEntriesTableAnnotationComposer,
      $$PlanogramEntriesTableCreateCompanionBuilder,
      $$PlanogramEntriesTableUpdateCompanionBuilder,
      (PlanogramEntry, $$PlanogramEntriesTableReferences),
      PlanogramEntry,
      PrefetchHooks Function({bool storeId, bool skuId})
    >;
typedef $$VisitsTableCreateCompanionBuilder =
    VisitsCompanion Function({
      required String id,
      required String storeId,
      required String beatId,
      Value<String> status,
      required int startedAt,
      Value<int?> confirmedAt,
      Value<double?> lat,
      Value<double?> lng,
      Value<double?> gpsAccuracyM,
      Value<bool> wasOffline,
      Value<String?> noteAudioPath,
      Value<String?> noteTranscript,
      Value<String?> llmSummary,
      Value<String?> llmRationale,
      Value<String?> llmModelId,
      Value<int?> durationMs,
      Value<int> rowid,
    });
typedef $$VisitsTableUpdateCompanionBuilder =
    VisitsCompanion Function({
      Value<String> id,
      Value<String> storeId,
      Value<String> beatId,
      Value<String> status,
      Value<int> startedAt,
      Value<int?> confirmedAt,
      Value<double?> lat,
      Value<double?> lng,
      Value<double?> gpsAccuracyM,
      Value<bool> wasOffline,
      Value<String?> noteAudioPath,
      Value<String?> noteTranscript,
      Value<String?> llmSummary,
      Value<String?> llmRationale,
      Value<String?> llmModelId,
      Value<int?> durationMs,
      Value<int> rowid,
    });

final class $$VisitsTableReferences
    extends BaseReferences<_$AppDatabase, $VisitsTable, Visit> {
  $$VisitsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $StoresTable _storeIdTable(_$AppDatabase db) =>
      db.stores.createAlias('visits__store_id__stores__id');

  $$StoresTableProcessedTableManager get storeId {
    final $_column = $_itemColumn<String>('store_id')!;

    final manager = $$StoresTableTableManager(
      $_db,
      $_db.stores,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_storeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $BeatsTable _beatIdTable(_$AppDatabase db) =>
      db.beats.createAlias('visits__beat_id__beats__id');

  $$BeatsTableProcessedTableManager get beatId {
    final $_column = $_itemColumn<String>('beat_id')!;

    final manager = $$BeatsTableTableManager(
      $_db,
      $_db.beats,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_beatIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$VisitPhotosTable, List<VisitPhoto>>
  _visitPhotosRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.visitPhotos,
    aliasName: 'visits__id__visit_photos__visit_id',
  );

  $$VisitPhotosTableProcessedTableManager get visitPhotosRefs {
    final manager = $$VisitPhotosTableTableManager(
      $_db,
      $_db.visitPhotos,
    ).filter((f) => f.visitId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_visitPhotosRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$DetectionsTable, List<Detection>>
  _detectionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.detections,
    aliasName: 'visits__id__detections__visit_id',
  );

  $$DetectionsTableProcessedTableManager get detectionsRefs {
    final manager = $$DetectionsTableTableManager(
      $_db,
      $_db.detections,
    ).filter((f) => f.visitId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_detectionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ShelfFactsTable, List<ShelfFact>>
  _shelfFactsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.shelfFacts,
    aliasName: 'visits__id__shelf_facts__visit_id',
  );

  $$ShelfFactsTableProcessedTableManager get shelfFactsRefs {
    final manager = $$ShelfFactsTableTableManager(
      $_db,
      $_db.shelfFacts,
    ).filter((f) => f.visitId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_shelfFactsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$OrderLinesTable, List<OrderLine>>
  _orderLinesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.orderLines,
    aliasName: 'visits__id__order_lines__visit_id',
  );

  $$OrderLinesTableProcessedTableManager get orderLinesRefs {
    final manager = $$OrderLinesTableTableManager(
      $_db,
      $_db.orderLines,
    ).filter((f) => f.visitId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_orderLinesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$VisitsTableFilterComposer
    extends Composer<_$AppDatabase, $VisitsTable> {
  $$VisitsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get confirmedAt => $composableBuilder(
    column: $table.confirmedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lng => $composableBuilder(
    column: $table.lng,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get gpsAccuracyM => $composableBuilder(
    column: $table.gpsAccuracyM,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get wasOffline => $composableBuilder(
    column: $table.wasOffline,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get noteAudioPath => $composableBuilder(
    column: $table.noteAudioPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get noteTranscript => $composableBuilder(
    column: $table.noteTranscript,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get llmSummary => $composableBuilder(
    column: $table.llmSummary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get llmRationale => $composableBuilder(
    column: $table.llmRationale,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get llmModelId => $composableBuilder(
    column: $table.llmModelId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  $$StoresTableFilterComposer get storeId {
    final $$StoresTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.storeId,
      referencedTable: $db.stores,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StoresTableFilterComposer(
            $db: $db,
            $table: $db.stores,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$BeatsTableFilterComposer get beatId {
    final $$BeatsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.beatId,
      referencedTable: $db.beats,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BeatsTableFilterComposer(
            $db: $db,
            $table: $db.beats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> visitPhotosRefs(
    Expression<bool> Function($$VisitPhotosTableFilterComposer f) f,
  ) {
    final $$VisitPhotosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.visitPhotos,
      getReferencedColumn: (t) => t.visitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VisitPhotosTableFilterComposer(
            $db: $db,
            $table: $db.visitPhotos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> detectionsRefs(
    Expression<bool> Function($$DetectionsTableFilterComposer f) f,
  ) {
    final $$DetectionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.detections,
      getReferencedColumn: (t) => t.visitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DetectionsTableFilterComposer(
            $db: $db,
            $table: $db.detections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> shelfFactsRefs(
    Expression<bool> Function($$ShelfFactsTableFilterComposer f) f,
  ) {
    final $$ShelfFactsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.shelfFacts,
      getReferencedColumn: (t) => t.visitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShelfFactsTableFilterComposer(
            $db: $db,
            $table: $db.shelfFacts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> orderLinesRefs(
    Expression<bool> Function($$OrderLinesTableFilterComposer f) f,
  ) {
    final $$OrderLinesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.orderLines,
      getReferencedColumn: (t) => t.visitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrderLinesTableFilterComposer(
            $db: $db,
            $table: $db.orderLines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$VisitsTableOrderingComposer
    extends Composer<_$AppDatabase, $VisitsTable> {
  $$VisitsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get confirmedAt => $composableBuilder(
    column: $table.confirmedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lng => $composableBuilder(
    column: $table.lng,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get gpsAccuracyM => $composableBuilder(
    column: $table.gpsAccuracyM,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get wasOffline => $composableBuilder(
    column: $table.wasOffline,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get noteAudioPath => $composableBuilder(
    column: $table.noteAudioPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get noteTranscript => $composableBuilder(
    column: $table.noteTranscript,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get llmSummary => $composableBuilder(
    column: $table.llmSummary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get llmRationale => $composableBuilder(
    column: $table.llmRationale,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get llmModelId => $composableBuilder(
    column: $table.llmModelId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  $$StoresTableOrderingComposer get storeId {
    final $$StoresTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.storeId,
      referencedTable: $db.stores,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StoresTableOrderingComposer(
            $db: $db,
            $table: $db.stores,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$BeatsTableOrderingComposer get beatId {
    final $$BeatsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.beatId,
      referencedTable: $db.beats,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BeatsTableOrderingComposer(
            $db: $db,
            $table: $db.beats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$VisitsTableAnnotationComposer
    extends Composer<_$AppDatabase, $VisitsTable> {
  $$VisitsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<int> get confirmedAt => $composableBuilder(
    column: $table.confirmedAt,
    builder: (column) => column,
  );

  GeneratedColumn<double> get lat =>
      $composableBuilder(column: $table.lat, builder: (column) => column);

  GeneratedColumn<double> get lng =>
      $composableBuilder(column: $table.lng, builder: (column) => column);

  GeneratedColumn<double> get gpsAccuracyM => $composableBuilder(
    column: $table.gpsAccuracyM,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get wasOffline => $composableBuilder(
    column: $table.wasOffline,
    builder: (column) => column,
  );

  GeneratedColumn<String> get noteAudioPath => $composableBuilder(
    column: $table.noteAudioPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get noteTranscript => $composableBuilder(
    column: $table.noteTranscript,
    builder: (column) => column,
  );

  GeneratedColumn<String> get llmSummary => $composableBuilder(
    column: $table.llmSummary,
    builder: (column) => column,
  );

  GeneratedColumn<String> get llmRationale => $composableBuilder(
    column: $table.llmRationale,
    builder: (column) => column,
  );

  GeneratedColumn<String> get llmModelId => $composableBuilder(
    column: $table.llmModelId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  $$StoresTableAnnotationComposer get storeId {
    final $$StoresTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.storeId,
      referencedTable: $db.stores,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StoresTableAnnotationComposer(
            $db: $db,
            $table: $db.stores,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$BeatsTableAnnotationComposer get beatId {
    final $$BeatsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.beatId,
      referencedTable: $db.beats,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BeatsTableAnnotationComposer(
            $db: $db,
            $table: $db.beats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> visitPhotosRefs<T extends Object>(
    Expression<T> Function($$VisitPhotosTableAnnotationComposer a) f,
  ) {
    final $$VisitPhotosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.visitPhotos,
      getReferencedColumn: (t) => t.visitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VisitPhotosTableAnnotationComposer(
            $db: $db,
            $table: $db.visitPhotos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> detectionsRefs<T extends Object>(
    Expression<T> Function($$DetectionsTableAnnotationComposer a) f,
  ) {
    final $$DetectionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.detections,
      getReferencedColumn: (t) => t.visitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DetectionsTableAnnotationComposer(
            $db: $db,
            $table: $db.detections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> shelfFactsRefs<T extends Object>(
    Expression<T> Function($$ShelfFactsTableAnnotationComposer a) f,
  ) {
    final $$ShelfFactsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.shelfFacts,
      getReferencedColumn: (t) => t.visitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShelfFactsTableAnnotationComposer(
            $db: $db,
            $table: $db.shelfFacts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> orderLinesRefs<T extends Object>(
    Expression<T> Function($$OrderLinesTableAnnotationComposer a) f,
  ) {
    final $$OrderLinesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.orderLines,
      getReferencedColumn: (t) => t.visitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrderLinesTableAnnotationComposer(
            $db: $db,
            $table: $db.orderLines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$VisitsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VisitsTable,
          Visit,
          $$VisitsTableFilterComposer,
          $$VisitsTableOrderingComposer,
          $$VisitsTableAnnotationComposer,
          $$VisitsTableCreateCompanionBuilder,
          $$VisitsTableUpdateCompanionBuilder,
          (Visit, $$VisitsTableReferences),
          Visit,
          PrefetchHooks Function({
            bool storeId,
            bool beatId,
            bool visitPhotosRefs,
            bool detectionsRefs,
            bool shelfFactsRefs,
            bool orderLinesRefs,
          })
        > {
  $$VisitsTableTableManager(_$AppDatabase db, $VisitsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VisitsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VisitsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VisitsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> storeId = const Value.absent(),
                Value<String> beatId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> startedAt = const Value.absent(),
                Value<int?> confirmedAt = const Value.absent(),
                Value<double?> lat = const Value.absent(),
                Value<double?> lng = const Value.absent(),
                Value<double?> gpsAccuracyM = const Value.absent(),
                Value<bool> wasOffline = const Value.absent(),
                Value<String?> noteAudioPath = const Value.absent(),
                Value<String?> noteTranscript = const Value.absent(),
                Value<String?> llmSummary = const Value.absent(),
                Value<String?> llmRationale = const Value.absent(),
                Value<String?> llmModelId = const Value.absent(),
                Value<int?> durationMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VisitsCompanion(
                id: id,
                storeId: storeId,
                beatId: beatId,
                status: status,
                startedAt: startedAt,
                confirmedAt: confirmedAt,
                lat: lat,
                lng: lng,
                gpsAccuracyM: gpsAccuracyM,
                wasOffline: wasOffline,
                noteAudioPath: noteAudioPath,
                noteTranscript: noteTranscript,
                llmSummary: llmSummary,
                llmRationale: llmRationale,
                llmModelId: llmModelId,
                durationMs: durationMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String storeId,
                required String beatId,
                Value<String> status = const Value.absent(),
                required int startedAt,
                Value<int?> confirmedAt = const Value.absent(),
                Value<double?> lat = const Value.absent(),
                Value<double?> lng = const Value.absent(),
                Value<double?> gpsAccuracyM = const Value.absent(),
                Value<bool> wasOffline = const Value.absent(),
                Value<String?> noteAudioPath = const Value.absent(),
                Value<String?> noteTranscript = const Value.absent(),
                Value<String?> llmSummary = const Value.absent(),
                Value<String?> llmRationale = const Value.absent(),
                Value<String?> llmModelId = const Value.absent(),
                Value<int?> durationMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VisitsCompanion.insert(
                id: id,
                storeId: storeId,
                beatId: beatId,
                status: status,
                startedAt: startedAt,
                confirmedAt: confirmedAt,
                lat: lat,
                lng: lng,
                gpsAccuracyM: gpsAccuracyM,
                wasOffline: wasOffline,
                noteAudioPath: noteAudioPath,
                noteTranscript: noteTranscript,
                llmSummary: llmSummary,
                llmRationale: llmRationale,
                llmModelId: llmModelId,
                durationMs: durationMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$VisitsTable, Visit>(table),
                  $$VisitsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                storeId = false,
                beatId = false,
                visitPhotosRefs = false,
                detectionsRefs = false,
                shelfFactsRefs = false,
                orderLinesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (visitPhotosRefs) db.visitPhotos,
                    if (detectionsRefs) db.detections,
                    if (shelfFactsRefs) db.shelfFacts,
                    if (orderLinesRefs) db.orderLines,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (storeId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.storeId,
                                    referencedTable: $$VisitsTableReferences
                                        ._storeIdTable(db),
                                    referencedColumn: $$VisitsTableReferences
                                        ._storeIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (beatId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.beatId,
                                    referencedTable: $$VisitsTableReferences
                                        ._beatIdTable(db),
                                    referencedColumn: $$VisitsTableReferences
                                        ._beatIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (visitPhotosRefs)
                        await $_getPrefetchedData<
                          Visit,
                          $VisitsTable,
                          VisitPhoto
                        >(
                          currentTable: table,
                          referencedTable: $$VisitsTableReferences
                              ._visitPhotosRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$VisitsTableReferences(
                                db,
                                table,
                                p0,
                              ).visitPhotosRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.visitId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (detectionsRefs)
                        await $_getPrefetchedData<
                          Visit,
                          $VisitsTable,
                          Detection
                        >(
                          currentTable: table,
                          referencedTable: $$VisitsTableReferences
                              ._detectionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$VisitsTableReferences(
                                db,
                                table,
                                p0,
                              ).detectionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.visitId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (shelfFactsRefs)
                        await $_getPrefetchedData<
                          Visit,
                          $VisitsTable,
                          ShelfFact
                        >(
                          currentTable: table,
                          referencedTable: $$VisitsTableReferences
                              ._shelfFactsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$VisitsTableReferences(
                                db,
                                table,
                                p0,
                              ).shelfFactsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.visitId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (orderLinesRefs)
                        await $_getPrefetchedData<
                          Visit,
                          $VisitsTable,
                          OrderLine
                        >(
                          currentTable: table,
                          referencedTable: $$VisitsTableReferences
                              ._orderLinesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$VisitsTableReferences(
                                db,
                                table,
                                p0,
                              ).orderLinesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.visitId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$VisitsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VisitsTable,
      Visit,
      $$VisitsTableFilterComposer,
      $$VisitsTableOrderingComposer,
      $$VisitsTableAnnotationComposer,
      $$VisitsTableCreateCompanionBuilder,
      $$VisitsTableUpdateCompanionBuilder,
      (Visit, $$VisitsTableReferences),
      Visit,
      PrefetchHooks Function({
        bool storeId,
        bool beatId,
        bool visitPhotosRefs,
        bool detectionsRefs,
        bool shelfFactsRefs,
        bool orderLinesRefs,
      })
    >;
typedef $$VisitPhotosTableCreateCompanionBuilder =
    VisitPhotosCompanion Function({
      required String id,
      required String visitId,
      required String filePath,
      required int width,
      required int height,
      Value<int?> detectLatencyMs,
      required int capturedAt,
      Value<int> rowid,
    });
typedef $$VisitPhotosTableUpdateCompanionBuilder =
    VisitPhotosCompanion Function({
      Value<String> id,
      Value<String> visitId,
      Value<String> filePath,
      Value<int> width,
      Value<int> height,
      Value<int?> detectLatencyMs,
      Value<int> capturedAt,
      Value<int> rowid,
    });

final class $$VisitPhotosTableReferences
    extends BaseReferences<_$AppDatabase, $VisitPhotosTable, VisitPhoto> {
  $$VisitPhotosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $VisitsTable _visitIdTable(_$AppDatabase db) =>
      db.visits.createAlias('visit_photos__visit_id__visits__id');

  $$VisitsTableProcessedTableManager get visitId {
    final $_column = $_itemColumn<String>('visit_id')!;

    final manager = $$VisitsTableTableManager(
      $_db,
      $_db.visits,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_visitIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$DetectionsTable, List<Detection>>
  _detectionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.detections,
    aliasName: 'visit_photos__id__detections__photo_id',
  );

  $$DetectionsTableProcessedTableManager get detectionsRefs {
    final manager = $$DetectionsTableTableManager(
      $_db,
      $_db.detections,
    ).filter((f) => f.photoId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_detectionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$VisitPhotosTableFilterComposer
    extends Composer<_$AppDatabase, $VisitPhotosTable> {
  $$VisitPhotosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get detectLatencyMs => $composableBuilder(
    column: $table.detectLatencyMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$VisitsTableFilterComposer get visitId {
    final $$VisitsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.visitId,
      referencedTable: $db.visits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VisitsTableFilterComposer(
            $db: $db,
            $table: $db.visits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> detectionsRefs(
    Expression<bool> Function($$DetectionsTableFilterComposer f) f,
  ) {
    final $$DetectionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.detections,
      getReferencedColumn: (t) => t.photoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DetectionsTableFilterComposer(
            $db: $db,
            $table: $db.detections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$VisitPhotosTableOrderingComposer
    extends Composer<_$AppDatabase, $VisitPhotosTable> {
  $$VisitPhotosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get detectLatencyMs => $composableBuilder(
    column: $table.detectLatencyMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$VisitsTableOrderingComposer get visitId {
    final $$VisitsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.visitId,
      referencedTable: $db.visits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VisitsTableOrderingComposer(
            $db: $db,
            $table: $db.visits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$VisitPhotosTableAnnotationComposer
    extends Composer<_$AppDatabase, $VisitPhotosTable> {
  $$VisitPhotosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<int> get width =>
      $composableBuilder(column: $table.width, builder: (column) => column);

  GeneratedColumn<int> get height =>
      $composableBuilder(column: $table.height, builder: (column) => column);

  GeneratedColumn<int> get detectLatencyMs => $composableBuilder(
    column: $table.detectLatencyMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => column,
  );

  $$VisitsTableAnnotationComposer get visitId {
    final $$VisitsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.visitId,
      referencedTable: $db.visits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VisitsTableAnnotationComposer(
            $db: $db,
            $table: $db.visits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> detectionsRefs<T extends Object>(
    Expression<T> Function($$DetectionsTableAnnotationComposer a) f,
  ) {
    final $$DetectionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.detections,
      getReferencedColumn: (t) => t.photoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DetectionsTableAnnotationComposer(
            $db: $db,
            $table: $db.detections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$VisitPhotosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VisitPhotosTable,
          VisitPhoto,
          $$VisitPhotosTableFilterComposer,
          $$VisitPhotosTableOrderingComposer,
          $$VisitPhotosTableAnnotationComposer,
          $$VisitPhotosTableCreateCompanionBuilder,
          $$VisitPhotosTableUpdateCompanionBuilder,
          (VisitPhoto, $$VisitPhotosTableReferences),
          VisitPhoto,
          PrefetchHooks Function({bool visitId, bool detectionsRefs})
        > {
  $$VisitPhotosTableTableManager(_$AppDatabase db, $VisitPhotosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VisitPhotosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VisitPhotosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VisitPhotosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> visitId = const Value.absent(),
                Value<String> filePath = const Value.absent(),
                Value<int> width = const Value.absent(),
                Value<int> height = const Value.absent(),
                Value<int?> detectLatencyMs = const Value.absent(),
                Value<int> capturedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VisitPhotosCompanion(
                id: id,
                visitId: visitId,
                filePath: filePath,
                width: width,
                height: height,
                detectLatencyMs: detectLatencyMs,
                capturedAt: capturedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String visitId,
                required String filePath,
                required int width,
                required int height,
                Value<int?> detectLatencyMs = const Value.absent(),
                required int capturedAt,
                Value<int> rowid = const Value.absent(),
              }) => VisitPhotosCompanion.insert(
                id: id,
                visitId: visitId,
                filePath: filePath,
                width: width,
                height: height,
                detectLatencyMs: detectLatencyMs,
                capturedAt: capturedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$VisitPhotosTable, VisitPhoto>(table),
                  $$VisitPhotosTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({visitId = false, detectionsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (detectionsRefs) db.detections],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (visitId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.visitId,
                                referencedTable: $$VisitPhotosTableReferences
                                    ._visitIdTable(db),
                                referencedColumn: $$VisitPhotosTableReferences
                                    ._visitIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (detectionsRefs)
                    await $_getPrefetchedData<
                      VisitPhoto,
                      $VisitPhotosTable,
                      Detection
                    >(
                      currentTable: table,
                      referencedTable: $$VisitPhotosTableReferences
                          ._detectionsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$VisitPhotosTableReferences(
                            db,
                            table,
                            p0,
                          ).detectionsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.photoId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$VisitPhotosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VisitPhotosTable,
      VisitPhoto,
      $$VisitPhotosTableFilterComposer,
      $$VisitPhotosTableOrderingComposer,
      $$VisitPhotosTableAnnotationComposer,
      $$VisitPhotosTableCreateCompanionBuilder,
      $$VisitPhotosTableUpdateCompanionBuilder,
      (VisitPhoto, $$VisitPhotosTableReferences),
      VisitPhoto,
      PrefetchHooks Function({bool visitId, bool detectionsRefs})
    >;
typedef $$DetectionsTableCreateCompanionBuilder =
    DetectionsCompanion Function({
      required String id,
      required String visitId,
      required String photoId,
      required double x1,
      required double y1,
      required double x2,
      required double y2,
      required double detConfidence,
      Value<String?> skuId,
      Value<double?> matchConfidence,
      Value<String> matchMethod,
      Value<int?> shelfRow,
      Value<bool> isGap,
      Value<bool> wasCorrected,
      Value<Uint8List?> embedding,
      required int createdAt,
      Value<int> rowid,
    });
typedef $$DetectionsTableUpdateCompanionBuilder =
    DetectionsCompanion Function({
      Value<String> id,
      Value<String> visitId,
      Value<String> photoId,
      Value<double> x1,
      Value<double> y1,
      Value<double> x2,
      Value<double> y2,
      Value<double> detConfidence,
      Value<String?> skuId,
      Value<double?> matchConfidence,
      Value<String> matchMethod,
      Value<int?> shelfRow,
      Value<bool> isGap,
      Value<bool> wasCorrected,
      Value<Uint8List?> embedding,
      Value<int> createdAt,
      Value<int> rowid,
    });

final class $$DetectionsTableReferences
    extends BaseReferences<_$AppDatabase, $DetectionsTable, Detection> {
  $$DetectionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $VisitsTable _visitIdTable(_$AppDatabase db) =>
      db.visits.createAlias('detections__visit_id__visits__id');

  $$VisitsTableProcessedTableManager get visitId {
    final $_column = $_itemColumn<String>('visit_id')!;

    final manager = $$VisitsTableTableManager(
      $_db,
      $_db.visits,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_visitIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $VisitPhotosTable _photoIdTable(_$AppDatabase db) =>
      db.visitPhotos.createAlias('detections__photo_id__visit_photos__id');

  $$VisitPhotosTableProcessedTableManager get photoId {
    final $_column = $_itemColumn<String>('photo_id')!;

    final manager = $$VisitPhotosTableTableManager(
      $_db,
      $_db.visitPhotos,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_photoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $SkusTable _skuIdTable(_$AppDatabase db) =>
      db.skus.createAlias('detections__sku_id__skus__id');

  $$SkusTableProcessedTableManager? get skuId {
    final $_column = $_itemColumn<String>('sku_id');
    if ($_column == null) return null;
    final manager = $$SkusTableTableManager(
      $_db,
      $_db.skus,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_skuIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DetectionsTableFilterComposer
    extends Composer<_$AppDatabase, $DetectionsTable> {
  $$DetectionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get x1 => $composableBuilder(
    column: $table.x1,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get y1 => $composableBuilder(
    column: $table.y1,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get x2 => $composableBuilder(
    column: $table.x2,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get y2 => $composableBuilder(
    column: $table.y2,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get detConfidence => $composableBuilder(
    column: $table.detConfidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get matchConfidence => $composableBuilder(
    column: $table.matchConfidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get matchMethod => $composableBuilder(
    column: $table.matchMethod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get shelfRow => $composableBuilder(
    column: $table.shelfRow,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isGap => $composableBuilder(
    column: $table.isGap,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get wasCorrected => $composableBuilder(
    column: $table.wasCorrected,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get embedding => $composableBuilder(
    column: $table.embedding,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$VisitsTableFilterComposer get visitId {
    final $$VisitsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.visitId,
      referencedTable: $db.visits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VisitsTableFilterComposer(
            $db: $db,
            $table: $db.visits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$VisitPhotosTableFilterComposer get photoId {
    final $$VisitPhotosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.photoId,
      referencedTable: $db.visitPhotos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VisitPhotosTableFilterComposer(
            $db: $db,
            $table: $db.visitPhotos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SkusTableFilterComposer get skuId {
    final $$SkusTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.skuId,
      referencedTable: $db.skus,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SkusTableFilterComposer(
            $db: $db,
            $table: $db.skus,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DetectionsTableOrderingComposer
    extends Composer<_$AppDatabase, $DetectionsTable> {
  $$DetectionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get x1 => $composableBuilder(
    column: $table.x1,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get y1 => $composableBuilder(
    column: $table.y1,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get x2 => $composableBuilder(
    column: $table.x2,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get y2 => $composableBuilder(
    column: $table.y2,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get detConfidence => $composableBuilder(
    column: $table.detConfidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get matchConfidence => $composableBuilder(
    column: $table.matchConfidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get matchMethod => $composableBuilder(
    column: $table.matchMethod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get shelfRow => $composableBuilder(
    column: $table.shelfRow,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isGap => $composableBuilder(
    column: $table.isGap,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get wasCorrected => $composableBuilder(
    column: $table.wasCorrected,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get embedding => $composableBuilder(
    column: $table.embedding,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$VisitsTableOrderingComposer get visitId {
    final $$VisitsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.visitId,
      referencedTable: $db.visits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VisitsTableOrderingComposer(
            $db: $db,
            $table: $db.visits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$VisitPhotosTableOrderingComposer get photoId {
    final $$VisitPhotosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.photoId,
      referencedTable: $db.visitPhotos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VisitPhotosTableOrderingComposer(
            $db: $db,
            $table: $db.visitPhotos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SkusTableOrderingComposer get skuId {
    final $$SkusTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.skuId,
      referencedTable: $db.skus,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SkusTableOrderingComposer(
            $db: $db,
            $table: $db.skus,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DetectionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DetectionsTable> {
  $$DetectionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get x1 =>
      $composableBuilder(column: $table.x1, builder: (column) => column);

  GeneratedColumn<double> get y1 =>
      $composableBuilder(column: $table.y1, builder: (column) => column);

  GeneratedColumn<double> get x2 =>
      $composableBuilder(column: $table.x2, builder: (column) => column);

  GeneratedColumn<double> get y2 =>
      $composableBuilder(column: $table.y2, builder: (column) => column);

  GeneratedColumn<double> get detConfidence => $composableBuilder(
    column: $table.detConfidence,
    builder: (column) => column,
  );

  GeneratedColumn<double> get matchConfidence => $composableBuilder(
    column: $table.matchConfidence,
    builder: (column) => column,
  );

  GeneratedColumn<String> get matchMethod => $composableBuilder(
    column: $table.matchMethod,
    builder: (column) => column,
  );

  GeneratedColumn<int> get shelfRow =>
      $composableBuilder(column: $table.shelfRow, builder: (column) => column);

  GeneratedColumn<bool> get isGap =>
      $composableBuilder(column: $table.isGap, builder: (column) => column);

  GeneratedColumn<bool> get wasCorrected => $composableBuilder(
    column: $table.wasCorrected,
    builder: (column) => column,
  );

  GeneratedColumn<Uint8List> get embedding =>
      $composableBuilder(column: $table.embedding, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$VisitsTableAnnotationComposer get visitId {
    final $$VisitsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.visitId,
      referencedTable: $db.visits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VisitsTableAnnotationComposer(
            $db: $db,
            $table: $db.visits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$VisitPhotosTableAnnotationComposer get photoId {
    final $$VisitPhotosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.photoId,
      referencedTable: $db.visitPhotos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VisitPhotosTableAnnotationComposer(
            $db: $db,
            $table: $db.visitPhotos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SkusTableAnnotationComposer get skuId {
    final $$SkusTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.skuId,
      referencedTable: $db.skus,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SkusTableAnnotationComposer(
            $db: $db,
            $table: $db.skus,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DetectionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DetectionsTable,
          Detection,
          $$DetectionsTableFilterComposer,
          $$DetectionsTableOrderingComposer,
          $$DetectionsTableAnnotationComposer,
          $$DetectionsTableCreateCompanionBuilder,
          $$DetectionsTableUpdateCompanionBuilder,
          (Detection, $$DetectionsTableReferences),
          Detection,
          PrefetchHooks Function({bool visitId, bool photoId, bool skuId})
        > {
  $$DetectionsTableTableManager(_$AppDatabase db, $DetectionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DetectionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DetectionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DetectionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> visitId = const Value.absent(),
                Value<String> photoId = const Value.absent(),
                Value<double> x1 = const Value.absent(),
                Value<double> y1 = const Value.absent(),
                Value<double> x2 = const Value.absent(),
                Value<double> y2 = const Value.absent(),
                Value<double> detConfidence = const Value.absent(),
                Value<String?> skuId = const Value.absent(),
                Value<double?> matchConfidence = const Value.absent(),
                Value<String> matchMethod = const Value.absent(),
                Value<int?> shelfRow = const Value.absent(),
                Value<bool> isGap = const Value.absent(),
                Value<bool> wasCorrected = const Value.absent(),
                Value<Uint8List?> embedding = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DetectionsCompanion(
                id: id,
                visitId: visitId,
                photoId: photoId,
                x1: x1,
                y1: y1,
                x2: x2,
                y2: y2,
                detConfidence: detConfidence,
                skuId: skuId,
                matchConfidence: matchConfidence,
                matchMethod: matchMethod,
                shelfRow: shelfRow,
                isGap: isGap,
                wasCorrected: wasCorrected,
                embedding: embedding,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String visitId,
                required String photoId,
                required double x1,
                required double y1,
                required double x2,
                required double y2,
                required double detConfidence,
                Value<String?> skuId = const Value.absent(),
                Value<double?> matchConfidence = const Value.absent(),
                Value<String> matchMethod = const Value.absent(),
                Value<int?> shelfRow = const Value.absent(),
                Value<bool> isGap = const Value.absent(),
                Value<bool> wasCorrected = const Value.absent(),
                Value<Uint8List?> embedding = const Value.absent(),
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => DetectionsCompanion.insert(
                id: id,
                visitId: visitId,
                photoId: photoId,
                x1: x1,
                y1: y1,
                x2: x2,
                y2: y2,
                detConfidence: detConfidence,
                skuId: skuId,
                matchConfidence: matchConfidence,
                matchMethod: matchMethod,
                shelfRow: shelfRow,
                isGap: isGap,
                wasCorrected: wasCorrected,
                embedding: embedding,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DetectionsTable, Detection>(table),
                  $$DetectionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({visitId = false, photoId = false, skuId = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (visitId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.visitId,
                                    referencedTable: $$DetectionsTableReferences
                                        ._visitIdTable(db),
                                    referencedColumn:
                                        $$DetectionsTableReferences
                                            ._visitIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (photoId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.photoId,
                                    referencedTable: $$DetectionsTableReferences
                                        ._photoIdTable(db),
                                    referencedColumn:
                                        $$DetectionsTableReferences
                                            ._photoIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (skuId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.skuId,
                                    referencedTable: $$DetectionsTableReferences
                                        ._skuIdTable(db),
                                    referencedColumn:
                                        $$DetectionsTableReferences
                                            ._skuIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$DetectionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DetectionsTable,
      Detection,
      $$DetectionsTableFilterComposer,
      $$DetectionsTableOrderingComposer,
      $$DetectionsTableAnnotationComposer,
      $$DetectionsTableCreateCompanionBuilder,
      $$DetectionsTableUpdateCompanionBuilder,
      (Detection, $$DetectionsTableReferences),
      Detection,
      PrefetchHooks Function({bool visitId, bool photoId, bool skuId})
    >;
typedef $$ShelfFactsTableCreateCompanionBuilder =
    ShelfFactsCompanion Function({
      required String id,
      required String visitId,
      required String skuId,
      required int detectedFacings,
      required int targetFacings,
      required String status,
      required int computedAt,
      Value<int> rowid,
    });
typedef $$ShelfFactsTableUpdateCompanionBuilder =
    ShelfFactsCompanion Function({
      Value<String> id,
      Value<String> visitId,
      Value<String> skuId,
      Value<int> detectedFacings,
      Value<int> targetFacings,
      Value<String> status,
      Value<int> computedAt,
      Value<int> rowid,
    });

final class $$ShelfFactsTableReferences
    extends BaseReferences<_$AppDatabase, $ShelfFactsTable, ShelfFact> {
  $$ShelfFactsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $VisitsTable _visitIdTable(_$AppDatabase db) =>
      db.visits.createAlias('shelf_facts__visit_id__visits__id');

  $$VisitsTableProcessedTableManager get visitId {
    final $_column = $_itemColumn<String>('visit_id')!;

    final manager = $$VisitsTableTableManager(
      $_db,
      $_db.visits,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_visitIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $SkusTable _skuIdTable(_$AppDatabase db) =>
      db.skus.createAlias('shelf_facts__sku_id__skus__id');

  $$SkusTableProcessedTableManager get skuId {
    final $_column = $_itemColumn<String>('sku_id')!;

    final manager = $$SkusTableTableManager(
      $_db,
      $_db.skus,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_skuIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ShelfFactsTableFilterComposer
    extends Composer<_$AppDatabase, $ShelfFactsTable> {
  $$ShelfFactsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get detectedFacings => $composableBuilder(
    column: $table.detectedFacings,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetFacings => $composableBuilder(
    column: $table.targetFacings,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get computedAt => $composableBuilder(
    column: $table.computedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$VisitsTableFilterComposer get visitId {
    final $$VisitsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.visitId,
      referencedTable: $db.visits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VisitsTableFilterComposer(
            $db: $db,
            $table: $db.visits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SkusTableFilterComposer get skuId {
    final $$SkusTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.skuId,
      referencedTable: $db.skus,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SkusTableFilterComposer(
            $db: $db,
            $table: $db.skus,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ShelfFactsTableOrderingComposer
    extends Composer<_$AppDatabase, $ShelfFactsTable> {
  $$ShelfFactsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get detectedFacings => $composableBuilder(
    column: $table.detectedFacings,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetFacings => $composableBuilder(
    column: $table.targetFacings,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get computedAt => $composableBuilder(
    column: $table.computedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$VisitsTableOrderingComposer get visitId {
    final $$VisitsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.visitId,
      referencedTable: $db.visits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VisitsTableOrderingComposer(
            $db: $db,
            $table: $db.visits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SkusTableOrderingComposer get skuId {
    final $$SkusTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.skuId,
      referencedTable: $db.skus,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SkusTableOrderingComposer(
            $db: $db,
            $table: $db.skus,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ShelfFactsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ShelfFactsTable> {
  $$ShelfFactsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get detectedFacings => $composableBuilder(
    column: $table.detectedFacings,
    builder: (column) => column,
  );

  GeneratedColumn<int> get targetFacings => $composableBuilder(
    column: $table.targetFacings,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get computedAt => $composableBuilder(
    column: $table.computedAt,
    builder: (column) => column,
  );

  $$VisitsTableAnnotationComposer get visitId {
    final $$VisitsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.visitId,
      referencedTable: $db.visits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VisitsTableAnnotationComposer(
            $db: $db,
            $table: $db.visits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SkusTableAnnotationComposer get skuId {
    final $$SkusTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.skuId,
      referencedTable: $db.skus,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SkusTableAnnotationComposer(
            $db: $db,
            $table: $db.skus,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ShelfFactsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ShelfFactsTable,
          ShelfFact,
          $$ShelfFactsTableFilterComposer,
          $$ShelfFactsTableOrderingComposer,
          $$ShelfFactsTableAnnotationComposer,
          $$ShelfFactsTableCreateCompanionBuilder,
          $$ShelfFactsTableUpdateCompanionBuilder,
          (ShelfFact, $$ShelfFactsTableReferences),
          ShelfFact,
          PrefetchHooks Function({bool visitId, bool skuId})
        > {
  $$ShelfFactsTableTableManager(_$AppDatabase db, $ShelfFactsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ShelfFactsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ShelfFactsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ShelfFactsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> visitId = const Value.absent(),
                Value<String> skuId = const Value.absent(),
                Value<int> detectedFacings = const Value.absent(),
                Value<int> targetFacings = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> computedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ShelfFactsCompanion(
                id: id,
                visitId: visitId,
                skuId: skuId,
                detectedFacings: detectedFacings,
                targetFacings: targetFacings,
                status: status,
                computedAt: computedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String visitId,
                required String skuId,
                required int detectedFacings,
                required int targetFacings,
                required String status,
                required int computedAt,
                Value<int> rowid = const Value.absent(),
              }) => ShelfFactsCompanion.insert(
                id: id,
                visitId: visitId,
                skuId: skuId,
                detectedFacings: detectedFacings,
                targetFacings: targetFacings,
                status: status,
                computedAt: computedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ShelfFactsTable, ShelfFact>(table),
                  $$ShelfFactsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({visitId = false, skuId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (visitId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.visitId,
                                referencedTable: $$ShelfFactsTableReferences
                                    ._visitIdTable(db),
                                referencedColumn: $$ShelfFactsTableReferences
                                    ._visitIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (skuId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.skuId,
                                referencedTable: $$ShelfFactsTableReferences
                                    ._skuIdTable(db),
                                referencedColumn: $$ShelfFactsTableReferences
                                    ._skuIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ShelfFactsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ShelfFactsTable,
      ShelfFact,
      $$ShelfFactsTableFilterComposer,
      $$ShelfFactsTableOrderingComposer,
      $$ShelfFactsTableAnnotationComposer,
      $$ShelfFactsTableCreateCompanionBuilder,
      $$ShelfFactsTableUpdateCompanionBuilder,
      (ShelfFact, $$ShelfFactsTableReferences),
      ShelfFact,
      PrefetchHooks Function({bool visitId, bool skuId})
    >;
typedef $$OrderLinesTableCreateCompanionBuilder =
    OrderLinesCompanion Function({
      required String id,
      required String visitId,
      required String skuId,
      required int suggestedQty,
      required int finalQty,
      Value<String> unit,
      required int valuePaise,
      Value<bool> wasOverridden,
      required int createdAt,
      Value<int> rowid,
    });
typedef $$OrderLinesTableUpdateCompanionBuilder =
    OrderLinesCompanion Function({
      Value<String> id,
      Value<String> visitId,
      Value<String> skuId,
      Value<int> suggestedQty,
      Value<int> finalQty,
      Value<String> unit,
      Value<int> valuePaise,
      Value<bool> wasOverridden,
      Value<int> createdAt,
      Value<int> rowid,
    });

final class $$OrderLinesTableReferences
    extends BaseReferences<_$AppDatabase, $OrderLinesTable, OrderLine> {
  $$OrderLinesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $VisitsTable _visitIdTable(_$AppDatabase db) =>
      db.visits.createAlias('order_lines__visit_id__visits__id');

  $$VisitsTableProcessedTableManager get visitId {
    final $_column = $_itemColumn<String>('visit_id')!;

    final manager = $$VisitsTableTableManager(
      $_db,
      $_db.visits,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_visitIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $SkusTable _skuIdTable(_$AppDatabase db) =>
      db.skus.createAlias('order_lines__sku_id__skus__id');

  $$SkusTableProcessedTableManager get skuId {
    final $_column = $_itemColumn<String>('sku_id')!;

    final manager = $$SkusTableTableManager(
      $_db,
      $_db.skus,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_skuIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$OrderLinesTableFilterComposer
    extends Composer<_$AppDatabase, $OrderLinesTable> {
  $$OrderLinesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get suggestedQty => $composableBuilder(
    column: $table.suggestedQty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get finalQty => $composableBuilder(
    column: $table.finalQty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get valuePaise => $composableBuilder(
    column: $table.valuePaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get wasOverridden => $composableBuilder(
    column: $table.wasOverridden,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$VisitsTableFilterComposer get visitId {
    final $$VisitsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.visitId,
      referencedTable: $db.visits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VisitsTableFilterComposer(
            $db: $db,
            $table: $db.visits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SkusTableFilterComposer get skuId {
    final $$SkusTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.skuId,
      referencedTable: $db.skus,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SkusTableFilterComposer(
            $db: $db,
            $table: $db.skus,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OrderLinesTableOrderingComposer
    extends Composer<_$AppDatabase, $OrderLinesTable> {
  $$OrderLinesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get suggestedQty => $composableBuilder(
    column: $table.suggestedQty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get finalQty => $composableBuilder(
    column: $table.finalQty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get valuePaise => $composableBuilder(
    column: $table.valuePaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get wasOverridden => $composableBuilder(
    column: $table.wasOverridden,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$VisitsTableOrderingComposer get visitId {
    final $$VisitsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.visitId,
      referencedTable: $db.visits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VisitsTableOrderingComposer(
            $db: $db,
            $table: $db.visits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SkusTableOrderingComposer get skuId {
    final $$SkusTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.skuId,
      referencedTable: $db.skus,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SkusTableOrderingComposer(
            $db: $db,
            $table: $db.skus,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OrderLinesTableAnnotationComposer
    extends Composer<_$AppDatabase, $OrderLinesTable> {
  $$OrderLinesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get suggestedQty => $composableBuilder(
    column: $table.suggestedQty,
    builder: (column) => column,
  );

  GeneratedColumn<int> get finalQty =>
      $composableBuilder(column: $table.finalQty, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<int> get valuePaise => $composableBuilder(
    column: $table.valuePaise,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get wasOverridden => $composableBuilder(
    column: $table.wasOverridden,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$VisitsTableAnnotationComposer get visitId {
    final $$VisitsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.visitId,
      referencedTable: $db.visits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VisitsTableAnnotationComposer(
            $db: $db,
            $table: $db.visits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SkusTableAnnotationComposer get skuId {
    final $$SkusTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.skuId,
      referencedTable: $db.skus,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SkusTableAnnotationComposer(
            $db: $db,
            $table: $db.skus,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OrderLinesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OrderLinesTable,
          OrderLine,
          $$OrderLinesTableFilterComposer,
          $$OrderLinesTableOrderingComposer,
          $$OrderLinesTableAnnotationComposer,
          $$OrderLinesTableCreateCompanionBuilder,
          $$OrderLinesTableUpdateCompanionBuilder,
          (OrderLine, $$OrderLinesTableReferences),
          OrderLine,
          PrefetchHooks Function({bool visitId, bool skuId})
        > {
  $$OrderLinesTableTableManager(_$AppDatabase db, $OrderLinesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OrderLinesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OrderLinesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OrderLinesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> visitId = const Value.absent(),
                Value<String> skuId = const Value.absent(),
                Value<int> suggestedQty = const Value.absent(),
                Value<int> finalQty = const Value.absent(),
                Value<String> unit = const Value.absent(),
                Value<int> valuePaise = const Value.absent(),
                Value<bool> wasOverridden = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OrderLinesCompanion(
                id: id,
                visitId: visitId,
                skuId: skuId,
                suggestedQty: suggestedQty,
                finalQty: finalQty,
                unit: unit,
                valuePaise: valuePaise,
                wasOverridden: wasOverridden,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String visitId,
                required String skuId,
                required int suggestedQty,
                required int finalQty,
                Value<String> unit = const Value.absent(),
                required int valuePaise,
                Value<bool> wasOverridden = const Value.absent(),
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => OrderLinesCompanion.insert(
                id: id,
                visitId: visitId,
                skuId: skuId,
                suggestedQty: suggestedQty,
                finalQty: finalQty,
                unit: unit,
                valuePaise: valuePaise,
                wasOverridden: wasOverridden,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$OrderLinesTable, OrderLine>(table),
                  $$OrderLinesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({visitId = false, skuId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (visitId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.visitId,
                                referencedTable: $$OrderLinesTableReferences
                                    ._visitIdTable(db),
                                referencedColumn: $$OrderLinesTableReferences
                                    ._visitIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (skuId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.skuId,
                                referencedTable: $$OrderLinesTableReferences
                                    ._skuIdTable(db),
                                referencedColumn: $$OrderLinesTableReferences
                                    ._skuIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$OrderLinesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OrderLinesTable,
      OrderLine,
      $$OrderLinesTableFilterComposer,
      $$OrderLinesTableOrderingComposer,
      $$OrderLinesTableAnnotationComposer,
      $$OrderLinesTableCreateCompanionBuilder,
      $$OrderLinesTableUpdateCompanionBuilder,
      (OrderLine, $$OrderLinesTableReferences),
      OrderLine,
      PrefetchHooks Function({bool visitId, bool skuId})
    >;
typedef $$OverrideEventsTableCreateCompanionBuilder =
    OverrideEventsCompanion Function({
      required String id,
      required String visitId,
      required String entity,
      required String entityId,
      required String field,
      Value<String?> oldValue,
      Value<String?> newValue,
      required int createdAt,
      Value<int> rowid,
    });
typedef $$OverrideEventsTableUpdateCompanionBuilder =
    OverrideEventsCompanion Function({
      Value<String> id,
      Value<String> visitId,
      Value<String> entity,
      Value<String> entityId,
      Value<String> field,
      Value<String?> oldValue,
      Value<String?> newValue,
      Value<int> createdAt,
      Value<int> rowid,
    });

class $$OverrideEventsTableFilterComposer
    extends Composer<_$AppDatabase, $OverrideEventsTable> {
  $$OverrideEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get visitId => $composableBuilder(
    column: $table.visitId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get field => $composableBuilder(
    column: $table.field,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get oldValue => $composableBuilder(
    column: $table.oldValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get newValue => $composableBuilder(
    column: $table.newValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OverrideEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $OverrideEventsTable> {
  $$OverrideEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get visitId => $composableBuilder(
    column: $table.visitId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get field => $composableBuilder(
    column: $table.field,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get oldValue => $composableBuilder(
    column: $table.oldValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get newValue => $composableBuilder(
    column: $table.newValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OverrideEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $OverrideEventsTable> {
  $$OverrideEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get visitId =>
      $composableBuilder(column: $table.visitId, builder: (column) => column);

  GeneratedColumn<String> get entity =>
      $composableBuilder(column: $table.entity, builder: (column) => column);

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get field =>
      $composableBuilder(column: $table.field, builder: (column) => column);

  GeneratedColumn<String> get oldValue =>
      $composableBuilder(column: $table.oldValue, builder: (column) => column);

  GeneratedColumn<String> get newValue =>
      $composableBuilder(column: $table.newValue, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$OverrideEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OverrideEventsTable,
          OverrideEvent,
          $$OverrideEventsTableFilterComposer,
          $$OverrideEventsTableOrderingComposer,
          $$OverrideEventsTableAnnotationComposer,
          $$OverrideEventsTableCreateCompanionBuilder,
          $$OverrideEventsTableUpdateCompanionBuilder,
          (
            OverrideEvent,
            BaseReferences<_$AppDatabase, $OverrideEventsTable, OverrideEvent>,
          ),
          OverrideEvent,
          PrefetchHooks Function()
        > {
  $$OverrideEventsTableTableManager(
    _$AppDatabase db,
    $OverrideEventsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OverrideEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OverrideEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OverrideEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> visitId = const Value.absent(),
                Value<String> entity = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> field = const Value.absent(),
                Value<String?> oldValue = const Value.absent(),
                Value<String?> newValue = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OverrideEventsCompanion(
                id: id,
                visitId: visitId,
                entity: entity,
                entityId: entityId,
                field: field,
                oldValue: oldValue,
                newValue: newValue,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String visitId,
                required String entity,
                required String entityId,
                required String field,
                Value<String?> oldValue = const Value.absent(),
                Value<String?> newValue = const Value.absent(),
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => OverrideEventsCompanion.insert(
                id: id,
                visitId: visitId,
                entity: entity,
                entityId: entityId,
                field: field,
                oldValue: oldValue,
                newValue: newValue,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$OverrideEventsTable, OverrideEvent>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $OverrideEventsTable,
                    OverrideEvent
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OverrideEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OverrideEventsTable,
      OverrideEvent,
      $$OverrideEventsTableFilterComposer,
      $$OverrideEventsTableOrderingComposer,
      $$OverrideEventsTableAnnotationComposer,
      $$OverrideEventsTableCreateCompanionBuilder,
      $$OverrideEventsTableUpdateCompanionBuilder,
      (
        OverrideEvent,
        BaseReferences<_$AppDatabase, $OverrideEventsTable, OverrideEvent>,
      ),
      OverrideEvent,
      PrefetchHooks Function()
    >;
typedef $$ExportBatchesTableCreateCompanionBuilder =
    ExportBatchesCompanion Function({
      required String id,
      required String beatId,
      required int visitCount,
      required int lineCount,
      required int totalValuePaise,
      Value<String?> xlsxPath,
      Value<String?> csvPath,
      Value<String?> pdfPath,
      required int createdAt,
      Value<int> rowid,
    });
typedef $$ExportBatchesTableUpdateCompanionBuilder =
    ExportBatchesCompanion Function({
      Value<String> id,
      Value<String> beatId,
      Value<int> visitCount,
      Value<int> lineCount,
      Value<int> totalValuePaise,
      Value<String?> xlsxPath,
      Value<String?> csvPath,
      Value<String?> pdfPath,
      Value<int> createdAt,
      Value<int> rowid,
    });

final class $$ExportBatchesTableReferences
    extends BaseReferences<_$AppDatabase, $ExportBatchesTable, ExportBatche> {
  $$ExportBatchesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $BeatsTable _beatIdTable(_$AppDatabase db) =>
      db.beats.createAlias('export_batches__beat_id__beats__id');

  $$BeatsTableProcessedTableManager get beatId {
    final $_column = $_itemColumn<String>('beat_id')!;

    final manager = $$BeatsTableTableManager(
      $_db,
      $_db.beats,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_beatIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ExportBatchesTableFilterComposer
    extends Composer<_$AppDatabase, $ExportBatchesTable> {
  $$ExportBatchesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get visitCount => $composableBuilder(
    column: $table.visitCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lineCount => $composableBuilder(
    column: $table.lineCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalValuePaise => $composableBuilder(
    column: $table.totalValuePaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get xlsxPath => $composableBuilder(
    column: $table.xlsxPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get csvPath => $composableBuilder(
    column: $table.csvPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pdfPath => $composableBuilder(
    column: $table.pdfPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$BeatsTableFilterComposer get beatId {
    final $$BeatsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.beatId,
      referencedTable: $db.beats,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BeatsTableFilterComposer(
            $db: $db,
            $table: $db.beats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExportBatchesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExportBatchesTable> {
  $$ExportBatchesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get visitCount => $composableBuilder(
    column: $table.visitCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lineCount => $composableBuilder(
    column: $table.lineCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalValuePaise => $composableBuilder(
    column: $table.totalValuePaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get xlsxPath => $composableBuilder(
    column: $table.xlsxPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get csvPath => $composableBuilder(
    column: $table.csvPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pdfPath => $composableBuilder(
    column: $table.pdfPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$BeatsTableOrderingComposer get beatId {
    final $$BeatsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.beatId,
      referencedTable: $db.beats,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BeatsTableOrderingComposer(
            $db: $db,
            $table: $db.beats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExportBatchesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExportBatchesTable> {
  $$ExportBatchesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get visitCount => $composableBuilder(
    column: $table.visitCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lineCount =>
      $composableBuilder(column: $table.lineCount, builder: (column) => column);

  GeneratedColumn<int> get totalValuePaise => $composableBuilder(
    column: $table.totalValuePaise,
    builder: (column) => column,
  );

  GeneratedColumn<String> get xlsxPath =>
      $composableBuilder(column: $table.xlsxPath, builder: (column) => column);

  GeneratedColumn<String> get csvPath =>
      $composableBuilder(column: $table.csvPath, builder: (column) => column);

  GeneratedColumn<String> get pdfPath =>
      $composableBuilder(column: $table.pdfPath, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$BeatsTableAnnotationComposer get beatId {
    final $$BeatsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.beatId,
      referencedTable: $db.beats,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BeatsTableAnnotationComposer(
            $db: $db,
            $table: $db.beats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExportBatchesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExportBatchesTable,
          ExportBatche,
          $$ExportBatchesTableFilterComposer,
          $$ExportBatchesTableOrderingComposer,
          $$ExportBatchesTableAnnotationComposer,
          $$ExportBatchesTableCreateCompanionBuilder,
          $$ExportBatchesTableUpdateCompanionBuilder,
          (ExportBatche, $$ExportBatchesTableReferences),
          ExportBatche,
          PrefetchHooks Function({bool beatId})
        > {
  $$ExportBatchesTableTableManager(_$AppDatabase db, $ExportBatchesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExportBatchesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExportBatchesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExportBatchesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> beatId = const Value.absent(),
                Value<int> visitCount = const Value.absent(),
                Value<int> lineCount = const Value.absent(),
                Value<int> totalValuePaise = const Value.absent(),
                Value<String?> xlsxPath = const Value.absent(),
                Value<String?> csvPath = const Value.absent(),
                Value<String?> pdfPath = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExportBatchesCompanion(
                id: id,
                beatId: beatId,
                visitCount: visitCount,
                lineCount: lineCount,
                totalValuePaise: totalValuePaise,
                xlsxPath: xlsxPath,
                csvPath: csvPath,
                pdfPath: pdfPath,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String beatId,
                required int visitCount,
                required int lineCount,
                required int totalValuePaise,
                Value<String?> xlsxPath = const Value.absent(),
                Value<String?> csvPath = const Value.absent(),
                Value<String?> pdfPath = const Value.absent(),
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => ExportBatchesCompanion.insert(
                id: id,
                beatId: beatId,
                visitCount: visitCount,
                lineCount: lineCount,
                totalValuePaise: totalValuePaise,
                xlsxPath: xlsxPath,
                csvPath: csvPath,
                pdfPath: pdfPath,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ExportBatchesTable, ExportBatche>(table),
                  $$ExportBatchesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({beatId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (beatId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.beatId,
                                referencedTable: $$ExportBatchesTableReferences
                                    ._beatIdTable(db),
                                referencedColumn: $$ExportBatchesTableReferences
                                    ._beatIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ExportBatchesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExportBatchesTable,
      ExportBatche,
      $$ExportBatchesTableFilterComposer,
      $$ExportBatchesTableOrderingComposer,
      $$ExportBatchesTableAnnotationComposer,
      $$ExportBatchesTableCreateCompanionBuilder,
      $$ExportBatchesTableUpdateCompanionBuilder,
      (ExportBatche, $$ExportBatchesTableReferences),
      ExportBatche,
      PrefetchHooks Function({bool beatId})
    >;
typedef $$ModelRegistryTableCreateCompanionBuilder =
    ModelRegistryCompanion Function({
      required String id,
      required String kind,
      required String label,
      required String assetPath,
      Value<bool> loadedOk,
      Value<int?> loadMs,
      Value<double?> meanLatencyMs,
      Value<int> runCount,
      Value<String?> lastError,
      Value<int> rowid,
    });
typedef $$ModelRegistryTableUpdateCompanionBuilder =
    ModelRegistryCompanion Function({
      Value<String> id,
      Value<String> kind,
      Value<String> label,
      Value<String> assetPath,
      Value<bool> loadedOk,
      Value<int?> loadMs,
      Value<double?> meanLatencyMs,
      Value<int> runCount,
      Value<String?> lastError,
      Value<int> rowid,
    });

class $$ModelRegistryTableFilterComposer
    extends Composer<_$AppDatabase, $ModelRegistryTable> {
  $$ModelRegistryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get assetPath => $composableBuilder(
    column: $table.assetPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get loadedOk => $composableBuilder(
    column: $table.loadedOk,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get loadMs => $composableBuilder(
    column: $table.loadMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get meanLatencyMs => $composableBuilder(
    column: $table.meanLatencyMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get runCount => $composableBuilder(
    column: $table.runCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ModelRegistryTableOrderingComposer
    extends Composer<_$AppDatabase, $ModelRegistryTable> {
  $$ModelRegistryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get assetPath => $composableBuilder(
    column: $table.assetPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get loadedOk => $composableBuilder(
    column: $table.loadedOk,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get loadMs => $composableBuilder(
    column: $table.loadMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get meanLatencyMs => $composableBuilder(
    column: $table.meanLatencyMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get runCount => $composableBuilder(
    column: $table.runCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ModelRegistryTableAnnotationComposer
    extends Composer<_$AppDatabase, $ModelRegistryTable> {
  $$ModelRegistryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get assetPath =>
      $composableBuilder(column: $table.assetPath, builder: (column) => column);

  GeneratedColumn<bool> get loadedOk =>
      $composableBuilder(column: $table.loadedOk, builder: (column) => column);

  GeneratedColumn<int> get loadMs =>
      $composableBuilder(column: $table.loadMs, builder: (column) => column);

  GeneratedColumn<double> get meanLatencyMs => $composableBuilder(
    column: $table.meanLatencyMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get runCount =>
      $composableBuilder(column: $table.runCount, builder: (column) => column);

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);
}

class $$ModelRegistryTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ModelRegistryTable,
          ModelRegistryData,
          $$ModelRegistryTableFilterComposer,
          $$ModelRegistryTableOrderingComposer,
          $$ModelRegistryTableAnnotationComposer,
          $$ModelRegistryTableCreateCompanionBuilder,
          $$ModelRegistryTableUpdateCompanionBuilder,
          (
            ModelRegistryData,
            BaseReferences<
              _$AppDatabase,
              $ModelRegistryTable,
              ModelRegistryData
            >,
          ),
          ModelRegistryData,
          PrefetchHooks Function()
        > {
  $$ModelRegistryTableTableManager(_$AppDatabase db, $ModelRegistryTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ModelRegistryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ModelRegistryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ModelRegistryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<String> assetPath = const Value.absent(),
                Value<bool> loadedOk = const Value.absent(),
                Value<int?> loadMs = const Value.absent(),
                Value<double?> meanLatencyMs = const Value.absent(),
                Value<int> runCount = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ModelRegistryCompanion(
                id: id,
                kind: kind,
                label: label,
                assetPath: assetPath,
                loadedOk: loadedOk,
                loadMs: loadMs,
                meanLatencyMs: meanLatencyMs,
                runCount: runCount,
                lastError: lastError,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String kind,
                required String label,
                required String assetPath,
                Value<bool> loadedOk = const Value.absent(),
                Value<int?> loadMs = const Value.absent(),
                Value<double?> meanLatencyMs = const Value.absent(),
                Value<int> runCount = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ModelRegistryCompanion.insert(
                id: id,
                kind: kind,
                label: label,
                assetPath: assetPath,
                loadedOk: loadedOk,
                loadMs: loadMs,
                meanLatencyMs: meanLatencyMs,
                runCount: runCount,
                lastError: lastError,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ModelRegistryTable, ModelRegistryData>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $ModelRegistryTable,
                    ModelRegistryData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ModelRegistryTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ModelRegistryTable,
      ModelRegistryData,
      $$ModelRegistryTableFilterComposer,
      $$ModelRegistryTableOrderingComposer,
      $$ModelRegistryTableAnnotationComposer,
      $$ModelRegistryTableCreateCompanionBuilder,
      $$ModelRegistryTableUpdateCompanionBuilder,
      (
        ModelRegistryData,
        BaseReferences<_$AppDatabase, $ModelRegistryTable, ModelRegistryData>,
      ),
      ModelRegistryData,
      PrefetchHooks Function()
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      required String key,
      required String value,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> updatedAt,
      Value<int> rowid,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSetting,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSetting,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
          ),
          AppSetting,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AppSettingsTable, AppSetting>(table),
                  BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      AppSetting,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSetting,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
      ),
      AppSetting,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$BeatsTableTableManager get beats =>
      $$BeatsTableTableManager(_db, _db.beats);
  $$StoresTableTableManager get stores =>
      $$StoresTableTableManager(_db, _db.stores);
  $$SkusTableTableManager get skus => $$SkusTableTableManager(_db, _db.skus);
  $$SkuEmbeddingsTableTableManager get skuEmbeddings =>
      $$SkuEmbeddingsTableTableManager(_db, _db.skuEmbeddings);
  $$PlanogramEntriesTableTableManager get planogramEntries =>
      $$PlanogramEntriesTableTableManager(_db, _db.planogramEntries);
  $$VisitsTableTableManager get visits =>
      $$VisitsTableTableManager(_db, _db.visits);
  $$VisitPhotosTableTableManager get visitPhotos =>
      $$VisitPhotosTableTableManager(_db, _db.visitPhotos);
  $$DetectionsTableTableManager get detections =>
      $$DetectionsTableTableManager(_db, _db.detections);
  $$ShelfFactsTableTableManager get shelfFacts =>
      $$ShelfFactsTableTableManager(_db, _db.shelfFacts);
  $$OrderLinesTableTableManager get orderLines =>
      $$OrderLinesTableTableManager(_db, _db.orderLines);
  $$OverrideEventsTableTableManager get overrideEvents =>
      $$OverrideEventsTableTableManager(_db, _db.overrideEvents);
  $$ExportBatchesTableTableManager get exportBatches =>
      $$ExportBatchesTableTableManager(_db, _db.exportBatches);
  $$ModelRegistryTableTableManager get modelRegistry =>
      $$ModelRegistryTableTableManager(_db, _db.modelRegistry);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
}
