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
    
    var didReceiveMessage: Observable<Room.MessageInRoom> {
        return Observable.merge(messageProxy.skip(1).notNil(),
                                manager.defaultSocket.rx.subscribe(onEvent: "message"))
    }
    
    func didReceiveMessage(in room: RoomIdentifier) -> Observable<Room.MessageInRoom> {
        return didReceiveMessage
            .filter { $0.roomId == room.id }
    }

    func send(message: Room.MessageInRoom) -> Single<Room.MessageInRoom> {
        
        struct Confirmation: Codable {
            let isSuccess: Bool
            let messageId: String?
        }
        
        return manager.defaultSocket.rx.send(event: "message", with: message)
            .map { (x: Confirmation) -> Room.MessageInRoom in
                
                guard let id = x.messageId else {
                    throw FantasyError.generic(description: "Unsuccessfull message sent \(message)")
                }
                
                var mes = message
                mes.raw.messageId = id
                return mes
            }
            .do(onSuccess: { x in
                self.messageProxy.onNext(x)
            })
            
    }
    ///rule of sending own message to self via socket is in this proxy
    ///in reality you should just use socket as transport
    ///shame on you lazy ass =)
    private let messageProxy = BehaviorSubject<Room.MessageInRoom?>(value: nil)
    
    /////----------
    /////Implementation
    /////----------
    
    private var manager: SocketManager!
    
    init() {
        
        let _ =
        appState.map { $0.currentUser != nil }
            .distinctUntilChanged()
            .drive(onNext: { (userExist) in

                guard let t = PFUser.current()?.sessionToken else {
                    self.manager = nil

                    return
                }

                self.manager = SocketManager(socketURL: URL(string: ServerURL.socket)!,
                                                   config: [ .log(true), .forceNew(true), .connectParams(["token": t]) ])
                ///bug in the library
                ///need to call it to lazily create default socketIOClient
                _ = self.manager.defaultSocket
                self.manager.connect()

            })
                
    }
//
//    lazy var didConnect: Observable<Void> = {
//
//        return Observable.create { [unowned s = self.manager.defaultSocket] (subscriber) -> Disposable in
//
//            s.on(clientEvent: .connect, callback: { (data, ack: SocketAckEmitter) in
//                subscriber.onNext( () )
//            })
//
//            return Disposables.create {
//                ///
//            }
//        }
//        .share()
//
//    }()
//
//    lazy var didDisconnect: Observable<Void> = {
//
//        return Observable.create { [unowned s = self.manager.defaultSocket] (subscriber) -> Disposable in
//
//            s.on(clientEvent: .disconnect, callback: { (data, ack: SocketAckEmitter) in
//                subscriber.onNext( () )
//            })
//
//            return Disposables.create {
//                ///
//            }
//        }
//        .share()
//
//    }()
    
}

extension SocketIOClient {
    var rx: Reactive<SocketIOClient> {
        return Reactive(self)
    }
}

extension Reactive where Base == SocketIOClient {

    fileprivate func subscribe<T: Codable>(onEvent name: String) -> Observable<T> {

        return Observable.create { (subscriber) -> Disposable in

            let uid = self.base.on(name) { (data: [Any]?, emt: SocketAckEmitter) in
                
                guard let dic = data?.first as? [String: Any],
                    let bytes = try? JSONSerialization.data(withJSONObject: dic, options: []),
                    let model = try? fantasyDecoder.decode(T.self, from: bytes) else {
                        
                    subscriber.onError( FantasyError.generic(description: "Can't parse response for socket event \(name)") )
                    return
                        
                }
                
                subscriber.onNext(model)
                
            }
            
            
            return Disposables.create {
                self.base.off(id: uid)
            }
        }
        
    }
    
    fileprivate func send<T: SocketData, U: Codable>(event: String, with data: T) -> Single<U> {
        
        return Single.create { (subscriber) -> Disposable in
            
            self.base.emitWithAck(event, data).timingOut(after: 1) { (data: [Any]) in
                
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
    
}