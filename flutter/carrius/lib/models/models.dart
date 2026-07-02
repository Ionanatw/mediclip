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
  });
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

enum HappyKind { breathing, gratitude, exercise, challenge, share, bodyScan, observeBreath, microMove, sunbathe, goal }

class HappyTask {
  final String title, subtitle;
  final int sun;
  final HappyKind kind;
  bool done;
  HappyTask(this.title, this.subtitle, this.sun, this.kind, {this.done = false});
}

/// 花園頁的快樂活動卡（依「想放鬆／想振奮／想被在乎」分組橫向滑動）。
/// kind 決定點擊路由：breathing→呼吸、gratitude→感恩、share→心情小卡，
/// 其餘（exercise/challenge）走 state.completeTask。
class GardenActivity {
  final IconData icon;
  final Color tint; // 圖示底色基準（卡片背景與圖塊以此調出）
  final String title, guide, chem;
  final int sun;
  final HappyKind kind;
  const GardenActivity({
    required this.icon,
    required this.tint,
    required this.title,
    required this.guide,
    required this.chem,
    required this.sun,
    required this.kind,
  });
}

/// 一組活動（含分組標題與引導）。
class GardenActivityGroup {
  final String title, subtitle;
  final List<GardenActivity> activities;
  const GardenActivityGroup(this.title, this.subtitle, this.activities);
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
