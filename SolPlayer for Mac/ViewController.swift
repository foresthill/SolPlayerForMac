//
//  ViewController.swift
//  SolPlayer for Mac
//
//  Created by Morioka Naoya on H28/06/30.
//  Copyright © 平成28年 Morioka Naoya. All rights reserved.
//

import Cocoa

import AVFoundation

import AVKit

import MediaPlayer

import AppKit

class ViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {

    // MARK: - Song Info
    @IBOutlet weak var titleLabel: NSTextField!
    @IBOutlet weak var artistLabel: NSTextField!
    @IBOutlet weak var playlistLabel: NSTextField!
    @IBOutlet weak var artworkImage: NSImageView!

    // MARK: - Time Controls
    @IBOutlet weak var timeSlider: NSSlider!
    @IBOutlet weak var nowTimeLabel: NSTextField!
    @IBOutlet weak var endTimeLabel: NSTextField!

    // MARK: - Playback Controls
    @IBOutlet weak var prevButton: NSButton!
    @IBOutlet weak var stopButton: NSButton!
    @IBOutlet weak var playButton: NSButton!
    @IBOutlet weak var loadButton: NSButton!

    // MARK: - Hz Controls
    @IBOutlet weak var hzSlider: NSSlider!
    @IBOutlet weak var hzLabel: NSTextField!
    @IBOutlet weak var hzTitleLabel: NSTextField!
    @IBOutlet weak var to432Button: NSButton!
    @IBOutlet weak var to444Button: NSButton!
    @IBOutlet weak var to437Button: NSButton!

    // MARK: - Speed Controls
    @IBOutlet weak var speedSlider: NSSlider!
    @IBOutlet weak var speedLabel: NSTextField!
    @IBOutlet weak var speedTitleLabel: NSTextField!
    @IBOutlet weak var speed1xButton: NSButton!
    @IBOutlet weak var speed2xButton: NSButton!
    @IBOutlet weak var speed4xButton: NSButton!
    @IBOutlet weak var speed8xButton: NSButton!

    // MARK: - Reverb Controls
    @IBOutlet weak var reverbSlider: NSSlider!
    @IBOutlet weak var reverbLabel: NSTextField!
    @IBOutlet weak var reverbTitleLabel: NSTextField!

    // MARK: - Volume Controls
    @IBOutlet weak var volumeSlider: NSSlider!
    @IBOutlet weak var volumeLabel: NSTextField!
    @IBOutlet weak var volumeTitleLabel: NSTextField!

    // MARK: - Playlist Views
    @IBOutlet weak var playlistSchrollView: NSScrollView!
    @IBOutlet weak var songTableView: NSTableView!
    @IBOutlet weak var playlistHeaderView: NSTableHeaderView!
    @IBOutlet weak var searchAlbum: NSSearchField!
    @IBOutlet weak var playlist2column: NSTableColumn!
    @IBOutlet weak var playlist2column2: NSTableColumn!
    @IBOutlet weak var playlistOutlineView: NSOutlineView!
    @IBOutlet weak var outlineScrollView: NSScrollView!
    
    // SolPlayerのインスタンス（シングルトン）
    var solPlayer: SolPlayer!
    
    // urlを暫定的に外出し。
    var url: NSURL!

    // iTunesを読み込み
    var iTunes: ITunesLibrary = ITunesLibrary()

    // 曲
    var trackIds: [Int] = []

    // 再生時間更新用タイマー
    var playbackTimer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()

        solPlayer = SolPlayer.sharedManager

        // 最初なぜかリバーブが0にならないので強引に
        solPlayer.reverbChange(val: 0.0)

        // iTunes Library読み込み
        openLibrary(path: ITunesLibrary.XmlFilePath())

        // ビジュアルエフェクト背景をセットアップ（Auto Layout前に追加）
        setupVisualEffectBackground()

        // Auto Layoutセットアップ
        setupConstraints()

        // UIスタイルのセットアップ
        setupStyles()
    }

    override func viewDidAppear() {
        super.viewDidAppear()

        // ウィンドウサイズ制約を設定
        setupWindowConstraints()
    }

    // MARK: - Window Size Constraints

    private func setupWindowConstraints() {
        guard let window = view.window else { return }

        // 最小サイズ: コントロールが収まる最小限のサイズ
        window.minSize = NSSize(width: 700, height: 520)

        // 最大サイズ: 画面サイズに制限（任意）
        window.maxSize = NSSize(width: 1400, height: 900)

        // 現在のサイズが最小サイズより小さい場合は調整
        if window.frame.width < window.minSize.width || window.frame.height < window.minSize.height {
            let newWidth = max(window.frame.width, window.minSize.width)
            let newHeight = max(window.frame.height, window.minSize.height)
            window.setContentSize(NSSize(width: newWidth, height: newHeight))
        }
    }

    // MARK: - Auto Layout Setup

    private func setupConstraints() {
        guard let mainView = self.view as? NSView else { return }

        // 全ての要素でAuto Layoutを有効化
        enableAutoLayout(for: mainView)

        // 定数定義
        let padding: CGFloat = 16
        let smallPadding: CGFloat = 8
        let controlHeight: CGFloat = 24
        let buttonHeight: CGFloat = 28
        let sliderWidth: CGFloat = 100

        // MARK: Artwork (Top Right Corner)
        if let artworkImage = artworkImage {
            NSLayoutConstraint.activate([
                artworkImage.topAnchor.constraint(equalTo: mainView.topAnchor, constant: padding),
                artworkImage.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -padding),
                artworkImage.widthAnchor.constraint(equalToConstant: 60),
                artworkImage.heightAnchor.constraint(equalToConstant: 60),
            ])
        }

        // MARK: Volume Controls (Right side, below artwork)
        if let volumeSlider = volumeSlider, let volumeLabel = volumeLabel, let volumeTitleLabel = volumeTitleLabel, let artworkImage = artworkImage {
            NSLayoutConstraint.activate([
                // Volタイトル（アートワークの下）
                volumeTitleLabel.topAnchor.constraint(equalTo: artworkImage.bottomAnchor, constant: smallPadding),
                volumeTitleLabel.centerXAnchor.constraint(equalTo: artworkImage.centerXAnchor),

                // 縦スライダー（Volラベルの下）
                volumeSlider.topAnchor.constraint(equalTo: volumeTitleLabel.bottomAnchor, constant: 4),
                volumeSlider.centerXAnchor.constraint(equalTo: volumeTitleLabel.centerXAnchor),
                volumeSlider.widthAnchor.constraint(equalToConstant: 24),
                volumeSlider.heightAnchor.constraint(equalToConstant: 80),

                // 数値ラベル（スライダーの下）
                volumeLabel.topAnchor.constraint(equalTo: volumeSlider.bottomAnchor, constant: 4),
                volumeLabel.centerXAnchor.constraint(equalTo: volumeSlider.centerXAnchor),
            ])
        }

        // MARK: Song Info Area (Top Left)
        if let titleLabel = titleLabel, let artistLabel = artistLabel, let artworkImage = artworkImage {
            NSLayoutConstraint.activate([
                titleLabel.topAnchor.constraint(equalTo: mainView.topAnchor, constant: padding),
                titleLabel.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: padding),
                titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: artworkImage.leadingAnchor, constant: -padding * 2),

                artistLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
                artistLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
                artistLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            ])
        }

        // MARK: Playlist Label (Below Artist)
        if let playlistLabel = playlistLabel, let artistLabel = artistLabel {
            NSLayoutConstraint.activate([
                playlistLabel.topAnchor.constraint(equalTo: artistLabel.bottomAnchor, constant: 2),
                playlistLabel.leadingAnchor.constraint(equalTo: artistLabel.leadingAnchor),
            ])
        }

        // MARK: Time Slider & Labels
        if let timeSlider = timeSlider, let nowTimeLabel = nowTimeLabel, let endTimeLabel = endTimeLabel {
            NSLayoutConstraint.activate([
                timeSlider.topAnchor.constraint(equalTo: mainView.topAnchor, constant: 85),
                timeSlider.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: padding),
                timeSlider.widthAnchor.constraint(equalToConstant: 180),
                timeSlider.heightAnchor.constraint(equalToConstant: controlHeight),

                nowTimeLabel.topAnchor.constraint(equalTo: timeSlider.bottomAnchor, constant: 2),
                nowTimeLabel.leadingAnchor.constraint(equalTo: timeSlider.leadingAnchor),

                endTimeLabel.topAnchor.constraint(equalTo: timeSlider.bottomAnchor, constant: 2),
                endTimeLabel.trailingAnchor.constraint(equalTo: timeSlider.trailingAnchor),
            ])
        }

        // MARK: Playback Controls (Below time controls)
        if let prevButton = prevButton, let stopButton = stopButton, let playButton = playButton, let loadButton = loadButton {
            NSLayoutConstraint.activate([
                prevButton.topAnchor.constraint(equalTo: mainView.topAnchor, constant: 125),
                prevButton.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: padding),
                prevButton.heightAnchor.constraint(equalToConstant: buttonHeight),

                stopButton.centerYAnchor.constraint(equalTo: prevButton.centerYAnchor),
                stopButton.leadingAnchor.constraint(equalTo: prevButton.trailingAnchor, constant: smallPadding),
                stopButton.heightAnchor.constraint(equalToConstant: buttonHeight),

                playButton.centerYAnchor.constraint(equalTo: stopButton.centerYAnchor),
                playButton.leadingAnchor.constraint(equalTo: stopButton.trailingAnchor, constant: smallPadding),
                playButton.heightAnchor.constraint(equalToConstant: buttonHeight),

                loadButton.centerYAnchor.constraint(equalTo: playButton.centerYAnchor),
                loadButton.leadingAnchor.constraint(equalTo: playButton.trailingAnchor, constant: padding),
                loadButton.heightAnchor.constraint(equalToConstant: buttonHeight),
                loadButton.widthAnchor.constraint(equalToConstant: 36),
            ])
        }

        // MARK: Search Field (Next to load button)
        if let searchAlbum = searchAlbum, let loadButton = loadButton {
            NSLayoutConstraint.activate([
                searchAlbum.centerYAnchor.constraint(equalTo: loadButton.centerYAnchor),
                searchAlbum.leadingAnchor.constraint(equalTo: loadButton.trailingAnchor, constant: smallPadding),
                searchAlbum.widthAnchor.constraint(equalToConstant: 140),
                searchAlbum.heightAnchor.constraint(equalToConstant: buttonHeight),
            ])
        }

        // MARK: Hz Controls (左側中段)
        if let hzTitleLabel = hzTitleLabel, let hzSlider = hzSlider, let hzLabel = hzLabel {
            let hzTop: CGFloat = 165

            NSLayoutConstraint.activate([
                hzTitleLabel.topAnchor.constraint(equalTo: mainView.topAnchor, constant: hzTop),
                hzTitleLabel.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: padding),
                hzTitleLabel.widthAnchor.constraint(equalToConstant: 45),

                hzSlider.centerYAnchor.constraint(equalTo: hzTitleLabel.centerYAnchor),
                hzSlider.leadingAnchor.constraint(equalTo: hzTitleLabel.trailingAnchor, constant: smallPadding),
                hzSlider.widthAnchor.constraint(equalToConstant: sliderWidth),

                hzLabel.centerYAnchor.constraint(equalTo: hzTitleLabel.centerYAnchor),
                hzLabel.leadingAnchor.constraint(equalTo: hzSlider.trailingAnchor, constant: smallPadding),
                hzLabel.widthAnchor.constraint(equalToConstant: 35),
            ])
        }

        // MARK: Hz Preset Buttons
        if let to432Button = to432Button, let to444Button = to444Button, let to437Button = to437Button, let hzLabel = hzLabel {
            NSLayoutConstraint.activate([
                to432Button.centerYAnchor.constraint(equalTo: hzLabel.centerYAnchor),
                to432Button.leadingAnchor.constraint(equalTo: hzLabel.trailingAnchor, constant: smallPadding),

                to444Button.centerYAnchor.constraint(equalTo: to432Button.centerYAnchor),
                to444Button.leadingAnchor.constraint(equalTo: to432Button.trailingAnchor, constant: 4),

                to437Button.centerYAnchor.constraint(equalTo: to432Button.centerYAnchor),
                to437Button.leadingAnchor.constraint(equalTo: to444Button.trailingAnchor, constant: 4),
            ])
        }

        // MARK: Speed Controls
        if let speedTitleLabel = speedTitleLabel, let speedSlider = speedSlider, let speedLabel = speedLabel {
            let speedTop: CGFloat = 200

            NSLayoutConstraint.activate([
                speedTitleLabel.topAnchor.constraint(equalTo: mainView.topAnchor, constant: speedTop),
                speedTitleLabel.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: padding),
                speedTitleLabel.widthAnchor.constraint(equalToConstant: 45),

                speedSlider.centerYAnchor.constraint(equalTo: speedTitleLabel.centerYAnchor),
                speedSlider.leadingAnchor.constraint(equalTo: speedTitleLabel.trailingAnchor, constant: smallPadding),
                speedSlider.widthAnchor.constraint(equalToConstant: sliderWidth),

                speedLabel.centerYAnchor.constraint(equalTo: speedTitleLabel.centerYAnchor),
                speedLabel.leadingAnchor.constraint(equalTo: speedSlider.trailingAnchor, constant: smallPadding),
                speedLabel.widthAnchor.constraint(equalToConstant: 35),
            ])
        }

        // MARK: Speed Preset Buttons
        if let speed1xButton = speed1xButton, let speed2xButton = speed2xButton,
           let speed4xButton = speed4xButton, let speed8xButton = speed8xButton,
           let speedLabel = speedLabel {
            NSLayoutConstraint.activate([
                speed1xButton.centerYAnchor.constraint(equalTo: speedLabel.centerYAnchor),
                speed1xButton.leadingAnchor.constraint(equalTo: speedLabel.trailingAnchor, constant: smallPadding),

                speed2xButton.centerYAnchor.constraint(equalTo: speed1xButton.centerYAnchor),
                speed2xButton.leadingAnchor.constraint(equalTo: speed1xButton.trailingAnchor, constant: 4),

                speed4xButton.centerYAnchor.constraint(equalTo: speed1xButton.centerYAnchor),
                speed4xButton.leadingAnchor.constraint(equalTo: speed2xButton.trailingAnchor, constant: 4),

                speed8xButton.centerYAnchor.constraint(equalTo: speed1xButton.centerYAnchor),
                speed8xButton.leadingAnchor.constraint(equalTo: speed4xButton.trailingAnchor, constant: 4),
            ])
        }

        // MARK: Reverb Controls
        if let reverbTitleLabel = reverbTitleLabel, let reverbSlider = reverbSlider, let reverbLabel = reverbLabel {
            let reverbTop: CGFloat = 235

            NSLayoutConstraint.activate([
                reverbTitleLabel.topAnchor.constraint(equalTo: mainView.topAnchor, constant: reverbTop),
                reverbTitleLabel.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: padding),
                reverbTitleLabel.widthAnchor.constraint(equalToConstant: 45),

                reverbSlider.centerYAnchor.constraint(equalTo: reverbTitleLabel.centerYAnchor),
                reverbSlider.leadingAnchor.constraint(equalTo: reverbTitleLabel.trailingAnchor, constant: smallPadding),
                reverbSlider.widthAnchor.constraint(equalToConstant: sliderWidth),

                reverbLabel.centerYAnchor.constraint(equalTo: reverbTitleLabel.centerYAnchor),
                reverbLabel.leadingAnchor.constraint(equalTo: reverbSlider.trailingAnchor, constant: smallPadding),
                reverbLabel.widthAnchor.constraint(equalToConstant: 35),
            ])
        }

        // MARK: Playlist Tables (Bottom)
        if let playlistSchrollView = playlistSchrollView, let outlineScrollView = outlineScrollView {
            NSLayoutConstraint.activate([
                playlistSchrollView.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: padding),
                playlistSchrollView.bottomAnchor.constraint(equalTo: mainView.bottomAnchor, constant: -padding),
                playlistSchrollView.widthAnchor.constraint(equalTo: mainView.widthAnchor, multiplier: 0.45, constant: -padding),
                playlistSchrollView.heightAnchor.constraint(equalToConstant: 180),

                outlineScrollView.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -padding),
                outlineScrollView.bottomAnchor.constraint(equalTo: mainView.bottomAnchor, constant: -padding),
                outlineScrollView.widthAnchor.constraint(equalTo: mainView.widthAnchor, multiplier: 0.45, constant: -padding),
                outlineScrollView.heightAnchor.constraint(equalToConstant: 180),
            ])
        }
    }

    private func enableAutoLayout(for view: NSView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        for subview in view.subviews {
            subview.translatesAutoresizingMaskIntoConstraints = false
        }
    }

    // MARK: - Style Setup

    private func setupStyles() {
        // 注: 背景はNSVisualEffectViewで処理されるため、
        // view.layer?.backgroundColorは設定しない

        // MARK: Song Info Labels
        titleLabel?.font = NSFont.systemFont(ofSize: 20, weight: .semibold)
        titleLabel?.textColor = NSColor.labelColor

        artistLabel?.font = NSFont.systemFont(ofSize: 13, weight: .regular)
        artistLabel?.textColor = NSColor.secondaryLabelColor

        playlistLabel?.font = NSFont.systemFont(ofSize: 11, weight: .medium)
        playlistLabel?.textColor = NSColor.tertiaryLabelColor

        // MARK: Control Title Labels（Hz, Speed, Reverb）
        let titleFont = NSFont.systemFont(ofSize: 12, weight: .medium)
        let titleColor = NSColor.secondaryLabelColor

        hzTitleLabel?.font = titleFont
        hzTitleLabel?.textColor = titleColor

        speedTitleLabel?.font = titleFont
        speedTitleLabel?.textColor = titleColor

        reverbTitleLabel?.font = titleFont
        reverbTitleLabel?.textColor = titleColor

        volumeTitleLabel?.font = titleFont
        volumeTitleLabel?.textColor = titleColor

        // MARK: Value Labels（数値表示用 - 等幅フォント）
        let valueFont = NSFont.monospacedDigitSystemFont(ofSize: 11, weight: .regular)
        let valueColor = NSColor.secondaryLabelColor

        hzLabel?.font = valueFont
        hzLabel?.textColor = valueColor

        speedLabel?.font = valueFont
        speedLabel?.textColor = valueColor

        reverbLabel?.font = valueFont
        reverbLabel?.textColor = valueColor

        volumeLabel?.font = valueFont
        volumeLabel?.textColor = valueColor

        // MARK: Time Labels（再生時間表示）
        let timeFont = NSFont.monospacedDigitSystemFont(ofSize: 11, weight: .medium)
        nowTimeLabel?.font = timeFont
        nowTimeLabel?.textColor = NSColor.labelColor

        endTimeLabel?.font = timeFont
        endTimeLabel?.textColor = NSColor.tertiaryLabelColor

        // MARK: Artwork Image Style
        artworkImage?.wantsLayer = true
        artworkImage?.layer?.cornerRadius = 8
        artworkImage?.layer?.masksToBounds = true
        artworkImage?.layer?.borderWidth = 0.5
        artworkImage?.layer?.borderColor = NSColor.separatorColor.cgColor

        // MARK: Button & Slider Styles
        setupButtonStyles()
        setupSliderStyles()

        // MARK: Table/Outline View Style
        setupTableViewStyles()
    }

    // MARK: - Button Styles

    private func setupButtonStyles() {
        // 再生コントロールボタン - SF Symbols
        configurePlaybackButton(prevButton, symbolName: "backward.fill", pointSize: 16)
        configurePlaybackButton(stopButton, symbolName: "stop.fill", pointSize: 16)
        configurePlaybackButton(playButton, symbolName: "play.fill", pointSize: 18)
        configurePlaybackButton(loadButton, symbolName: "folder.badge.plus", pointSize: 14)

        // Hzプリセットボタン
        configurePresetButton(to432Button)
        configurePresetButton(to437Button)
        configurePresetButton(to444Button)

        // スピードプリセットボタン
        configurePresetButton(speed1xButton)
        configurePresetButton(speed2xButton)
        configurePresetButton(speed4xButton)
        configurePresetButton(speed8xButton)
    }

    private func configurePlaybackButton(_ button: NSButton?, symbolName: String, pointSize: CGFloat) {
        guard let button = button else { return }

        let config = NSImage.SymbolConfiguration(pointSize: pointSize, weight: .medium)
        if let image = NSImage(systemSymbolName: symbolName, accessibilityDescription: nil) {
            let configuredImage = image.withSymbolConfiguration(config)
            button.image = configuredImage
            button.imagePosition = .imageOnly
        }

        button.bezelStyle = .regularSquare
        button.isBordered = false
        button.wantsLayer = true
        button.contentTintColor = NSColor.controlAccentColor
    }

    private func configurePresetButton(_ button: NSButton?) {
        guard let button = button else { return }

        button.bezelStyle = .roundRect
        button.font = NSFont.systemFont(ofSize: 11, weight: .medium)
        button.wantsLayer = true
        button.layer?.cornerRadius = 4
    }

    // MARK: - Slider Styles

    private func setupSliderStyles() {
        // 全スライダーの共通スタイル
        let sliders = [timeSlider, hzSlider, speedSlider, reverbSlider, volumeSlider]

        for slider in sliders {
            guard let slider = slider else { continue }
            slider.controlSize = .regular
        }
    }

    private func setupTableViewStyles() {
        // Song Table View
        songTableView?.backgroundColor = NSColor.controlBackgroundColor
        songTableView?.gridColor = NSColor.separatorColor
        songTableView?.usesAlternatingRowBackgroundColors = true

        // Playlist Outline View
        playlistOutlineView?.backgroundColor = NSColor.controlBackgroundColor
        playlistOutlineView?.usesAlternatingRowBackgroundColors = true

        // Scroll View Borders
        playlistSchrollView?.wantsLayer = true
        playlistSchrollView?.layer?.cornerRadius = 6
        playlistSchrollView?.layer?.borderWidth = 1
        playlistSchrollView?.layer?.borderColor = NSColor.separatorColor.cgColor

        outlineScrollView?.wantsLayer = true
        outlineScrollView?.layer?.cornerRadius = 6
        outlineScrollView?.layer?.borderWidth = 1
        outlineScrollView?.layer?.borderColor = NSColor.separatorColor.cgColor
    }

    // MARK: - Visual Effect Background

    /// コントロールエリアに背景ぼかしエフェクトを追加
    /// 注意: この機能はmacOS 10.10+で利用可能
    private func setupVisualEffectBackground() {
        // メインビューの背景にビジュアルエフェクトを適用
        let visualEffectView = NSVisualEffectView()
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        visualEffectView.material = .sidebar  // サイドバー風の外観
        visualEffectView.blendingMode = .behindWindow
        visualEffectView.state = .active

        // ビューの最背面に追加
        view.addSubview(visualEffectView, positioned: .below, relativeTo: view.subviews.first)

        NSLayoutConstraint.activate([
            visualEffectView.topAnchor.constraint(equalTo: view.topAnchor),
            visualEffectView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            visualEffectView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            visualEffectView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    /// コントロールパネル用の半透明背景を作成
    private func createControlPanelBackground(for controlViews: [NSView]) {
        for controlView in controlViews {
            guard let superview = controlView.superview else { continue }

            let backgroundView = NSVisualEffectView()
            backgroundView.translatesAutoresizingMaskIntoConstraints = false
            backgroundView.material = .popover
            backgroundView.blendingMode = .withinWindow
            backgroundView.state = .active
            backgroundView.wantsLayer = true
            backgroundView.layer?.cornerRadius = 8

            superview.addSubview(backgroundView, positioned: .below, relativeTo: controlView)

            NSLayoutConstraint.activate([
                backgroundView.topAnchor.constraint(equalTo: controlView.topAnchor, constant: -4),
                backgroundView.leadingAnchor.constraint(equalTo: controlView.leadingAnchor, constant: -8),
                backgroundView.trailingAnchor.constraint(equalTo: controlView.trailingAnchor, constant: 8),
                backgroundView.bottomAnchor.constraint(equalTo: controlView.bottomAnchor, constant: 4)
            ])
        }
    }

    //func readFileAudio() -> NSURL {
    func readFileAudio() {
        //ダイアログ
        //var url:NSURL = NSURL()
        //URLを初期化
        url = NSURL()
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false //複数ファイルの選択を許すか
        openPanel.canChooseDirectories = false //ディレクトリの選択を許すか
        openPanel.canCreateDirectories = false //ディレクトリの作成を許すか
        openPanel.canChooseFiles = true //ファイルを選択できるか
        //openPanel.allowedFileTypes = NSImage.imageTypes()
        //openPanel.allowedFileTypes = AVMovie.movieTypes()
        //openPanel.allowedFileTypes = AVAudioFile
        //openPanel.allowedFileTypes = AVMediaTypeAudio
        openPanel.allowedFileTypes = ["mp3", "wav", "m4a"]
        //print(kUTTypeAudio)
        openPanel.begin{ (result) -> Void in
//            if result is NSFileHandlingPanelOKButton {  //ファイルを選択したか（OKを押したか）
            if result != nil && openPanel.url != nil{
                self.url = openPanel.url! as NSURL
                
                //音声ファイル情報読み込み
                
                let path = NSString(string: (openPanel.url?.absoluteString)!)
                
                //print(path.absolutePath)
                //print(path.lastPathComponent)
                
                
                //openPanel.filena
                //assetURL
                //print(self.url.absoluteString)
                //self.solPlayer.playlist.append(Song(title: openPanel.nameFieldLabel, assetURL: openPanel.URL!))
                //self.solPlayer.playlist.append(Song(title: openPanel.stringWithSavedFrame, assetURL: openPanel.URL!))
                self.solPlayer.playlist.append(Song(title: path.lastPathComponent, assetURL: openPanel.url! as NSURL))
//                print(self.solPlayer.playlist)
                self.songTableView.reloadData()
                //AudioUnit
                
                //ちな。
                //let avAsset = AVURLAsset(URL: openPanel.URL!)
                //let playerItem = AVPlayerItem(asset: avAsset)
                //print(playerItem.attributeKeys)
                //var mediaItem:MPMediaItem = MPMediaItem.url
                
            }
        }
        //return url
    }
    
    func readFileAudio2() {
        //Pickerないわ。
    }
    
    
    @IBAction func playButtonAction(sender: AnyObject) {
        // 一時停止中なら再開
        if solPlayer.audioPlayerNode != nil && !solPlayer.audioPlayerNode.isPlaying && solPlayer.pausedTime > 0 {
            solPlayer.audioPlayerNode.play()
            startPlaybackTimer()
            return
        }

        // とりあえず最後に読み込んだ曲を再生（2021/10/31）
        solPlayer.song = solPlayer.playlist.last
        if solPlayer.song.assetURL != nil {
            do {
                try solPlayer.readAudioFile(_song: solPlayer.song)
                solPlayer.startPlayer()
                // 曲情報をセット
                setScreen(values: true)
                // タイマー開始
                startPlaybackTimer()
            } catch {
                //TODO:再生失敗時の処理
            }
        }
    }

    @IBAction func stopButtonAction(sender: AnyObject) {
        solPlayer.pause()
        stopPlaybackTimer()
    }
    
    @IBAction func readFileButtonAction(sender: AnyObject) {
        //print("readFile")
        //url = readFileAudio()
        readFileAudio()
    }
    
    @IBAction func hzSliderAction(sender: AnyObject) {
//        print("hzSlider")
        hzLabel.intValue = hzSlider.intValue
        solPlayer.pitchChange(hzVal: hzSlider.intValue)
    }
    
    @IBAction func toSpecificHzButtonAction(sender: NSButton) {
//        print(sender.tag)
        let specificHz = Int32(sender.tag)
        hzLabel.intValue = specificHz
        hzSlider.intValue = specificHz
        solPlayer.pitchChange(hzVal: specificHz)
        
    }
    
    @IBAction func speedSliderAction(sender: AnyObject) {
//        print("speedSlider")
        speedLabel.floatValue = speedSlider.floatValue
        solPlayer.speedChange(speedSliderValue: speedSlider.floatValue)
    }
    
    @IBAction func speedChangeButtonAction(sender: AnyObject) {
//        print(sender.tag)
        let speed:Float = Float(sender.tag)
        speedLabel.floatValue = speed
        speedSlider.floatValue = speed
        solPlayer.speedChange(speedSliderValue: speed)
    }
    
    @IBAction func reverbSliderAction(sender: AnyObject) {
//        print("reverbSlider")
        reverbLabel.floatValue = reverbSlider.floatValue
        solPlayer.reverbChange(val: reverbSlider.floatValue)
    }
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    @IBAction func volumeSliderAction(sender: AnyObject) {
        volumeLabel.intValue = volumeSlider.intValue
        solPlayer.volumeChange(volumeSliderValue: volumeSlider.floatValue / 50.0)
    }
    
    /** tableView */
    func numberOfRows(in tableView: NSTableView) -> Int {
        return solPlayer.playlist.count
    }
    
    /** tableView */
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {

//        print("tableview")
        
        let song = solPlayer.playlist[row]
        let title = song.title
        let duration = song.durationString()
        let columnName = tableColumn?.identifier
        let columnNameString:String = (columnName!.rawValue + "") as String
        
        if columnNameString == "Title" {
            return title as AnyObject
        } else if columnNameString == "Duration" {
            return duration as AnyObject
        }
        return "" as AnyObject
    }
    
    /** tableViewをクリックしたときの処理 */
    func tableViewSelectionDidChange(_ notification: Notification) {
        let row = songTableView.selectedRow
        guard row >= 0 && row < solPlayer.playlist.count else { return }

        let song = solPlayer.playlist[row]
        guard song.assetURL != nil else { return }

        // 曲番号を更新
        solPlayer.number = row

        do {
            solPlayer.stop()
            stopPlaybackTimer()
            try solPlayer.readAudioFile(_song: song)
            solPlayer.startPlayer()
            setScreen(values: true)
            startPlaybackTimer()
        } catch {
            setScreen(values: false)
        }
    }
    
    /* TODO: plistからoutletに直接入るようにする。 */
    private func openLibrary(path: String) -> NSMutableDictionary {
        /*
        if let err = iTunes.load(path) {
            // TODO: iTunes読み込みエラー
        } else {
            // 読み込み成功
            
        }*/
        var plist:NSMutableDictionary
        do {
            plist = try iTunes.load(libraryXmlPath: path)
        }
        //solPlayer.playlist.append(Element)
        return plist
        
    }

    /**
      各値を画面にセットする
      - parameter song: 曲情報
      - parameter reset: 画面を初期化するフラグ
      */
    func setScreen(values: Bool) {
        if values {
            //プレイヤーラベルを設定 #103
            if let song = solPlayer.song {
                titleLabel.stringValue = song.title ?? "Untitled"
                artistLabel.stringValue = song.artist ?? "Unknown Artist"
                //endTimeLabel.stringValue = GeneralUtil.formatTimeString(Float(solPlayer.duration))
                endTimeLabel.stringValue = song.durationString()
                artworkImage.image = song.artwork
            }
            
            //スライダーを操作可能に #72
            //timeSlider.isEnabled = true
            timeSlider.isHidden = false
            //timeSlider.maximumValue = Float(solPlayer.duration)
            timeSlider.maxValue = solPlayer.duration
            
            //プレイリスト情報を更新
            //playlistLabel.text = solPlayer.subPlaylist.name
            playlistLabel.stringValue = solPlayer.mainPlaylist.name
                        
        } else {

            //画面表示を初期化
            titleLabel.stringValue = "Untitled"
            artistLabel.stringValue = "Unknown Artist"
            nowTimeLabel.stringValue = "00:00:00"
            endTimeLabel.stringValue = "-99:99:99"
            //artworkImage.image = GeneralUtil.makeBoxWithColor(UIColor.init(colorLiteralRed: 0.67, green: 0.67, blue: 0.67, alpha: 1.0), width: 40.0, height: 40.0)
            //playButton.setTitle("PLAY", forState: .Normal)

            //timeSliderを0に固定していじらせない #72
            timeSlider.intValue = 0
            //timeSlider.isEnabled = false
            timeSlider.isHidden = true

            //プレイリスト情報を更新
            playlistLabel.stringValue = solPlayer.mainPlaylist.name

        }

        //再生・一時再生ボタンをセット
        setPlayLabel(playing: solPlayer.audioPlayerNode.isPlaying)

    }

    /**
     再生ボタン/一時停止ボタンをセット
     
     - parameter: true（再生）、false（一時停止）
     - returns: なし
     */
    func setPlayLabel(playing: Bool){
        if playing {
            //playButton.setImage(UIImage(named: "pause64.png"), for: UIControlState())
//            print("一次停止ボタンに")
        } else {
            //playButton.setImage(UIImage(named: "play64.png"), for: UIControlState())
//            print("再生ボタンに")
        }
    }

    // MARK: - Playback Timer

    /// 再生時間更新タイマーを開始
    private func startPlaybackTimer() {
        stopPlaybackTimer()
        playbackTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.updatePlaybackTime()
        }
    }

    /// 再生時間更新タイマーを停止
    private func stopPlaybackTimer() {
        playbackTimer?.invalidate()
        playbackTimer = nil
    }

    /// 再生時間を更新（タイマーから呼ばれる）
    @objc private func updatePlaybackTime() {
        guard solPlayer.audioPlayerNode != nil else {
            stopPlaybackTimer()
            return
        }

        let currentTime = solPlayer.currentPlayTime()
        let duration = solPlayer.duration ?? 0

        // 曲が終了したかチェック（余裕を持って0.5秒前）
        if duration > 0 && Double(currentTime) >= duration - 0.5 {
            stopPlaybackTimer()
            onSongFinished()
            return
        }

        // 再生が停止している場合
        if !solPlayer.audioPlayerNode.isPlaying {
            stopPlaybackTimer()
            return
        }

        timeSlider.floatValue = currentTime
        nowTimeLabel.stringValue = formatTime(Double(currentTime))
    }

    /// 曲が終了した時の処理
    private func onSongFinished() {
        // リピートモードまたはプレイリストに次の曲がある場合
        if solPlayer.repeatAll || solPlayer.number < solPlayer.playlist.count - 1 {
            // 次の曲を再生
            nextButtonAction(self)
        } else {
            // 再生を停止してUIをリセット
            timeSlider.floatValue = 0
            nowTimeLabel.stringValue = formatTime(0)
            solPlayer.stop()
        }
    }

    /// 時間をフォーマット（秒 → MM:SS）
    private func formatTime(_ seconds: Double) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%02d:%02d", mins, secs)
    }

    // MARK: - Time Slider Action

    @IBAction func timeSliderAction(_ sender: NSSlider) {
        let seekTime = sender.floatValue
        solPlayer.timeShift(current: seekTime)
        nowTimeLabel.stringValue = formatTime(Double(seekTime))
    }

    // MARK: - Prev/Next Button Actions

    @IBAction func prevButtonAction(_ sender: AnyObject) {
        guard solPlayer.playlist.count > 1 else { return }

        // 現在の曲のインデックスを見つけて前の曲を再生
        if solPlayer.number > 0 {
            solPlayer.number = solPlayer.number - 1
        } else {
            solPlayer.number = solPlayer.playlist.count - 1  // 最後の曲に戻る
        }

        playCurrentSong()
    }

    @IBAction func nextButtonAction(_ sender: AnyObject) {
        guard solPlayer.playlist.count > 1 else { return }

        // 次の曲を再生
        if solPlayer.number < solPlayer.playlist.count - 1 {
            solPlayer.number = solPlayer.number + 1
        } else {
            solPlayer.number = 0  // 最初の曲に戻る
        }

        playCurrentSong()
    }

    /// 現在のインデックスの曲を再生
    private func playCurrentSong() {
        guard solPlayer.number >= 0 && solPlayer.number < solPlayer.playlist.count else { return }

        let song = solPlayer.playlist[solPlayer.number]
        guard song.assetURL != nil else { return }

        do {
            solPlayer.stop()
            try solPlayer.readAudioFile(_song: song)
            solPlayer.startPlayer()
            setScreen(values: true)
            startPlaybackTimer()
        } catch {
            // 再生失敗
        }
    }

    /* 検索 */
    @IBAction func searchAlbumAction(_ sender: AnyObject) {
        // 空検索の場合は何もしない
        if (searchAlbum.stringValue.isEmpty) {
            return
        }
        trackIds = iTunes.searchAlbum(title: searchAlbum.stringValue)
        //print(searchAlbum.stringValue)
        //print(trackIds)
        for trackId in trackIds {
            solPlayer.playlist.append(Song(title:iTunes.songTitle(id: trackId), assetURL:iTunes.songAssetURL(id: trackId)))
            //print(iTunes.songAssetURL(trackId))
        }
        
        songTableView.reloadData()
    }
    
    
    
    
}

