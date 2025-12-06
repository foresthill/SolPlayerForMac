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
        let sliderWidth: CGFloat = 120

        // MARK: Song Info Area (Top Left)
        if let titleLabel = titleLabel, let artistLabel = artistLabel {
            NSLayoutConstraint.activate([
                titleLabel.topAnchor.constraint(equalTo: mainView.topAnchor, constant: padding),
                titleLabel.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: padding),
                titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: mainView.centerXAnchor, constant: -padding),

                artistLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
                artistLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
                artistLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            ])
        }

        // MARK: Artwork & Playlist Label (Top Right)
        if let artworkImage = artworkImage, let playlistLabel = playlistLabel {
            NSLayoutConstraint.activate([
                artworkImage.topAnchor.constraint(equalTo: mainView.topAnchor, constant: padding),
                artworkImage.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -padding),
                artworkImage.widthAnchor.constraint(equalToConstant: 64),
                artworkImage.heightAnchor.constraint(equalToConstant: 64),

                playlistLabel.topAnchor.constraint(equalTo: mainView.topAnchor, constant: padding),
                playlistLabel.trailingAnchor.constraint(equalTo: artworkImage.leadingAnchor, constant: -smallPadding),
            ])
        }

        // MARK: Search & Load Button (Top Center)
        if let searchAlbum = searchAlbum, let loadButton = loadButton {
            NSLayoutConstraint.activate([
                loadButton.topAnchor.constraint(equalTo: mainView.topAnchor, constant: padding),
                loadButton.centerXAnchor.constraint(equalTo: mainView.centerXAnchor),
                loadButton.heightAnchor.constraint(equalToConstant: buttonHeight),

                searchAlbum.centerYAnchor.constraint(equalTo: loadButton.centerYAnchor),
                searchAlbum.leadingAnchor.constraint(equalTo: loadButton.trailingAnchor, constant: smallPadding),
                searchAlbum.widthAnchor.constraint(equalToConstant: 150),
            ])
        }

        // MARK: Time Slider Area
        if let timeSlider = timeSlider, let nowTimeLabel = nowTimeLabel, let endTimeLabel = endTimeLabel {
            NSLayoutConstraint.activate([
                timeSlider.topAnchor.constraint(equalTo: mainView.topAnchor, constant: 90),
                timeSlider.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: padding),
                timeSlider.widthAnchor.constraint(equalToConstant: 200),
                timeSlider.heightAnchor.constraint(equalToConstant: controlHeight),

                nowTimeLabel.topAnchor.constraint(equalTo: timeSlider.bottomAnchor, constant: 4),
                nowTimeLabel.leadingAnchor.constraint(equalTo: timeSlider.leadingAnchor),

                endTimeLabel.topAnchor.constraint(equalTo: timeSlider.bottomAnchor, constant: 4),
                endTimeLabel.trailingAnchor.constraint(equalTo: timeSlider.trailingAnchor),
            ])
        }

        // MARK: Playback Controls
        if let prevButton = prevButton, let stopButton = stopButton, let playButton = playButton {
            NSLayoutConstraint.activate([
                stopButton.topAnchor.constraint(equalTo: mainView.topAnchor, constant: 130),
                stopButton.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: padding + 50),
                stopButton.heightAnchor.constraint(equalToConstant: buttonHeight),

                prevButton.centerYAnchor.constraint(equalTo: stopButton.centerYAnchor),
                prevButton.trailingAnchor.constraint(equalTo: stopButton.leadingAnchor, constant: -smallPadding),
                prevButton.heightAnchor.constraint(equalToConstant: buttonHeight),

                playButton.centerYAnchor.constraint(equalTo: stopButton.centerYAnchor),
                playButton.leadingAnchor.constraint(equalTo: stopButton.trailingAnchor, constant: smallPadding),
                playButton.heightAnchor.constraint(equalToConstant: buttonHeight),
            ])
        }

        // MARK: Hz Controls
        if let hzTitleLabel = hzTitleLabel, let hzSlider = hzSlider, let hzLabel = hzLabel {
            let hzTopAnchor = mainView.topAnchor
            let hzTop: CGFloat = 180

            NSLayoutConstraint.activate([
                hzTitleLabel.topAnchor.constraint(equalTo: hzTopAnchor, constant: hzTop),
                hzTitleLabel.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: padding),
                hzTitleLabel.widthAnchor.constraint(equalToConstant: 50),

                hzSlider.centerYAnchor.constraint(equalTo: hzTitleLabel.centerYAnchor),
                hzSlider.leadingAnchor.constraint(equalTo: hzTitleLabel.trailingAnchor, constant: smallPadding),
                hzSlider.widthAnchor.constraint(equalToConstant: sliderWidth),

                hzLabel.centerYAnchor.constraint(equalTo: hzTitleLabel.centerYAnchor),
                hzLabel.leadingAnchor.constraint(equalTo: hzSlider.trailingAnchor, constant: smallPadding),
                hzLabel.widthAnchor.constraint(equalToConstant: 40),
            ])
        }

        // MARK: Hz Preset Buttons
        if let to432Button = to432Button, let to444Button = to444Button, let to437Button = to437Button, let hzLabel = hzLabel {
            NSLayoutConstraint.activate([
                to432Button.centerYAnchor.constraint(equalTo: hzLabel.centerYAnchor),
                to432Button.leadingAnchor.constraint(equalTo: hzLabel.trailingAnchor, constant: padding),

                to444Button.centerYAnchor.constraint(equalTo: to432Button.centerYAnchor),
                to444Button.leadingAnchor.constraint(equalTo: to432Button.trailingAnchor, constant: smallPadding),

                to437Button.centerYAnchor.constraint(equalTo: to432Button.centerYAnchor),
                to437Button.leadingAnchor.constraint(equalTo: to444Button.trailingAnchor, constant: smallPadding),
            ])
        }

        // MARK: Speed Controls
        if let speedTitleLabel = speedTitleLabel, let speedSlider = speedSlider, let speedLabel = speedLabel {
            let speedTop: CGFloat = 215

            NSLayoutConstraint.activate([
                speedTitleLabel.topAnchor.constraint(equalTo: mainView.topAnchor, constant: speedTop),
                speedTitleLabel.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: padding),
                speedTitleLabel.widthAnchor.constraint(equalToConstant: 50),

                speedSlider.centerYAnchor.constraint(equalTo: speedTitleLabel.centerYAnchor),
                speedSlider.leadingAnchor.constraint(equalTo: speedTitleLabel.trailingAnchor, constant: smallPadding),
                speedSlider.widthAnchor.constraint(equalToConstant: sliderWidth),

                speedLabel.centerYAnchor.constraint(equalTo: speedTitleLabel.centerYAnchor),
                speedLabel.leadingAnchor.constraint(equalTo: speedSlider.trailingAnchor, constant: smallPadding),
                speedLabel.widthAnchor.constraint(equalToConstant: 40),
            ])
        }

        // MARK: Speed Preset Buttons
        if let speed1xButton = speed1xButton, let speed2xButton = speed2xButton,
           let speed4xButton = speed4xButton, let speed8xButton = speed8xButton,
           let speedLabel = speedLabel {
            NSLayoutConstraint.activate([
                speed1xButton.centerYAnchor.constraint(equalTo: speedLabel.centerYAnchor),
                speed1xButton.leadingAnchor.constraint(equalTo: speedLabel.trailingAnchor, constant: padding),

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
            let reverbTop: CGFloat = 250

            NSLayoutConstraint.activate([
                reverbTitleLabel.topAnchor.constraint(equalTo: mainView.topAnchor, constant: reverbTop),
                reverbTitleLabel.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: padding),
                reverbTitleLabel.widthAnchor.constraint(equalToConstant: 50),

                reverbSlider.centerYAnchor.constraint(equalTo: reverbTitleLabel.centerYAnchor),
                reverbSlider.leadingAnchor.constraint(equalTo: reverbTitleLabel.trailingAnchor, constant: smallPadding),
                reverbSlider.widthAnchor.constraint(equalToConstant: sliderWidth),

                reverbLabel.centerYAnchor.constraint(equalTo: reverbTitleLabel.centerYAnchor),
                reverbLabel.leadingAnchor.constraint(equalTo: reverbSlider.trailingAnchor, constant: smallPadding),
                reverbLabel.widthAnchor.constraint(equalToConstant: 40),
            ])
        }

        // MARK: Volume Slider (Vertical)
        if let volumeSlider = volumeSlider, let volumeLabel = volumeLabel {
            NSLayoutConstraint.activate([
                volumeSlider.topAnchor.constraint(equalTo: mainView.topAnchor, constant: 180),
                volumeSlider.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -padding - 80),
                volumeSlider.widthAnchor.constraint(equalToConstant: 24),
                volumeSlider.heightAnchor.constraint(equalToConstant: 100),

                volumeLabel.topAnchor.constraint(equalTo: volumeSlider.bottomAnchor, constant: 4),
                volumeLabel.centerXAnchor.constraint(equalTo: volumeSlider.centerXAnchor),
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
        artworkImage?.layer?.borderColor = NSColor.gridColor.cgColor

        // MARK: Table/Outline View Style
        setupTableViewStyles()
    }

    private func setupTableViewStyles() {
        // Song Table View
        songTableView?.backgroundColor = NSColor.controlBackgroundColor
        songTableView?.gridColor = NSColor.gridColor
        songTableView?.usesAlternatingRowBackgroundColors = true

        // Playlist Outline View
        playlistOutlineView?.backgroundColor = NSColor.controlBackgroundColor
        playlistOutlineView?.usesAlternatingRowBackgroundColors = true

        // Scroll View Borders
        playlistSchrollView?.wantsLayer = true
        playlistSchrollView?.layer?.cornerRadius = 6
        playlistSchrollView?.layer?.borderWidth = 1
        playlistSchrollView?.layer?.borderColor = NSColor.gridColor.cgColor

        outlineScrollView?.wantsLayer = true
        outlineScrollView?.layer?.cornerRadius = 6
        outlineScrollView?.layer?.borderWidth = 1
        outlineScrollView?.layer?.borderColor = NSColor.gridColor.cgColor
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
        // とりあえず最後に読み込んだ曲を再生（2021/10/31）
        solPlayer.song = solPlayer.playlist.last
//        if url != nil {
//        dump(solPlayer.song)
        if solPlayer.song.assetURL != nil {
            do {
                //print("play")
//                try solPlayer.readAudioFile(_url: url)
                try solPlayer.readAudioFile(_song: solPlayer.song)
                //print("read")
                solPlayer.startPlayer()
                //print("start")
                //print(solPlayer.audioPlayerNode.volume)
                // 曲情報をセット
                setScreen(values: true)
            } catch {
                //TODO:再生失敗時の処理
            }
        }
    }
    
    @IBAction func stopButtonAction(sender: AnyObject) {
        //print("stop")
        solPlayer.pause()
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
    func tableViewSelectionDidChange(notification: NSNotification) {
        let row = songTableView.selectedRow
        if row >= 0 {
            if let selected = solPlayer.playlist[row].title {
                //print("Selected: \(selected)")    //2018/05/10
            }
            //再生処理
            //if let playUrl = solPlayer.playlist[row].assetURL {
            let song:Song = solPlayer.playlist[row]
            if song != nil {
                    do {
                    solPlayer.stop()
                    //読み込み
                    //try solPlayer.readAudioFile(playUrl)
                        try solPlayer.readAudioFile(_song: song)
                    //print("read")
                    solPlayer.startPlayer()
                    //再生時間を設定する
                    //endTimeLabel = solPlayer.playlist[row].durationString()   //Segmentationエラーになる
                    //再生情報を更新
                        setScreen(values: true)
                } catch {
                    //print("再生できませんでした。")  //2018/05/10
                    //再生情報を更新
                    setScreen(values: false)
                }
            }
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

