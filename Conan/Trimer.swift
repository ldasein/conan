//
//  Trimer.swift
//  Conan
//
//  Created by 黄明 on 2017/1/17.
//  Copyright © 2017年 Danis. All rights reserved.
//

import Foundation

class Trimmer {
    
    var baseInputURL: URL
    var toTrimInputURL: URL
    
    init(input1: String, input2: String) throws {
        guard FileManager.default.fileExists(atPath: input1) else {
            throw CheckerError.InvalidInputPath
        }
        guard FileManager.default.fileExists(atPath: input2) else {
            throw CheckerError.InvalidInputPath
        }
        
        self.baseInputURL = URL(fileURLWithPath: input1)
        self.toTrimInputURL = URL(fileURLWithPath: input2)
    }
    
    func start() throws {
        let baseText = try String(contentsOf: baseInputURL)
        let toTrimText = try String(contentsOf: toTrimInputURL)
        
        let baseKeys = try findKeys(fromLocalized: baseText)
        let toTrimKeys = try findKeys(fromLocalized: toTrimText)
        
        var trimedKeys = Set<KeyLine>()
        
        for toTrim in toTrimKeys {
            for base in baseKeys {
                if toTrim.key == base.key {
                    trimedKeys.insert(toTrim)
                }
            }
        }
        
        var outputText = ""
        
        let lines = toTrimText.components(separatedBy: "\n")
        var currentLine = 0
        for line in lines {
            for trimed in trimedKeys {
                if trimed.line == currentLine {
                    outputText.append(line)
                    outputText.append("\n")
                }
            }
            
            currentLine += 1
        }
        
        try outputText.write(to: URL(fileURLWithPath: "thin.strings"), atomically: true, encoding: .utf8)
        
        beautyPrint(text: "😀😀 导出成功了哦")
    }
    
    func beautyPrint(text: String) {
        let preferedCount = 50
        var borderLine = ""
        for _ in 0..<preferedCount {
            borderLine.append("=")
        }
        
        print("\n")
        print(borderLine)
        print(text)
        print(borderLine)
    }
    func findKeys(fromLocalized localized: String) throws -> [KeyLine] {
        var keys = [KeyLine]()
        
        let lines = localized.components(separatedBy: "\n")
        var currentLine = 0
        for line in lines {
            var symbols = [Int]()
            var previewsChar: Character?
            
            var index = 0
            for char in line.characters {
                if char == "\"" {
                    if let previewsChar = previewsChar {
                        if previewsChar == "\\" {
                            
                        }else {
                            symbols.append(index)
                        }
                    }else {
                        symbols.append(index)
                    }
                }
                if symbols.count == 2 {
                    let key = (line as NSString).substring(with: NSMakeRange(symbols[0], symbols[1] - symbols[0] + 1))
                    keys.append(KeyLine(key: key, line: currentLine))
                    
                    break
                }
                
                index += 1
                previewsChar = char
            }
            
            currentLine += 1
        }
        
        return keys
    }
}

class KeyLine: Hashable {
    let key: String
    let line: Int
    var hashValue: Int {
        return key.hashValue
    }
    init(key: String, line: Int) {
        self.key = key
        self.line = line
    }
    static func == (left: KeyLine, right: KeyLine) -> Bool {
        return left.key == right.key && left.line == right.line
    }
}
