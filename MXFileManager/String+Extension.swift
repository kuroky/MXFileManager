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
        return self + "/" + path
    }
}
