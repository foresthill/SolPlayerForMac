//
//  ViewController.swift
//  SolPlayer for Mac
//
//  Created by Morioka Naoya on H28/06/30.
//  Copyright © 平成28年 Morioka Naoya. All rights reserved.
//

import Cocoa

import AVFoundation

class ViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {

    @IBOutlet weak var timeSlider: NSSlider!
    @IBOutlet weak var nowTimeLabel: NSTextField!
    @IBOutlet weak var endTimeLabel: NSTextField!
    
    @IBOutlet weak var hzSlider: NSSlider!
    @IBOutlet weak var hzLabel: NSTextField!
    
    @IBOutlet weak var speedSlider: NSSlider!
    @IBOutlet weak var speedLabel: NSTextField!
    
    @IBOutlet weak var reverbSlider: NSSlider!
    @IBOutlet weak var reverbLabel: NSTextField!
    @IBOutlet weak var to432Button: NSButton!
    @IBOutlet weak var to444Button: NSButton!
    
    @IBOutlet weak var playlistSchrollView: NSScrollView!
    
    @IBOutlet weak var songTableView: NSTableView!

    @IBOutlet weak var playlistHeaderView: NSTableHeaderView!
    
    //SolPlayerのインスタンス（シングルトン）
    var solPlayer: SolPlayer!
    
    //urlを暫定的に外出し。
    var url: NSURL!
    
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
        
        // Do any additional setup after loading the view.
    }
    
    //func readFileAudio() -> NSURL {
    func readFileAudio() {
        //ダイアログ
        //var url:NSURL = NSURL()
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
        print(kUTTypeAudio)
        openPanel.beginWithCompletionHandler{ (result) -> Void in
            if result == NSFileHandlingPanelOKButton {  //ファイルを選択したか（OKを押したか）
                self.url = openPanel.URL!
                //openPanel.filena
                //assetURL
                //print(self.url.absoluteString)
                //self.solPlayer.playlist.append(Song(title: openPanel.nameFieldLabel, assetURL: openPanel.URL!))
                self.solPlayer.playlist.append(Song(title: openPanel.nameFieldStringValue, assetURL: openPanel.URL!))
                //print(self.solPlayer.playlist)
                self.songTableView.reloadData()
                
            }
        }
        //return url
    }

    @IBAction func playButtonAction(sender: AnyObject) {
        if url != nil {
            do {
                //print("play")
                try solPlayer.readAudioFile(url)
                //print("read")
                solPlayer.startPlayer()
                //print("start")
            } catch {
                
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
        solPlayer.pitchChange(432)
    }
    
    /** 
     * button.tagでひとまとめにしたほうが良い
     */
    @IBAction func to444HzButtonAction(sender: AnyObject) {
        print("to444Hz")
        hzLabel.intValue = 444
        hzSlider.intValue = 444
        solPlayer.pitchChange(444)
    }
    
    @IBAction func hzSliderAction(sender: AnyObject) {
        print("hzSlider")
        hzLabel.intValue = hzSlider.intValue
        solPlayer.pitchChange(hzSlider.intValue)
    }

    @IBAction func speedSliderAction(sender: AnyObject) {
        print("speedSlider")
        speedLabel.floatValue = speedSlider.floatValue
        solPlayer.speedChange(speedSlider.floatValue)
    }
    
    @IBAction func speedChangeButtonAction(sender: AnyObject) {
        print(sender.tag)
        speedLabel.floatValue = 1.0
        speedSlider.floatValue = 1.0
        solPlayer.speedChange(1.0)
    }
    
    @IBAction func reverbSliderAction(sender: AnyObject) {
        print("reverbSlider")
        reverbLabel.floatValue = reverbSlider.floatValue
        solPlayer.reverbChange(reverbSlider.floatValue)
    }
    
    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    /** tableView */
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return solPlayer.playlist.count
    }
    
    /** tableView */
    func tableView(songTableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        
        print("tableview")
        
        let song = solPlayer.playlist[row]
        let title = song.title
        let duration = song.durationString()
        let columnName = tableColumn?.identifier
        
        if columnName == "Title" {
            return title
        } else if columnName == "Duration" {
            return duration
        }
        return ""
    }
    
    func tableViewSelectionDidChange(notification: NSNotification) {
        let row = songTableView.selectedRow
        if row >= 0 {
            if let selected = solPlayer.playlist[row].title {
                print("Selected: \(selected)")
            }
            //再生処理
            if let playUrl = solPlayer.playlist[row].assetURL {
                do {
                    solPlayer.stop()
                    //読み込み
                    try solPlayer.readAudioFile(playUrl)
                    //print("read")
                    solPlayer.startPlayer()
                } catch {
                    print("再生できませんでした。")
                }
            }
        }
    }

}

