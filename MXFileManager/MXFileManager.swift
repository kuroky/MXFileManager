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
    
    /// cache文件夹路径
    @objc public var userCachePath: String = ""
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
        
        let libraryPath = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).last! as String
        self.storagePath = libraryPath.appendingDirectoryPath(path: appName)
        
        let appBundleId = Bundle.main.object(forInfoDictionaryKey: kCFBundleIdentifierKey as String) as! String
        let cachePath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).last! as String
        self.userCachePath = cachePath.appendingDirectoryPath(path: appBundleId)
        
        self.userTmpPath = (NSTemporaryDirectory() as String).appendingDirectoryPath(path: appBundleId)
        
        
        if let items = NSKeyedUnarchiver.unarchiveObject(withFile: self.storagePath) {
            self.storageData = items as! [String]
        }
    }
    
    /// 初始化
    @objc public func fileSetup() {
        
        if !self.fileManager.fileExists(atPath: self.storagePath) {
            _ = self.createFileAtPath(path: self.storagePath)
        }
        
        if !self.fileManager.fileExists(atPath: self.userCachePath) {
            _ = self.createDirectoryAtPath(path: self.userCachePath)
        }
        
        if !self.fileManager.fileExists(atPath: self.userTmpPath) {
            _ = self.createDirectoryAtPath(path: self.userTmpPath)
        }
    }
    
    /// 创建文件夹
    ///
    /// - Parameters:
    ///   - dirName: 名称
    ///   - isTmp: 是否在缓存路径 默认false
    ///   - shouldStorage: 是否需要持久化 默认true
    ///   - completion: callback
    @objc public func createDirectiory(dirName: String, isTmp: Bool = false, shouldStorage: Bool = true, completion: ((String?) -> Void)?) {
        if dirName.isEmpty {
            completion?(nil)
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
            completion?(filePath)
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
    
    ///
    /// - Parameter completion: callback
    @objc public func clearTmpData(completion: (() -> Void)?) {
        self.ioQueue.async {
            self.clearData(path: self.userTmpPath)
            
            DispatchQueue.main.async {
                completion?()
            }
        }
    }
    
    /// 清除缓存路径数据
    
    ///
    /// - Parameter completion: callback
    @objc public func clearCacheData(completion: (() -> Void)?) {
        self.ioQueue.async {
            self.clearData(path: self.userTmpPath)
            self.clearData(path: self.userCachePath)
            
            DispatchQueue.main.async {
                completion?()
            }
        }
    }
    
    /// 获取文件所占大小
    
    ///
    /// - Parameter completion: callback 格式 x.xxx 单位 MB
    @objc public func getSize(completion: ((Double) -> Void)?) {
        self.ioQueue.async {
            let size1 = self.calculateSize(path: self.userCachePath)
            let size2 = self.calculateSize(path: self.userTmpPath)
            let size3 = self.calculateSize(path: self.storagePath)
            DispatchQueue.main.async {
                completion?((size1 + size2 + size3) / 1024.0 / 1024.0)
            }
        }
    }
    
    /// 枚举文件目录
    ///
    /// - Parameters:
    ///   - tmp: 是否tmp目录
    ///   - completion: callback
    @objc public func enumeratorForTmp(tmp: Bool, completion: @escaping (Array<String>) -> Void) {
        let targetPath = tmp ? self.userTmpPath : self.userCachePath
        var files: [String] = [String]()
        
        guard let enumerator = self.fileManager.enumerator(atPath: targetPath) else {
            completion(files)
            return
        }
        
        self.ioQueue.async {
            for fileName in enumerator {
                if let name = fileName as? String {
                    let filePath = targetPath.appendingDirectoryPath(path: name)
                    files.append(filePath)
                }
            }
            
            DispatchQueue.main.async {
                completion(files)
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
        
        self.saveRecordData()
    }
    
    //MARK:- 保存数据
    func saveRecordData() {
        let data = NSKeyedArchiver.archivedData(withRootObject: self.storageData)
        let url = URL.init(fileURLWithPath: self.storagePath)
        do {
            try data.write(to: url, options: [])
        }
        catch let error as NSError {
            print(error)
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
