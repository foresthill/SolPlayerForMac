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

#### Phase 3: ボタン/スライダーのスタイル更新 [DONE]
- [x] 再生コントロールボタンをSF Symbolsに変更
- [x] スライダーのスタイル統一
- [x] Hzボタン、スピードボタンのデザイン改善

#### Phase 4: ウィンドウリサイズ対応 [DONE]
- [x] 最小/最大ウィンドウサイズの設定
- [x] 各要素のリサイズ動作確認
- [x] レスポンシブなレイアウト調整

### バグ修正 / 機能改善 [DONE]

#### UI/レイアウトの問題
- [x] タイトルとフォルダパスの表示が被っている → レイアウト制約を調整
- [x] 不要な「button」ボタンを削除

#### 再生機能の問題
- [x] 時間シークバーが曲の再生時間と連動していない → タイマーで更新
- [x] 前の曲/次の曲ボタンが機能していない → アクション実装

### Implementation Notes

#### Phase 1で追加したもの
- `setupConstraints()` - Auto Layout制約をプログラマティックに設定
- `setupStyles()` - UIスタイルを統一的に設定
- `enableAutoLayout(for:)` - ビューのtranslatesAutoresizingMaskIntoConstraintsをfalseに設定

#### Phase 2で追加したもの
- `setupVisualEffectBackground()` - NSVisualEffectViewで背景ぼかし効果
- `setupTableViewStyles()` - テーブル/アウトラインビューのスタイル設定
- `createControlPanelBackground(for:)` - コントロールパネル用背景（将来用）
- システムカラー: `labelColor`, `secondaryLabelColor`, `tertiaryLabelColor`, `separatorColor`
- 等幅数字フォント: `monospacedDigitSystemFont` で数値表示を統一

#### Phase 3で追加したもの
- `setupButtonStyles()` - ボタンスタイルの設定
- `configurePlaybackButton()` - SF Symbolsで再生ボタンを設定
- `configurePresetButton()` - プリセットボタン（Hz、Speed）のスタイル設定
- `setupSliderStyles()` - スライダーの共通スタイル設定
- SF Symbols: `backward.fill`, `stop.fill`, `play.fill`, `folder.badge.plus`
- デプロイメントターゲット: 10.14 → 11.0（Big Sur）に更新

#### Phase 4で追加したもの
- `setupWindowConstraints()` - ウィンドウの最小/最大サイズを設定
- 最小サイズ: 700x520、最大サイズ: 1400x900
- レイアウト制約の調整（タイトルとロードボタンの重なり防止）

#### バグ修正で追加したもの
- `playbackTimer` - 再生時間更新用タイマー
- `startPlaybackTimer()` / `stopPlaybackTimer()` - タイマー制御
- `updatePlaybackTime()` - スライダーと時間ラベルを更新
- `formatTime()` - 秒をMM:SS形式にフォーマット
- `timeSliderAction()` - シークバー操作時のアクション
- `prevButtonAction()` / `nextButtonAction()` - 前後曲ボタン
- `playCurrentSong()` - 指定インデックスの曲を再生

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
