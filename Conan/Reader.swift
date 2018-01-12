//
//  Reader.swift
//  Conan
//
//  Created by 黄明 on 2016/12/1.
//  Copyright © 2016年 Danis. All rights reserved.
//

import Foundation

class Reader {
    private var inputURL: URL
    private var outputURL: URL
    
    init(input: String, output: String) throws {
        var isDir: ObjCBool = false
        guard FileManager.default.fileExists(atPath: input, isDirectory: &isDir) else {
            throw ReadError.InvalidInputPath
        }
        guard isDir.boolValue else {
            throw ReadError.InvalidInputPath
        }
        guard let inputURL = URL(string: input) else {
            throw ReadError.InvalidInputPath
        }
        self.inputURL = inputURL
        outputURL = URL(fileURLWithPath: output)
    }
    
    func start() throws {
        let clue = Clue()
        for (_, value) in clue.localizedMap {
            for folder in value {
                let fileUrl = inputURL.appendingPathComponent(folder).appendingPathComponent("Localizable.strings")
                if FileManager.default.fileExists(atPath: fileUrl.absoluteString) {
                    let fileName = folder.components(separatedBy: ".").first!.appending(".strings")
                    let dest = outputURL.appendingPathComponent(fileName)
                    
                    let text = try String(contentsOfFile: fileUrl.absoluteString)
                    try text.write(toFile: dest.absoluteURL.path, atomically: true, encoding: .utf8)
                    
                    
                    print("文件拷贝 ✅: \(fileUrl.absoluteString) -> \(dest.absoluteURL.path)")
                }
            }
        }
    }
}
