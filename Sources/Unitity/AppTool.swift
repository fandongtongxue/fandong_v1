//
//  AppTool.swift
//  FDTX
//
//  Created by fandong on 2017/9/6.
//  Copyright © 2017年 fandong. All rights reserved.
//  通用工具类

import Foundation

private let AppToolShared = AppTool()

class AppTool {
    
    class var shared : AppTool {
        return AppToolShared
    }
}

extension AppTool {
    
    func translateDateToString(originDate:Date) -> String {
        let formatter = DateFormatter.init()
        formatter.dateFormat = "yyyy-MM-dd-HH:mm:ss"
        formatter.locale = Locale(identifier: "zh-CN")
        let dateString = formatter.string(from: originDate)
        return dateString
    }
    
    func translateStringToDate(originDate:String) ->Date {
        let formatter = DateFormatter.init()
        formatter.dateFormat = "EEE, d MMM yyyy HH:mm:ss ZZZ"
        formatter.locale = Locale(identifier: "en-US")
        let date = formatter.date(from: originDate)
        return date!
    }
}
