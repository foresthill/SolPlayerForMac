# SolPlayer for Mac - Development Notes

## Project Overview
macOS用音楽プレイヤーアプリ（ソルフェジオ周波数対応）

## Current Task: UI Modernization

### TODO List

#### Phase 1: Auto Layout対応 [DONE]
- [x] 各UI要素にAuto Layout制約を追加（Swiftコードで実装）
- [x] コントロールエリア（再生ボタン、スライダー等）のレイアウト
- [x] テーブルビュー/アウトラインビューのリサイズ対応
- [x] 新規IBOutlet追加（ボタン、タイトルラベル等）

#### Phase 2: モダンなmacOSデザイン [DONE]
- [x] ビジュアルエフェクトビュー（背景ぼかし）の追加
- [x] システムカラーの活用（ダークモード自動対応）
- [x] フォントスタイルの統一

#### Phase 3: ボタン/スライダーのスタイル更新
- [ ] 再生コントロールボタンをSF Symbolsに変更
- [ ] スライダーのスタイル統一
- [ ] Hzボタン、スピードボタンのデザイン改善

#### Phase 4: ウィンドウリサイズ対応
- [ ] 最小/最大ウィンドウサイズの設定
- [ ] 各要素のリサイズ動作確認
- [ ] レスポンシブなレイアウト調整

### Implementation Notes

#### Phase 1で追加したもの
- `setupConstraints()` - Auto Layout制約をプログラマティックに設定
- `setupStyles()` - UIスタイルを統一的に設定
- `enableAutoLayout(for:)` - ビューのtranslatesAutoresizingMaskIntoConstraintsをfalseに設定

#### Phase 2で追加したもの
- `setupVisualEffectBackground()` - NSVisualEffectViewで背景ぼかし効果
- `setupTableViewStyles()` - テーブル/アウトラインビューのスタイル設定
- `createControlPanelBackground(for:)` - コントロールパネル用背景（将来用）
- システムカラー: `labelColor`, `secondaryLabelColor`, `tertiaryLabelColor`, `gridColor`
- 等幅数字フォント: `monospacedDigitSystemFont` で数値表示を統一

#### 新規追加IBOutlet
- Playback: `prevButton`, `stopButton`, `playButton`, `loadButton`
- Hz: `hzTitleLabel`, `to437Button`
- Speed: `speedTitleLabel`, `speed1xButton`, `speed2xButton`, `speed4xButton`, `speed8xButton`
- Reverb: `reverbTitleLabel`
- Views: `outlineScrollView`

### Files Modified
- `SolPlayer for Mac/ViewController.swift`
- `SolPlayer for Mac/Base.lproj/Main.storyboard`

### Notes
- Swift 4.2対応
- IBOutlet接続はStoryboard XML直接編集で追加
