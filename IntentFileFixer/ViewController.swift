//
//  ViewController.swift
//  IntentFileFixer
//
//  Created by Jonny Kuang on 8/6/22.
//  Copyright © 2022 Jonny Kuang. All rights reserved. MIT license.
//

import Cocoa

class ViewController: NSViewController {

    @IBAction func selectReceiptFile(_ sender: Any) {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = true
        
        panel.beginSheetModal(for: view.window!) { response in
            guard response == .OK else {
                return
            }
            for url in panel.urls where url.pathExtension == "swift" {
                print(url.path)
                
                if url.startAccessingSecurityScopedResource() {
                    DispatchQueue.main.async {
                        url.stopAccessingSecurityScopedResource()
                    }
                }
                self.handleFile(at: url)
            }
        }
    }
    
    func handleFile(at fileURL: URL) {
        do {
            var string = try String(contentsOfFile: fileURL.path, encoding: .utf8)
            
            // string = string.replacingOccurrences(of: "internal ", with: "public ") // optionally make every Intent API public
            
            // MARK: Find and remove all async APIs
            // @available(iOS 15.0, macOS 12.0, watchOS 8.0, *)
            // @objc(handleSearchTwitter:completion:)
            // func handle(intent: KJYSearchTwitterIntent) async -> KJYSearchTwitterIntentResponse
            
            while let asyncIndex = string.range(of: " async ")?.lowerBound,
                  let lastNewLineIndex = string.range(of: "\n", range: asyncIndex..<string.endIndex)?.lowerBound,
                  let availableIndex = string.range(of: "@available", options: .backwards, range: string.startIndex..<asyncIndex)?.lowerBound,
                  let firstNewLineIndex = string.range(of: "\n", options: .backwards, range: string.startIndex..<availableIndex)?.upperBound
            {
                string.removeSubrange(firstNewLineIndex..<lastNewLineIndex)
            }
            try string.data(using: .utf8)!.write(to: fileURL, options: .atomic)
        } catch {
            presentError(error)
        }
    }
}

