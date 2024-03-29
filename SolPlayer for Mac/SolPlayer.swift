//
//  SolPlayer.swift
//  SolPlayer for Mac
//
//  Created by Morioka Naoya on H28/06/30.
//  Copyright © 平成28年 Morioka Naoya. All rights reserved.
//

import AVKit
import AVFoundation
import CoreData
import AudioUnit        //Mac(Cocoa)
import AudioToolbox     //Mac(Cocoa)

/**
 SolffegioPlayer本体（音源再生を管理する）
 */
class SolPlayer {
    
    /**
     シングルトン
     */
    static let sharedManager = SolPlayer()
    
    //AVKit
    var audioEngine: AVAudioEngine!
    var audioPlayerNode: AVAudioPlayerNode! = AVAudioPlayerNode()
    var audioFile: AVAudioFile!
    
    //エフェクトを外出し（2016/06/03）
    var reverbEffect: AVAudioUnitReverb! = AVAudioUnitReverb()
    var timePitch: AVAudioUnitTimePitch! = AVAudioUnitTimePitch()
    
    //ソルフェジオのモード（ver1:440→444Hz、ver2:440→432Hz）
    var solMode:Int! = 1
    
    //ソルフェジオSwitchの画像
    //var solSwitchImage: UIImage!
    
    //停止時間（初期化してないと（nilだと）最初のcurrentTimePlay()で落ちる） #74
    var pausedTime: Float! = 0.0
    
    //タイマー
    var timer:Timer!
    
    //総再生時間
    var duration: Double!
    
    //音量（2017/03/05）
    var volume: Float = 1.0
    
    //サンプルレート
    var sampleRate: Double!
    
    //時間をずらした時の辻褄あわせ
    var offset = 0.0
    
    //リモートで操作された時
    var remoteOffset = 0.0
    
    //ユーザ設定値
    var config = UserDefaults.standard
    
    //再生中のプレイリスト（ViewController）
    //var playlist: [Song]! = nil
    var playlist:[Song]!
    //var playlist = [NSManagedObject]()
    
    //編集中のプレイリスト（PlaylistViewController） #64, #81
    var editPlaylist:[Song]!
    
    //再生中の曲番号
    var number: Int! = 0
    
    //プレイリストのリスト。#64
    //var allPlaylists:[(id: NSNumber, name: String)]!
    var allPlaylists:[(id: Int, name: String)]!
    
    //メイン（再生中）のプレイリスト名 #64, #81
    var mainPlaylist: (id: Int, name: String) = (0, "default")
    
    //サブ（待機中）のプレイリスト名 #64, #81
    var subPlaylist: (id: Int, name: String) = (0, "default")
    
    //停止フラグ（プレイリストの再読み込みなど）
    var stopFlg = true
    
    //appDelegate外出し
    //var appDelegate: AppDelegate! = UIApplication.sharedApplication().delegate as! AppDelegate
    
    //画面ロック時の曲情報を持つインスタンス
    //var defaultCenter: MPNowPlayingInfoCenter!
    
    //画面ロック時にも再生を続ける
    //let session: AVAudioSession = AVAudioSession.sharedInstance()
    
    //曲情報外出し
    //var song: Song!
    var song: Song!
    
    //Coder（2016/06/19Test）
    let coder = NSCoder()
    
    //全曲リピート（１曲リピートはViewControllerで）
    var repeatAll = false
    
    //エンティティの変数名
    let SONG = "Song"
    let PLAYLIST = "Playlist"
    
    /**
     初期処理（シングルトンクラスのため外部からのアクセス禁止）
     */
    private init(){
        //画面ロック時も再生のカテゴリを指定
        /*
        do {
            //try session.setCategory(AVAudioSessionCategoryPlayback)
            //try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
            //オーディオセッションを有効化
            //try session.setActive(true)
        } catch {
            
        }
        */
        
        //画面ロック時のアクションを取得する（取得できなかったため暫定的にViewControllerで行う）
        //UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
        
        //画面ロック時の曲情報を持つインスタンス
        //var defaultCenter = MPNowPlayingInfoCenter.defaultCenter()
        
        //設定値を取得する
        config = UserDefaults.standard
        
        //ソルフェジオモード
        let defaultConfig = config.object(forKey: "solMode")
        if(defaultConfig != nil){
            solMode = defaultConfig as! Int
            //solSwitchImage =
        }
        
        //プレイリストを初期化
        playlist = [Song()]
        
        //defaultのプレイリストを読み込み
        /*
        do {
            playlist = try loadPlayList(0)
        } catch {
            
        }*/
        
        //プレイリストのリストを読み込み
        /*
        do {
            //try loadAllPlayLists()
        } catch {
            
        }*/
        
    }
    
    /** "C"RUD:プレイリスト新規作成 #64 */
    //    func newPlayList(name: String) throws -> NSNumber {
    /*
    func newPlayList(name: String) throws -> Int {
        
        //let managedContext: NSManagedObjectContext = appDelegate.managedObjectContext
        
        do {
            let entity = NSEntityDescription.entityForName(PLAYLIST, inManagedObjectContext: managedContext)
            let playlistObject = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
            
            //PersistentID（曲を一意に特定するID）を代入
            //let id = songObject.objectID as NSNumber
            let id = generateID()
            playlistObject.setValue(id, forKey: "id")
            
            //プレイリストのIDを代入
            playlistObject.setValue(name, forKey: "name")
            
            //print("\(id)と\(name)でプレイリスト作ります")
            
            try managedContext.save()
            
            return id
            
        } catch {
            throw AppError.CantMakePlaylistError
        }
    }
     */
    
    /** ID生成（プレイリスト作成時に使う：NSManagedObjectIDの使い方がわかるまで）*/
    //func generateID() -> NSNumber {
    func generateID() -> Int {
        
        let now = NSDate()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmss"
        
        let string: String = formatter.string(from: now as Date)
        
        return Int(string)!
    }
    
    /** C"R"UD:プレイリストのリストを読込 #64 */
    /*
    func loadAllPlayLists() throws {
        
        //defaultを設定
        allPlaylists = [(0,"default")]
        
        do {
            let managedContext: NSManagedObjectContext = appDelegate.managedObjectContext
            let fetchRequest = NSFetchRequest(entityName:PLAYLIST)
            let fetchResults = try managedContext.executeFetchRequest(fetchRequest)
            
            if let results: Array = fetchResults {
                
                for playlistObject:AnyObject in results {
                    //persistentIDを頼りに検索
                    //                    let id: NSNumber = playlistObject.valueForKey("id") as! NSNumber
                    let id: Int = playlistObject.valueForKey("id") as! Int
                    let name: String = playlistObject.valueForKey("name") as! String
                    //読み込んだSongをプレイリストに追加
                    if(id != 0){
                        allPlaylists.append((id, name))
                    }
                }
                
            }
            
        } catch {
            throw AppError.CantLoadError
            
        }
        
    }
     */
    
    /** C"R"UD:プレイリストの曲を読込 #81 */
    /*
    func loadPlayList(playlistId: Int) throws -> Array<Song> {
        
        //プレイリストを初期化
        var retPlaylist = Array<Song>()
        
        do {
            let managedContext: NSManagedObjectContext = appDelegate.managedObjectContext
            let fetchRequest = NSFetchRequest(entityName:SONG)
            fetchRequest.predicate = NSPredicate(format: "playlist = %d", playlistId)
            let fetchResults = try managedContext.executeFetchRequest(fetchRequest)
            
            //TODO:ソート
            //let sort_descriptor: NSSortDescriptor = NSSortDescriptor(key:"trackNumber", ascending: true)
            //fetchResults.sort
            
            if let results: Array = fetchResults {
                
                for songObject:AnyObject in results {
                    //persistentIDを頼りに検索
                    let song:Song = loadSong(songObject.valueForKey("persistentID") as! NSNumber)
                    //読み込んだSongをプレイリストに追加
                    if(song.assetURL != nil){
                        retPlaylist.append(song)
                    }
                }
                
            }
            
            return retPlaylist
            
        } catch {
            throw AppError.CantLoadError
            
        }
        
    }
    */
    
    /** C"R"UD:MediaQueryで曲を読込み #81 */
    /*
    func loadSong(songId: NSNumber) -> Song {
        
        var song = Song()
        
        let property: MPMediaPropertyPredicate = MPMediaPropertyPredicate(value: songId, forProperty: SongPropertyPersistentID)
        
        let query: MPMediaQuery = MPMediaQuery()
        query.addFilterPredicate(property)
        
        let items: [Song] = query.items! as [Song]
        if(items.count > 0){
            song = items[items.count - 1]
        }
        
        return song
    }
     */
    
    /** "C"RUD:プレイリストの曲を保存（永続化処理） #81 */
    /*
    func savePlayList(playlistId: NSNumber) throws {
        
        let managedContext: NSManagedObjectContext = appDelegate.managedObjectContext
        
        do {
            //            try playlist.forEach { (song) in
            for (index, song) in editPlaylist.enumerate() {
                let entity = NSEntityDescription.entityForName(SONG, inManagedObjectContext: managedContext)
                let songObject = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
                
                //PersistentID（曲を一意に特定するID）を代入
                let songId = song.persistentID as UInt64
                songObject.setValue(NSNumber(unsignedLongLong: songId), forKey: "persistentID")
                
                //プレイリストのIDを代入
                songObject.setValue(playlistId, forKey: "playlist")
                
                //曲順を代入
                songObject.setValue(index, forKey: "trackNumber")
                
                //print("songID:\(songId) playlistID:\(playlistId) index:\(index) に保存")
                
                try managedContext.save()
            }
        } catch {
            throw AppError.CantSaveError
        }
        
    }
     */
    
    /** CRU"D":プレイリストの曲を削除（１曲削除） */
    /*
    func removeSong(persistentId: UInt64) throws {
        
        do {
            let managedContext: NSManagedObjectContext = appDelegate.managedObjectContext
            
            let fetchRequest = NSFetchRequest(entityName:SONG)
            fetchRequest.predicate = NSPredicate(format: "persistentID = %d", persistentId)
            
            let fetchResults = try managedContext.executeFetchRequest(fetchRequest)
            
            if let results: Array = fetchResults {
                
                for songObject:AnyObject in results {
                    //削除
                    managedContext.deleteObject(songObject as! NSManagedObject)
                    
                    //print("songID:\(persistentId)の\(songObject) を削除")
                }
                
            }
            
        } catch {
            throw AppError.CantRemoveError
        }
        
    }
    */
    
    /** CRU"D":プレイリストの曲を削除（全曲削除） */
    /*
    func removeAllSongs(playlistId: Int) throws {
        do {
            let managedContext: NSManagedObjectContext = appDelegate.managedObjectContext
            
            let fetchRequest = NSFetchRequest(entityName:SONG)
            fetchRequest.predicate = NSPredicate(format: "playlist = %d", playlistId)
            
            let fetchResults = try managedContext.executeFetchRequest(fetchRequest)
            
            
            if let results: Array = fetchResults {
                
                for songObject:AnyObject in results {
                    //削除
                    managedContext.deleteObject(songObject as! NSManagedObject)
                    
                    //print("\(songObject) を削除")
                }
                
            }
            
        } catch {
            throw AppError.CantRemoveError
        }
        
    }
    */
    
    /** CRU"D":プレイリスト自体を削除 */
    /*
    func removePlaylist(playlistId: Int) throws {
        
        do {
            //最初にプレイリストに入っている曲を削除
            try removeAllSongs(playlistId)
            //それからプレイリストを削除
            let managedContext: NSManagedObjectContext = appDelegate.managedObjectContext
            
            let fetchRequest = NSFetchRequest(entityName:PLAYLIST)
            fetchRequest.predicate = NSPredicate(format: "id = %d", playlistId)
            
            let fetchResults = try managedContext.executeFetchRequest(fetchRequest)
            
            
            if let results: Array = fetchResults {
                
                for songObject:AnyObject in results {
                    //削除
                    managedContext.deleteObject(songObject as! NSManagedObject)
                }
                
            }
            
        } catch {
            throw AppError.CantRemoveError
        }
    }
    */
    
    /** CR"U"D:プレイリストの曲を更新（実際はは削除→追加） */
    /*
    func updatePlayList(playlistId: Int) throws {
        
        do {
            //全曲削除
            try removeAllSongs(playlistId)
            //全曲追加
            try savePlayList(playlistId)
            
            //プレイリストも更新（2016/06/26）
            if(mainPlaylist == subPlaylist){
                playlist = editPlaylist
            }
            
        } catch AppError.CantRemoveError {
            //
        } catch AppError.CantSaveError {
            //
        }
        
    }
     */
    
    /**
     audioFileをプレイヤーに読み込む
     */
    //func readAudioFile() throws -> Song {
    //func readAudioFile() throws {
    //func readAudioFile(url: NSURL) throws {
    func readAudioFile(_song: Song) throws {
        
        //20170109
        /*
        if !playable() {
            throw AppError.NoPlayListError
        }
        
        //AVAudioFileの読み込み処理（errorが発生した場合はメソッドの外へthrowされる）
        //number = appDelegate.number
        
        //プレイリストが変更されている場合
        if(number >= playlist.count){
            number = playlist.count - 1
        }
        //let song = playlist[number]
        song = playlist[number]
         */
        
        //曲情報読み込み（2018/05/10）
        self.song = _song
        
        //audioFile = try AVAudioFile(forReading: song.assetURL!)
        //let assetURL = song.valueForProperty(SongPropertyAssetURL) as! NSURL
        //let assetURL = song.valueForProperty(SongPropertyAssetURL) as! NSURL
        //audioFile = try AVAudioFile(forReading: url)
//        audioFile = try AVAudioFile(forReading: _song.assetURL! as URL)
        audioFile = try AVAudioFile(forReading: self.song.assetURL! as URL)

        //サンプルレートの取得
        sampleRate = audioFile.fileFormat.sampleRate
        
        //再生時間
        duration = Double(audioFile.length) / sampleRate
        
        //AudioEngineを初期化
        initAudioEngine()
        
        //画面ロック時の情報を指定 #73
        /*
        let defaultCenter = MPNowPlayingInfoCenter.defaultCenter()
        
        let playbackTime:NSTimeInterval = Double(currentPlayTime())
        //print(playbackTime)
        
        //ディクショナリ型で定義
        defaultCenter.nowPlayingInfo = [
            SongPropertyTitle:(song.title ?? "No Title"),
            SongPropertyArtist:(song.artist ?? "Unknown Artist"),
            SongPropertyPlaybackDuration:duration!,
            MPNowPlayingInfoPropertyPlaybackRate:1.0,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: playbackTime
        ]
        
        if let artwork = song.artwork {
            defaultCenter.nowPlayingInfo![SongPropertyArtwork] = artwork
        }
         */
    }
    
    /**
     AudioEngineを初期化
     */
    func initAudioEngine(){
        
        //AVAudioEngineの生成
        audioEngine = AVAudioEngine()
        
        //AVPlayerNodeの生成
        audioPlayerNode = AVAudioPlayerNode()
        
        //アタッチリスト
        var attachList:Array<AVAudioNode> = [audioPlayerNode, reverbEffect, timePitch]
        
        //AVAudioEngineにアタッチ
        /*TODO:なんか綺麗にかけないのかなぁ forEachとかで。。*/
        for i in 0 ... attachList.count-1 {
            audioEngine.attach(attachList[i])
            if(i >= 1){
                audioEngine.connect(attachList[i-1], to:attachList[i], format:audioFile.processingFormat)
            }
        }
        //ミキサー出力
        audioEngine.connect(attachList.last!, to:audioEngine.mainMixerNode, format:audioFile.processingFormat)
        
        //AVAudioEngineの開始
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            
        }
        
    }
    
    
    /** 現在の再生時刻を返す */
    func currentPlayTime() -> Float {
        
        if audioPlayerNode.isPlaying {
            
            if(sampleRate == 0){
                return 0
            }
            
            //便宜上分かりやすく書いてみる
            let nodeTime = audioPlayerNode.lastRenderTime
            
            //ヘッドフォンを抜き差しした（なぜかnodeTimeがnilになる）時のエラーハンドリング #75
            if(nodeTime == nil){
                stop()
                //TODO: 抜き差しされた時の時間remoteOffsetを持っておく
                return 0
            }
            
            //便宜上分かりやすく書いてみる
            let playerTime = audioPlayerNode.playerTime(forNodeTime: nodeTime!)
            let currentTime = (Double(playerTime!.sampleTime) / sampleRate)
            
            return (Float)(currentTime + offset)
            
        } else {
            //停止時
            return pausedTime
            
        }
        
    }
    
    /**
     solPlayer再生処理
     
     - parameter:なし
     
     - throws: AppError.CantPlayError（音源ファイルの読み込みに失敗した時）
     
     - returns: なし //true（停止→再生）、false（一時停止→再生）
     
     */
    func play() throws {
        
        //初回再生時あるいは再読込時
        if stopFlg {
        //if stopFlg && let song = playlist[] {
            
            do {
                //再生するプレイリストを更新 #64,#81
                //if(mainPlaylist != subPlaylist){
                //選択されたプレイリストを読込
                //print("読みなおす")
                //playlist = try loadPlayList(self.subPlaylist.id)
                mainPlaylist = subPlaylist
                //}
                
                //音源ファイルを読み込む
                //try readAudioFile()
                
                //player起動
                startPlayer()
                
                //停止フラグをfalseに
                stopFlg = false
                
            } catch {
                //TODO:ファイルが読み込めなかった場合のエラーハンドリング
                throw AppError.CantPlayError
            }
            
        }
        
    }
    
    /**
     audioPlayerNode起動（暫定的）
     */
    func startPlayer(){
        
        //print(audioFile)
        
        //print(audioFile.valueForKey("title"))
        //print(audioFile.length)
        
        //音量設定（2017/03/05）※これ入れないと、毎回音量がリセットされる
        audioPlayerNode.volume = volume
        
        //再生
        audioPlayerNode.scheduleFile(audioFile, at: nil, completionHandler: nil)
        
        //リモート操作されるとpauseがうまく動かないため暫定対応 #74
        if(remoteOffset != 0.0){
            
            //シーク位置（AVAudioFramePosition）取得
            let restartPosition = AVAudioFramePosition(Float(sampleRate) * Float(remoteOffset))
            
            //残り時間取得(sec)
            let remainSeconds = Float(self.duration) - Float(remoteOffset)
            
            //残りフレーム数（AVAudioFrameCount）取得
            let remainFrames = AVAudioFrameCount(Float(sampleRate) * remainSeconds)
            
            if remainFrames > 100 {
                //指定の位置から再生するようスケジューリング
                audioPlayerNode.scheduleSegment(audioFile, startingFrame: restartPosition, frameCount: remainFrames, at: nil, completionHandler: nil)
            }
            
            //remoteOffsetを初期化
            remoteOffset = 0.0
        }
        
        audioPlayerNode.play()
        
    }
    
    /**
     一時停止処理
     */
    func pause(){
        
        //二度押し対策？
        if !audioPlayerNode.isPlaying {
            return
        }
        
        pausedTime = currentPlayTime()
        
        audioPlayerNode.pause()
        
    }
    
    /**
     停止処理
     */
    func stop(){
        
        if !stopFlg {
            //タイマーを初期化
            timer = nil
            
            //プレイヤーを停止
            audioPlayerNode.stop()
            
            //その他必要なパラメータを初期化
            offset = 0.0
            pausedTime = 0.0
            
            //停止フラグをtrueに
            stopFlg = true
            
        }
        
    }
    
    /**
     リバーブを設定する（現在未使用）
     */
    func reverbChange(val: Float) {
        //リバーブを準備する
        //let reverbEffect = AVAudioUnitReverb()
        reverbEffect.loadFactoryPreset(AVAudioUnitReverbPreset.largeHall2)
        reverbEffect.wetDryMix = val
        
        //return reverbEffect
        
    }
    
    /**
     ソルフェジオモードon/off（ピッチ変更）処理
     */
    //func pitchChange(solSwitch: Bool){
    func pitchChange(hzVal: Int32){
        
        //設定値を取得する
        let result = config.object(forKey: "solMode")
        if(result != nil){
            solMode = result as! Int
        }
        
        
        //print("Float(hzVal / 440)=", Float(hzVal / 440))
        print("Float(hzVal / 440)=", Float(hzVal) / 440.0)
        print("log2(Float(hzVal / 440))=", log2(Float(hzVal / 440)))
        print("Hz=", hzVal);
        print("cent=", 1200 * log2(Float(hzVal) / 440.0))
        
        timePitch.pitch = 1200 * log2(Float(hzVal) / 440.0)
        
        /*
        if(solSwitch){
            switch solMode {
            case 1:
                timePitch.pitch = 15.66738339053706   //17:440Hz→444.34Hz 16:440Hz→444.09Hz
                break
            case 2:
                timePitch.pitch = -31.76665363343202   //-32:440Hz→431.941776Hz
                break
            default:
                timePitch.pitch = 0
            }
        } else {
            timePitch.pitch = 0
        }
         */
        
    }
    
    /**
     再生スピード変更処理
     
     -parameter: speedSliderValue（画面の再生速度スライダーから）
     */
    func speedChange(speedSliderValue: Float){
        timePitch.rate = speedSliderValue
    }
    
    /**
     シークバーを動かした時の処理
     */
    func timeShift(current: Float){
        
        //プレイリストが読み込まれていない時にシークバーの処理を動作しないようにする #72
        if !playable() || audioFile == nil {
            return
        }
        
        //let current = currentPlayTime()
        //       let current = timeSlider.value
        
        //退避
        offset = Double(current)
        
        //シーク位置（AVAudioFramePosition）取得
        let restartPosition = AVAudioFramePosition(Float(sampleRate) * current)
        
        //残り時間取得(sec)
        let remainSeconds = Float(self.duration) - current
        
        //残りフレーム数（AVAudioFrameCount）取得
        let remainFrames = AVAudioFrameCount(Float(sampleRate) * remainSeconds)
        
        //pause状態でseekbarを動かした場合→動かした後もpause状態を維持する（最後につじつま合わせる）
        let playing = audioPlayerNode.isPlaying
        
        audioPlayerNode.stop()
        
        if remainFrames > 100 {
            //指定の位置から再生するようスケジューリング
            audioPlayerNode.scheduleSegment(audioFile, startingFrame: restartPosition, frameCount: remainFrames, at: nil, completionHandler: nil)
        }
        
        audioPlayerNode.play()
        
        //画面を値に合わせる
        //        didEverySecondPassed()
        
        //一度playしてからpauseしないと画面に反映されないため
        if !playing {
            pause()
        }
        
    }
    
    /**
     * 音量変更処理
     */
    func volumeChange(volumeSliderValue: Float) {
        volume = volumeSliderValue
        if (audioPlayerNode != nil) {
            audioPlayerNode.volume = volume
        }
    }
    
    /**
     プレイリストの前の曲を読みこむ
     */
    func prevSong() throws {
        
        if !playable() {
            throw AppError.NoSongError
        }
        
        while number > 0 {
            number = number - 1
            
            do {
                stop()
                try play()
                return
            } catch {
            }
        }
        
        //while文を抜けてしまった場合（プレイリストの最初まで読み込める曲がなかった場合）
        throw AppError.NoSongError
        
    }
    
    /**
     プレイリストの次の曲を読みこむ
     */
    func nextSong() throws {
        
        if !playable() {
            throw AppError.NoSongError
        }
        
        while number < playlist.count-1 {
            number = number + 1
            do {
                stop()
                try play()
                return
            } catch {
            }
        }
        
        /* 以下、while文を抜けてしまった場合 */
        
        //全曲リピートの場合、最初に戻る
        if(repeatAll){
            number = 0
            do {
                stop()
                try play()
                return
            } catch {
            }
        }
        
        //プレイリストの最後まで読み込める曲がなかった場合
        throw AppError.NoSongError
        
    }
    
    /** 再生可能かどうか判定する（シークバーや次へなどの判定用）*/
    func playable() -> Bool{
        
        //playlist = appDelegate.playlist
        
        if(playlist != nil && playlist.count > 0){
            return true
        }
        
        return false
        
    }
    
    /*
    func volumeChange(value: Float) {
        audioPlayerNode.volume = value
    }
    */
    
    /**
     ロック画面からのイベントを処理する→ViewControllerへ移動。
     */
    /*
     //override func remoteControlReceivedWithEvent(event: UIEvent?) {
     func remoteControlReceivedWithEvent(event: UIEvent?) {
     
     if event?.type == UIEventType.RemoteControl {
     switch event!.subtype {
     case UIEventSubtype.RemoteControlPlay:
     do { try play() } catch { }
     case UIEventSubtype.RemoteControlPause:
     pause()
     case UIEventSubtype.RemoteControlTogglePlayPause:
     if
     break
     case UIEventSubtype.RemoteControlStop:
     stop()
     break
     case UIEventSubtype.RemoteControlPreviousTrack:
     do { try prevSong() } catch { }
     break
     case UIEventSubtype.RemoteControlNextTrack:
     do { try nextSong() } catch { }
     break
     default:
     break
     }
     }
     }
     */
    
    
}
