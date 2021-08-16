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

class ViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {

    @IBOutlet weak var titleLabel: NSTextField!
    @IBOutlet weak var artistLabel: NSTextField!
    
    @IBOutlet weak var playlistLabel: NSTextField!
    @IBOutlet weak var artworkImage: NSImageView!
    
    @IBOutlet weak var timeSlider: NSSlider!
    @IBOutlet weak var nowTimeLabel: NSTextField!
    @IBOutlet weak var endTimeLabel: NSTextField!
    
    @IBOutlet weak var hzSlider: NSSlider!
    @IBOutlet weak var hzLabel: NSTextField!
    
    @IBOutlet weak var volumeLabel: NSTextField!
    @IBOutlet weak var speedSlider: NSSlider!
    @IBOutlet weak var speedLabel: NSTextField!
    @IBOutlet weak var volumeSlider: NSSlider!
    
    @IBOutlet weak var reverbSlider: NSSlider!
    @IBOutlet weak var reverbLabel: NSTextField!
    @IBOutlet weak var to432Button: NSButton!
    @IBOutlet weak var to444Button: NSButton!
    
    @IBOutlet weak var playlistSchrollView: NSScrollView!
    
    @IBOutlet weak var songTableView: NSTableView!

    @IBOutlet weak var playlistHeaderView: NSTableHeaderView!

    // アルバム検索用テキストフィールド
    @IBOutlet weak var searchAlbum: NSSearchField!
    
    @IBOutlet weak var playlist2column: NSTableColumn!

    @IBOutlet weak var playlist2column2: NSTableColumn!
    
    @IBOutlet weak var playlistOutlineView: NSOutlineView!
    
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
        
        /*
        if let url:NSURL = readFileAudio() {
            do {
                try solPlayer.readAudioFile(url)
                solPlayer.startPlayer()
            } catch {
                
            }
        }
        */
        
        // 最初なぜかリバーブが0にならないので強引に
        solPlayer.reverbChange(val: 0.0)

        //
        openLibrary(path: ITunesLibrary.XmlFilePath())
        
        // Do any additional setup after loading the view.
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
            if result is NSFileHandlingPanelOKButton {  //ファイルを選択したか（OKを押したか）
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
                //print(self.solPlayer.playlist)
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
        if url != nil {
            do {
                //print("play")
                //try solPlayer.readAudioFile(url)
                try solPlayer.readAudioFile(_song: solPlayer.song)
                //print("read")
                solPlayer.startPlayer()
                //print("start")
                //print(solPlayer.audioPlayerNode.volume)
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
    
    @IBAction func to432HzButtonAction(sender: AnyObject) {
        print("to432Hz")
        hzLabel.intValue = 432
        hzSlider.intValue = 432
        solPlayer.pitchChange(hzVal: 432)
    }
    
    /** 
     * button.tagでひとまとめにしたほうが良い
     */
    @IBAction func to444HzButtonAction(sender: AnyObject) {
        print("to444Hz")
        hzLabel.intValue = 444
        hzSlider.intValue = 444
        solPlayer.pitchChange(hzVal: 444)
    }
    
    @IBAction func hzSliderAction(sender: AnyObject) {
        print("hzSlider")
        hzLabel.intValue = hzSlider.intValue
        solPlayer.pitchChange(hzVal: hzSlider.intValue)
    }
    
    @IBAction func toSpecificHzButtonAction(sender: NSButton) {
        print(sender.tag)
        let specificHz = Int32(sender.tag)
        hzLabel.intValue = specificHz
        hzSlider.intValue = specificHz
        solPlayer.pitchChange(hzVal: specificHz)
        
    }
    


    @IBAction func speedSliderAction(sender: AnyObject) {
        print("speedSlider")
        speedLabel.floatValue = speedSlider.floatValue
        solPlayer.speedChange(speedSliderValue: speedSlider.floatValue)
    }
    
    @IBAction func speedChangeButtonAction(sender: AnyObject) {
        print(sender.tag)
        speedLabel.floatValue = 1.0
        speedSlider.floatValue = 1.0
        solPlayer.speedChange(speedSliderValue: 1.0)
    }
    
    @IBAction func reverbSliderAction(sender: AnyObject) {
        print("reverbSlider")
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
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return solPlayer.playlist.count
    }
    
    /** tableView */
    func tableView(songTableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        
        //print("tableview")
        
        let song = solPlayer.playlist[row]
        let title = song.title
        let duration = song.durationString()
        let columnName = tableColumn?.identifier
        
        if columnName == "Title" {
            return title as AnyObject
        } else if columnName == "Duration" {
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
        setPlayLabel(playing: solPlayer.audioPlayerNode.playing)

    }

    /**
     再生ボタン/一時停止ボタンをセット
     
     - parameter: true（再生）、false（一時停止）
     - returns: なし
     */
    func setPlayLabel(playing: Bool){
        if playing {
            //playButton.setImage(UIImage(named: "pause64.png"), for: UIControlState())
            print("一次停止ボタンに")
        } else {
            //playButton.setImage(UIImage(named: "play64.png"), for: UIControlState())
            print("再生ボタンに")
        }
    }
    
    
    /* 検索 */
    @IBAction func searchAlbumAction(sender: AnyObject) {
        // 空検索の場合は何もしない
        if (searchAlbum.stringValue.isEmpty) {
            return
        }
        trackIds = iTunes.searchAlbum(title: searchAlbum.stringValue)
        //print(searchAlbum.stringValue)
        //print(trackIds)
        for trackId in trackIds {
            solPlayer.playlist.append(Song(title:iTunes.songTitle(id: trackId), assetURL:iTunes.songAssetURL(trackId)))
            //print(iTunes.songAssetURL(trackId))
        }
        
        songTableView.reloadData()
    }
    
    
    
    
}

