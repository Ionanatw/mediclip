import Foundation

/// 擬真化療出院衛教單整理結果（mock，貫穿全部畫面）
enum MockData {

    static func session() -> CareSession {
        CareSession(
            familyName: "媽媽",
            summary: "出院後居家照護重點：每日按時服用標靶藥與止吐藥、傷口保持乾燥、6/16 回診前一晚 12 點後禁食抽血。白血球偏低期間避免生食與人多場所。",
            medications: medications,
            events: events,
            notes: notes,
            checklist: checklist,
            documents: documents
        )
    }

    static let medications: [Medication] = [
        Medication(
            name: "癒妥 膜衣錠", dose: "50mg", timing: "晚餐後 1 顆，配開水",
            purpose: "標靶治療", form: .capsule,
            colorHexA: 0xFFFDF8, colorHexB: 0xAB9FF2, imprint: "TM50",
            appearanceText: "白＋紫 膠囊，刻痕 TM50",
            warning: "不可與葡萄柚同食",
            warningDetail: "影響藥物代謝，血中濃度過高。柚子、文旦同屬禁忌。",
            professionalNote: "4.3 禁忌：對本品成分過敏者。4.4 注意事項：治療期間應定期監測肝功能，避免與 CYP3A4 強抑制劑併用。4.5 交互作用：葡萄柚汁可能增加血中濃度。",
            plainNote: "這顆藥不能配柚子類水果（葡萄柚、柚子、文旦都算），會讓藥效太強。",
            takenToday: true, scheduledTime: "19:00"
        ),
        Medication(
            name: "止吐藥", dose: "8mg", timing: "睡前 1 顆，想吐時可提前",
            purpose: "預防化療噁心", form: .tablet,
            colorHexA: 0xFFD9E8, colorHexB: 0xFFD9E8, imprint: "OND8",
            appearanceText: "淡粉 圓錠，刻痕 OND8",
            warning: nil, warningDetail: nil,
            professionalNote: "4.4 注意事項：可能引起便祕與頭痛，長 QT 症候群患者慎用。",
            plainNote: "吃了可能會便祕，多喝水多吃蔬菜。心臟有問題要先跟醫師說。",
            takenToday: false, scheduledTime: "21:30"
        ),
        Medication(
            name: "胃藥", dose: "40mg", timing: "早餐前 30 分鐘 1 顆",
            purpose: "保護胃黏膜", form: .oblong,
            colorHexA: 0xF1FF52, colorHexB: 0xF1FF52, imprint: "PPI40",
            appearanceText: "黃 橢圓錠，刻痕 PPI40",
            warning: "不可與含鋁鎂制酸劑併服",
            warningDetail: "需間隔至少 2 小時，否則吸收下降。",
            professionalNote: "4.5 交互作用：不可與含鋁、鈣、鎂之制酸劑併服，間隔至少 2 小時。",
            plainNote: "不能跟一般胃散、胃乳片一起吃，要隔開 2 小時。",
            takenToday: true, scheduledTime: "07:30"
        ),
        Medication(
            name: "升白血球藥", dose: "300mcg", timing: "醫囑日皮下注射",
            purpose: "提升白血球", form: .tablet,
            colorHexA: 0xE2DFFE, colorHexB: 0xE2DFFE, imprint: "GCSF",
            appearanceText: "淡紫 圓錠（注射劑示意）",
            warning: nil, warningDetail: nil,
            professionalNote: "4.4 注意事項：可能出現骨頭痠痛，屬常見反應；發燒超過 38 度應立即回診。",
            plainNote: "打完可能會骨頭痠，是正常的。但如果發燒超過 38 度要馬上回醫院。",
            takenToday: false, scheduledTime: "依醫囑"
        )
    ]

    static let events: [ScheduleEvent] = [
        ScheduleEvent(kind: .lab, title: "抽血檢驗（空腹）", detail: "台大癌醫 1F 抽血站",
                      date: DateComponents(month: 6, day: 16), time: "08:30",
                      note: "前一晚 12 點後禁食"),
        ScheduleEvent(kind: .appointment, title: "血液腫瘤科回診", detail: "台大癌醫 3F 門診 12 診",
                      date: DateComponents(month: 6, day: 16), time: "09:30",
                      note: "攜帶藥袋與這份整理"),
        ScheduleEvent(kind: .dressing, title: "傷口換藥", detail: "居家，紗布＋生理食鹽水",
                      date: DateComponents(month: 6, day: 14), time: "10:00",
                      note: "觀察紅腫熱痛"),
        ScheduleEvent(kind: .appointment, title: "第二次化療", detail: "台大癌醫 5F 化療中心",
                      date: DateComponents(month: 6, day: 24), time: "08:00",
                      note: "預計 4-6 小時"),
        ScheduleEvent(kind: .medication, title: "癒妥 50mg", detail: "每天晚餐後，持續至 7/14",
                      date: DateComponents(month: 6, day: 13), time: "19:00", note: nil)
    ]

    static let notes: [CareNote] = [
        CareNote(severity: .high, title: "發燒超過 38°C 立即回診",
                 detail: "白血球低下期間發燒可能是感染，不可自行退燒觀察。"),
        CareNote(severity: .high, title: "避免生食",
                 detail: "生魚片、生菜沙拉、未削皮水果都暫停，食物要全熟。"),
        CareNote(severity: .medium, title: "傷口保持乾燥",
                 detail: "洗澡用防水敷料保護，若滲濕立即更換。"),
        CareNote(severity: .medium, title: "避免人多密閉場所",
                 detail: "外出戴口罩，回家先洗手。"),
        CareNote(severity: .low, title: "適度散步",
                 detail: "每天 20-30 分鐘，覺得累就休息。")
    ]

    static let checklist: [ChecklistItem] = [
        ChecklistItem(category: "用藥", title: "早餐前胃藥 40mg", detail: "07:30 前", done: true),
        ChecklistItem(category: "用藥", title: "晚餐後癒妥 50mg", detail: "19:00", done: true),
        ChecklistItem(category: "用藥", title: "睡前止吐藥 8mg", detail: "21:30"),
        ChecklistItem(category: "傷口", title: "檢查傷口有無紅腫", detail: "換藥時順便看"),
        ChecklistItem(category: "傷口", title: "更換紗布", detail: "10:00"),
        ChecklistItem(category: "飲食", title: "確認三餐全熟食", detail: nil, done: true),
        ChecklistItem(category: "飲食", title: "喝水 2000ml", detail: "目前約 1200ml"),
        ChecklistItem(category: "活動", title: "散步 20 分鐘", detail: "傍晚涼一點再去")
    ]

    static let documents: [DocumentRecord] = [
        DocumentRecord(title: "出院衛教單（化療照護）", phase: "術後第 1 週", dateText: "6/10",
                       pages: 6, kinds: ["用藥", "行程", "注意事項"]),
        DocumentRecord(title: "處方箋", phase: "術後第 1 週", dateText: "6/10",
                       pages: 1, kinds: ["用藥"]),
        DocumentRecord(title: "回診預約單", phase: "術後第 1 週", dateText: "6/10",
                       pages: 1, kinds: ["行程"]),
        DocumentRecord(title: "護理站口頭交代筆記", phase: "出院當天", dateText: "6/10",
                       pages: 1, kinds: ["注意事項"])
    ]

    static let happyTasks: [HappyTask] = [
        HappyTask(title: "478 呼吸練習", subtitle: "3 分鐘", sun: 2, done: true, kind: .breathing),
        HappyTask(title: "寫下一件感恩的事", subtitle: "感恩日記", sun: 2, kind: .gratitude),
        HappyTask(title: "頸部伸展一組", subtitle: "2 分鐘微運動", sun: 3, kind: .exercise),
        HappyTask(title: "小挑戰：跟一位陌生人微笑", subtitle: "微辣", sun: 3, kind: .challenge),
        HappyTask(title: "分享心情小卡", subtitle: "給家人或朋友", sun: 1, kind: .share)
    ]

    static let moodCards: [MoodCard] = [
        MoodCard(text: "你照顧別人的樣子，也值得被好好照顧。", author: "CareDoc"),
        MoodCard(text: "今天只要做到「夠好」就可以了，不用滿分。", author: "CareDoc"),
        MoodCard(text: "休息不是偷懶，是為了走更長的路。", author: "CareDoc")
    ]

    static let gratitudePrompts = [
        "今天有什麼小事讓你鬆了一口氣？",
        "誰今天幫了你一把？",
        "今天的自己哪裡做得不錯？"
    ]
}
