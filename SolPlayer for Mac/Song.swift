//
//  Song.swift
//  SolPlayer for Mac
//
//  Created by Morioka Naoya on H28/06/30.
//  Copyright © 平成28年 Morioka Naoya. All rights reserved.
//

//import Foundation
import Cocoa
//import MediaPlayer
import AVFoundation

class Song {
    
    /*あれ？独自クラス作らんでもMPMediaItemそのまま使えばよくね？？→cocoaではMPMediaItemがない。*/
    
    /** 曲名 */
    var title: String?
    /** アセットURL */
    var assetURL: NSURL?
    /** アーティスト */
    var artist: String?
    /** アルバムアーティスト */
    var albumArtist: String?
    /** アルバム名 */
    var albumTitle: String?
    /** アートワーク */
    //var artwork: UIImage?
    //var artwork: MPMediaItemArtwork?
    //var artwork: CGImage?
    var artwork: NSImage?
    /** 発売日 */
    var releaseDate: String?
    /** レート */
    var rating: String?
    /** ディスク番号 */
    var discNumber: String?
    /** メディアの種類 */
    var mediaType: String?
    /** 曲の長さ */
    var duration: NSTimeInterval = 0
    //var totalTime
    
    init(){
        
    }
    
    //ファイル読み込みから作成
    init(title: String, assetURL: NSURL){
        self.title = title
        self.assetURL = assetURL
        
        //メタ情報読み込み
        self.loadMetaDataFromAudioFile(assetURL)
    }
    
    //メタ情報読み込み
    //https://github.com/asmz/SwiftAudioPlayerSample/blob/master/SwiftAudioPlayerSample/SwiftPlayerManager.swift
    //func loadMetaDataFromAudioFile(url: NSURL) {
        //let asset: AVAsset = AVURLAsset(URL: url)
    //func loadMetaDataFromAudioFile(asset: AVAsset) {
    func loadMetaDataFromAudioFile(url: NSURL) {
        let asset: AVAsset = AVURLAsset(URL: url)
        let metadata: Array = asset.commonMetadata
        
        print(metadata)
        
        for item in metadata {
            switch item.commonKey! as String {
            case AVMetadataCommonKeyTitle:
                //タイトル取得
                self.title = item.stringValue!
            case AVMetadataCommonKeyAlbumName:
                //アルバム名取得
                self.albumTitle = item.stringValue!
            case AVMetadataCommonKeyArtist:
                //アーティスト名取得
                self.artist = item.stringValue!
            //case AVMetadatatime
                //時間は分からない
            /*
            case AVMetadataCommonKeyArtwork:
                //アートワーク取得
                if let artworkData = item.value as? NSDictionary {
                    //iOS7まではNSDirectory型が返却される
                    //artwork = UIImage(data:artworkData["data"] as! NSData)
                    print(artworkData)
                } else {
                    //iOS8からはNSData型が返却される
                    //artwork = UIImage(data:item.dataValue!)
                    print(item.dataValue)
                    
                }*/
            case AVMetadataCommonKeyArtwork:
                //アートワーク取得
                if let artworkData = item.value as? NSDictionary {
                    //iOS7まではNSDirectory型が返却される
                    //artwork = UIImage(data:artworkData["data"] as! NSData)
                    artwork = NSImage(data:artworkData["data"] as! NSData)
                    //print(artworkData)
                } else {
                    //iOS8からはNSData型が返却される
                    //artwork = UIImage(data:item.dataValue!)
                    artwork = NSImage(data:item.dataValue!)
                    //print(item.dataValue)
                    
                }
            default:
                break
            }
        }
        
        //再生時間を取得
        do {
            let audioFile: AVAudioFile = try AVAudioFile(forReading: url)
            //サンプルレートの取得
            let sampleRate = audioFile.fileFormat.sampleRate
            //総時間を取得
            self.duration = Double(audioFile.length) / sampleRate
        } catch {

        }
        
        
    }

    
    /*
    init(mediaItem: MPMediaItem){
        self.title = mediaItem.title
        //self.assetURL = mediaItem.assetURL
        self.assetURL = mediaItem.valueForProperty(MPMediaItemPropertyAssetURL) as? NSURL
        self.artist = mediaItem.artist
        self.albumArtist = mediaItem.albumArtist
        self.albumTitle = mediaItem.albumTitle
        //self.artwork = mediaItem.artwork?.imageWithSize(CGSize.init(width: 150, height: 150))
        self.artwork = mediaItem.artwork
        //self.releaseDate = mediaItem.releaseDate
        //self.totalTime = mediaItem.?
        //MPMediaItem.en
    }
     */
    func durationString() -> String {
        if let durationValue:NSTimeInterval = self.duration {
            return NSString(format: "%i:%02i", Int(durationValue) / 60, Int(durationValue) % 60) as String
        } else {
            return "00:00:00"
        }
    }
    
}
