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
    
    
    public init(cbOnConnect: @escaping () -> Void, cbOnData: @escaping () -> Void, cbOnError: @escaping () -> Void) {
        self.cbOnConnect = cbOnConnect
        self.cbOnData = cbOnData
        self.cbOnError = cbOnError
    }
    
    public func channelActive(context: ChannelHandlerContext) {
        self.cbOnConnect()
    }
    
    public func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        print(data)
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
}
