//
//  ProtocolClient.swift
//  HachiNIO
//
//  Created by Irineu Antunes on 02/12/22.
//

import Foundation
import NIOCore
import NIOPosix
    
public class HachiNIOClient{
    
    private var handler : HachiNIOHandler;
    
    public init (){
        handler = HachiNIOHandler(cbOnConnect: { ()-> Void in
            print("on connectx!")
        }, cbOnData:  { ()-> Void in
            print("on data!")
        }, cbOnError:  { ()-> Void in
            print("on error!")
        });
    }
    
    public func connect(ip: String, port: Int) -> Void {
        let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        
        let bootstrap = ClientBootstrap(group: group).channelInitializer { channel in
            channel.pipeline.addHandler(self.handler)
        }
        
        defer {
            try! group.syncShutdownGracefully()
        }
        
        do{
            let channel = try { () -> Channel in
                return try  bootstrap.connect(host: ip, port: port).wait()
            }()
            
            let header : Dictionary<String, Any> = ["transaction": "teste", "data" : "xpto", "lalla" : 123];
            handler.send(channel: channel, header: header);
            
            try channel.closeFuture.wait()
            print("disconnected!");
            
        }catch is NIOConnectionError{
            print("connection error")
        }catch{
            print("Unknown error")
        }

    }

}
