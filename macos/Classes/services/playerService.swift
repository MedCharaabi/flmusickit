//
//  player.swift
//  flmusickit
//
//  Created by Mohamed Charaabi on 1/2/2023.
//

import Foundation
import MusicKit



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
           await pause()
        
        case .stop: break
            await stop()
            
        case .play_next:
           await next()
        case .play_prev:
         await   previous()
        default:
        }
        
 
        
        
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    func play( ) async {
        Task{
         try   await player.play()
        }
        
    }
    
    func pause( ) {
        
        player.pause()
        
        
    }
    
    func stop(){
        if(player.state == MusicPlayer.State.running){
            player.stop()
        }
        
    }
    
    func next( ) async{
        Task{
            do{
                try  await  player.skipToNextEntry()
                
            }catch{
                
            }
        }
        
    }
    
    func previous( ) async{
        Task{
            try  await    player.skipToPreviousEntry()
        }
        
    }
    
    
}
