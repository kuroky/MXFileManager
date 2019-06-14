//
//  Array+Extension.swift
//  MXFileManager
//
//  Created by kuroky on 2019/6/13.
//

import Foundation

extension Array {
    
    mutating func removeObject(object: String) {
        
        if let index = self.lastIndex(where: { ($0 as! String) == object }) {
            self.remove(at: index)
        }
    }
}
