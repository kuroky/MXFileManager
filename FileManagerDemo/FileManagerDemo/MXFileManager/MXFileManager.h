//
//  MXFileManager.h
//  FileManagerDemo
//
//  Created by kuroky on 2017/6/16.
//  Copyright © 2017年 Kuroky. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 创建文件/文件夹

 @param filePath 路径
 */
typedef void(^MXFileCreateBlock)(NSString *filePath);

/**
 删除文件/文件夹
 */
typedef void(^MXFileClearBlock)(void);

/**
 1.Documents：只有用户生成的文件、应用程序不能重新创建的文件，应该保存在<Application_Home>/Documents 目录下面，并将通过iCloud自动备份。
 
 2.Library：可以重新下载或者重新生成的数据应该保存在<Application_Home>/Library/Caches 比如杂志、新闻、地图应用使用的数据库缓存文件和可下载内容应该保存到这个文件夹。
 
 3.tmp:只是临时使用的数据应该保存到<Application_Home>/tmp 文件夹。在应用在使用完这些数据之后要注意随时删除，避免占用用户设备的空间
 */

@interface MXFileManager : NSObject

/**
 SandBox file manager
 1. 在/Library/ 目录下生成一个文件，用来记录所有文件状态
 2. 在/Library/Caches 目录生成名bundle id的文件夹，保存缓存数据，用户手动删除
 3. 在/tmp 目录生成名bundle id的文件夹，保存临时缓存数据，自动删除
 
 @return MXFileManager
 */
+ (instancetype)sharedManager;

/**
 初始化
 */
- (void)mx_fileSetup;

/**
 创建文件夹

 @param dirName 文件夹名称
 @param tmp 是:生成在cache目录下，否:生成在tmp下
 @param storage 是:需要持久化
 @param completion file:文件路径
 */
- (void)mx_createDirectiory:(NSString *)dirName
                isTemporary:(BOOL)tmp
              shouldStorage:(BOOL)storage
                 completion:(MXFileCreateBlock)completion;

/**
 创建文件

 @param fileName 文件名
 @param tmp 是:生成在cache目录下，否:生成在tmp下
 @param storage 是:需要持久化
 @param completion file:文件路径
 */
- (void)mx_createFile:(NSString *)fileName
          isTemporary:(BOOL)tmp
        shouldStorage:(BOOL)storage
           completion:(MXFileCreateBlock)completion;

/**
 获取缓存大小

 @return NSUInteger
 */
- (NSUInteger)mx_getSize;

/**
 清除临时数据
 */
- (void)mx_clearTmpCompletion:(MXFileClearBlock)completion;

/**
 清除用户缓存数据
 */
- (void)mx_clearCacheCompletion:(MXFileClearBlock)completion;

/**
 枚举文件目录

 @param tmp 是否临时文件
 @param completion 列表
 */
- (void)mx_enumeratorFromTmp:(BOOL)tmp
                  completion:(void (^)(NSArray *files))completion;

/**
 缓存存放位置
 */
@property (nonatomic, copy, readonly) NSString *userCachePath;

/**
 临时文件存放位置
 */
@property (nonatomic, copy, readonly) NSString *userTmpPath;


@end
