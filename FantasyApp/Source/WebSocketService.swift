//
//  WebSocketService.swift
//  RhythmicRebellion
//
//  Created by Vlad Soroka on 6/26/18.
//  Copyright © 2018 Patron Empowerment, LLC. All rights reserved.
//

import Foundation
import SocketIO
import RxSwift

let webSocket = WebSocketService()

class WebSocketService {

    /////----------
    /////Interface
    /////----------
    
    var didReceiveMessage: Observable<Room.Message> {
        return Observable.merge(messageProxy.notNil(), subscribe(onEvent: "message"))
    }
    
    func didReceiveMessage(in room: RoomIdentifier) -> Observable<Room.Message> {
        return didReceiveMessage
            .filter { $0.roomId == room.id }
    }
    
    ///rule of sending own message to self via socket is in this proxy
    ///in reality you should just use socket as transport
    ///shame on you lazy ass =)
    private let messageProxy = BehaviorSubject<Room.Message?>(value: nil)
    func send(message: Room.Message) -> Single<Room.Message> {
        
        struct Confirmation: Codable {
            let isSuccess: Bool
            let messageId: String?
        }
        
        return send(event: "message", with: message)
            .map { (x: Confirmation) -> Room.Message in
                
                guard let id = x.messageId else {
                    throw FantasyError.generic(description: "Unsuccessfull message sent \(message)")
                }
                
                var mes = message
                mes.messageId = id
                return mes
            }
            .do(onSuccess: { x in
                self.messageProxy.onNext(x)
            })
            
    }
    
    /////----------
    /////Implementation
    /////----------
    
    private var socketManager: SocketManager!
    private static let url = "https://apidev.fantasyapp.com/socket.io/"
    
    init() {
        
        let _ =
        appState.map { $0.currentUser != nil }
            .distinctUntilChanged()
            .drive(onNext: { (userExist) in
        
                guard let t = PFUser.current()?.sessionToken else {
                    self.socketManager.defaultSocket.disconnect()
                    return
                }
                
                self.socketManager = SocketManager(socketURL: URL(string: WebSocketService.url)!,
                                                   config: [ .log(true), .connectParams(["token": t]) ])
                
                self.socketManager.connect()
        
                //DefaultSocketLogger.Logger.log = true
                
//                self.socketManager.defaultSocket.onAny { (evet) in
//                    print(evet)
//                }
                
            })
        
            didConnect.subscribe()
                
    }

    private func send<T: SocketData, U: Codable>(event: String, with data: T) -> Single<U> {
        
        return Single.create { (subscriber) -> Disposable in
            
            self.socketManager.defaultSocket.emitWithAck(event, data).timingOut(after: 1) { (data: [Any]) in
                
                guard let dic = data.first as? [String: Any],
                    let bytes = try? JSONSerialization.data(withJSONObject: dic, options: []),
                    let model = try? fantasyDecoder.decode(U.self, from: bytes) else {
                        
                    subscriber(.error(FantasyError.generic(description: "Can't parse response for socket event \(event)")))
                    return
                        
                }
                
                subscriber(.success(model))
            }
            
            return Disposables.create()
        }
        
        
    }
    
    private func subscribe<T: Codable>(onEvent name: String) -> Observable<T> {

        return Observable.create { [unowned s = self.socketManager.defaultSocket] (subscriber) -> Disposable in

            let uid = s.on(name) { (data: [Any]?, emt: SocketAckEmitter) in
                
                guard let dic = data?.first as? [String: Any],
                    let bytes = try? JSONSerialization.data(withJSONObject: dic, options: []),
                    let model = try? fantasyDecoder.decode(T.self, from: bytes) else {
                        
                    subscriber.onError( FantasyError.generic(description: "Can't parse response for socket event \(name)") )
                    return
                        
                }
                
                subscriber.onNext(model)
                
            }
            
            
            return Disposables.create {
                s.off(id: uid)
            }
        }
        
    }
    
    lazy var didConnect: Observable<Void> = {
        
        return Observable.create { [unowned s = self.socketManager.defaultSocket] (subscriber) -> Disposable in
            
            s.on(clientEvent: .connect, callback: { (data, ack: SocketAckEmitter) in
                subscriber.onNext( () )
            })
            
            return Disposables.create {
                ///
            }
        }
        .share()
        
    }()
    
    lazy var didDisconnect: Observable<Void> = {
        
        return Observable.create { [unowned s = self.socketManager.defaultSocket] (subscriber) -> Disposable in
            
            s.on(clientEvent: .disconnect, callback: { (data, ack: SocketAckEmitter) in
                subscriber.onNext( () )
            })
            
            return Disposables.create {
                ///
            }
        }
        .share()
        
    }()
    
}
