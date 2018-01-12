//
//  Finder.swift
//  Conan
//
//  Created by 黄明 on 2016/11/5.
//  Copyright © 2016年 Danis. All rights reserved.
//

import Foundation

class Finder {
    
    private var inputURL: URL
    private var outputURL: URL
    
    /// 创建搜索Localized对象
    ///
    /// - Parameters:
    ///   - path: 导入路径，文件或路径
    ///   - output: 导出文件路径
    init(input: String, output: String) throws {
        var isDir: ObjCBool = false
        guard FileManager.default.fileExists(atPath: input, isDirectory: &isDir) else {
            throw CheckerError.InvalidInputPath
        }
        guard isDir.boolValue else {
            throw CheckerError.InvalidInputPath
        }
        guard let inputURL = URL(string: input) else {
            throw CheckerError.InvalidInputPath
        }
        self.inputURL = inputURL
        outputURL = URL(fileURLWithPath: output)
    }
    
    func start() throws {
        var preferedCount = 0
        var realCount = 0
        var text = "{"
        var findedKeys = [String]()
        
        let files = FileManager.default.enumerator(atPath: inputURL.path)
        while let file: AnyObject = files?.nextObject() as AnyObject? {
            if let fileName = file as? String {
                if (fileName.hasSuffix(".m") || fileName.hasSuffix(".mm") || fileName.hasSuffix(".swift")) && !fileName.contains("String+Localized.swift"){
                    let codes = try String(contentsOfFile: inputURL.appendingPathComponent(fileName).absoluteString)
                    let localizeds = try find(inCodes: codes)
                    let count = try counts(inCodes: codes)
                    
                    preferedCount += count
                    realCount += localizeds.count
                    
                    if count != localizeds.count {
                        print("Some Errors At \(fileName) - \(count) - \(localizeds.count)")
                    }
                    
//                    if localizeds.count > 0 {
//                        if let last = fileName.components(separatedBy: "/").last {
//                            text += "\n\n// \(last)"
//                        }
//                    }
                    for line in localizeds {
                        if !findedKeys.contains(line) {
                            text += "\n\(line) : \(line),"
                            findedKeys.append(line)
                        }
                    }
                }
            }
        }
        text.removeLast()
        text.append("\n}")
        
        if preferedCount == realCount {
            print("find Succeed ✅")
        }else {
            print("prefered --- \(preferedCount)")
            print("real ------- \(realCount)")
        }
        
        do {
            try output(text: text)
        } catch {
            print(error)
        }
    }
    func counts(inCodes codes: String) throws -> Int {
        let regex = try NSRegularExpression(pattern: "ARVLocalizedString\\(|\\.localized\\b", options: .allowCommentsAndWhitespace)
        let matches = regex.matches(in: codes, options: [], range: NSMakeRange(0, (codes as NSString).length ))
        
        return matches.count
    }
    func find(inCodes codes: String) throws -> [String] {
        var localizedStrings = [String]()
        let regex = try NSRegularExpression(pattern: "(((?<=ARVLocalizedString\\(@)|(?<=ARVLocalizedString\\())\"((?!ARVLocalizedString).)*\"\\s*(?=,))|\"(((.*\\\\\".*)*)|[^\"]*)\"(?=.localized)", options: .allowCommentsAndWhitespace)
        let matches = regex.matches(in: codes, options: [], range: NSMakeRange(0, (codes as NSString).length ))
        for result in matches {
            let localized = (codes as NSString).substring(with: result.range)
            
            localizedStrings.append(localized)
        }
        
        return localizedStrings
    }
    func output(text: String) throws {
        var directoryURL = outputURL
        directoryURL.deleteLastPathComponent()
        try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        
        try text.write(to: outputURL, atomically: true, encoding: .utf8)
    }
}
