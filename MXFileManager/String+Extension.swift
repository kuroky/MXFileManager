//
//  String+Extension.swift
//  MXFileManager
//
//  Created by kuroky on 2019/6/13.
//

import Foundation

extension String {
    
    //MARK:- 路径转换
    func appendingDirectoryPath(path: String) -> String {
        if let url = URL(string: self) {
            let dirPath = url.appendingPathComponent(path, isDirectory: true)
            return dirPath.absoluteString
        }
        
        return path
    }
}
