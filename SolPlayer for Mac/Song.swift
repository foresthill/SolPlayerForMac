//
//  Song.swift
//  SolPlayer for Mac
//
//  Created by Morioka Naoya on H28/06/30.
//  Copyright © 平成28年 Morioka Naoya. All rights reserved.
//

import Foundation
//import MediaPlayer

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
        return NSString(format: "%i:%02i", Int(self.duration) / 60, Int(self.duration) % 60) as String
    }
    
}
