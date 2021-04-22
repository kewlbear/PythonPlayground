//
//  PythonPlaygroundApp.swift
//
//  Copyright (c) 2020 Changbeom Ahn
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import SwiftUI
import Resources
import PythonKit

var standardOutReader: StandardOutReader?

@main
struct PythonPlaygroundApp: App {
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(Buffer.shared)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
    
    init() {
        DispatchQueue.global(qos: .userInitiated).async {
            SetPythonHome()
            SetTMP()
            
            let sys = Python.import("sys")
            
            sys.stdout = Python.open(NSTemporaryDirectory() + "stdout.txt", "w", encoding: "utf8")
            sys.stderr = sys.stdout
            
            print(sys.stdout.encoding)
            
            standardOutReader = StandardOutReader(STDOUT_FILENO: Int32(sys.stdout.fileno())!, STDERR_FILENO: Int32(sys.stderr.fileno())!)
            
            guard let rubiconPath = Bundle.main.url(forResource: "rubicon-objc-0.4.0", withExtension: nil)?.path else {
                return
            }

            sys.path.insert(1, rubiconPath)
            
            sys.path.insert(1, Bundle.main.bundlePath)
            let bridge = Python.import("ObjCBridge")
            
//            DispatchQueue.main.sync {
//                Buffer.shared.text = ""
//            }
            
            let code = Python.import("code")
            code.interact(readfunc: bridge.input, exitmsg: "Bye.")
        }
    }
}

class PythonBridge: NSObject {
    @objc func input(_ prompt: String) -> String {
        Buffer.shared.append(prompt)
//        print(prompt)
        return Buffer.shared.read()
    }
}

class Buffer: ObservableObject {
    static let shared = Buffer()
    
    @Published var text = ""
    
    @Published var input = ""
    
    var inputs: [String] = []
    
    let semaphore = DispatchSemaphore(value: 0)
    
    func append(_ string: String) {
        DispatchQueue.main.async {
            self.text.append(string)
        }
    }
    
    func read() -> String {
        if inputs.isEmpty {
            standardOutReader?.isBufferEnabled = false
            semaphore.wait()
            standardOutReader?.isBufferEnabled = true
        }
        return inputs.removeFirst()
    }
    
    func onCommit() {
        var t = input
        let table = [
            "\u{2018}": "\'", // ‘
            "\u{2019}": "\'", // ’
            "\u{201C}": "\"", // “
            "\u{201D}": "\"", // ”
        ]
        for (c, r) in table {
            t = t.replacingOccurrences(of: c, with: r)
        }
        print(input, "->", t)

        text.append(t.appending("\n"))
        inputs.append(t)
        input = ""
        semaphore.signal()
    }
}

class StandardOutReader {
    let inputPipe = Pipe()
    
    let outputPipe = Pipe()
    
    var isBufferEnabled = true
    
    init(STDOUT_FILENO: Int32 = Darwin.STDOUT_FILENO, STDERR_FILENO: Int32 = Darwin.STDERR_FILENO) {
        dup2(STDOUT_FILENO, outputPipe.fileHandleForWriting.fileDescriptor)
        
        dup2(inputPipe.fileHandleForWriting.fileDescriptor, STDOUT_FILENO)
        dup2(inputPipe.fileHandleForWriting.fileDescriptor, STDERR_FILENO)
        // listening on the readabilityHandler
        inputPipe.fileHandleForReading.readabilityHandler = { [weak self] handle in
            let data = handle.availableData
            
            self?.outputPipe.fileHandleForWriting.write(data)
            
            guard self?.isBufferEnabled ?? false else {
                return
            }
            
            let str = String(data: data, encoding: .ascii) ?? "<Non-ascii data of size\(data.count)>\n"
            DispatchQueue.main.async {
                Buffer.shared.text += str
            }
        }
    }
}
