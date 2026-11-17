import 'dart:convert';
import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hef/src/data/models/chapter_directory_model.dart';
import 'package:hef/src/data/models/level_models/chapter_model.dart';
import 'package:http/http.dart' as http;
import 'package:hef/src/data/globals.dart';
import 'package:hef/src/data/models/user_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'chapter_details.g.dart';

class ChapterApiService {
  static Future<List<UserChapterModel>> fetchAllChapters() async {
    final url = Uri.parse('$baseUrl/user/list?limit=1000');
    print('Requesting URL: $url');
    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
    );

    log(response.body);
    if (response.statusCode == 200) {
      final dynamic data = json.decode(response.body)['data'];
      final usersJson = data as List<dynamic>? ?? [];

      // Extract unique chapters from users
      final Map<String, UserChapterModel> uniqueChapters = {};

      for (final user in usersJson) {
        final chapter = user['chapter'];
        if (chapter != null && chapter['_id'] != null) {
          final chapterId = chapter['_id'] as String;
          if (!uniqueChapters.containsKey(chapterId)) {
            uniqueChapters[chapterId] = UserChapterModel.fromJson(chapter);
          }
        }
      }

      return uniqueChapters.values.toList()
        ..sort((a, b) => (a.name ?? '')
            .toLowerCase()
            .compareTo((b.name ?? '').toLowerCase()));
    } else {
      print(json.decode(response.body)['message']);
      throw Exception(json.decode(response.body)['message']);
    }
  }

  static Future<ChapterDetailsModel> fetchChapterDetails(
      String chapterId) async {
    final url = Uri.parse('$baseUrl/hierarchy/chapter/$chapterId');
    print('Requesting URL: $url');
    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
    );

    log(response.body);
    if (response.statusCode == 200) {
      final dynamic data = json.decode(response.body)['data'];
      return ChapterDetailsModel.fromJson(data);
    } else {
      print(json.decode(response.body)['message']);
      throw Exception(json.decode(response.body)['message']);
    }
  }

  static Future<List<ChapterDirectoryItem>> fetchChapterDirectory() async {
    final headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };

    final responses = await Future.wait([
      http.get(Uri.parse('$baseUrl/hierarchy/chapter/list'), headers: headers),
      http.get(Uri.parse('$baseUrl/user/list?limit=1000'), headers: headers),
      http.get(Uri.parse('$baseUrl/hierarchy/district/list'), headers: headers),
    ]);

    final chaptersJson = _decodeList(responses[0]);
    final usersJson = _decodeList(responses[1]);
    final districtsJson = _decodeList(responses[2]);
    if (chaptersJson.isEmpty && usersJson.isEmpty) {
      throw Exception('Unable to load chapters');
    }

    final directory = <String, _ChapterAccumulator>{};
    final districtNamesById = <String, String>{};

    for (final item in districtsJson) {
      if (item is! Map) continue;
      final map = Map<String, dynamic>.from(item);
      final id = (map['_id'] ?? map['id'] ?? '').toString().trim();
      final name = (map['name'] ?? '').toString().trim();
      if (id.isNotEmpty && name.isNotEmpty) {
        districtNamesById[id] = name;
      }
    }

    for (final item in chaptersJson) {
      if (item is Map) {
        _mergeChapter(directory, Map<String, dynamic>.from(item));
      }
    }

    for (final item in usersJson) {
      if (item is! Map) continue;
      final user = Map<String, dynamic>.from(item);
      final chapter = user['chapter'];
      final userId = (user['_id'] ?? user['id'] ?? '').toString();
      if (chapter is String) {
        final existing = directory[chapter];
        if (existing != null && userId.isNotEmpty) {
          existing.memberIds.add(userId);
        }
        continue;
      }
      if (chapter is! Map) continue;
      _mergeChapter(
        directory,
        Map<String, dynamic>.from(chapter),
        memberId: userId,
      );
    }

    final districtIdsByName = <String, String>{
      for (final entry in districtNamesById.entries)
        entry.value.trim().toLowerCase(): entry.key,
    };

    for (final entry in directory.values) {
      if (entry.districtName.isEmpty && entry.districtId.isNotEmpty) {
        final resolved = districtNamesById[entry.districtId];
        if (resolved != null && resolved.isNotEmpty) {
          entry.districtName = resolved;
        } else {
          // Some payloads store the district name in districtId.
          final namedId = districtIdsByName[entry.districtId.toLowerCase()];
          if (namedId != null) {
            entry.districtName = districtNamesById[namedId] ?? entry.districtId;
            entry.districtId = namedId;
          }
        }
      }

      if (entry.districtId.isEmpty && entry.districtName.isNotEmpty) {
        final namedId = districtIdsByName[entry.districtName.toLowerCase()];
        if (namedId != null) entry.districtId = namedId;
      }

      if (entry.districtId.isEmpty && entry.location.isNotEmpty) {
        final locationLower = entry.location.toLowerCase();
        for (final district in districtNamesById.entries) {
          final nameLower = district.value.toLowerCase();
          if (locationLower == nameLower ||
              locationLower.startsWith('$nameLower,')) {
            entry.districtId = district.key;
            entry.districtName = district.value;
            break;
          }
        }
      }

      if (entry.location.isEmpty && entry.districtName.isNotEmpty) {
        entry.location = entry.districtName;
      }
    }

    // Chapter list often omits/mismatches districtIds. Resolve district names
    // the same way the filter does: chapters under each district.
    if (districtNamesById.isNotEmpty) {
      final chapterDistrictById = <String, ({String id, String name})>{};
      final chapterDistrictByName = <String, ({String id, String name})>{};

      await Future.wait(districtNamesById.entries.map((district) async {
        try {
          final response = await http.get(
            Uri.parse('$baseUrl/hierarchy/levels/${district.key}/district'),
            headers: headers,
          );
          for (final item in _decodeList(response)) {
            if (item is! Map) continue;
            final map = Map<String, dynamic>.from(item);
            final chapterId =
                (map['_id'] ?? map['id'] ?? '').toString().trim();
            final chapterName = (map['name'] ?? '').toString().trim();
            final link = (id: district.key, name: district.value);
            if (chapterId.isNotEmpty) {
              chapterDistrictById[chapterId] = link;
            }
            if (chapterName.isNotEmpty) {
              chapterDistrictByName[chapterName.toLowerCase()] = link;
            }
          }
        } catch (error) {
          log('Failed to resolve district ${district.key}: $error');
        }
      }));

      for (final entry in directory.values) {
        final link = chapterDistrictById[entry.id] ??
            chapterDistrictByName[entry.name.trim().toLowerCase()];
        if (link == null) continue;
        entry.districtId = link.id;
        entry.districtName = link.name;
        if (entry.location.isEmpty) {
          entry.location = link.name;
        }
      }
    }

    final items = directory.values.map((entry) => entry.toItem()).toList()
      ..sort((a, b) {
        final byCount = b.memberCount.compareTo(a.memberCount);
        if (byCount != 0) return byCount;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });
    return items;
  }
}

List<dynamic> _decodeList(http.Response response) {
  if (response.statusCode != 200) {
    log('Chapter directory request failed (${response.statusCode}) ${response.request?.url}');
    return const [];
  }
  try {
    final decoded = json.decode(response.body);
    if (decoded is! Map) return const [];
    return _asList(decoded['data']);
  } catch (error) {
    log('Chapter directory parse failed: $error');
    return const [];
  }
}

List<dynamic> _asList(dynamic data) {
  if (data is List) return data;
  if (data is Map) {
    for (final key in ['body', 'chapters', 'users', 'list', 'docs', 'data']) {
      final value = data[key];
      if (value is List) return value;
    }
  }
  return const [];
}

void _mergeChapter(
  Map<String, _ChapterAccumulator> directory,
  Map<String, dynamic> json, {
  String? memberId,
}) {
  final id = (json['_id'] ?? json['id'] ?? json['Name'] ?? '').toString();
  final name =
      (json['name'] ?? json['ChapterName'] ?? json['Name'] ?? '').toString();
  if (id.isEmpty || name.isEmpty || id == name) {
    final fallbackId = (json['_id'] ?? json['id'] ?? '').toString();
    if (fallbackId.isEmpty || name.isEmpty) return;
  }
  final resolvedId = (json['_id'] ?? json['id'] ?? '').toString().isNotEmpty
      ? (json['_id'] ?? json['id']).toString()
      : id;
  if (resolvedId.isEmpty || name.isEmpty) return;

  final location = _readLocation(json);
  final image = _readImage(json);
  final createdAt = DateTime.tryParse((json['createdAt'] ?? '').toString());
  final apiCount = _readCount(json);

  final current = directory.putIfAbsent(
    resolvedId,
    () => _ChapterAccumulator(id: resolvedId, name: name.trim()),
  );
  if (current.name.trim().isEmpty) current.name = name.trim();
  if (name.trim().isNotEmpty) current.name = name.trim();
  if (current.location.isEmpty && location.location.isNotEmpty) {
    current.location = location.location;
  }
  if (current.districtName.isEmpty && location.districtName.isNotEmpty) {
    current.districtName = location.districtName;
  }
  if (current.districtId.isEmpty && location.districtId.isNotEmpty) {
    current.districtId = location.districtId;
  }
  if ((current.image == null || current.image!.isEmpty) && image != null) {
    current.image = image;
  }
  if (current.createdAt == null && createdAt != null) {
    current.createdAt = createdAt;
  }
  if (apiCount > current.apiMemberCount) current.apiMemberCount = apiCount;
  if (memberId != null && memberId.isNotEmpty) {
    current.memberIds.add(memberId);
  }
}

({String location, String districtName, String districtId}) _readLocation(
  Map<String, dynamic> json,
) {
  final district = json['districtId'] ??
      json['district'] ??
      json['DistrictId'] ??
      json['District'];
  if (district is Map) {
    final districtMap = Map<String, dynamic>.from(district);
    final districtName = (districtMap['name'] ?? districtMap['Name'] ?? '')
        .toString()
        .trim();
    final districtId = (districtMap['_id'] ??
            districtMap['id'] ??
            districtMap['Name'] ??
            '')
        .toString()
        .trim();
    var stateName = '';
    final zone = districtMap['zoneId'] ?? districtMap['zone'];
    if (zone is Map) {
      final state = zone['stateId'] ?? zone['state'];
      if (state is Map) {
        stateName = (state['name'] ?? '').toString().trim();
      }
    }
    final location = [districtName, stateName]
        .where((part) => part.isNotEmpty)
        .join(', ');
    return (
      location: location,
      districtName: districtName,
      districtId: districtId,
    );
  }
  final fallback =
      (json['location'] ?? json['address'] ?? '').toString().trim();
  if (district is String && district.trim().isNotEmpty) {
    return (
      location: fallback,
      districtName: '',
      districtId: district.trim(),
    );
  }
  if (district != null) {
    final raw = district.toString().trim();
    if (raw.isNotEmpty && raw != 'null' && !raw.startsWith('{')) {
      return (
        location: fallback,
        districtName: '',
        districtId: raw,
      );
    }
  }
  return (location: fallback, districtName: '', districtId: '');
}

String? _readImage(Map<String, dynamic> json) {
  for (final key in ['image', 'logo', 'thumbnail', 'photo']) {
    final value = json[key];
    if (value is String && value.trim().isNotEmpty) return value.trim();
  }
  return null;
}

int _readCount(Map<String, dynamic> json) {
  for (final key in ['memberCount', 'membersCount', 'totalMembers', 'members']) {
    final value = json[key];
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
  }
  return 0;
}

class _ChapterAccumulator {
  final String id;
  String name;
  String location = '';
  String districtName = '';
  String districtId = '';
  String? image;
  DateTime? createdAt;
  int apiMemberCount = 0;
  final Set<String> memberIds;

  _ChapterAccumulator({
    required this.id,
    required this.name,
  }) : memberIds = <String>{};

  ChapterDirectoryItem toItem() {
    final counted = memberIds.length;
    return ChapterDirectoryItem(
      id: id,
      name: name,
      location: location,
      districtName: districtName,
      districtId: districtId,
      memberCount: counted > apiMemberCount ? counted : apiMemberCount,
      image: image,
      createdAt: createdAt,
    );
  }
}

final chapterDirectoryProvider =
    FutureProvider.autoDispose<List<ChapterDirectoryItem>>((ref) {
  return ChapterApiService.fetchChapterDirectory();
});

@riverpod
Future<List<UserChapterModel>> fetchAllChapters(Ref ref) {
  return ChapterApiService.fetchAllChapters();
}

@riverpod
Future<ChapterDetailsModel> fetchChapterDetails(Ref ref, String chapterId) {
  return ChapterApiService.fetchChapterDetails(chapterId);
}
