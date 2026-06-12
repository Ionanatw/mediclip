import SwiftUI
import Observation

enum Tab: Int, CaseIterable {
    case home, calendar, documents, garden

    var title: String {
        switch self {
        case .home: "首頁"
        case .calendar: "行事曆"
        case .documents: "文件"
        case .garden: "花園"
        }
    }
}

/// 上傳流程（中央鈕啟動的 modal 流程）
enum UploadStep {
    case none, upload, processing, followUp, results
}

@Observable
final class AppState {
    var hasOnboarded = false
    var tab: Tab = .home
    var uploadStep: UploadStep = .none

    // 照護資料
    var session: CareSession = MockData.session()
    var careDays = 47

    // 上傳流程暫存
    var pickedCount = 0
    var noteText = ""
    var followUps: [FollowUpQuestion] = [
        FollowUpQuestion(question: "胃藥「早餐前 30 分鐘」如果忘記吃，衛教單沒寫怎麼辦。要用哪個規則提醒？",
                         options: ["想起來立刻補吃", "過中午就跳過", "下次回診問醫師"]),
        FollowUpQuestion(question: "傷口換藥是每天一次，還是滲濕才換？單子上兩處寫法不同。",
                         options: ["每天固定一次", "滲濕就換", "兩者皆是"])
    ]

    // 快樂花園
    var sunToday = 6
    var sunTotal = 132
    var streak = 12
    var happyTasks: [HappyTask] = MockData.happyTasks
    var gratitudeText = ""
    var gratitudeSaved = false

    var stage: TreeStage {
        TreeStage.allCases.last { sunTotal >= $0.threshold } ?? .seed
    }
    var nextThreshold: Int {
        TreeStage(rawValue: stage.rawValue + 1)?.threshold ?? TreeStage.bloom.threshold
    }

    // MARK: - 行為

    func completeTask(_ task: HappyTask) {
        guard let i = happyTasks.firstIndex(where: { $0.id == task.id }), !happyTasks[i].done else { return }
        happyTasks[i].done = true
        let gain = min(task.sun, max(0, 15 - sunToday))
        sunToday += gain
        let before = stage
        sunTotal += gain
        if stage != before {
            Haptics.shared.levelUp()
        } else {
            Haptics.shared.success()
        }
    }

    func toggleChecklist(_ item: ChecklistItem) {
        guard let i = session.checklist.firstIndex(where: { $0.id == item.id }) else { return }
        session.checklist[i].done.toggle()
        if session.checklist[i].done { Haptics.shared.success() }
    }

    func toggleMedication(_ med: Medication) {
        guard let i = session.medications.firstIndex(where: { $0.id == med.id }) else { return }
        session.medications[i].takenToday.toggle()
        if session.medications[i].takenToday { Haptics.shared.success() }
    }

    func startUpload() {
        Haptics.shared.light()
        pickedCount = 0
        noteText = ""
        uploadStep = .upload
    }

    func finishProcessing() {
        Haptics.shared.attention()   // AI 完成，把人叫回來
        uploadStep = .followUp
    }
}
