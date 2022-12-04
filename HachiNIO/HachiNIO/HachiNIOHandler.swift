//
//  HachiNIOHandler.swift
//  HachiNIO
//
//  Created by Irineu Antunes on 03/12/22.
//

import Foundation
import NIOCore
import NIOPosix

public class HachiNIOHandler: ChannelInboundHandler{
    
    public typealias InboundIn = ByteBuffer
    public typealias OutboundOut = ByteBuffer
    
    private var sendBytes = 0
    private var receiveBuffer: ByteBuffer = ByteBuffer()
    
    private var cbOnConnect : () -> Void
    private var cbOnData : () -> Void
    private var cbOnError : () -> Void
    
    private var accumulator = ByteBuffer();
    private var messageSize = 0
    private var headerSize = 0
    
    
    public init(cbOnConnect: @escaping () -> Void, cbOnData: @escaping () -> Void, cbOnError: @escaping () -> Void) {
        self.cbOnConnect = cbOnConnect
        self.cbOnData = cbOnData
        self.cbOnError = cbOnError
    }
    
    public func channelActive(context: ChannelHandlerContext) {
        self.cbOnConnect()
    }
    
    public func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        var buff = self.unwrapInboundIn(data)
        accumulator.writeBuffer(&buff)
        
        tryRead();
    }
    
    private func tryRead() -> Void {
       
       
        
        if(messageSize == 0){
            
            let protocolPrefix = accumulator.readBytes(length: 4);
            
            if(protocolPrefix != Array("HNIO".utf8)){
                print("protocol problem");
                //throw error
            }
            
            messageSize = Int(byteArrayToInt32(from: accumulator.readBytes(length: 4)))
        }
        
        if(headerSize == 0){
            headerSize = Int(byteArrayToInt32(from: accumulator.readBytes(length: 4)))
        }
        
        if(accumulator.readableBytes < messageSize - 12){
            print("accumulate \(accumulator.writerIndex) \(messageSize)")
            return;
        }
        
        let header = String(bytes: accumulator.readBytes(length: Int(headerSize))!, encoding: .utf8);
        
        let body = accumulator.readBytes(length: Int(messageSize - headerSize - 8 - 4))!
        
        let strBody = String(bytes: body, encoding: .utf8);
        
        print(header)
        
        messageSize = 0;
        headerSize = 0;
        
        if(accumulator.readableBytes > 0){
           tryRead()
        }
        
        self.cbOnData()
    }
    
    public func errorCaught(context: ChannelHandlerContext, error: Error) {
        self.cbOnError()
    }
    
    public func send(channel: Channel, header: Dictionary<String, Any>) {
        var data = Array("HNIO".utf8)
        
        let header =  String(decoding: try! JSONSerialization.data(withJSONObject: header), as: UTF8.self)
        let body = "hello"
        
        data = data + (byteArray(from: Int32(8 + 4 + header.count + body.count)))
        data = data + (byteArray(from: Int32(header.count)))
        data = data + (Array(header.utf8))
        data = data + (Array(body.utf8))
        
        let buffer = channel.allocator.buffer(bytes: data)
        try! channel.writeAndFlush(buffer).wait();
    }
    
    private func byteArray<T>(from value: T) -> [UInt8] where T: FixedWidthInteger {
        withUnsafeBytes(of: value.littleEndian, Array.init)
    }
    
    private func byteArrayToInt32(from byteArr: [UInt8]?) -> UInt32{
        
        let messageSize: NSData = NSData(bytes: byteArr, length: 4)
        var value : UInt32 = 0
        messageSize.getBytes(&value, length: 4)
        value = UInt32(littleEndian: value)
        
        return value
    }
}
