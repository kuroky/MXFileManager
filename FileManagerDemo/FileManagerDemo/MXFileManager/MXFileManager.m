//
//  MXFileManager.m
//  FileManagerDemo
//
//  Created by kuroky on 2017/6/16.
//  Copyright © 2017年 Kuroky. All rights reserved.
//

#import "MXFileManager.h"

@interface MXFileManager () {
    NSFileManager *_fileManager;
}

/**
 cache文件夹
 */
@property (nonatomic, copy, readwrite) NSString *userCachePath;

/**
 临时文件夹
 */
@property (nonatomic, copy, readwrite) NSString *userTmpPath;

/**
 记录文件
 */
@property (nonatomic, copy) NSString *storagePath;

/**
 持久化文件存储
 @[@"filename1", @"filename2", @"filename3"...];
 */
@property (nonatomic, strong) NSMutableArray *storageData;

@property (strong, nonatomic, nullable) dispatch_queue_t ioQueue;

@end

@implementation MXFileManager

+ (instancetype)sharedManager {
    static MXFileManager *fileManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        fileManager = [MXFileManager new];
    });
    return fileManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    NSString *appName = [[[NSBundle mainBundle] infoDictionary] valueForKey:(__bridge NSString *)kCFBundleNameKey];
    NSString *libraryPath = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).lastObject;
    self.storagePath = [libraryPath stringByAppendingPathComponent:appName];

    NSString *appBundleId = [[[NSBundle mainBundle]infoDictionary] valueForKey:(__bridge NSString *)kCFBundleIdentifierKey];
    NSString *cachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).lastObject;
    self.userCachePath = [cachePath stringByAppendingPathComponent:appBundleId];
    
    self.userTmpPath = [NSTemporaryDirectory() stringByAppendingString:appBundleId];
    
    self.storageData = [NSMutableArray array];
    [self.storageData addObjectsFromArray:[NSArray arrayWithContentsOfFile:self.storagePath]];
    
    _ioQueue = dispatch_queue_create("com.kuroky.fileManager", DISPATCH_QUEUE_SERIAL);
    _fileManager = [NSFileManager defaultManager];
}

- (void)mx_fileSetup {
    if (![_fileManager fileExistsAtPath:self.storagePath]) {
        [self createFileAtPath:self.storagePath];
    }
    
    if (![_fileManager fileExistsAtPath:self.userCachePath]) {
        [self createDirectoryAtPath:self.userCachePath];
    }
    
    if (![_fileManager fileExistsAtPath:self.userTmpPath]) {
        [self createDirectoryAtPath:self.userTmpPath];
    }
}

#pragma mark - 创建文件夹
- (void)mx_createDirectiory:(NSString *)dirName
                isTemporary:(BOOL)tmp
              shouldStorage:(BOOL)storage
                 completion:(MXFileCreateBlock)completion {
    if (!dirName || !dirName.length) {
        completion ? completion(nil) : nil;
        return;
    }
    
    __block BOOL state = YES;
    // 临时文件路径 | 缓存路径
    NSString *prePath = tmp ? self.userTmpPath : self.userCachePath;
    NSString *filePath = [prePath stringByAppendingPathComponent:dirName];
    
    dispatch_sync(self.ioQueue, ^{
        if (![_fileManager fileExistsAtPath:filePath]) {
            state = [self createDirectoryAtPath:filePath];
        }
        if (state && !storage) { // 创建成功&&不需要持久化, 保存至记录文件
            [self addRecord:dirName temporary:tmp];
        }
    });
    if (completion && state) {
        completion(filePath);
    }
}

#pragma mark - 创建文件
- (void)mx_createFile:(NSString *)fileName
          isTemporary:(BOOL)tmp
        shouldStorage:(BOOL)storage
           completion:(MXFileCreateBlock)completion {
    if (!fileName || !fileName.length) {
        completion ? completion(nil) : nil;
        return;
    }
    __block BOOL state = YES;
    NSString *prePath = tmp ? self.userTmpPath : self.userCachePath;
    NSString *filePath = [prePath stringByAppendingPathComponent:fileName];
    
    dispatch_sync(self.ioQueue, ^{
        if (![_fileManager fileExistsAtPath:filePath]) {
            state = [self createFileAtPath:filePath];
        }
    
        if (state && !storage) { // 创建成功&&需要持久化, 保存至记录文件
            [self addRecord:fileName temporary:tmp];
        }
    });
    if (completion && filePath) {
        completion(filePath);
    }
}

#pragma mark - 清除临时数据
- (void)mx_clearTmpCompletion:(MXFileClearBlock)completion {
    dispatch_async(self.ioQueue, ^{
        NSDirectoryEnumerator *fileEnumerator = [_fileManager enumeratorAtPath:self.userTmpPath];
        for (NSString *fileName in fileEnumerator) {
            if ([self.storageData containsObject:fileName]) {
                NSString *filePath = [self.userTmpPath stringByAppendingPathComponent:fileName];
                [_fileManager removeItemAtPath:filePath error:nil];
                [self.storageData removeObject:fileName];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            completion ? completion() : nil;
        });
    });
}

#pragma mark - 清除缓存数据
- (void)mx_clearCacheCompletion:(MXFileClearBlock)completion {
    dispatch_async(self.ioQueue, ^{
        NSDirectoryEnumerator *fileEnumerator = [_fileManager enumeratorAtPath:self.userCachePath];
        for (NSString *fileName in fileEnumerator) {
            if ([self.storageData containsObject:fileName]) {
                NSString *filePath = [self.userCachePath stringByAppendingPathComponent:fileName];
                [_fileManager removeItemAtPath:filePath error:nil];
                [self.storageData removeObject:fileName];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            completion ? completion() : nil;
        });
    });
}

#pragma mark - 获取缓存文件大小
- (NSUInteger)mx_getSize {
    __block NSUInteger size = 0;
    dispatch_sync(self.ioQueue, ^{
        NSDirectoryEnumerator *fileEnumerator = [_fileManager enumeratorAtPath:self.userCachePath];
        for (NSString *fileName in fileEnumerator) {
            NSString *filePath = [self.userCachePath stringByAppendingPathComponent:fileName];
            NSDictionary<NSString *, id> *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
            size += [attrs fileSize];
        }
        
        fileEnumerator = [_fileManager enumeratorAtPath:self.userTmpPath];
        for (NSString *fileName in fileEnumerator) {
            NSString *filePath = [self.userTmpPath stringByAppendingPathComponent:fileName];
            NSDictionary<NSString *, id> *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
            size += [attrs fileSize];
        }
    });
    return size;
}

- (void)mx_enumeratorFromTmp:(BOOL)tmp
                  completion:(void (^)(NSArray *files))completion {
    __block NSMutableArray *arrFiles = [NSMutableArray array];
    NSString *targetPath = tmp ? self.userTmpPath : self.userCachePath;
    dispatch_async(self.ioQueue, ^{
        NSDirectoryEnumerator *fileEnumerator = [_fileManager enumeratorAtPath:targetPath];
        for (NSString *fileName in fileEnumerator) {
            NSString *filePath = [targetPath stringByAppendingPathComponent:fileName];
            [arrFiles addObject:filePath];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(arrFiles);
            }
        });
    });
}

#pragma mark - Private
- (BOOL)createDirectoryAtPath:(NSString *)path {
    return [_fileManager createDirectoryAtPath:path
                   withIntermediateDirectories:YES
                                    attributes:nil
                                         error:nil];
}

- (BOOL)createFileAtPath:(NSString *)path {
    return [_fileManager createFileAtPath:path
                                 contents:nil
                               attributes:nil];
}

- (void)addRecord:(NSString *)fileName
        temporary:(BOOL)tmp {
    if (![self.storageData containsObject:fileName]) {
        [self.storageData addObject:fileName];
    }
    
    [self.storageData writeToFile:self.storagePath
                       atomically:YES];
}

@end
