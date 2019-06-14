## MXFileManager
### 快速集成
#### 1.通过CocoaPod安装

```
pod 'MXFileManager', '~> 2.0.0'

```
#### 2.手动安装
将‘MXFileManager’添加至项目

### 使用说明
#### 1.在AppDelegate引用头文件
AppDelegate.swift
```Swift
import MXFileManager

MXFileManager.fileManager.fileSetup()

```
#### 2. MXFileManager.swift

```
```
#### 具体使用
- 文件夹的创建

```Swift
MXFileManager.fileManager.createDirectiory(dirName: "1123") { path in
                if let path = path {
                    print(path)
                }
            }
```

- 文件创建

```Swift
MXFileManager.fileManager.createFile(name: "456") { path in
                if let path = path {
                    print(path)
                }
            }
``` 



