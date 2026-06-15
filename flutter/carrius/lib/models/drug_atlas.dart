/// 藥品圖鑑資料模型。
/// 資料來源：藥台灣 drugtw.com（聚合）＋ 食藥署外觀 ＋ 各醫院藥品頁。
/// ⚠️ POC：內容版權屬各原始來源（食藥署/醫院），未取得授權前不得用於正式 App。
class DrugFull {
  final String slug, disease;
  final String chiName, enName, ingredient, drugClass;
  final String license, nhiCode, brand, appearanceMark;
  final String indication, dosage, sideEffects, precautions, contraindication;
  final String photoAsset; // assets/drugs/<slug>.jpg
  final String deepSource; // 深度臨床欄位來源（醫院網域）；空＝無
  final bool fdaImage; // 外觀照片是否為食藥署官方圖

  const DrugFull({
    required this.slug,
    required this.disease,
    required this.chiName,
    this.enName = '',
    this.ingredient = '',
    this.drugClass = '',
    this.license = '',
    this.nhiCode = '',
    this.brand = '',
    this.appearanceMark = '',
    this.indication = '',
    this.dosage = '',
    this.sideEffects = '',
    this.precautions = '',
    this.contraindication = '',
    required this.photoAsset,
    this.deepSource = '',
    this.fdaImage = false,
  });

  bool get hasDeep => dosage.isNotEmpty || sideEffects.isNotEmpty || precautions.isNotEmpty;

  /// 展開卡的 label/value 列（只回傳有內容的欄位），順序對齊鴿王提供的參考卡。
  List<MapEntry<String, String>> get rows {
    final r = <MapEntry<String, String>>[];
    void add(String k, String v) {
      if (v.trim().isNotEmpty) r.add(MapEntry(k, v.trim()));
    }
    add('藥品名稱', enName);
    add('中文名稱', chiName);
    add('學名／成分', ingredient);
    add('類別', drugClass);
    add('健保代號', nhiCode);
    add('廠牌', brand);
    add('外觀標記', appearanceMark);
    add('適應症', indication);
    add('用法用量', dosage);
    add('可能副作用', sideEffects);
    add('注意事項', precautions);
    add('禁忌', contraindication);
    add('許可證字號', license);
    return r;
  }
}

/// 四種病分組。
class DiseaseGroup {
  final String name;
  final List<DrugFull> drugs;
  const DiseaseGroup(this.name, this.drugs);
}
