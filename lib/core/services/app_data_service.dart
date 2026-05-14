import 'dart:io';
import 'dart:typed_data';

import 'package:ebeveyn_koprusu/core/errors/app_exception.dart';
import 'package:ebeveyn_koprusu/core/models/domain_models.dart';
import 'package:ebeveyn_koprusu/core/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppWorkspace {
  const AppWorkspace({
    required this.userId,
    required this.familyId,
    required this.childId,
  });

  final String userId;
  final String familyId;
  final String? childId;
}

class AppDocument {
  const AppDocument({
    required this.id,
    required this.title,
    required this.category,
    required this.createdAt,
    required this.sizeBytes,
    required this.isSensitive,
  });

  final String id;
  final String title;
  final String category;
  final DateTime createdAt;
  final int? sizeBytes;
  final bool isSensitive;
}

class AppDataService {
  const AppDataService._();

  static SupabaseClient get _client {
    final client = SupabaseService.client;
    if (client == null) {
      throw const AppException('Supabase baglantisi bulunamadi.');
    }
    return client;
  }

  static User get _user {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw const AppException('Devam etmek icin giris yapmalisin.');
    }
    return user;
  }

  static bool get hasSession =>
      SupabaseService.client?.auth.currentUser != null;

  static String friendlyError(Object error) {
    if (error is AppException) return error.message;
    if (error is AuthException) return error.message;
    if (error is PostgrestException) return error.message;
    if (error is StorageException) return error.message;
    return error.toString();
  }

  static Future<void> signOut() async {
    await _client.auth.signOut();
  }

  static Future<void> ensureStarterWorkspace({
    String? fullName,
    bool marketingConsent = false,
  }) async {
    final client = _client;
    final user = _user;
    final now = DateTime.now().toUtc().toIso8601String();
    final resolvedName = _resolveName(fullName, user);

    final profilePayload = <String, dynamic>{
      'id': user.id,
      'full_name': resolvedName,
      'email': user.email,
      'default_role': 'parent',
      'locale': 'tr',
      'timezone': 'Europe/Istanbul',
      'terms_accepted_at': now,
      'kvkk_accepted_at': now,
    };
    if (marketingConsent) {
      profilePayload['marketing_consent_at'] = now;
    }

    await client.from('profiles').upsert(profilePayload, onConflict: 'id');

    final existingMembership = await client
        .from('family_members')
        .select('family_id')
        .eq('user_id', user.id)
        .eq('status', 'active')
        .limit(1)
        .maybeSingle();

    if (existingMembership != null) {
      await _ensureDefaultChild(existingMembership['family_id'] as String);
      return;
    }

    final family = await client
        .from('families')
        .insert({
          'name': '$resolvedName ailesi',
          'created_by': user.id,
          'is_single_parent_mode': true,
        })
        .select('id')
        .single();
    final familyId = family['id'] as String;

    await client.from('family_members').insert({
      'family_id': familyId,
      'user_id': user.id,
      'role': 'parent',
      'relationship_label': 'Ebeveyn',
      'status': 'active',
      'access_level': 'full',
      'invited_by': user.id,
      'joined_at': now,
    });

    await _ensureDefaultChild(familyId);
  }

  static Future<AppWorkspace> requireWorkspace() async {
    final client = _client;
    final user = _user;

    var membership = await client
        .from('family_members')
        .select('family_id')
        .eq('user_id', user.id)
        .eq('status', 'active')
        .limit(1)
        .maybeSingle();

    if (membership == null) {
      await ensureStarterWorkspace();
      membership = await client
          .from('family_members')
          .select('family_id')
          .eq('user_id', user.id)
          .eq('status', 'active')
          .limit(1)
          .maybeSingle();
    }

    if (membership == null) {
      throw const AppException('Aile calisma alani olusturulamadi.');
    }

    final familyId = membership['family_id'] as String;
    final childId = await _ensureDefaultChild(familyId);
    return AppWorkspace(userId: user.id, familyId: familyId, childId: childId);
  }

  static Future<List<CustodyEvent>> fetchCustodyEvents() async {
    final workspace = await requireWorkspace();
    final rows = await _client
        .from('custody_events')
        .select('id,title,start_at,end_at,location_text,status')
        .eq('family_id', workspace.familyId)
        .order('start_at');

    return [
      for (final row in rows as List<dynamic>)
        _custodyEventFromRow(row as Map<String, dynamic>),
    ];
  }

  static Future<CustodyEvent> addCustodyEvent({
    required String title,
    required DateTime startAt,
    required DateTime endAt,
    required String location,
  }) async {
    final workspace = await requireWorkspace();
    if (workspace.childId == null) {
      throw const AppException('Once cocuk profili olusturulmali.');
    }

    final row = await _client
        .from('custody_events')
        .insert({
          'family_id': workspace.familyId,
          'child_id': workspace.childId,
          'assigned_parent_id': workspace.userId,
          'title': title.trim(),
          'start_at': startAt.toUtc().toIso8601String(),
          'end_at': endAt.toUtc().toIso8601String(),
          'location_text': location.trim().isEmpty ? null : location.trim(),
          'event_type': 'custody',
          'status': 'scheduled',
          'created_by': workspace.userId,
        })
        .select('id,title,start_at,end_at,location_text,status')
        .single();

    return _custodyEventFromRow(row);
  }

  static Future<List<ExpenseItem>> fetchExpenses() async {
    final workspace = await requireWorkspace();
    final rows = await _client
        .from('expenses')
        .select('id,title,category,amount,requested_share,status,created_at')
        .eq('family_id', workspace.familyId)
        .order('created_at', ascending: false);

    return [
      for (final row in rows as List<dynamic>)
        _expenseFromRow(row as Map<String, dynamic>),
    ];
  }

  static Future<ExpenseItem> addExpense({
    required String title,
    required String category,
    required double amount,
    required String description,
  }) async {
    final workspace = await requireWorkspace();
    final requestedShare = amount / 2;
    final row = await _client
        .from('expenses')
        .insert({
          'family_id': workspace.familyId,
          'child_id': workspace.childId,
          'title': title.trim(),
          'category': category.trim(),
          'amount': amount,
          'requested_share': requestedShare,
          'share_type': 'half',
          'description': description.trim().isEmpty ? null : description.trim(),
          'status': 'sent',
          'created_by': workspace.userId,
          'paid_by': workspace.userId,
        })
        .select('id,title,category,amount,requested_share,status,created_at')
        .single();

    return _expenseFromRow(row);
  }

  static Future<List<AppDocument>> fetchDocuments() async {
    final workspace = await requireWorkspace();
    final rows = await _client
        .from('documents')
        .select('id,title,category,created_at,size_bytes,is_sensitive')
        .eq('family_id', workspace.familyId)
        .order('created_at', ascending: false);

    return [
      for (final row in rows as List<dynamic>)
        _documentFromRow(row as Map<String, dynamic>),
    ];
  }

  static Future<AppDocument> uploadDocument({
    required String title,
    required String category,
    required String fileName,
    required int? sizeBytes,
    required String? mimeType,
    Uint8List? bytes,
    File? file,
  }) async {
    if (bytes == null && file == null) {
      throw const AppException('Yuklenecek dosya okunamadi.');
    }

    final workspace = await requireWorkspace();
    final safeName = _safeFileName(fileName);
    final storagePath =
        'families/${workspace.familyId}/documents/'
        '${DateTime.now().millisecondsSinceEpoch}-$safeName';

    final bucket = _client.storage.from('documents');
    final options = FileOptions(contentType: mimeType);
    if (bytes != null) {
      await bucket.uploadBinary(storagePath, bytes, fileOptions: options);
    } else {
      await bucket.upload(storagePath, file!, fileOptions: options);
    }

    final row = await _client
        .from('documents')
        .insert({
          'family_id': workspace.familyId,
          'child_id': workspace.childId,
          'uploaded_by': workspace.userId,
          'category': category,
          'title': title.trim().isEmpty ? fileName : title.trim(),
          'storage_bucket': 'documents',
          'storage_path': storagePath,
          'mime_type': mimeType,
          'size_bytes': sizeBytes,
          'is_sensitive': category == 'health' || category == 'legal',
          'visible_to_other_parent': true,
        })
        .select('id,title,category,created_at,size_bytes,is_sensitive')
        .single();

    return _documentFromRow(row);
  }

  static Future<String?> _ensureDefaultChild(String familyId) async {
    final client = _client;
    final user = _user;
    final existingChild = await client
        .from('children')
        .select('id')
        .eq('family_id', familyId)
        .limit(1)
        .maybeSingle();
    if (existingChild != null) return existingChild['id'] as String;

    final child = await client
        .from('children')
        .insert({
          'family_id': familyId,
          'full_name': 'Deniz',
          'created_by': user.id,
        })
        .select('id')
        .single();
    return child['id'] as String;
  }

  static String _resolveName(String? fullName, User user) {
    final trimmed = fullName?.trim();
    if (trimmed != null && trimmed.isNotEmpty) return trimmed;
    final metadataName = user.userMetadata?['full_name']?.toString().trim();
    if (metadataName != null && metadataName.isNotEmpty) return metadataName;
    final email = user.email;
    if (email != null && email.contains('@')) return email.split('@').first;
    return 'Ebeveyn';
  }

  static String _safeFileName(String name) {
    final safe = name.trim().replaceAll(RegExp(r'[^A-Za-z0-9._-]+'), '_');
    return safe.isEmpty ? 'belge' : safe;
  }

  static CustodyEvent _custodyEventFromRow(Map<String, dynamic> row) {
    final startAt = DateTime.parse(row['start_at'] as String).toLocal();
    final endAt = DateTime.parse(row['end_at'] as String).toLocal();
    return CustodyEvent(
      id: row['id'] as String,
      childName: 'Deniz',
      title: row['title'] as String,
      startAt: startAt,
      endAt: endAt,
      assignedParent: 'Sen',
      location: row['location_text']?.toString() ?? '',
      status: _mapEventStatus(row['status']?.toString()),
    );
  }

  static HandoverStatus _mapEventStatus(String? status) {
    return switch (status) {
      'completed' => HandoverStatus.completed,
      'missed' => HandoverStatus.missed,
      'cancelled' => HandoverStatus.missed,
      'disputed' => HandoverStatus.disputed,
      'change_requested' => HandoverStatus.delayed,
      'accepted' => HandoverStatus.arrived,
      _ => HandoverStatus.planned,
    };
  }

  static ExpenseItem _expenseFromRow(Map<String, dynamic> row) {
    return ExpenseItem(
      id: row['id'] as String,
      title: row['title'] as String,
      category: row['category'] as String,
      amount: (row['amount'] as num).toDouble(),
      requestedShare: (row['requested_share'] as num).toDouble(),
      status: _mapExpenseStatus(row['status']?.toString()),
      date: DateTime.parse(row['created_at'] as String).toLocal(),
    );
  }

  static ExpenseStatus _mapExpenseStatus(String? status) {
    return switch (status) {
      'accepted' || 'partially_accepted' => ExpenseStatus.accepted,
      'paid' || 'partially_paid' => ExpenseStatus.paid,
      'overdue' => ExpenseStatus.overdue,
      'disputed' || 'rejected' => ExpenseStatus.disputed,
      _ => ExpenseStatus.sent,
    };
  }

  static AppDocument _documentFromRow(Map<String, dynamic> row) {
    return AppDocument(
      id: row['id'] as String,
      title: row['title'] as String,
      category: row['category']?.toString() ?? 'other',
      createdAt: DateTime.parse(row['created_at'] as String).toLocal(),
      sizeBytes: (row['size_bytes'] as num?)?.toInt(),
      isSensitive: row['is_sensitive'] == true,
    );
  }
}
