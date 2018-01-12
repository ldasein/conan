//
//  Checker.swift
//  Conan
//
//  Created by 黄明 on 2016/11/5.
//  Copyright © 2016年 Danis. All rights reserved.
//

import Foundation

class Checker {
    
    var inputURL: URL
    var outputURL: URL
    
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
        let files = FileManager.default.enumerator(atPath: inputURL.path)
        
        var otherFiles = [String]()
        var baseFile: String?
        while let file: AnyObject = files?.nextObject() as AnyObject? {
            if let fileName = file as? String {
//                if fileName.contains(".strings") || fileName.contains(".txt") {
//                    if fileName.contains("finder") {
//                        baseFile = fileName
//                    }else {
//                        otherFiles.append(fileName)
//                    }
//                }
                if fileName.contains(".json") {
                    if fileName.contains("finder") {
                        baseFile = fileName
                    }else {
                        otherFiles.append(fileName)
                    }
                }
            }
        }
        
        guard baseFile != nil else {
            throw CheckerError.NoBaseFile
        }
        
        let baseContent = try String(contentsOfFile: inputURL.appendingPathComponent(baseFile!).absoluteString)
        var text = ""
        
        for other in otherFiles {
            let otherContent = try String(contentsOfFile: inputURL.appendingPathComponent(other).absoluteString)
            let missedKeys = try compare(fromBase: baseContent, to: otherContent)
            
            if missedKeys.count > 0 {
                beautyPrint(text: ("\(other) has \(missedKeys.count) missed 😭😭"))
                text.append("================\(other) has \(missedKeys.count) missed 😭😭===================\n")
                text.append("{\n")
                for i in 0...(missedKeys.count - 1){
                    let key = missedKeys[i]
                    print(" \(key)")
                    text.append("\"\(key)\" : \"\(key)\"")
                    if i != missedKeys.count - 1{
                        text.append(",")
                    }
                    text.append("\n")

                }
                //                for key in missedKeys {
                //                    print(" \(key)")
                //                    text.append("\"\(key)\" : \"\"\n")
                //                }
                text.append("}\n")

            }else {
                beautyPrint(text: ("\(other) OK 🙄🙄"))
                text.append("\(other) OK 🙄🙄")
            }
        }
        try output(text: text)
        
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
    
    func compare(fromBase base: String, to destination: String) throws -> [String] {
        // "sdfsdfsdf" = "";
        let baseKeys = try findKeys(fromLocalized: base)
        let destKeys = try findKeys(fromLocalized: destination)
        
        var missedKeys = [String]()
        
        baseKeys.forEach { (key) in
            if !destKeys.contains(key) {
                missedKeys.append(key)
            }
        }
        
        return missedKeys
    }
//    func findKeys(fromLocalized localized: String) throws -> Set<String> {
//        var keys = Set<String>()
//        
//        let lines = localized.components(separatedBy: "\n")
//        for line in lines {
//            var symbols = [Int]()
//            var previewsChar: Character?
//            
//            var index = 0
//            for char in line.characters {
//                if char == "\"" {
//                    if let previewsChar = previewsChar {
//                        if previewsChar == "\\" {
//                            
//                        }else {
//                            symbols.append(index)
//                        }
//                    }else {
//                        symbols.append(index)
//                    }
//                }
//                if symbols.count == 2 {
//                    keys.insert((line as NSString).substring(with: NSMakeRange(symbols[0], symbols[1] - symbols[0] + 1)))
//                    
//                    break
//                }
//                
//                index += 1
//                previewsChar = char
//            }
//        }
//        
//        return keys
//    }
    
    func findKeys(fromLocalized localized: String) throws -> Set<String> {
        var keys = Set<String>()
        
        guard let json = try JSONSerialization.jsonObject(with: localized.data(using: .utf8)!, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: Any] else {
            return keys
        }
        for (key, _) in json {
            if !keys.contains(key) {
                keys.insert(key)
            }
        }
        
        return keys
    }
    func output(text: String) throws {
        var directoryURL = outputURL
        directoryURL.deleteLastPathComponent()
        try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        
        try text.write(to: outputURL, atomically: true, encoding: .utf8)
    }
}
