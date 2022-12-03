//
//  ProtocolServer.swift
//  HachiNIO
//
//  Created by Irineu Antunes on 02/12/22.
//

import Foundation
import NIOTLS
import NIOSSL
import NIOCore
import NIOPosix


public class ProtocolServer{
    
    public init (){
        
//        do{
//            var configuration = TLSConfiguration.makeClientConfiguration()
//            configuration.certificateVerification = CertificateVerification.none
//            
//            let sslContext = try NIOSSLContext(configuration: configuration)
//            
//            let handler = try NIOSSLClientHandler(context: sslContext, serverHostname: nil)
//            
//            let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
//            let client = ClientBootstrap(group: group).channelInitializer { channel in
//                    // important: The handler must be initialized _inside_ the `channelInitializer`x
//                channel.pipeline.addHandlers([handler, HachiNIOHandler()])
//            }
//            
//            defer {
//                try! group.syncShutdownGracefully()
//            }
//            
//            let defaultHost = "127.0.0.1"
//            let defaultPort: Int = 7890
//            
//            let channel = try { () -> Channel in
//                return try client.connect(host: defaultHost, port: defaultPort).wait()
//            }()
//            
//            print("TESTEEEE")
//            try channel.closeFuture.wait()
//            print("????")
//            
//            
//        }catch {
//            print("NOOOO cu")
//        }
        
        
        
    }
    
    public func sayHello() -> Void {
        print("Hello world!")
    }

}
