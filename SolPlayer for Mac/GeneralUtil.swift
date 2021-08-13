//
//  GeneralUtil
//  （旧）ImageUtil.swift
//  SolPlayer
//
//  Created by Morioka Naoya on H28/06/25.
//  Copyright © 平成28年 Morioka Naoya. All rights reserved.
//

import Foundation

class GeneralUtil {
    
    /** 四角形の画像を生成する */
    /*
    static func makeBoxWithColor(_ color: UIColor, width: CGFloat, height: CGFloat) -> UIImage {
        let rect: CGRect = CGRect(x: 0.0, y: 0.0, width: width, height: height)
        UIGraphicsBeginImageContext(rect.size)
        let context: CGContext = UIGraphicsGetCurrentContext()!
        
        context.setFillColor(color.cgColor)
        context.fill(rect)
        
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return image
        
    }
    */
    
    /** 秒をHH:mm:ss形式に直す */
    static func formatHHmmss(_ seconds: String) -> String {
        let sec = Int(seconds)
        let s = Int(sec! % 60)
        let m = Int(((sec! - s) / 60) % 60)
        
        if(sec! < 3600) {
            return String(format: "%02d:%02d", m, s)
        } else {
            let h = Int(((sec! - m - s) / 3600) % 3600)
            return String(format: "%02d:%02d:%02d", h, m, s)
        }
    }
    
    /**
     時間をhh:mm:ssにフォーマットする（ViewControllerから移動）
     
     - parameters:
     - time: 時刻
     
     - throws: なし
     
     - returns: 文字列（hh:mm:ss）
     */
    /*
    static func formatTimeString(_ time: Float) -> String {
        let s: Int = Int(time.truncatingRemainder(dividingBy: 60))
        let m: Int = Int(((time - Float(s)) / 60).truncatingRemainder(dividingBy: 60))
        if time.isLess(than: 3600.0) {
            return String(format: "%02d:%02d", m, s)
        } else {
            let h: Int = Int(((time - Float(m) - Float(s)) / 3600).truncatingRemainder(dividingBy: 3600))
            return String(format: "%02d:%02d:%02d", h, m, s)
        }
        //        return str
    }
     */
    
}
