import Foundation

// MARK: - 藥品

enum PillForm: String {
    case capsule    // 膠囊
    case tablet     // 錠劑（圓片）
    case oblong     // 橢圓錠
}

struct Medication: Identifiable {
    let id = UUID()
    let name: String            // 藥名
    let dose: String            // 劑量
    let timing: String          // 服用時機
    let purpose: String         // 用途
    let form: PillForm
    let colorHexA: UInt32       // 外觀主色
    let colorHexB: UInt32       // 外觀次色（膠囊另一半；錠劑同主色）
    let imprint: String         // 刻痕
    let appearanceText: String  // 外觀描述（對應食藥署欄位）
    let warning: String?        // 最重要禁忌（紅卡）
    let warningDetail: String?
    let professionalNote: String // 仿單原文（專業版，免費）
    let plainNote: String        // 白話版（鎖定）
    var takenToday: Bool = false
    let scheduledTime: String    // 今日下次時間
}

// MARK: - 行程

enum EventKind {
    case appointment   // 回診
    case lab           // 檢驗
    case medication    // 用藥節點
    case dressing      // 換藥
}

struct ScheduleEvent: Identifiable {
    let id = UUID()
    let kind: EventKind
    let title: String
    let detail: String
    let date: DateComponents     // 月/日
    let time: String
    let note: String?
}

// MARK: - 注意事項 / 追問 / 文件

enum Severity { case high, medium, low }

struct CareNote: Identifiable {
    let id = UUID()
    let severity: Severity
    let title: String
    let detail: String
}

struct FollowUpQuestion: Identifiable {
    let id = UUID()
    let question: String
    let options: [String]
    var selected: String?
}

struct DocumentRecord: Identifiable {
    let id = UUID()
    let title: String
    let phase: String        // 版本標記：術後第 1 週…
    let dateText: String
    let pages: Int
    let kinds: [String]      // 內含：用藥/行程/注意事項
}

// MARK: - 待辦

struct ChecklistItem: Identifiable {
    let id = UUID()
    let category: String     // 用藥 / 傷口 / 飲食 / 活動
    let title: String
    let detail: String?
    var done: Bool = false
}

// MARK: - 快樂花園

enum TreeStage: Int, CaseIterable {
    case seed = 0, sprout, sapling, growing, bloom

    var name: String {
        switch self {
        case .seed: "種子"
        case .sprout: "發芽"
        case .sapling: "幼苗"
        case .growing: "茁壯"
        case .bloom: "大樹"
        }
    }
    var threshold: Int {
        switch self {
        case .seed: 0
        case .sprout: 20
        case .sapling: 60
        case .growing: 120
        case .bloom: 200
        }
    }
}

struct HappyTask: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let sun: Int
    var done: Bool = false
    let kind: HappyTaskKind
}

enum HappyTaskKind { case breathing, gratitude, exercise, challenge, share }

struct MoodCard: Identifiable {
    let id = UUID()
    let text: String
    let author: String
}

// MARK: - 照護 Session（一次 AI 整理的結果）

struct CareSession {
    var familyName: String
    var summary: String
    var medications: [Medication]
    var events: [ScheduleEvent]
    var notes: [CareNote]
    var checklist: [ChecklistItem]
    var documents: [DocumentRecord]
}
