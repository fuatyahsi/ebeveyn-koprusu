import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:ebeveyn_koprusu/core/errors/app_exception.dart';
import 'package:ebeveyn_koprusu/core/models/domain_models.dart';
import 'package:ebeveyn_koprusu/core/services/supabase_service.dart';
import 'package:ebeveyn_koprusu/core/utils/hash_utils.dart';
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

class FamilyOverview {
  const FamilyOverview({
    required this.id,
    required this.name,
    required this.isSingleParentMode,
    required this.members,
    required this.invitations,
  });

  final String id;
  final String name;
  final bool isSingleParentMode;
  final List<FamilyMemberInfo> members;
  final List<FamilyInvitationInfo> invitations;
}

class FamilyMemberInfo {
  const FamilyMemberInfo({
    required this.id,
    required this.role,
    required this.label,
    required this.status,
    required this.accessLevel,
    required this.userId,
  });

  final String id;
  final String role;
  final String label;
  final String status;
  final String accessLevel;
  final String? userId;
}

class FamilyInvitationInfo {
  const FamilyInvitationInfo({
    required this.id,
    required this.contact,
    required this.role,
    required this.code,
    required this.status,
    required this.expiresAt,
  });

  final String id;
  final String contact;
  final String role;
  final String code;
  final String status;
  final DateTime expiresAt;
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

class LiveRecord {
  const LiveRecord({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.createdAt,
    this.extra,
  });

  final String id;
  final String title;
  final String subtitle;
  final String status;
  final DateTime createdAt;
  final Map<String, dynamic>? extra;
}

class VisionFeatureRecord {
  const VisionFeatureRecord({
    required this.id,
    required this.featureKey,
    required this.title,
    required this.detail,
    required this.status,
    required this.createdAt,
    required this.payload,
  });

  final String id;
  final String featureKey;
  final String title;
  final String detail;
  final String status;
  final DateTime createdAt;
  final Map<String, dynamic> payload;
}

class MessageItem {
  const MessageItem({
    required this.id,
    required this.body,
    required this.senderId,
    required this.createdAt,
    required this.isMine,
  });

  final String id;
  final String body;
  final String senderId;
  final DateTime createdAt;
  final bool isMine;
}

class MessageWorkspace {
  const MessageWorkspace({required this.thread, required this.messages});

  final LiveRecord thread;
  final List<MessageItem> messages;
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

  static Future<FamilyOverview> fetchFamilyOverview() async {
    final workspace = await requireWorkspace();
    final family = await _client
        .from('families')
        .select('id,name,is_single_parent_mode')
        .eq('id', workspace.familyId)
        .single();

    final members = await _client
        .from('family_members')
        .select('id,user_id,role,relationship_label,status,access_level')
        .eq('family_id', workspace.familyId)
        .order('created_at');

    final invitations = await _client
        .from('family_invitations')
        .select(
          'id,invited_email,invited_phone,invited_role,invitation_code,status,expires_at',
        )
        .eq('family_id', workspace.familyId)
        .order('created_at', ascending: false);

    return FamilyOverview(
      id: family['id'] as String,
      name: family['name']?.toString() ?? 'Ailem',
      isSingleParentMode: family['is_single_parent_mode'] == true,
      members: [
        for (final row in members as List<dynamic>)
          _familyMemberFromRow(row as Map<String, dynamic>),
      ],
      invitations: [
        for (final row in invitations as List<dynamic>)
          _familyInvitationFromRow(row as Map<String, dynamic>),
      ],
    );
  }

  static Future<void> updateFamily({
    required String name,
    required bool isSingleParentMode,
  }) async {
    final workspace = await requireWorkspace();
    await _client
        .from('families')
        .update({
          'name': name.trim().isEmpty ? 'Ailem' : name.trim(),
          'is_single_parent_mode': isSingleParentMode,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', workspace.familyId);
  }

  static Future<FamilyInvitationInfo> createFamilyInvitation({
    required String email,
    required String phone,
    required String role,
  }) async {
    final workspace = await requireWorkspace();
    if (email.trim().isEmpty && phone.trim().isEmpty) {
      throw const AppException('E-posta veya telefon girmelisin.');
    }

    final code = _generateInvitationCode();
    final row = await _client
        .from('family_invitations')
        .insert({
          'family_id': workspace.familyId,
          'invited_email': email.trim().isEmpty ? null : email.trim(),
          'invited_phone': phone.trim().isEmpty ? null : phone.trim(),
          'invited_role': role,
          'invitation_code': code,
          'expires_at': DateTime.now()
              .toUtc()
              .add(const Duration(days: 7))
              .toIso8601String(),
          'created_by': workspace.userId,
        })
        .select(
          'id,invited_email,invited_phone,invited_role,invitation_code,status,expires_at',
        )
        .single();

    return _familyInvitationFromRow(row);
  }

  static Future<void> acceptFamilyInvitation(String code) async {
    final trimmed = code.trim().toUpperCase();
    if (trimmed.isEmpty) throw const AppException('Davet kodu gerekli.');
    await ensureStarterWorkspace();
    await _client.rpc(
      'accept_family_invitation',
      params: {'invitation_code_input': trimmed},
    );
  }

  static Future<List<LiveRecord>> fetchLiveRecords(String moduleKey) async {
    final workspace = await requireWorkspace();
    final user = _user;

    switch (moduleKey) {
      case 'children':
        final rows = await _client
            .from('children')
            .select('id,full_name,notes,created_at')
            .eq('family_id', workspace.familyId)
            .order('created_at', ascending: false);
        return [
          for (final row in rows as List<dynamic>)
            _record(
              row as Map<String, dynamic>,
              titleKey: 'full_name',
              subtitleKey: 'notes',
              status: 'aktif',
            ),
        ];
      case 'contacts':
        final rows = await _client
            .from('contacts')
            .select(
              'id,full_name,relation,phone,email,notes,approval_status,created_at',
            )
            .eq('family_id', workspace.familyId)
            .order('created_at', ascending: false);
        return [
          for (final row in rows as List<dynamic>)
            _record(
              row as Map<String, dynamic>,
              titleKey: 'full_name',
              subtitle: [
                row['relation'],
                row['phone'],
                row['email'],
                row['notes'],
              ].where((v) => v != null && v.toString().isNotEmpty).join(' · '),
              status: row['approval_status']?.toString() ?? 'draft',
            ),
        ];
      case 'decisions':
        final rows = await _client
            .from('decision_requests')
            .select('id,title,description,status,created_at')
            .eq('family_id', workspace.familyId)
            .order('created_at', ascending: false);
        return [
          for (final row in rows as List<dynamic>)
            _record(
              row as Map<String, dynamic>,
              titleKey: 'title',
              subtitleKey: 'description',
              status: row['status']?.toString() ?? 'sent',
            ),
        ];
      case 'disputes':
        final rows = await _client
            .from('disputes')
            .select('id,title,description,status,created_at')
            .eq('family_id', workspace.familyId)
            .order('created_at', ascending: false);
        return [
          for (final row in rows as List<dynamic>)
            _record(
              row as Map<String, dynamic>,
              titleKey: 'title',
              subtitleKey: 'description',
              status: row['status']?.toString() ?? 'open',
            ),
        ];
      case 'journal':
        final rows = await _client
            .from('personal_journal_entries')
            .select('id,title,body,include_in_report,created_at')
            .eq('family_id', workspace.familyId)
            .eq('user_id', user.id)
            .order('created_at', ascending: false);
        return [
          for (final row in rows as List<dynamic>)
            _record(
              row as Map<String, dynamic>,
              titleKey: 'title',
              subtitleKey: 'body',
              status: row['include_in_report'] == true ? 'raporda' : 'gizli',
            ),
        ];
      case 'emergency':
        final rows = await _client
            .from('emergency_events')
            .select('id,title,description,status,created_at')
            .eq('family_id', workspace.familyId)
            .order('created_at', ascending: false);
        return [
          for (final row in rows as List<dynamic>)
            _record(
              row as Map<String, dynamic>,
              titleKey: 'title',
              subtitleKey: 'description',
              status: row['status']?.toString() ?? 'open',
            ),
        ];
      case 'handover':
        final rows = await _client
            .from('handover_logs')
            .select('id,action,status,note,created_at')
            .eq('family_id', workspace.familyId)
            .order('created_at', ascending: false);
        return [
          for (final row in rows as List<dynamic>)
            _record(
              row as Map<String, dynamic>,
              titleKey: 'action',
              subtitleKey: 'note',
              status: row['status']?.toString() ?? 'planned',
            ),
        ];
      case 'reports':
        final rows = await _client
            .from('reports')
            .select(
              'id,report_type,report_hash,verification_token,generated_at',
            )
            .eq('family_id', workspace.familyId)
            .order('generated_at', ascending: false);
        return [
          for (final row in rows as List<dynamic>)
            LiveRecord(
              id: row['id'] as String,
              title: 'Koordinasyon raporu',
              subtitle:
                  'Token: ${row['verification_token'] ?? '-'} · ${row['report_hash'] ?? '-'}',
              status: row['report_type']?.toString() ?? 'coordination',
              createdAt: DateTime.parse(
                row['generated_at'] as String,
              ).toLocal(),
            ),
        ];
      case 'admin':
        final rows = await _client
            .from('audit_logs')
            .select('id,action,entity_type,current_hash,created_at')
            .eq('family_id', workspace.familyId)
            .order('created_at', ascending: false)
            .limit(20);
        return [
          for (final row in rows as List<dynamic>)
            LiveRecord(
              id: row['id'] as String,
              title: row['action']?.toString() ?? 'Audit',
              subtitle:
                  '${row['entity_type'] ?? 'entity'} · ${row['current_hash'] ?? ''}',
              status: 'audit',
              createdAt: DateTime.parse(row['created_at'] as String).toLocal(),
            ),
        ];
      default:
        throw AppException('Bilinmeyen modul: $moduleKey');
    }
  }

  static Future<LiveRecord> addLiveRecord({
    required String moduleKey,
    required String title,
    required String detail,
  }) async {
    final workspace = await requireWorkspace();
    final user = _user;
    final cleanTitle = title.trim();
    final cleanDetail = detail.trim();
    if (cleanTitle.isEmpty) throw const AppException('Baslik zorunlu.');

    switch (moduleKey) {
      case 'children':
        final row = await _client
            .from('children')
            .insert({
              'family_id': workspace.familyId,
              'full_name': cleanTitle,
              'notes': cleanDetail.isEmpty ? null : cleanDetail,
              'created_by': user.id,
            })
            .select('id,full_name,notes,created_at')
            .single();
        return _record(row, titleKey: 'full_name', subtitleKey: 'notes');
      case 'contacts':
        final row = await _client
            .from('contacts')
            .insert({
              'family_id': workspace.familyId,
              'child_id': workspace.childId,
              'full_name': cleanTitle,
              'relation': cleanDetail.isEmpty ? 'Yakın' : cleanDetail,
              'notes': cleanDetail.isEmpty ? null : cleanDetail,
              'can_pickup': true,
              'can_be_called_in_emergency': true,
              'approval_status': 'sent',
              'created_by': user.id,
              'updated_by': user.id,
            })
            .select('id,full_name,relation,notes,approval_status,created_at')
            .single();
        return _record(
          row,
          titleKey: 'full_name',
          subtitleKey: 'relation',
          status: row['approval_status']?.toString() ?? 'sent',
        );
      case 'decisions':
        final row = await _client
            .from('decision_requests')
            .insert({
              'family_id': workspace.familyId,
              'child_id': workspace.childId,
              'decision_type': 'general',
              'title': cleanTitle,
              'description': cleanDetail.isEmpty ? null : cleanDetail,
              'requested_by': user.id,
              'response_due_at': DateTime.now()
                  .toUtc()
                  .add(const Duration(days: 3))
                  .toIso8601String(),
              'status': 'sent',
            })
            .select('id,title,description,status,created_at')
            .single();
        return _record(
          row,
          titleKey: 'title',
          subtitleKey: 'description',
          status: row['status']?.toString() ?? 'sent',
        );
      case 'disputes':
        final row = await _client
            .from('disputes')
            .insert({
              'family_id': workspace.familyId,
              'child_id': workspace.childId,
              'dispute_type': 'general',
              'title': cleanTitle,
              'description': cleanDetail.isEmpty ? null : cleanDetail,
              'opened_by': user.id,
              'status': 'open',
            })
            .select('id,title,description,status,created_at')
            .single();
        return _record(
          row,
          titleKey: 'title',
          subtitleKey: 'description',
          status: row['status']?.toString() ?? 'open',
        );
      case 'journal':
        final row = await _client
            .from('personal_journal_entries')
            .insert({
              'family_id': workspace.familyId,
              'child_id': workspace.childId,
              'user_id': user.id,
              'title': cleanTitle,
              'body': cleanDetail.isEmpty ? null : cleanDetail,
              'category': 'note',
              'include_in_report': false,
            })
            .select('id,title,body,include_in_report,created_at')
            .single();
        return _record(
          row,
          titleKey: 'title',
          subtitleKey: 'body',
          status: 'gizli',
        );
      case 'emergency':
        final row = await _client
            .from('emergency_events')
            .insert({
              'family_id': workspace.familyId,
              'child_id': workspace.childId,
              'emergency_type': 'general',
              'title': cleanTitle,
              'description': cleanDetail.isEmpty ? null : cleanDetail,
              'opened_by': user.id,
              'status': 'open',
            })
            .select('id,title,description,status,created_at')
            .single();
        return _record(
          row,
          titleKey: 'title',
          subtitleKey: 'description',
          status: row['status']?.toString() ?? 'open',
        );
      case 'handover':
        return addHandoverLog(action: cleanTitle, note: cleanDetail);
      case 'reports':
        return createReport();
      default:
        throw AppException('$moduleKey icin ekleme desteklenmiyor.');
    }
  }

  static Future<void> updateLiveRecord({
    required String moduleKey,
    required String id,
    required String title,
    required String detail,
  }) async {
    final user = _user;
    final cleanTitle = title.trim();
    final cleanDetail = detail.trim();
    if (cleanTitle.isEmpty) throw const AppException('Baslik zorunlu.');

    switch (moduleKey) {
      case 'children':
        await _client
            .from('children')
            .update({
              'full_name': cleanTitle,
              'notes': cleanDetail.isEmpty ? null : cleanDetail,
              'updated_at': DateTime.now().toUtc().toIso8601String(),
            })
            .eq('id', id);
        return;
      case 'contacts':
        await _client
            .from('contacts')
            .update({
              'full_name': cleanTitle,
              'notes': cleanDetail.isEmpty ? null : cleanDetail,
              'updated_by': user.id,
              'updated_at': DateTime.now().toUtc().toIso8601String(),
            })
            .eq('id', id);
        return;
      case 'decisions':
        await _client
            .from('decision_requests')
            .update({
              'title': cleanTitle,
              'description': cleanDetail.isEmpty ? null : cleanDetail,
              'updated_at': DateTime.now().toUtc().toIso8601String(),
            })
            .eq('id', id);
        return;
      case 'disputes':
        await _client
            .from('disputes')
            .update({
              'title': cleanTitle,
              'description': cleanDetail.isEmpty ? null : cleanDetail,
              'updated_at': DateTime.now().toUtc().toIso8601String(),
            })
            .eq('id', id);
        return;
      case 'journal':
        await _client
            .from('personal_journal_entries')
            .update({
              'title': cleanTitle,
              'body': cleanDetail.isEmpty ? null : cleanDetail,
              'updated_at': DateTime.now().toUtc().toIso8601String(),
            })
            .eq('id', id);
        return;
      case 'emergency':
        await _client
            .from('emergency_events')
            .update({
              'title': cleanTitle,
              'description': cleanDetail.isEmpty ? null : cleanDetail,
              'updated_at': DateTime.now().toUtc().toIso8601String(),
            })
            .eq('id', id);
        return;
      default:
        throw AppException('$moduleKey icin guncelleme desteklenmiyor.');
    }
  }

  static Future<void> setLiveRecordStatus({
    required String moduleKey,
    required String id,
    required String status,
  }) async {
    final user = _user;
    final now = DateTime.now().toUtc().toIso8601String();

    switch (moduleKey) {
      case 'decisions':
        await _client
            .from('decision_requests')
            .update({
              'status': status,
              'responded_by': user.id,
              'responded_at': now,
              'updated_at': now,
            })
            .eq('id', id);
        return;
      case 'disputes':
        await _client
            .from('disputes')
            .update({
              'status': status,
              'resolution_note': status == 'closed'
                  ? 'Uygulamada kapatıldı.'
                  : null,
              'updated_at': now,
            })
            .eq('id', id);
        return;
      case 'emergency':
        await _client
            .from('emergency_events')
            .update({
              'status': status,
              'closed_by': status == 'closed' ? user.id : null,
              'closed_at': status == 'closed' ? now : null,
              'updated_at': now,
            })
            .eq('id', id);
        return;
      case 'journal':
        await _client
            .from('personal_journal_entries')
            .update({
              'include_in_report': status == 'raporda',
              'updated_at': now,
            })
            .eq('id', id);
        return;
      default:
        throw AppException('$moduleKey icin durum degistirme desteklenmiyor.');
    }
  }

  static Future<LiveRecord> addHandoverLog({
    required String action,
    required String note,
    String status = 'arrived',
  }) async {
    final workspace = await requireWorkspace();
    final row = await _client
        .from('handover_logs')
        .insert({
          'family_id': workspace.familyId,
          'child_id': workspace.childId,
          'actor_id': workspace.userId,
          'action': action.trim(),
          'status': status,
          'note': note.trim().isEmpty ? null : note.trim(),
          'location_consent_at': DateTime.now().toUtc().toIso8601String(),
        })
        .select('id,action,status,note,created_at')
        .single();

    return _record(
      row,
      titleKey: 'action',
      subtitleKey: 'note',
      status: row['status']?.toString() ?? status,
    );
  }

  static Future<List<LiveRecord>> fetchChecklistItems() async {
    final workspace = await requireWorkspace();
    final checklistId = await _ensureChecklist(workspace);
    final rows = await _client
        .from('handover_checklist_items')
        .select('id,title,is_checked,created_at')
        .eq('checklist_id', checklistId)
        .order('created_at');

    return [
      for (final row in rows as List<dynamic>)
        LiveRecord(
          id: row['id'] as String,
          title: row['title']?.toString() ?? 'Madde',
          subtitle: row['is_checked'] == true ? 'Tamamlandı' : 'Bekliyor',
          status: row['is_checked'] == true ? 'done' : 'open',
          createdAt: DateTime.parse(row['created_at'] as String).toLocal(),
        ),
    ];
  }

  static Future<LiveRecord> addChecklistItem(String title) async {
    final workspace = await requireWorkspace();
    final checklistId = await _ensureChecklist(workspace);
    final cleanTitle = title.trim();
    if (cleanTitle.isEmpty) throw const AppException('Madde adı gerekli.');

    final row = await _client
        .from('handover_checklist_items')
        .insert({
          'family_id': workspace.familyId,
          'checklist_id': checklistId,
          'title': cleanTitle,
        })
        .select('id,title,is_checked,created_at')
        .single();

    return LiveRecord(
      id: row['id'] as String,
      title: row['title']?.toString() ?? cleanTitle,
      subtitle: 'Bekliyor',
      status: 'open',
      createdAt: DateTime.parse(row['created_at'] as String).toLocal(),
    );
  }

  static Future<void> setChecklistItemChecked({
    required String id,
    required bool isChecked,
  }) async {
    final user = _user;
    await _client
        .from('handover_checklist_items')
        .update({
          'is_checked': isChecked,
          'checked_by': isChecked ? user.id : null,
          'checked_at': isChecked
              ? DateTime.now().toUtc().toIso8601String()
              : null,
        })
        .eq('id', id);
  }

  static Future<List<VisionFeatureRecord>> fetchVisionFeatureRecords(
    String featureKey,
  ) async {
    final workspace = await requireWorkspace();
    final rows = await _client
        .from('vision_feature_records')
        .select('id,feature_key,title,detail,status,payload,created_at')
        .eq('family_id', workspace.familyId)
        .eq('feature_key', featureKey)
        .order('created_at', ascending: false);

    return [
      for (final row in rows as List<dynamic>)
        _visionFeatureRecordFromRow(row as Map<String, dynamic>),
    ];
  }

  static Future<VisionFeatureRecord> createVisionFeatureRecord({
    required String featureKey,
    required String title,
    required String detail,
    required String status,
    Map<String, dynamic> payload = const {},
  }) async {
    final workspace = await requireWorkspace();
    final cleanTitle = title.trim();
    if (cleanTitle.isEmpty) throw const AppException('Başlık zorunlu.');
    final row = await _client
        .from('vision_feature_records')
        .insert({
          'family_id': workspace.familyId,
          'child_id': workspace.childId,
          'feature_key': featureKey,
          'title': cleanTitle,
          'detail': detail.trim().isEmpty ? null : detail.trim(),
          'status': status,
          'payload': payload,
          'created_by': workspace.userId,
        })
        .select('id,feature_key,title,detail,status,payload,created_at')
        .single();

    return _visionFeatureRecordFromRow(row);
  }

  static Future<void> updateVisionFeatureRecordStatus({
    required String id,
    required String status,
  }) async {
    await _client
        .from('vision_feature_records')
        .update({'status': status})
        .eq('id', id);
  }

  static Future<MessageWorkspace> fetchMessageWorkspace() async {
    final workspace = await requireWorkspace();
    final thread = await _ensureDefaultThread(workspace);
    final rows = await _client
        .from('messages')
        .select('id,body,sender_id,created_at')
        .eq('thread_id', thread.id)
        .order('created_at');

    return MessageWorkspace(
      thread: thread,
      messages: [
        for (final row in rows as List<dynamic>)
          MessageItem(
            id: row['id'] as String,
            body: row['body']?.toString() ?? '',
            senderId: row['sender_id']?.toString() ?? '',
            createdAt: DateTime.parse(row['created_at'] as String).toLocal(),
            isMine: row['sender_id'] == workspace.userId,
          ),
      ],
    );
  }

  static Future<MessageItem> sendMessage(String body) async {
    final workspace = await requireWorkspace();
    final cleanBody = body.trim();
    if (cleanBody.isEmpty) throw const AppException('Mesaj boş olamaz.');
    final thread = await _ensureDefaultThread(workspace);
    final row = await _client
        .from('messages')
        .insert({
          'family_id': workspace.familyId,
          'thread_id': thread.id,
          'sender_id': workspace.userId,
          'body': cleanBody,
          'tone_assistant_used': true,
          'tone_risk_score': _toneRisk(cleanBody),
        })
        .select('id,body,sender_id,created_at')
        .single();

    await _client
        .from('message_threads')
        .update({'updated_at': DateTime.now().toUtc().toIso8601String()})
        .eq('id', thread.id);

    return MessageItem(
      id: row['id'] as String,
      body: row['body']?.toString() ?? cleanBody,
      senderId: row['sender_id']?.toString() ?? workspace.userId,
      createdAt: DateTime.parse(row['created_at'] as String).toLocal(),
      isMine: true,
    );
  }

  static Future<LiveRecord> createReport() async {
    final workspace = await requireWorkspace();
    final token = _generateInvitationCode();
    final payload =
        '${workspace.familyId}|${workspace.childId}|$token|${DateTime.now().toUtc().toIso8601String()}';
    final hash = HashUtils.sha256(payload);
    final row = await _client
        .from('reports')
        .insert({
          'family_id': workspace.familyId,
          'child_id': workspace.childId,
          'report_type': 'coordination',
          'filters': {
            'range': 'last_30_days',
            'include': ['handover', 'messages', 'expenses', 'decisions'],
          },
          'report_hash': hash,
          'verification_token': token,
          'generated_by': workspace.userId,
        })
        .select('id,report_type,report_hash,verification_token,generated_at')
        .single();

    return LiveRecord(
      id: row['id'] as String,
      title: 'Koordinasyon raporu',
      subtitle: 'Token: ${row['verification_token']} · ${row['report_hash']}',
      status: row['report_type']?.toString() ?? 'coordination',
      createdAt: DateTime.parse(row['generated_at'] as String).toLocal(),
    );
  }

  static Future<List<LiveRecord>> fetchSubscriptionPlans() async {
    final rows = await _client
        .from('subscription_plan_catalog')
        .select('code,title,monthly_price_try,entitlement,storage_limit_gb')
        .order('monthly_price_try');

    return [
      for (final row in rows as List<dynamic>)
        LiveRecord(
          id: row['code']?.toString() ?? '',
          title: row['title']?.toString() ?? 'Plan',
          subtitle:
              '${row['monthly_price_try'] ?? '-'} TL/ay · ${row['storage_limit_gb'] ?? '-'} GB',
          status: row['entitlement']?.toString() ?? 'plan',
          createdAt: DateTime.now(),
        ),
    ];
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

  static FamilyMemberInfo _familyMemberFromRow(Map<String, dynamic> row) {
    return FamilyMemberInfo(
      id: row['id'] as String,
      role: row['role']?.toString() ?? 'parent',
      label: row['relationship_label']?.toString().trim().isNotEmpty == true
          ? row['relationship_label'].toString()
          : row['role']?.toString() ?? 'Üye',
      status: row['status']?.toString() ?? 'active',
      accessLevel: row['access_level']?.toString() ?? 'full',
      userId: row['user_id']?.toString(),
    );
  }

  static FamilyInvitationInfo _familyInvitationFromRow(
    Map<String, dynamic> row,
  ) {
    final email = row['invited_email']?.toString();
    final phone = row['invited_phone']?.toString();
    return FamilyInvitationInfo(
      id: row['id'] as String,
      contact: (email != null && email.isNotEmpty)
          ? email
          : (phone != null && phone.isNotEmpty)
          ? phone
          : 'Davet',
      role: row['invited_role']?.toString() ?? 'parent',
      code: row['invitation_code']?.toString() ?? '',
      status: row['status']?.toString() ?? 'pending',
      expiresAt: DateTime.parse(row['expires_at'] as String).toLocal(),
    );
  }

  static LiveRecord _record(
    Map<String, dynamic> row, {
    required String titleKey,
    String? subtitleKey,
    String? subtitle,
    String status = 'aktif',
  }) {
    final createdValue = row['created_at'] ?? row['generated_at'];
    return LiveRecord(
      id: row['id'] as String,
      title: row[titleKey]?.toString().trim().isNotEmpty == true
          ? row[titleKey].toString()
          : 'Kayıt',
      subtitle:
          subtitle ??
          (subtitleKey == null
              ? ''
              : row[subtitleKey]?.toString().trim().isNotEmpty == true
              ? row[subtitleKey].toString()
              : ''),
      status: status,
      createdAt: createdValue == null
          ? DateTime.now()
          : DateTime.parse(createdValue as String).toLocal(),
      extra: row,
    );
  }

  static VisionFeatureRecord _visionFeatureRecordFromRow(
    Map<String, dynamic> row,
  ) {
    final payload = row['payload'];
    return VisionFeatureRecord(
      id: row['id'] as String,
      featureKey: row['feature_key']?.toString() ?? '',
      title: row['title']?.toString().trim().isNotEmpty == true
          ? row['title'].toString()
          : 'Kayıt',
      detail: row['detail']?.toString() ?? '',
      status: row['status']?.toString() ?? 'draft',
      createdAt: DateTime.parse(row['created_at'] as String).toLocal(),
      payload: payload is Map<String, dynamic> ? payload : <String, dynamic>{},
    );
  }

  static String _generateInvitationCode() {
    const alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random.secure();
    return List.generate(
      8,
      (_) => alphabet[random.nextInt(alphabet.length)],
    ).join();
  }

  static Future<String> _ensureChecklist(AppWorkspace workspace) async {
    final existing = await _client
        .from('handover_checklists')
        .select('id')
        .eq('family_id', workspace.familyId)
        .eq('checklist_type', 'handover_bag')
        .limit(1)
        .maybeSingle();
    if (existing != null) return existing['id'] as String;

    final row = await _client
        .from('handover_checklists')
        .insert({
          'family_id': workspace.familyId,
          'child_id': workspace.childId,
          'title': 'Teslim çantası',
          'checklist_type': 'handover_bag',
          'created_by': workspace.userId,
        })
        .select('id')
        .single();
    return row['id'] as String;
  }

  static Future<LiveRecord> _ensureDefaultThread(AppWorkspace workspace) async {
    final existing = await _client
        .from('message_threads')
        .select('id,title,topic,status,created_at,updated_at')
        .eq('family_id', workspace.familyId)
        .eq('topic', 'general')
        .limit(1)
        .maybeSingle();
    if (existing != null) {
      return LiveRecord(
        id: existing['id'] as String,
        title: existing['title']?.toString() ?? 'Aile mesajları',
        subtitle: existing['topic']?.toString() ?? 'general',
        status: existing['status']?.toString() ?? 'open',
        createdAt: DateTime.parse(existing['created_at'] as String).toLocal(),
      );
    }

    final row = await _client
        .from('message_threads')
        .insert({
          'family_id': workspace.familyId,
          'child_id': workspace.childId,
          'topic': 'general',
          'title': 'Aile mesajları',
          'created_by': workspace.userId,
        })
        .select('id,title,topic,status,created_at')
        .single();
    return LiveRecord(
      id: row['id'] as String,
      title: row['title']?.toString() ?? 'Aile mesajları',
      subtitle: row['topic']?.toString() ?? 'general',
      status: row['status']?.toString() ?? 'open',
      createdAt: DateTime.parse(row['created_at'] as String).toLocal(),
    );
  }

  static int _toneRisk(String body) {
    final lower = body.toLowerCase();
    var score = 0;
    for (final word in ['hep', 'asla', 'sorumsuz', 'suç', 'yine']) {
      if (lower.contains(word)) score += 18;
    }
    return score.clamp(0, 100);
  }
}
