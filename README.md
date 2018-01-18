## MXFileManager
### 快速集成
#### 1.通过CocoaPod安装

```
pod 'MXFileManager', '~> 1.0.0'

```

#### 2.手动安装
将‘MXFileManager’添加至项目

### 使用说明
#### 1.在AppDelegate引用头文件

```
#import "MXFileManager.h"

[[MXFileManager sharedManager] mx_fileSetup];

```

#### 2. MXFileManager.h

```
/**
 创建文件/文件夹

 @param filePath 路径
 */
typedef void(^MXFileCreateBlock)(NSString *filePath);

/**
 删除文件/文件夹
 */
typedef void(^MXFileClearBlock)(void);
```

```
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
```
#### 具体使用
- 文件夹的创建

```
NSString *name = [@"cache" stringByAppendingString:[NSUUID UUID].UUIDString];
[[MXFileManager sharedManager] mx_createDirectiory:name
                                       isTemporary:NO
                                     shouldStorage:storage
                                        completion:^(NSString *filePath) {
                                            NSLog(@"创建文件夹: %@", filePath);
                                        }];
```

- 文件创建

```
NSString *name = [@"tmp" stringByAppendingString:[NSUUID UUID].UUIDString]; [[MXFileManager sharedManager] mx_createDirectiory:name
                                       isTemporary:YES
                                     shouldStorage:storage
                                        completion:^(NSString *filePath) {
                                            NSLog(@"创建临时文件夹: %@", filePath);
                                        }];
``` 



