//
//  ViewController.swift
//  MXFileManageriOS
//
//  Created by kuroky on 2019/6/12.
//  Copyright © 2019 Emucoo. All rights reserved.
//

import UIKit

import MXFileManager

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    let dataList = ["cache文件夹", "文件", "临时文件夹", "所占文件大小", "清除tmp", "清除cache路径"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.rowHeight = 50
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let text = dataList[indexPath.row]
        cell.textLabel?.text = text
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let text = dataList[indexPath.row]
        if text == "cache文件夹" {
            MXFileManager.fileManager.createDirectiory(dirName: "1123") { path in
                if let path = path {
                    print(path)
                }
            }
        }
        else if text == "文件" {
            MXFileManager.fileManager.createFile(name: "456") { path in
                if let path = path {
                    print(path)
                }
            }
        }
        else if text == "所占文件大小" {
            MXFileManager.fileManager.getSize { size in
                print(size)
            }
        }
        else if text == "清除tmp" {
            MXFileManager.fileManager.clearTmpData {
                print("tmp clear")
            }
        }
        else if text == "清除cache路径" {
            MXFileManager.fileManager.clearCacheData {
                print("cache clear")
            }
        }
    }
}

