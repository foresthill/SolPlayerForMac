//
//  ITunesLibrary.swift
//  SolPlayer for Mac
//
//  Created by Morioka Naoya on H30/05/05.
//  Inspired by Yuumi Yoshida on 2014/08/15.
//  https://github.com/yuumi3/iTunesTitleRepairer/blob/master/iTunesTitleRepairer/ITunesLibrary.swift
//
//  Copyright © 平成30年 Morioka Naoya. All rights reserved.
//

import Foundation

struct MpegFileTitle: CustomStringConvertible {
    let path: String
    let title: String
    var description: String { get {return "path: \(self.path) title: \(self.title)"} } // Not work as "Swift Standard Library"
}

typealias TrackId = Int

class ITunesLibrary: NSObject {
    class var LibraryXmlFileName: String { get { return "iTunes Music Library.xml" } }
    class var MpegTitleFileName: String { get { return "MpegTitleList.txt" } }
    
    var libraryDict: NSMutableDictionary = [:]
    var mpegTitleList: [MpegFileTitle] = []
    
    class func XmlFilePath() -> String {
        return NSHomeDirectory() + "/Music/iTunes/iTunes Music Library.xml"
    }
    
    /*func load(libraryXmlPath: String) -> NSError? {*/
    /* func load(libraryXmlPath: String) { */
    func load(libraryXmlPath: String) -> NSMutableDictionary {
        /*var error:NSError = NSError()*/
        
        //let data = NSData.dataWithContentsOfFile(libraryXmlPath, options:nil, error: &error)
        let data = NSData(contentsOf: NSURL(fileURLWithPath: libraryXmlPath) as URL)
        var plist = NSMutableDictionary()
        if data != nil {
            do {
                plist = try PropertyListSerialization.propertyList(from: data! as Data, options: PropertyListSerialization.ReadOptions(rawValue: UInt(2)), format: nil) as! NSMutableDictionary as NSMutableDictionary
            } catch {
                //throw error
            }
            libraryDict = plist
            mpegTitleList = []
        }
        //print(data)
        //print(plist)
        /*
        return nil
         */
        return plist
    }
    
/*    func save(saveFolderPath: String) -> NSError? {*/
    func saveLibrary(saveFolderPath: String) {
        //var error: NSError?
        /*var error: NSError = NSError()*/
        
        var data = NSData()
        do {
            data = try PropertyListSerialization.data(fromPropertyList: libraryDict, format: PropertyListSerialization.PropertyListFormat.xml, options: 0) as NSData
            try data.write(toFile: ITunesLibrary.LibraryXmlFileName, options: NSData.WritingOptions.atomicWrite)

            var mpegTitlesFile = ""
            //try mpegTitlesFile.writeToFile(saveFolderPath.stringByAppendingPathComponent(ITunesLibrary.MpegTitleFileName), atomically: true, encoding: NSUTF8StringEncoding)
            try mpegTitlesFile.write(toFile: saveFolderPath, atomically: true, encoding: String.Encoding.utf8)
            
        } catch {
            //
        }
        /*
        if data == nil {
            return error
        }*/
        
        //var mpegTitlesFile = "\n".join(mpegTitleList.map({"\($0.path)\t\($0.title)"})) + "\n"
        //var mpegTitlesFile = "\n".append(mpegTitleList.map({"\($0.path)\t\($0.title)"})) + "\n"
        //var mpegTitlesFile = mpegTitleList.enumerate().forEach({ print("\($0.path)\t\($0.title)")})
        /*
        if !mpegTitlesFile.writeToFile(saveFolderPath.stringByAppendingPathComponent(ITunesLibrary.MpegTitleFileName), atomically: true, encoding: NSUTF8StringEncoding, error: &error) {
            return error
        }
        */
        
        
        /*return nil*/
        
    }
    
    func searchAlbum(title: String) -> [TrackId] {
        var trackIds : Array<TrackId> = []

        // libraryDictが空または"Tracks"がない場合は空配列を返す
        guard let tracks = libraryDict["Tracks"] as? NSDictionary else {
            print("Warning: No Tracks found in iTunes library")
            return trackIds
        }

        for (key, dict) in tracks {
            guard let dictTemp = dict as? NSDictionary else { continue }
            if let albumName = dictTemp["Album"] as? NSString {
                if albumName.localizedCaseInsensitiveContains(title) {
                    if let keyString = key as? String, let trackId = Int(keyString) {
                        trackIds.append(trackId)
                    }
                }
            }
        }
        trackIds.sort { $0 < $1 }

        return trackIds
    }
    
    /* 曲名取得 */
    func songTitle(id: TrackId) -> String {
        guard let tracks = libraryDict["Tracks"] as? NSDictionary,
              let track = tracks[String(id)] as? NSDictionary,
              let name = track["Name"] as? String else {
            return "Unknown"
        }
        return name
    }

    /* 再生時間取得（ms） */
    func songDuration(id: TrackId) -> String {
        guard let tracks = libraryDict["Tracks"] as? NSDictionary,
              let track = tracks[String(id)] as? NSDictionary,
              let duration = track["Total Time"] else {
            return "0"
        }
        return String(describing: duration)
    }

    /* アセットURL取得 */
    func songAssetURL(id: TrackId) -> NSURL? {
        guard let tracks = libraryDict["Tracks"] as? NSDictionary,
              let track = tracks[String(id)] as? NSDictionary,
              let location = track["Location"] as? String,
              let url = NSURL(string: location) else {
            return nil
        }
        return url
    }
    
    class func parse(titlesChunk: String) -> [String] {
        var titles: [String] = []
        do {
            //let regex = try NSRegularExpression.regularExpressionWithPattern("\\d+\\.\\s*(.æ?)(\\s*視聴する|\\s+\\d:\\d+.*楽曲を購入.*)?$")
            //let regex = try NSRegularExpression(coder: "\\d+\\.\\s*(.æ?)(\\s*視聴する|\\s+\\d:\\d+.*楽曲を購入.*)?$", options: [NSRegularExpressionOption.{オプション}])
            /*
            let regex = NSRegularExpression.init(coder: NSCoder("\\d+\\.\\s*(.æ?)(\\s*視聴する|\\s+\\d:\\d+.*楽曲を購入.*)?$"))
            for line in titlesChunk.componentsSeparatedByString("\n") {
                if let matches = regex.firstMatchInString(line, options: NSMatchingOptions(), range: NSMakeRange(0, line.characters.count)) {
                    titles.append((line as NSString).substringWithRange(matches.rangeAtIndex(1)))
                }
            }
 */
        } catch {
            
        }
        
        
        return titles
    }
    
    func replaceTitles(ids: [TrackId], _ titles: [String]) -> NSError? {
        if ids.count != titles.count {
            return NSError(domain: "The number of titles is not the same as the number of tracks", code: 10001, userInfo: nil)
        }
        guard let tracks = libraryDict["Tracks"] as? NSDictionary else {
            return NSError(domain: "No Tracks found in library", code: 10003, userInfo: nil)
        }

        for id in ids {
            if tracks[String(id)] == nil {
                return NSError(domain: "TrackId \(id) not found", code: 10002, userInfo: nil)
            }
        }

        for i in 0 ..< ids.count {
            guard let track = tracks[String(ids[i])] as? NSMutableDictionary,
                  let location = track["Location"] as? String,
                  let url = NSURL(string: location),
                  let path = url.path else {
                continue
            }
            track["Name"] = titles[i]
            mpegTitleList.append(MpegFileTitle(path: path, title: titles[i]))
        }

        return nil
        
    }
}
