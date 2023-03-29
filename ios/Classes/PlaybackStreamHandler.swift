//
//  PlaybackStream.swift
//  flmusickit
//
//  Created by Mohamed Charaabi on 28/3/2023.
//

import Foundation
import MediaPlayer
import Flutter



class PlaybackStreamHandler :  NSObject,  FlutterStreamHandler{
    var player: MPMusicPlayerController
    var currentPlayerState: MPMusicPlaybackState?

    init(player: MPMusicPlayerController) {
        self.player = player
    }
        
        var eventSink: FlutterEventSink?
        
        func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
            eventSink = events
            print("[flmusickit] listennig to Playback events.....")
            
            
            
            
            player.beginGeneratingPlaybackNotifications()
            // player state changed event
            NotificationCenter.default.addObserver(forName: .MPMusicPlayerControllerPlaybackStateDidChange, object: player, queue: nil) { notification in
                         self.handlePlaybackStateChange(player: self.player, item: self.player.playbackState)
                     }
            
            return nil
        }
        
        func onCancel(withArguments arguments: Any?) -> FlutterError? {
            eventSink = nil
            return nil
        }
        
        func sendEvent(event: String, data: Any?){
            if let sink = eventSink {
                sink([event, data])
            }
        }
    
    
    func handlePlaybackStateChange(player: MPMusicPlayerController, item: MPMusicPlaybackState?) {
                    if let playbackState = item  {
                        
                        if(item == self.currentPlayerState){
                            return
                        }
                        
                        print("[flmusickit] change: Playback state changed : \(playbackState)")
                        self.currentPlayerState = item
                        
                        let eventData = EventModel.init(type: EventType.playerState, data:  playbackState.self.rawValue)

                        self.eventSink?(eventData.toJson())
                        
                    } else {
                        print("[flmusickit] No song is currently playing.")
                    }
    }
}
