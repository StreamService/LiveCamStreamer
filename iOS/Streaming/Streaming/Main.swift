//
//  Main.swift
//  Streaming
//
//  Created by Siyuan Yao on 2/17/20.
//  Copyright © 2020 Siyuan Yao. All rights reserved.
//

import UIKit

protocol StreamerDelegate: class {
    func received(img: UIImage)
}



class Streamer: NSObject {
    weak var delegate: StreamerDelegate?
    
    var ins: InputStream!
    var outs: OutputStream!
    
    var username = ""
    
    let maxReadLength = 1024
    
    func initialize(){
        var reads: Unmanaged<CFReadStream>?
        var writes: Unmanaged<CFWriteStream>?
        
        CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, "10.0.0.203" as CFString, 9999, &reads, &writes)
        
        ins = reads!.takeRetainedValue()
        outs = writes!.takeRetainedValue()
        
        ins.schedule(in: .current, forMode: .common)
        outs.schedule(in: .current, forMode: .common)
        
        ins.open()
        outs.open()
        
        
        ins.delegate = self
    }
    
    func send() {
        let data = "RECV".data(using: .utf8)!
        
        _ = data.withUnsafeBytes{
        guard let pointer = $0.baseAddress?.assumingMemoryBound(to: UInt8.self) else{
                print("ERROR")
                return
            }
            outs.write(pointer, maxLength: data.count)
        }
    }
    
}

extension Streamer: StreamDelegate {
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        switch eventCode {
        case .hasBytesAvailable:
            print("recv")
            readAvailableBytes(stream: aStream as! InputStream)
        case .endEncountered:
            print("recv")
        case .errorOccurred:
            print("error")
        case .hasSpaceAvailable:
            print("space available")
        default:
            print("other")
        }
    }
    
    private func readAvailableBytes(stream: InputStream) {
        let l_buff = UnsafeMutablePointer<UInt8>.allocate(capacity: 8)
        let i_buff = UnsafeMutablePointer<UInt8>.allocate(capacity: maxReadLength)
        // var buffer = [U
        
        var buff_str = ""
        
        while stream.hasBytesAvailable {
            ins.read(l_buff, maxLength: 8)
            
            let l_str:String = NSString(bytes: l_buff, length: 8, encoding: String.Encoding.utf8.rawValue)!.replacingOccurrences(of: " ", with: "")
            let l:Int? = Int(l_str)
            print(l)
            if l == nil {
                continue
            }
            var buffer:Data = Data(count: 0)
            var numberOfBytesReadTotal = 0
            while l! > numberOfBytesReadTotal {
                let numberOfBytesRead = ins.read(i_buff, maxLength: maxReadLength)
                numberOfBytesReadTotal += numberOfBytesRead
                buffer.append(i_buff, count:numberOfBytesRead)
                
            }
            
            print(buffer as NSData)
            
            
            if numberOfBytesReadTotal < l!, let error = stream.streamError {
                print(error)
                break
            }
            
            if let img:UIImage = processedMessageString(buffer: buffer, length: numberOfBytesReadTotal){
                delegate?.received(img: img)
            }
            send()
        }
    }
    
    private func processedMessageString(buffer: Data, length: Int) -> UIImage? {
        //let str:String = String(cString: buffer)
        //let data:NSData = NSData(bytes: buffer, length: length)
        
        
        // let img : UIImage = UIImage(data: data as Data)!
        /*
        let cgsize = CGSize(width: 100, height: 100)
        let rect = CGRect(x: 0, y:0,width:100, height: 100)
        let color = UIColor(cgColor: CGColor(srgbRed: 1, green: 0, blue: 0, alpha: 0.5))
        UIGraphicsBeginImageContextWithOptions(cgsize, false, 0)
        color.setFill()
        let image:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image*/
        return UIImage(data: buffer)
    }
}
