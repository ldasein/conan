//
//  Error.swift
//  Conan
//
//  Created by 黄明 on 2016/11/5.
//  Copyright © 2016年 Danis. All rights reserved.
//

import Foundation

enum FinderError: Error {
    case InvalidInputPath
    case InvalidOutputPath
}

enum CheckerError: Error {
    case InvalidInputPath
    case NoBaseFile
}

enum ReadError: Error {
    case InvalidInputPath
    case InvalidOutputPath
}

enum FillError: Error {
    case InvalidInputPath
    case InvalidOutputPath
}
