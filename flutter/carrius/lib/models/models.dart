import 'package:flutter/material.dart';

enum PillForm { capsule, tablet, oblong }

class Medication {
  final String name, dose, timing, purpose;
  final PillForm form;
  final int colorA, colorB;
  final String imprint, appearanceText;
  final String? warning, warningDetail;
  final String professionalNote, plainNote;
  final String scheduledTime;
  bool takenToday;

  /// 實拍外觀照片（bundled asset 路徑）。有則優先顯示實拍照，無則回退手繪向量。
  final String? photoAsset;

  /// 外觀來源（例如「食藥署」）。有值代表外觀已核實；null 代表外觀為示意。
  final String? appearanceSource;

  Medication({
    required this.name,
    required this.dose,
    required this.timing,
    required this.purpose,
    required this.form,
    required this.colorA,
    required this.colorB,
    required this.imprint,
    required this.appearanceText,
    this.warning,
    this.warningDetail,
    required this.professionalNote,
    required this.plainNote,
    required this.scheduledTime,
    this.takenToday = false,
    this.photoAsset,
    this.appearanceSource,
  });

  bool get appearanceVerified => appearanceSource != null;
}

enum EventKind { appointment, lab, medication, dressing }

class ScheduleEvent {
  final EventKind kind;
  final String title, detail, time;
  final int month, day;
  final String? note;
  ScheduleEvent({
    required this.kind,
    required this.title,
    required this.detail,
    required this.month,
    required this.day,
    required this.time,
    this.note,
  });
}

enum Severity { high, medium, low }

class CareNote {
  final Severity severity;
  final String title, detail;
  CareNote(this.severity, this.title, this.detail);
}

class FollowUpQuestion {
  final String question;
  final List<String> options;
  String? selected;
  FollowUpQuestion(this.question, this.options, {this.selected});
}

class DocumentRecord {
  final String title, phase, dateText;
  final int pages;
  final List<String> kinds;
  DocumentRecord(this.title, this.phase, this.dateText, this.pages, this.kinds);
}

class ChecklistItem {
  final String category, title;
  final String? detail;
  bool done;
  ChecklistItem(this.category, this.title, {this.detail, this.done = false});
}

enum TreeStageRef { seed, sprout, sapling, growing, bloom }

enum HappyKind { breathing, gratitude, exercise, challenge, share }

class HappyTask {
  final String title, subtitle;
  final int sun;
  final HappyKind kind;
  bool done;
  HappyTask(this.title, this.subtitle, this.sun, this.kind, {this.done = false});
}

class MoodCard {
  final String text, author;
  MoodCard(this.text, this.author);
}

/// 身分（Email 註冊頁單選）
enum UserRole {
  patient('患者'),
  caregiver('照護者'),
  other('其他');

  const UserRole(this.label);
  final String label;
}

@immutable
class CareSession {
  final String familyName, summary;
  final List<Medication> medications;
  final List<ScheduleEvent> events;
  final List<CareNote> notes;
  final List<ChecklistItem> checklist;
  final List<DocumentRecord> documents;
  const CareSession({
    required this.familyName,
    required this.summary,
    required this.medications,
    required this.events,
    required this.notes,
    required this.checklist,
    required this.documents,
  });
}
