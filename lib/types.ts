export interface Medication {
  name_zh: string; name_en?: string; dosage?: string; frequency?: string;
  duration?: string; route?: "口服" | "注射" | "外用" | string; notes?: string;
  shape?: "圓形" | "橢圓" | "膠囊" | "粉包" | string;   // 供生 SVG
  color?: string;                                       // 供生 SVG，例：白色/粉紅色
}
export interface ScheduleItem {
  date?: string; time?: string; event: string; location?: string; notes?: string;
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
  medication: Medication[];
  schedule: ScheduleItem[];
  precautions: Precaution[];
  lab_tests: LabTest[];
  symptoms: Symptom[];
  doctor_responses: DoctorResponse[];
  followup_questions: FollowupQuestion[];
  lifestyle_notes: LifestyleNote[];
  warnings: string[];
}
