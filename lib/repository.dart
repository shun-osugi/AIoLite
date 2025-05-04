// lib/repository.dart
import 'dart:collection';

class FeedbackData {
  final String subject;
  final List<String> labels;
  FeedbackData(this.subject, this.labels);
}

/// 集計結果
class Stats {
  final Map<String, double> subjectRate;
  final Map<String, List<(String,int)>> tops;
  Stats(this.subjectRate, this.tops);
}

/// ───────────────────────────
///  データを抱える唯一のクラス
///  ─ DB ロード、追加、統計計算を担当
/// ───────────────────────────
class Repository {
  Repository._();               // private ctor
  static final _inst = Repository._();
  static Repository get I => _inst;

  // ------------------ 内部保持 ------------------
  final List<FeedbackData> _raw = [];
  Stats? _cache;                // ★集計済みをキャッシュ

  // ---------- ① 起動時に DB → メモリ ----------
  Future<void> loadFromDb() async {
    // TODO: SQLite / Hive などから読み込み
    _raw.clear();
    _raw.addAll(_dummy);        // ←ダミー投入
    _rebuild();                 // _cache 生成
  }

  // ---------- ② 集計を外部へ返す --------------
  Stats get stats => _cache ?? _rebuild();

  // ---------- ③ フィードバック 1 件追加 --------
  void add(FeedbackData fb) {
    _raw.add(fb);
    _rebuild();                 // 差分更新でも O(N) でもどちらでも可
  }

  // ---------- 内部: 再計算 ----------------------
  Stats _rebuild() {
    final total = _raw.length;
    if (total == 0) {
      return _cache = Stats(const {}, const {});
    }

    final subjCnt  = <String, int>{};
    final labelCnt = <String, Map<String, int>>{};

    for (final fb in _raw) {
      subjCnt.update(fb.subject, (v) => v + 1, ifAbsent: () => 1);
      final m = labelCnt.putIfAbsent(fb.subject, () => {});
      for (final lb in fb.labels) {
        m.update(lb, (v) => v + 1, ifAbsent: () => 1);
      }
    }

    final subjRate = {
      for (final e in subjCnt.entries) e.key: e.value * 100 / total
    };
    final tops = <String, List<(String,int)>>{};
    labelCnt.forEach((subj, m) {
      final top3 = m.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      tops[subj] = top3.take(3).map((e) => (e.key, e.value)).toList();
    });

    return _cache = Stats(subjRate, tops);
  }
}

// -------------- ダミーデータ --------------
final _dummy = <FeedbackData>[
  FeedbackData('国語',  ['漢文']),
  FeedbackData('数学',  ['図形']),
  FeedbackData('数学',  ['確率','計算']),
  FeedbackData('英語',  ['英文法']),
];
