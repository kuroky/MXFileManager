//
//  MXFileManager.swift
//  MXFileManager
//
//  Created by kuroky on 2019/6/12.
//

import Foundation


/// 1.Documents：只有用户生成的文件、应用程序不能重新创建的文件，应该保存在<Application_Home>/Documents 目录下面，并将通过iCloud自动备份。
/// 2.Library：可以重新下载或者重新生成的数据应该保存在<Application_Home>/Library/Caches 比如杂志、新闻、地图应用使用的数据库缓存文件和可下载内容应该保存到这个文件夹。
/// 3.tmp:只是临时使用的数据应该保存到<Application_Home>/tmp 文件夹。在应用在使用完这些数据之后要注意随时删除，避免占用用户设备的空间

public class MXFileManager: NSObject {
    
    /// document文件夹路径
    var documentPath: String = ""
    /// cache文件夹路径
    var userCachePath: String = ""
    /// 临时文件夹路径
    var userTmpPath: String = ""
    /// 记录需要删除的临时文件路径
    var storagePath: String = ""
    /// 记录需要删除的临时文件
    var storageData: [String] = Array.init()

    let fileManager = FileManager.default
    let ioQueue = DispatchQueue(label: "com.kuroky.fileManager", attributes: .concurrent)
    
    /// 1. 在/Library/ 目录下生成一个文件，用来记录所有文件状态
    /// 2. 在/Library/Caches 目录生成名bundle id的文件夹，保存缓存数据，用户手动删除
    /// 3. 在/tmp 目录生成名bundle id的文件夹，保存临时缓存数据，自动删除
    @objc public static let fileManager = MXFileManager()
    
    override init() {
        super.init()
        self.setup()
    }
    
    func setup() {
        let appName = Bundle.main.object(forInfoDictionaryKey: kCFBundleNameKey as String) as! String
        let document = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last! as String
        self.documentPath = document.appendingDirectoryPath(path: appName)
        
        let libraryPath = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).last! as String
        self.storagePath = libraryPath.appendingDirectoryPath(path: appName)
        
        let appBundleId = Bundle.main.object(forInfoDictionaryKey: kCFBundleIdentifierKey as String) as! String
        let cachePath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).last! as String
        self.userCachePath = cachePath.appendingDirectoryPath(path: appBundleId)
        
        self.userTmpPath = (NSTemporaryDirectory() as String).appendingDirectoryPath(path: appBundleId)
        
        if let items = NSArray(contentsOfFile: self.storagePath) {
            self.storageData = items as! [String]
        }
    }
    
    /// 初始化
    @objc public func fileSetup() {
        if !self.fileManager.fileExists(atPath: self.documentPath) {
            let b = self.createDirectoryAtPath(path: self.documentPath)
            print(b)
        }
        
        if !self.fileManager.fileExists(atPath: self.storagePath) {
            let b = self.createFileAtPath(path: self.storagePath)
            print(b)
        }
        
        if !self.fileManager.fileExists(atPath: self.userCachePath) {
            let b = self.createDirectoryAtPath(path: self.userCachePath)
            print(b)
        }
        
        if !self.fileManager.fileExists(atPath: self.userTmpPath) {
            let b = self.createDirectoryAtPath(path: self.userTmpPath)
            print(b)
        }
    }
    
    /// 创建文件夹
    ///
    /// - Parameters:
    ///   - dirName: 名称
    ///   - isTmp: 是否在缓存路径 默认false
    ///   - shouldStorage: 是否需要持久化 默认true
    ///   - closure: callback
    @objc public func createDirectiory(dirName: String, isTmp: Bool = false, shouldStorage: Bool = true, closure: ((String?) -> Void)?) {
        if dirName.isEmpty {
            closure?(nil)
            return
        }
        
        let prePath = isTmp ? self.userTmpPath : self.userCachePath
        let filePath = prePath.appendingDirectoryPath(path: dirName)
        
        var state = true
        self.ioQueue.sync {
            if !self.fileManager.fileExists(atPath: filePath) {
                state = self.createDirectoryAtPath(path: filePath)
            }
            
            if state && !shouldStorage {
                self.addRecord(fileName: dirName, tmp: isTmp)
            }
        }
        
        if state {
            closure?(filePath)
        }
    }
    
    /// 创建文件
    ///
    /// - Parameters:
    ///   - name: 文件名
    ///   - isTmp: 是否在tmp目录 默认false
    ///   - shouldStorage: 是否需要持久化 默认true
    ///   - completion: callback
    @objc public func createFile(name: String, isTmp: Bool = false, shouldStorage: Bool = true, completion: ((String?) -> Void)?) {
        if name.isEmpty {
            completion?(nil)
            return
        }
        
        let prePath = isTmp ? self.userTmpPath : self.userCachePath
        let filePath = prePath.appendingDirectoryPath(path: name)
        
        var state = true
        self.ioQueue.sync {
            if !self.fileManager.fileExists(atPath: filePath) {
                state = self.createFileAtPath(path: filePath)
            }
            
            if state && !shouldStorage {
                self.addRecord(fileName: filePath, tmp: isTmp)
            }
        }
        
        if state {
            completion?(filePath)
        }
    }
    
    /// 清除tmp路径数据
    @objc public func clearTmpData(closure: (() -> Void)?) {
        self.ioQueue.async {
            self.clearData(path: self.userTmpPath)
            
            DispatchQueue.main.async {
                closure?()
            }
        }
    }
    
    /// 清除缓存路径数据
    @objc public func clearCacheData(closure: (() -> Void)?) {
        self.ioQueue.async {
            self.clearData(path: self.userTmpPath)
            self.clearData(path: self.userCachePath)
            
            DispatchQueue.main.async {
                closure?()
            }
        }
    }
    
    /// 获取文件所占大小
    
    ///
    /// - Parameter closure: callback 格式 x.xxx 单位 MB
    @objc public func getSize(closure: ((Double) -> Void)?) {
        self.ioQueue.async {
            let size1 = self.calculateSize(path: self.documentPath)
            let size2 = self.calculateSize(path: self.userCachePath)
            let size3 = self.calculateSize(path: self.userTmpPath)
            let size4 = self.calculateSize(path: self.storagePath)
            DispatchQueue.main.async {
                closure?((size1 + size2 + size3 + size4) / 1024.0 / 1024.0)
            }
        }
    }
}

extension MXFileManager {
    
    //MARK:- 创建文件夹
    func createDirectoryAtPath(path: String) -> Bool {
        do {
            try self.fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
            return true
        } catch let error as NSError {
            print(error)
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
        if let url = URL(string: self.storagePath) {
            try? data.write(to: url, options: [])
        }
    }
    
    //MARK:- 计算文件夹大小
    func calculateSize(path: String) -> Double {

        var size: Double = 0

        if let attr = try? self.fileManager.attributesOfItem(atPath: path) {
            size += attr[.size] as! Double
        }
        
        return size
    }
    
    //MARK:- 清除对应文件
    func clearData(path: String) {
        guard let enumrator = self.fileManager.enumerator(atPath: path) else {
            return
        }
        
        for fileName in enumrator {
            if let name = fileName as? String, self.storageData.contains(name) {
                let filePath = path.appendingDirectoryPath(path: name)
                if let url = URL(string: filePath) {
                    try? self.fileManager.removeItem(at: url)
                    self.storageData.removeObject(object: name)
                }
            }
        }
    }
}
