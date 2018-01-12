//
//  ToJSON.swift
//  Conan
//
//  Created by 黄明 on 2017/3/30.
//  Copyright © 2017年 Danis. All rights reserved.
//

import Foundation


class ToJSON {
    
    var inputURL: URL
    var outputURL: URL
    
    init(input: String) throws {
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
        self.outputURL = inputURL
    }
    
    func start() throws {
        let files = FileManager.default.enumerator(atPath: inputURL.path)
        
        while let file = files?.nextObject() as AnyObject? {
            if let fileName = file as? String {
                if fileName.contains(".strings") {
                    let content = try String(contentsOfFile: inputURL.appendingPathComponent(fileName).absoluteString)
                    let json = try toJSON(from: content)
                    let jsonName = fileName.components(separatedBy: ".").first!.appending(".json")
//                    try json.write(to: outputURL.appendingPathComponent(jsonName), atomically: true, encoding: .utf8)
                    try json.write(toFile: outputURL.appendingPathComponent(jsonName).path, atomically: true, encoding: .utf8)
                }
            }
        }
    }
    
    func toJSON(from strings: String) throws -> String {
        var jsonDict = [String: String]()
        
        let lines = strings.components(separatedBy: "\n")
        for line in lines {
            var positions = [Int]()
            
            var previousChar: Character?
            var index = 0
            for char in line.characters {
                if char == "\"" {
                    if previousChar != "\\" {
                        positions.append(index)
                    }
                }
                
                if positions.count == 4 {
                    let key = (line as NSString).substring(with: NSMakeRange(positions[0] + 1, positions[1] - positions[0] - 1))
                    let value = (line as NSString).substring(with: NSMakeRange(positions[2] + 1, positions[3] - positions[2] - 1))
                    
                    jsonDict[key] = value
                }
                
                
                index += 1
                previousChar = char
            }
        }
        
        var jsonString = "{\n"
        for (key, value) in jsonDict {
            jsonString.append("\n\"\(key)\" : \"\(value)\",")
        }
        jsonString.removeLast()
        jsonString.append("\n}")
        
        return jsonString
    }
}
