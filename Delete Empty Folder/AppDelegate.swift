//
//  AppDelegate.swift
//  Delete Empty Folder
//
//  Created by zzz on 2023/12/23.
//  Copyright © 2023 zzz. All rights reserved.
//

import Cocoa
import UserNotifications

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var theLabel: NSTextField!
    @IBOutlet weak var progressBar: NSProgressIndicator!
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        
        //フォルダを選択
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true   // ディレクトリの選択を許可する
        panel.canChooseFiles = false        // ファイルの選択を不可にする
        
        if panel.runModal() == .cancel {
            NSSound(named: "Frog")?.play()
            NSApp.terminate(self)
            return
        }
        
        let selectURL = panel.url!
        print(selectURL)
        
        // ダイアログで確認
        let alert = NSAlert()
        alert.alertStyle = .critical
        //alert.alertStyle = .warning
        alert.informativeText = "This item will be deleted immediately. You can't undo this action."
        alert.messageText = "Do you want to delete empty folders?"
        //キャンセルボタンをデフォルトにする
        alert.addButton(withTitle: "Cancel")
        alert.addButton(withTitle: "OK")
        alert.buttons[0].tag = NSApplication.ModalResponse.OK.rawValue
        alert.buttons[1].tag = NSApplication.ModalResponse.cancel.rawValue
        
        let result = alert.runModal()
        if result == .OK {
            print("tapped: OK")
            NSSound(named: "Frog")?.play()
            NSApp.terminate(self)
        } else if result == .cancel {
            print("tapped: Cancel")
        } else {
            print("tapped: Unknown")
        }
        
        // プログレスウィンドウを準備
        //theLabel.stringValue = selectURL!.absoluteString
        theLabel.stringValue = selectURL.path
        progressBar.isIndeterminate = true
        progressBar.startAnimation(nil)
        window.center()
        window.makeKeyAndOrderFront(self)
        
        //return
        let startTime = Date()
        
        // フォルダを検索
        theLabel.stringValue = "Searching for folder..."
        let dirContents = FileManager().enumerator(at: selectURL, includingPropertiesForKeys: nil)
        var fileURLs = dirContents!.allObjects as! [URL]
        fileURLs.insert(selectURL, at: 0)
        
        //「.DS_store」を抽出＆削除
        theLabel.stringValue = "Deleting \".DS_store\"..."
        let filteredArray = (fileURLs.filter { $0.lastPathComponent == ".DS_Store" })
        print(filteredArray.count)
        
        for aURL in filteredArray {
            do {
                try FileManager().removeItem(at: aURL)
            } catch {
                print(error.localizedDescription)
            }
        }
        
        //空フォルダを削除
        theLabel.stringValue = "Deleting empty folder..."
        var deleteCount = 0
        for aURL in fileURLs.reversed() {
            
            var isDir : ObjCBool = false
            if FileManager().fileExists(atPath: aURL.path, isDirectory:&isDir) {
                if isDir.boolValue {
                    do {
                        
                        let contentsFiles = try FileManager().contentsOfDirectory(at: aURL, includingPropertiesForKeys: nil)
                        if contentsFiles.count == 0 {
                            try FileManager().removeItem(at: aURL)
                            deleteCount = deleteCount + 1
                        }
                        
                    } catch {
                        print("Error while enumerating files \(aURL.path): \(error.localizedDescription)")
                    }
                }
            }
        }
        
        //deleteEmptyFolder(srcURL: selectURL)
        
        let elapsed2 = Date().timeIntervalSince(startTime)
        print(elapsed2)
        
        //終了を通知
        
        NSSound.beep()
        return NSApp.terminate(self)
        
    }
    
    // swiftのarrayで処理する
    /*func deleteEmptyFolder(srcURL: URL) {
        print("deleteEmptyFolder")
        
        let dirContents = FileManager().enumerator(at: srcURL, includingPropertiesForKeys: nil)
        var fileURLs = dirContents!.allObjects as! [URL]
        fileURLs.insert(srcURL, at: 0)
        
        //「.DS_store」を抽出＆削除
        let filteredArray = (fileURLs.filter { $0.lastPathComponent == ".DS_Store" })
        print(filteredArray.count)
        
        for aURL in filteredArray {
            do {
                try FileManager().removeItem(at: aURL)
            } catch {
                print(error.localizedDescription)
            }
        }
        
        //空フォルダを削除
        var deleteCount = 0
        for aURL in fileURLs.reversed() {
            
            var isDir : ObjCBool = false
            if FileManager().fileExists(atPath: aURL.path, isDirectory:&isDir) {
                if isDir.boolValue {
                    do {
                        
                        let contentsFiles = try FileManager().contentsOfDirectory(at: aURL, includingPropertiesForKeys: nil)
                        if contentsFiles.count == 0 {
                            try FileManager().removeItem(at: aURL)
                            deleteCount = deleteCount + 1
                        }
                        
                    } catch {
                        print("Error while enumerating files \(aURL.path): \(error.localizedDescription)")
                    }
                }
            }
        }
        return
    }*/
}

