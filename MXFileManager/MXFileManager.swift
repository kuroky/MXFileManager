//
//  MXFileManager.swift
//  MXFileManager
//
//  Created by kuroky on 2019/6/12.
//

import Foundation

public class MXFileManager: NSObject {
    
    /// cache文件夹
    var userCachePath: String = ""
    
    /// 临时文件夹
    var userTmpPath: String = ""
    
    /// 记录文件
    var storagePath: String = ""
    
    var storageData: [String] = Array.init()
    
    let fileManager = FileManager.default
    
    let ioQueue = DispatchQueue(label: "com.kuroky.fileManager", attributes: .concurrent)
    
    @objc public static let fileManager = MXFileManager()
    
    override init() {
        super.init()
        self.setup()
    }
    
    func setup() {
        let appName = Bundle.main.object(forInfoDictionaryKey: kCFBundleNameKey as String) as! String
        let libraryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last! as String
        self.storagePath = appName + "/" + libraryPath
        
        
        let appBundleId = Bundle.main.object(forInfoDictionaryKey: kCFBundleIdentifierKey as String) as! String
        let cachePath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).last! as String
        self.userCachePath = cachePath + "/" + appBundleId
        
        self.userTmpPath = NSTemporaryDirectory().appendingFormat("", appBundleId)
        
        self.storageData = NSArray(contentsOfFile: self.storagePath) as! [String]
        
    }
    
    /// 初始化
    @objc public func fileSetup() {
        if self.fileManager.fileExists(atPath: self.storagePath) {
            _ = self.createFileAtPath(path: self.storagePath)
        }
        
        if self.fileManager.fileExists(atPath: self.userCachePath) {
            _ = self.createDirectoryAtPath(path: self.userCachePath)
        }
        
        if self.fileManager.fileExists(atPath: self.userTmpPath) {
            _ = self.createDirectoryAtPath(path: self.userTmpPath)
        }
    }
    
    /// 创建文件夹
    @objc public func createDirectiory(dirName: String, isTmp: Bool, shouldStorage: Bool, completionHandler: ((String?) -> Void)?) {
        if dirName.isEmpty {
            completionHandler?(nil)
            return
        }
        
        let prePath = isTmp ? self.userTmpPath : self.userCachePath
        //let filePath = prePath.append
    }
}

extension MXFileManager {
    
    //MARK:- 创建文件夹
    func createDirectoryAtPath(path: String) -> Bool {
        do {
            try self.fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
            return true
        } catch {
            return false
        }
    }
    
    //MARK:- 创建空文件
    func createFileAtPath(path: String) -> Bool {
        return self.fileManager.createFile(atPath: path, contents: nil, attributes: nil)
    }
    
    //MARK:- 写入数据
    func addRecord(fileName: String, tmp: Bool) {
        if !self.storageData.contains(fileName) {
            self.storageData.append(fileName)
        }
        
        let data = NSKeyedArchiver.archivedData(withRootObject: self.storageData)
        do {
            let url = URL.init(fileURLWithPath: self.storagePath)
            try data.write(to: url, options: [])
        } catch {
            
        }
    }
}
