import 'package:flutter/material.dart';
import '../design/tokens.dart';
import '../design/components.dart';
import '../design/haptics.dart';
import '../state/app_state.dart';

/// 設定分頁（取代原本的設定 sheet）：帳號 hero + 提醒 + 外觀(深色) + 關於與隱私。
class SettingsScreen extends StatefulWidget {
  final AppState state;
  const SettingsScreen({super.key, required this.state});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool medReminder = true;
  bool sitReminder = true;
  bool hapticsOn = true;

  @override
  Widget build(BuildContext context) {
    final p = PaletteScope.of(context);
    final s = widget.state;
    final sysDark = MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    final isDark = s.themePref == ThemePref.dark || (s.themePref == ThemePref.system && sysDark);
    final email = s.email.isNotEmpty ? s.email : '尚未設定 email';

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 120),
      children: [
        // ---- 帳號 hero ----
        Center(
          child: Column(
            children: [
              Container(
                width: 72, height: 72,
                decoration: BoxDecoration(color: CD.accent, borderRadius: BorderRadius.circular(24)),
                child: const Icon(Icons.person, size: 36, color: CD.cream),
              ),
              const SizedBox(height: 10),
              Text(email, style: CDText.title(16, color: p.text)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 5),
                decoration: BoxDecoration(color: CD.accentSoft, borderRadius: BorderRadius.circular(999)),
                child: Text('免費方案 · 剩 1 次照護時段',
                    style: CDText.body(12, weight: FontWeight.w700, color: CD.plumDeep)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        SectionHeader(title: '提醒'),
        const SizedBox(height: 10),
        CDCard(
          padding: const EdgeInsets.all(6),
          child: Column(
            children: [
              _toggle(p, Icons.medication_outlined, '用藥時間輕震提醒', medReminder, (v) => setState(() => medReminder = v)),
              _divider(p),
              _toggle(p, Icons.directions_walk, '久坐提醒（等候時）', sitReminder, (v) => setState(() => sitReminder = v)),
              _divider(p),
              _toggle(p, Icons.vibration, '震動回饋', hapticsOn, (v) => setState(() => hapticsOn = v)),
            ],
          ),
        ),
        const SizedBox(height: 14),

        SectionHeader(title: '外觀'),
        const SizedBox(height: 10),
        CDCard(
          padding: const EdgeInsets.all(6),
          child: _toggle(p, Icons.dark_mode_outlined, '深色模式', isDark,
              (v) => s.setThemePref(v ? ThemePref.dark : ThemePref.light)),
        ),
        const SizedBox(height: 14),

        SectionHeader(title: '帳號'),
        const SizedBox(height: 10),
        CDCard(
          padding: const EdgeInsets.all(6),
          child: Column(
            children: [
              _nav(p, Icons.mail_outline, email, chevron: false),
              _divider(p),
              _nav(p, Icons.credit_card, '方案：免費（剩 1 次照護時段）',
                  onTap: () => showCDSheet(context, title: '方案與計費', body: _pricingBody(p))),
            ],
          ),
        ),
        const SizedBox(height: 14),

        SectionHeader(title: '關於與隱私'),
        const SizedBox(height: 10),
        CDCard(
          padding: const EdgeInsets.all(6),
          child: Column(
            children: [
              _nav(p, Icons.lock_outline, '隱私政策',
                  onTap: () => showCDSheet(context, title: '隱私政策', body: _privacyBody(p))),
              _divider(p),
              _nav(p, Icons.article_outlined, '使用者同意書',
                  onTap: () => showCDSheet(context, title: '使用者同意書', body: _consentBody(p))),
              _divider(p),
              _nav(p, Icons.info_outline, '關於 Carrius v0.1 POC',
                  onTap: () => showCDSheet(context, title: '關於 Carrius', body: _aboutBody(p))),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text('醫療資料只存在你的手機。伺服器只知道你的 email 和付費狀態。',
            textAlign: TextAlign.center, style: CDText.body(11.5, weight: FontWeight.w500, color: p.text3)),
      ],
    );
  }

  Widget _divider(Palette p) => Divider(height: 1, color: p.cardBorder);

  Widget _toggle(Palette p, IconData icon, String label, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 26, child: Icon(icon, size: 15, color: CD.accent)),
          const SizedBox(width: 11),
          Text(label, style: CDText.body(13.5, weight: FontWeight.w700, color: p.text)),
          const Spacer(),
          Switch(value: value, onChanged: onChanged, activeTrackColor: CD.accent, activeThumbColor: CD.cream),
        ],
      ),
    );
  }

  Widget _nav(Palette p, IconData icon, String label, {VoidCallback? onTap, bool chevron = true}) {
    final row = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      child: Row(
        children: [
          SizedBox(width: 26, child: Icon(icon, size: 15, color: p.text2)),
          const SizedBox(width: 11),
          Expanded(child: Text(label, style: CDText.body(13.5, weight: FontWeight.w700, color: p.text))),
          if (chevron) Icon(Icons.chevron_right, size: 16, color: p.text3),
        ],
      ),
    );
    if (onTap == null) return row;
    return GestureDetector(
      onTap: () {
        Haptics.light();
        onTap();
      },
      child: row,
    );
  }

  // ---- 內容頁（真實可讀，非佔位）----

  Widget _privacyBody(Palette p) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        SheetParagraph('一句話：你的醫療資料只存在這台手機。'),
        SheetHeading('我們怎麼處理你的資料'),
        SheetBullet('照片與整理結果只存在手機本機，不上傳雲端、不進入我們的伺服器。'),
        SheetBullet('伺服器只保存你的 email 與付費狀態，不碰、不存、不看任何醫療內容。'),
        SheetBullet('AI 整理透過加密通道即時處理，處理完不留存你的文件內容。'),
        SheetBullet('解除安裝 App，手機上的醫療資料就一併消失。'),
        SheetHeading('你的權利'),
        SheetBullet('你可以隨時在裝置上刪除任何一次照護時段的資料。'),
        SheetBullet('你可以來信要求刪除帳號（email 與付費紀錄）。'),
        SheetParagraph('\n本頁為 Carrius v0.1 POC 草稿，正式版上線前將送法務複核。'),
      ],
    );
  }

  Widget _consentBody(Palette p) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        SheetParagraph('使用 Carrius 前，請先了解以下事項。'),
        SheetBullet('Carrius 是醫療資訊整理的輔助工具，不是醫療器材，不提供診斷、處方或治療建議。'),
        SheetBullet('所有整理結果由 AI 輔助產生，可能有誤。請務必與原始醫療文件、醫師或藥師核對。'),
        SheetBullet('用藥、停藥、劑量調整一律以醫囑為準，不要僅依本 App 內容自行決定。'),
        SheetBullet('遇到緊急狀況請撥打 119 或立即就醫，不要等待 App。'),
        SheetParagraph('\n繼續使用即代表你已了解並同意以上說明。'),
        SheetParagraph('本頁為 Carrius v0.1 POC 草稿，正式版上線前將送法務複核。'),
      ],
    );
  }

  Widget _pricingBody(Palette p) {
    Widget tier(String name, String price, List<String> feats, {bool current = false}) {
      return Container(
        margin: const EdgeInsets.only(top: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: current ? CD.accent.withValues(alpha: 0.12) : p.surface2,
          borderRadius: BorderRadius.circular(CD.rRow),
          border: Border.all(color: current ? CD.accent : p.cardBorder, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(name, style: CDText.title(14, color: p.text)),
                const SizedBox(width: 8),
                Text(price, style: CDText.body(12.5, weight: FontWeight.w800, color: CD.accent)),
                const Spacer(),
                if (current) const TagView(text: '目前方案', color: CD.accent),
              ],
            ),
            const SizedBox(height: 6),
            for (final f in feats) Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Text('· $f', style: CDText.body(12, weight: FontWeight.w500, color: p.text2)),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SheetParagraph('以「照護時段」計費：24 小時內不限上傳張數與整理次數。'),
        tier('免費', '\$0', ['AI 整理 2 次', '專業版注意事項（用藥安全永遠免費）'], current: true),
        tier('輕量', '\$30 / 3 時段', ['AI 整理 3 次']),
        tier('吃到飽', '\$149 / 月', ['AI 整理 15 次/月', '白話版注意事項（含嚴重度標示）']),
        const SheetHeading('加購'),
        const SheetBullet('照護海報 \$49 一次買斷'),
        const SheetBullet('推播提醒 \$29 / 月'),
        const SheetParagraph('\n付費功能即將在正式版開放。'),
      ],
    );
  }

  Widget _aboutBody(Palette p) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        SheetParagraph('Carrius — 醫療照護整理工具（care + carry + us）。'),
        SheetParagraph('把散亂的醫療文件，3 分鐘變成全家看得懂的照護指南。'),
        SheetHeading('版本'),
        SheetBullet('v0.1 POC 展示版本。部分功能（金流、雲端同步、語音輸入、.ics 匯出）尚未開放。'),
        SheetHeading('資料來源致謝'),
        SheetBullet('藥品資料引用食藥署 Open Data 與各醫院藥品資訊，POC 階段僅供展示，正式版前將取得授權。'),
        SheetParagraph('\n此內容由 AI 輔助整理，請與原始醫療文件核對。'),
      ],
    );
  }
}
