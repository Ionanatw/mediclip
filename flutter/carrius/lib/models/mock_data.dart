import 'package:flutter/material.dart';
import 'models.dart';

/// 擬真化療出院衛教單整理結果（mock，貫穿全畫面）。
/// ⚠️ 藥品外觀為示意，未經食藥署核實——詳見 docs/drug-appearance-check.html。
class MockData {
  static List<Medication> medications() => [
        Medication(
          name: '癒妥 膜衣錠', dose: '50mg', timing: '晚餐後 1 顆，配開水',
          purpose: '標靶治療', form: PillForm.capsule,
          colorA: 0xFFFFFDF8, colorB: 0xFFAB9FF2, imprint: 'TM50',
          appearanceText: '白＋紫 膠囊，刻痕 TM50',
          warning: '不可與葡萄柚同食',
          warningDetail: '影響藥物代謝，血中濃度過高。柚子、文旦同屬禁忌。',
          professionalNote: '4.3 禁忌：對本品成分過敏者。4.4 注意事項：治療期間應定期監測肝功能，避免與 CYP3A4 強抑制劑併用。4.5 交互作用：葡萄柚汁可能增加血中濃度。',
          plainNote: '這顆藥不能配柚子類水果（葡萄柚、柚子、文旦都算），會讓藥效太強。',
          scheduledTime: '19:00', takenToday: true,
        ),
        Medication(
          name: '止吐藥', dose: '8mg', timing: '睡前 1 顆，想吐時可提前',
          purpose: '預防化療噁心', form: PillForm.tablet,
          colorA: 0xFFFFD9E8, colorB: 0xFFFFD9E8, imprint: 'OND8',
          appearanceText: '淡粉 圓錠，刻痕 OND8',
          professionalNote: '4.4 注意事項：可能引起便祕與頭痛，長 QT 症候群患者慎用。',
          plainNote: '吃了可能會便祕，多喝水多吃蔬菜。心臟有問題要先跟醫師說。',
          scheduledTime: '21:30',
        ),
        Medication(
          name: '胃藥', dose: '40mg', timing: '早餐前 30 分鐘 1 顆',
          purpose: '保護胃黏膜', form: PillForm.oblong,
          colorA: 0xFFF1FF52, colorB: 0xFFF1FF52, imprint: 'PPI40',
          appearanceText: '黃 橢圓錠，刻痕 PPI40',
          warning: '不可與含鋁鎂制酸劑併服',
          warningDetail: '需間隔至少 2 小時，否則吸收下降。',
          professionalNote: '4.5 交互作用：不可與含鋁、鈣、鎂之制酸劑併服，間隔至少 2 小時。',
          plainNote: '不能跟一般胃散、胃乳片一起吃，要隔開 2 小時。',
          scheduledTime: '07:30', takenToday: true,
        ),
        Medication(
          name: '升白血球藥', dose: '300mcg', timing: '醫囑日皮下注射',
          purpose: '提升白血球', form: PillForm.tablet,
          colorA: 0xFFE2DFFE, colorB: 0xFFE2DFFE, imprint: 'GCSF',
          appearanceText: '淡紫 圓錠（注射劑示意）',
          professionalNote: '4.4 注意事項：可能出現骨頭痠痛，屬常見反應；發燒超過 38 度應立即回診。',
          plainNote: '打完可能會骨頭痠，是正常的。但如果發燒超過 38 度要馬上回醫院。',
          scheduledTime: '依醫囑',
        ),
      ];

  static List<ScheduleEvent> events() => [
        ScheduleEvent(kind: EventKind.lab, title: '抽血檢驗（空腹）', detail: '台大癌醫 1F 抽血站', month: 6, day: 16, time: '08:30', note: '前一晚 12 點後禁食'),
        ScheduleEvent(kind: EventKind.appointment, title: '血液腫瘤科回診', detail: '台大癌醫 3F 門診 12 診', month: 6, day: 16, time: '09:30', note: '攜帶藥袋與這份整理'),
        ScheduleEvent(kind: EventKind.dressing, title: '傷口換藥', detail: '居家，紗布＋生理食鹽水', month: 6, day: 14, time: '10:00', note: '觀察紅腫熱痛'),
        ScheduleEvent(kind: EventKind.appointment, title: '第二次化療', detail: '台大癌醫 5F 化療中心', month: 6, day: 24, time: '08:00', note: '預計 4-6 小時'),
        ScheduleEvent(kind: EventKind.medication, title: '癒妥 50mg', detail: '每天晚餐後，持續至 7/14', month: 6, day: 13, time: '19:00'),
      ];

  static List<CareNote> notes() => [
        CareNote(Severity.high, '發燒超過 38°C 立即回診', '白血球低下期間發燒可能是感染，不可自行退燒觀察。'),
        CareNote(Severity.high, '避免生食', '生魚片、生菜沙拉、未削皮水果都暫停，食物要全熟。'),
        CareNote(Severity.medium, '傷口保持乾燥', '洗澡用防水敷料保護，若滲濕立即更換。'),
        CareNote(Severity.medium, '避免人多密閉場所', '外出戴口罩，回家先洗手。'),
        CareNote(Severity.low, '適度散步', '每天 20-30 分鐘，覺得累就休息。'),
      ];

  static List<ChecklistItem> checklist() => [
        ChecklistItem('用藥', '早餐前胃藥 40mg', detail: '07:30 前', done: true),
        ChecklistItem('用藥', '晚餐後癒妥 50mg', detail: '19:00', done: true),
        ChecklistItem('用藥', '睡前止吐藥 8mg', detail: '21:30'),
        ChecklistItem('傷口', '檢查傷口有無紅腫', detail: '換藥時順便看'),
        ChecklistItem('傷口', '更換紗布', detail: '10:00'),
        ChecklistItem('飲食', '確認三餐全熟食', done: true),
        ChecklistItem('飲食', '喝水 2000ml', detail: '目前約 1200ml'),
        ChecklistItem('活動', '散步 20 分鐘', detail: '傍晚涼一點再去'),
      ];

  static List<DocumentRecord> documents() => [
        DocumentRecord('出院衛教單（化療照護）', '術後第 1 週', '6/10', 6, ['用藥', '行程', '注意事項']),
        DocumentRecord('處方箋', '術後第 1 週', '6/10', 1, ['用藥']),
        DocumentRecord('回診預約單', '術後第 1 週', '6/10', 1, ['行程']),
        DocumentRecord('護理站口頭交代筆記', '出院當天', '6/10', 1, ['注意事項']),
      ];

  // ---- 首頁「今天要做的」餐錨點時段流（鴿王指定模擬：三餐各餐前3+餐後1、睡前2、中午換敷料） ----

  static List<CareTask> _preMeds() => [
        CareTask('胃藥 40mg', '不可與胃散胃乳同服，隔 2 小時', fullName: '艾美拉唑膜衣錠 40 毫克', warn: true),
        CareTask('血壓藥 5mg', '不可自行停藥', fullName: '氨氯地平錠 5 毫克', warn: true),
        CareTask('抗生素 250mg', '整顆吞服，不可剝半', fullName: '阿莫西林膠囊 250 毫克'),
      ];

  static List<CareTask> _postMeds() => [
        CareTask('鐵劑 100mg', '避免與茶、咖啡同服', fullName: '葡萄糖酸亞鐵錠 100 毫克'),
      ];

  static DaySlot _meal(String id, String title, String hint, SlotTint tint) => DaySlot(
        id: id,
        title: title,
        hint: hint,
        tint: tint,
        nowLabel: '$title前',
        nowTitle: '$title前要吃 3 顆',
        groups: [
          CareGroup('餐前 30 分', '3 顆', _preMeds()),
          CareGroup('餐後', '1 顆', _postMeds()),
        ],
      );

  static List<DaySlot> daySlots() => [
        _meal('bk', '早餐', '約 07:30', SlotTint.breakfast),
        _meal('ln', '午餐', '約 12:00', SlotTint.lunch),
        DaySlot(
          id: 'care',
          title: '中午 · 傷口換敷料',
          hint: '午餐後',
          tint: SlotTint.care,
          nowLabel: '中午 · 照護',
          nowTitle: '中午要換敷料',
          groups: [
            CareGroup('照護', '2 項', [
              CareTask('更換紗布', '紗布＋生理食鹽水'),
              CareTask('檢查傷口紅腫', '紅腫熱痛要回報', warn: true),
            ]),
          ],
        ),
        _meal('dn', '晚餐', '約 18:30', SlotTint.dinner),
        DaySlot(
          id: 'nt',
          title: '睡前',
          hint: '約 21:30',
          tint: SlotTint.night,
          nowLabel: '睡前',
          nowTitle: '睡前要吃 2 顆',
          groups: [
            CareGroup('兩顆不同的藥', '', [
              CareTask('止吐藥 8mg', '想吐時可提前吃', fullName: '昂丹司瓊錠 8 毫克'),
              CareTask('軟便劑 1 包', '配一整杯水', fullName: '氧化鎂粉 500 毫克'),
            ]),
          ],
        ),
      ];

  /// 不綁時段的「今天隨時」項（承接原 checklist 的飲食／活動）。
  static List<CareTask> anytimeTasks() => [
        CareTask('三餐全熟食', '化療期間避免生食'),
        CareTask('喝水 2000ml', '目前約 1200ml'),
        CareTask('散步 20 分鐘', '傍晚涼一點再去'),
      ];

  static List<HappyTask> happyTasks() => [
        HappyTask('478 呼吸練習', '3 分鐘', 2, HappyKind.breathing, done: true),
        HappyTask('寫下一件感恩的事', '感恩日記', 2, HappyKind.gratitude),
        HappyTask('頸部伸展一組', '2 分鐘微運動', 3, HappyKind.exercise),
        HappyTask('小挑戰：跟一位陌生人微笑', '微辣', 3, HappyKind.challenge),
        HappyTask('分享心情小卡', '給家人或朋友', 1, HappyKind.share),
      ];

  // 花園頁分組快樂活動（對齊 docs/carrius-garden-full.html mockup）。
  // tint 為各卡的色相基準，卡片背景與圖塊以此調淡。
  static const _blue = Color(0xFF3F7BC4);
  static const _green = Color(0xFF2E8B72);
  static const _amber = Color(0xFFC2872E);
  static const _purple = Color(0xFF6B5FC0);
  static const _pink = Color(0xFFC75E8A);
  static const _olive = Color(0xFF5C8A2A);

  static List<GardenActivityGroup> happyActivities() => const [
        GardenActivityGroup('想放鬆一下', '安撫緊繃，慢慢放鬆下來', [
          GardenActivity(icon: Icons.air, tint: _blue, title: '478 呼吸', guide: '吸4 停7 吐8，3 分鐘', chem: '血清素', sun: 2, kind: HappyKind.breathing),
          GardenActivity(icon: Icons.self_improvement, tint: _green, title: '身體掃描', guide: '從頭到腳放鬆 2 分鐘', chem: '副交感', sun: 2, kind: HappyKind.bodyScan),
          GardenActivity(icon: Icons.spa_outlined, tint: _purple, title: '觀呼吸', guide: '只是看著呼吸，1 分鐘', chem: '正念', sun: 2, kind: HappyKind.observeBreath),
        ]),
        GardenActivityGroup('想振奮一點', '動起來、給自己一點成就感', [
          GardenActivity(icon: Icons.accessibility_new, tint: _olive, title: '微運動', guide: '頸肩手腳跟著動，約 1 分鐘', chem: '腦內啡', sun: 3, kind: HappyKind.microMove),
          GardenActivity(icon: Icons.wb_sunny_outlined, tint: _amber, title: '曬太陽', guide: '轉向光，曬一下，90 秒', chem: '血清素', sun: 3, kind: HappyKind.sunbathe),
          GardenActivity(icon: Icons.flag_outlined, tint: _blue, title: '寫個小目標', guide: '今天想完成的一件小事', chem: '多巴胺', sun: 2, kind: HappyKind.goal),
        ]),
        GardenActivityGroup('想被在乎、被連結', '和在乎的人靠近一點', [
          GardenActivity(icon: Icons.chat_bubble_outline, tint: _pink, title: '跟家人說說話', guide: '傳一張暖暖小卡給他', chem: '催產素', sun: 2, kind: HappyKind.familyTalk),
          GardenActivity(icon: Icons.volunteer_activism_outlined, tint: _purple, title: '給自己一個擁抱', guide: '雙手環抱 20 秒', chem: '催產素', sun: 1, kind: HappyKind.hug),
          GardenActivity(icon: Icons.eco_outlined, tint: _green, title: '感謝自己', guide: '寫一句，樹會替你記得', chem: '血清素', sun: 2, kind: HappyKind.gratitude),
        ]),
      ];

  /// 跟家人說說話：暖暖小卡備選文案（長輩早安圖的溫暖語感，直接傳出去不突兀）
  static const familyCardTexts = [
    '早安，平安就是福。今天也要好好吃飯、好好休息',
    '天氣多變，記得添件衣裳。你的平安，是我最大的心願',
    '想你了。願你今天福氣滿滿，笑口常開',
  ];

  /// 感謝自己：可換題的引導（聚焦「今天的自己」）
  static const gratitudePrompts = [
    '今天的自己，哪裡做得不錯？',
    '今天你為家人撐住了什麼？謝謝自己',
    '哪一件小事，讓你鬆了一口氣？',
  ];

  static CareSession session() => CareSession(
        familyName: '媽媽',
        summary: '出院後居家照護重點：每日按時服用標靶藥與止吐藥、傷口保持乾燥、6/16 回診前一晚 12 點後禁食抽血。白血球偏低期間避免生食與人多場所。',
        medications: medications(),
        events: events(),
        notes: notes(),
        checklist: checklist(),
        documents: documents(),
      );
}
