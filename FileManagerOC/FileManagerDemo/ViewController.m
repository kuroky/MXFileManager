//
//  ViewController.m
//  FileManagerDemo
//
//  Created by kuroky on 2017/6/23.
//  Copyright © 2017年 kuroky. All rights reserved.
//

#import "ViewController.h"
#import <MXFileManager-Swift.h>

@interface ViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray *dataList;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupData];
    [self setupUI];
}

- (void)setupData {
    self.dataList = @[@"创建文件夹", @"创建临时文件夹", @"创建文件", @"创建临时文件", @"自动清除缓存", @"手动清除缓存", @"遍历文件tmp", @"遍历文件cache", @"文件大小"];
}

- (void)setupUI {
    self.tableView.rowHeight = 49;
    self.tableView.separatorInset = UIEdgeInsetsZero;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cellId"];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellId"];
    cell.textLabel.text = self.dataList[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *title = self.dataList[indexPath.row];
    if ([title isEqualToString:@"创建文件夹"]) {
        static BOOL storage = YES;
        NSString *name = [@"cache" stringByAppendingString:[NSUUID UUID].UUIDString];
        [[MXFileManager fileManager] createDirectioryWithDirName:name
                                                           isTmp:NO
                                                   shouldStorage:storage
                                                      completion:^(NSString *filePath) {
                                                          NSLog(@"创建文件夹: %@", filePath);
                                                      }];
        storage = !storage;
    }
    else if ([title isEqualToString:@"创建临时文件夹"]) {
        static BOOL storage = YES;
        NSString *name = [@"tmp" stringByAppendingString:[NSUUID UUID].UUIDString];
        [[MXFileManager fileManager] createDirectioryWithDirName:name
                                                           isTmp:YES
                                                   shouldStorage:storage
                                                      completion:^(NSString *filePath) {
                                                          NSLog(@"创建临时文件夹: %@", filePath);
                                                      }];
        storage = !storage;
    }
    else if ([title isEqualToString:@"创建文件"]) {
        static BOOL storage = YES;
        NSString *name = [NSString stringWithFormat:@"cache_%@.txt", [NSUUID UUID].UUIDString];
        [[MXFileManager fileManager] createFileWithName:name
                                                  isTmp:NO
                                          shouldStorage:storage
                                             completion:^(NSString *filePath) {
                                                 NSLog(@"创建文件: %@", filePath);
                                             }];
        storage = !storage;
    }
    else if ([title isEqualToString:@"创建临时文件"]) {
        static BOOL storage = YES;
        NSString *name = [NSString stringWithFormat:@"tmp_%@.txt", [NSUUID UUID].UUIDString];
        [[MXFileManager fileManager] createFileWithName:name
                                                  isTmp:YES
                                          shouldStorage:storage
                                             completion:^(NSString *filePath) {
                                                 NSLog(@"创建临时文件: %@", filePath);
                                             }];
        storage = !storage;
    }
    else if ([title isEqualToString:@"自动清除缓存"]) {
        [[MXFileManager fileManager] clearTmpDataWithCompletion:^{
            NSLog(@"自动清除缓存");
        }];
    }
    else if ([title isEqualToString:@"手动清除缓存"]) {
        [[MXFileManager fileManager] clearCacheDataWithCompletion:^{
            NSLog(@"手动清除缓存");
        }];
    }
    else if ([title isEqualToString:@"遍历文件tmp"]) {
        
        [[MXFileManager fileManager] enumeratorForTmpWithTmp:YES
                                                  completion:^(NSArray<NSString *> *files) {
                                                      NSLog(@"files : %@", files);
                                                  }];
    }
    else if ([title isEqualToString:@"遍历文件cache"]) {
        [[MXFileManager fileManager] enumeratorForTmpWithTmp:NO completion:^(NSArray<NSString *> *files) {
            NSLog(@"files : %@", files);
        }];
    }
    else if ([title isEqualToString:@"文件大小"]) {
        [[MXFileManager fileManager] getSizeWithCompletion:^(double size) {
            NSLog(@"size: %lu", (unsigned long)size);
        }];
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
