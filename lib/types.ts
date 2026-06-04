export interface Medication {
  name_zh: string; name_en?: string; dosage?: string; frequency?: string;
  duration?: string; route?: "口服" | "注射" | "外用" | string; notes?: string;
  shape?: "圓形" | "橢圓" | "膠囊" | "粉包" | string;   // 供生 SVG
  color?: string;                                       // 供生 SVG，例：白色/粉紅色
  timing?: string[];          // 服用時段：早 / 中 / 晚 / 睡前（可多個）
  meal_relation?: string;     // 飯前 / 飯後 / 睡前 / 空腹
}
export interface DocumentItem {
  title?: string;   // 文件標題或類型，例：化療衛教單、轉診單
  date?: string;    // 文件上的日期（有才填）
  summary?: string; // 一句話摘要
}
export interface Treatment {
  name: string;          // 例：化學治療、放射線治療
  type?: string;         // 化療 | 電療 | 物理治療 | 其他療程
  schedule?: string;     // 療程安排，例：每 3 週一次、共 6 次
  frequency?: string;
  location?: string;
  notes?: string;
}
export interface ScheduleItem {
  date?: string; time?: string; event: string; location?: string; notes?: string;
  department?: string;        // 科別（以轉診單為準）
}
export interface Precaution {
  category: "飲食" | "活動" | "傷口" | "用藥" | "其他" | string;
  description: string; severity: "必做" | "注意" | "知道就好" | string;
}
export interface LabTest { name: string; name_en?: string; date?: string; fasting?: boolean; }
export interface Symptom { description: string; category?: string; }
export interface DoctorResponse { question: string; answer: string; status?: string; }
export interface FollowupQuestion { question: string; options?: string[]; }
export interface LifestyleNote { icon?: string; title: string; description: string; }

export interface CareDocResult {
  document_type?: string;
  summary?: string;
  patient_name?: string;   // 病人姓名
  doctor_name?: string;    // 主治醫師姓名
  documents: DocumentItem[]; // 每張上傳文件的標題/日期/摘要
  treatments: Treatment[]; // 院內療程：化療/電療/物理治療等
  medication: Medication[];// 帶回家自行服用的藥物
  schedule: ScheduleItem[];
  precautions: Precaution[];
  lab_tests: LabTest[];
  symptoms: Symptom[];
  doctor_responses: DoctorResponse[];
  followup_questions: FollowupQuestion[];
  lifestyle_notes: LifestyleNote[];
  warnings: string[];
}
