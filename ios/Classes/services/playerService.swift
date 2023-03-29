//
//  player.swift
//  flmusickit
//
//  Created by Mohamed Charaabi on 1/2/2023.
//

import Foundation
import MusicKit



@available(iOS 15.0, *)
class PlayerService{
    
    let  player =  MusicPlayer.self
    
    static private var instance : PlayerService?
    
    
   static func getInstance() -> PlayerService{
        if(instance == nil){
            instance = PlayerService()
        }
        
        return instance!
    }
    
   
    
    
    
    func playerControl(action: PlayerAction) async {
        
        switch (action){
            
        case .play:
           await play()
            
        case .pause:
            pause()
        
        case .stop:
             stop()
            
            
        case .play_next:
           await next()
        case .play_prev:
         await   previous()
        default:
            break;
        }
        
 
        
        
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    func play( ) async {
        Task{
            player.play
        }
        
    }
    
    func pause( ) {
        Task{
            player.pause
        }
        
        
        
    }
    
    func stop(){
        //        if(player.State == MusicPlayer.State){
        Task{
            player.stop
        }
        
        //    }
        
    }
    
    func next( ) async{
        Task{
                player.skipToNextEntry
            
        }
        
    }
    
    func previous( ) async{
        Task{
            player.skipToPreviousEntry
        }
        
    }
    
    
}
