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

// ---- 首頁「今天要做的」：餐錨點時段流（2026-07-02 首頁改版定案 H3+版3） ----

/// 一項可勾選的照護任務（用藥或照護動作）。
/// fullName＝藥單上的正確全名（小字顯示）；warn＝紅字仿單警告（false 為溫和提醒）。
class CareTask {
  final String title;
  final String? fullName;
  final String note;
  final bool warn;
  bool done;
  CareTask(this.title, this.note, {this.fullName, this.warn = false, this.done = false});
}

/// 時段內的小節（例：餐前 30 分 3 顆／餐後 1 顆）。
class CareGroup {
  final String label, hint;
  final List<CareTask> tasks;
  const CareGroup(this.label, this.hint, this.tasks);
}

/// 時段色相（早餐暖黃／午餐橘／照護綠／晚餐藍／睡前紫）。
enum SlotTint { breakfast, lunch, care, dinner, night }

/// 一個餐錨點時段（早餐／午餐／中午照護／晚餐／睡前）。
/// nowLabel／nowTitle 為該時段成為「現在」聚焦卡時的文案。
class DaySlot {
  final String id, title, nowLabel, nowTitle;
  final String? hint; // 參考時間小字（約 07:30）
  final SlotTint tint;
  final List<CareGroup> groups;
  const DaySlot({
    required this.id,
    required this.title,
    required this.nowLabel,
    required this.nowTitle,
    this.hint,
    required this.tint,
    required this.groups,
  });
  Iterable<CareTask> get tasks => groups.expand((g) => g.tasks);
}

enum HappyKind { breathing, gratitude, exercise, challenge, share, bodyScan, observeBreath, microMove, sunbathe, goal, hug, familyTalk }

class HappyTask {
  final String title, subtitle;
  final int sun;
  final HappyKind kind;
  bool done;
  HappyTask(this.title, this.subtitle, this.sun, this.kind, {this.done = false});
}

/// 花園頁的快樂活動卡（依「想放鬆／想振奮／想被在乎」分組橫向滑動）。
/// kind 決定點擊路由：各活動有專屬引導畫面，
/// 其餘（exercise/challenge/share）走 state.completeActivity。
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
