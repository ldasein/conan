//
//  Filler.swift
//  Conan
//
//  Created by 黄明 on 2016/12/1.
//  Copyright © 2016年 Danis. All rights reserved.
//

import Foundation

class Filler {
    fileprivate var inputUrl: URL
    fileprivate var projectUrl: URL
    
    
    init(input: String, project: String) throws {
        var isDir: ObjCBool = false
        guard FileManager.default.fileExists(atPath: input, isDirectory: &isDir) else {
            throw FillError.InvalidInputPath
        }
        guard isDir.boolValue else {
            throw FillError.InvalidInputPath
        }
        guard let inputURL = URL(string: input) else {
            throw FillError.InvalidInputPath
        }
        var projectIsDir = false as ObjCBool
        guard FileManager.default.fileExists(atPath: project, isDirectory: &projectIsDir) else {
            throw FillError.InvalidOutputPath
        }
        guard projectIsDir.boolValue else {
            throw FillError.InvalidOutputPath
        }
        
        self.inputUrl = inputURL
        projectUrl = URL(string: project)!
    }
    
    func start() throws {
        let files = try FileManager.default.contentsOfDirectory(atPath: inputUrl.path)
        
        let clue = Clue()
        for key in clue.localizedMap.keys {
            if files.contains(key + ".strings") {
                let from = inputUrl.appendingPathComponent("\(key).strings").absoluteString
                for toName in clue.localizedMap[key]! {
                    let to = projectUrl.appendingPathComponent(toName).appendingPathComponent("Localizable.strings").absoluteString
                    
                    try appendText(fromFile: from, to: to)
                    print("✅  尾部添加成功 \(toName)")
                }
            } else {
                print("❌  缺失 \(key)")
            }
        }
    }
    func appendText(fromFile from: String, to: String) throws {
        let toText = try String(contentsOfFile: to)
        let fromText = try String(contentsOfFile: from)
        
        let newText = toText.appending("\n\n\(fromText)")
        
        try newText.write(toFile: to, atomically: true, encoding: .utf8)
    }
}
