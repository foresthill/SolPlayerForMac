# SolPlayer for Mac - Development Notes

## Project Overview
macOS用音楽プレイヤーアプリ（ソルフェジオ周波数対応）

## Current Task: UI Modernization

### TODO List

#### Phase 1: Auto Layout対応
- [ ] 現在のfixedFrame指定を削除
- [ ] 各UI要素にAuto Layout制約を追加
- [ ] コントロールエリア（再生ボタン、スライダー等）のレイアウト
- [ ] テーブルビュー/アウトラインビューのリサイズ対応

#### Phase 2: モダンなmacOSデザイン
- [ ] ビジュアルエフェクトビュー（背景ぼかし）の検討
- [ ] システムカラーの活用
- [ ] フォントスタイルの統一

#### Phase 3: ボタン/スライダーのスタイル更新
- [ ] 再生コントロールボタンをSF Symbolsに変更
- [ ] スライダーのスタイル統一
- [ ] Hzボタン、スピードボタンのデザイン改善

#### Phase 4: ウィンドウリサイズ対応
- [ ] 最小/最大ウィンドウサイズの設定
- [ ] 各要素のリサイズ動作確認
- [ ] レスポンシブなレイアウト調整

### Notes
- Storyboard: `SolPlayer for Mac/Base.lproj/Main.storyboard`
- Main ViewController: `SolPlayer for Mac/ViewController.swift`
- Swift 4.2対応
