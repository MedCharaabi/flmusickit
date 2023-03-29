import Flutter
import UIKit
import MusicKit
import StoreKit
import MediaPlayer


@available(iOS 13.0.0, *)
public class FlmusickitPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
    
    private var eventSink: FlutterEventSink?
    let player = MPMusicPlayerController.applicationQueuePlayer
    
    var currentSong: MPMediaItem?
    var currentPlayerState: MPMusicPlaybackState?
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        print("[flmusickit] listennig to Song events.....")
    




        player.beginGeneratingPlaybackNotifications()
        
        // current song changed event
        NotificationCenter.default.addObserver(forName: .MPMusicPlayerControllerNowPlayingItemDidChange, object: player, queue: nil) { notification in
            self.handlePlayerItemChange(player: self.player, item: self.player.nowPlayingItem)
        }
//        player.beginGeneratingPlaybackNotifications()
//        // player state changed event
//        NotificationCenter.default.addObserver(forName: .MPMusicPlayerControllerPlaybackStateDidChange, object: player, queue: nil) { notification in
//                     self.handlePlaybackStateChange(player: self.player, item: self.player.playbackState)
//                 }
        
        
       return nil

    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        NotificationCenter.default.removeObserver(self)
           eventSink = nil
           return nil
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

    
  
    func handlePlayerItemChange(player: MPMusicPlayerController, item: MPMediaItem?) {
                    if let currentItem = item  {
                        if(currentItem == self.currentSong){
                            return
                        }
                        
                        self.currentSong = currentItem
                     
                        print("[flmusickit] change: Current song changed : \(String(describing: currentItem.title))")
                        
                        var resultSong = [String : Any?]()
                        resultSong["id"] = currentItem.persistentID
                        resultSong["title"] = currentItem.title
                        resultSong["artist"] = currentItem.artist
                        resultSong["album"] = currentItem.albumTitle
                        resultSong["duration"] = currentItem.playbackDuration
                        
                        if let image = currentItem.artwork?.image(at: CGSize(width: 300, height: 300)) {
                                let imageData = image.pngData()
                                let base64String = imageData?.base64EncodedString(options: .endLineWithLineFeed)
                                
                                resultSong["albumArt"] = base64String
                                    
                            }else{
                                resultSong["albumArt"] = nil
                            }
            
                        print("[flmusickit] sending result...")
                        
                        let eventData = EventModel.init(type: EventType.nowPlaying, data:  resultSong)
                        
//                        let playerStateEventData = EventModel.init(type: EventType.playerState, data:  player.playbackState.self.rawValue)

                        self.eventSink?(eventData.toJson())
//                        self.eventSink?(playerStateEventData.toJson())
                        
                    } else {
                        print("[flmusickit] No song is currently playing.")
                    }
                }
    
    
  
  
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flmusickit", binaryMessenger: registrar.messenger())
        let songEventChannel = FlutterEventChannel(name: "flmusickit/song", binaryMessenger: registrar.messenger())
        let playBackEventChannel = FlutterEventChannel(name: "flmusickit/playback", binaryMessenger: registrar.messenger())
        let instance = FlmusickitPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        songEventChannel.setStreamHandler(instance)
        let playBackStream  = PlaybackStreamHandler(player: instance.player)
        playBackEventChannel.setStreamHandler(playBackStream)
        
        
    }
    
    
    
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult)  {
        //        await result("iOS " + UIDevice.current.systemVersion)
        
        if #unavailable(iOS 15.0) {
            result("this Flmusickit plugin requires minumum ios 15")
            return
        }
        if #available(iOS 15.0, *){
            
            switch call.method {
            case "getPlatformVersion":
                result("macOS " + ProcessInfo.processInfo.operatingSystemVersionString)
                
                
            case "status":
                if #available(macOS 12.0, *) {
                    
                    
                    let status : String =   MusicAuthorization.currentStatus.rawValue
                    result(status )
                    
                    
                    
                } else {
                    
                    result(MusicAuthorization.Status.notDetermined.rawValue)
                };
                
                
            case "connectToAppleMusic":
                
                
                let status  =  MusicAuthorization.currentStatus.self
                
                Task{
                    let newStatus =  await AuthenticationService().authenticate(initialStatus: status);
                    result(newStatus.rawValue)
                    
                }
                
                
                
            case "getPlaylists":
                // get apple music playlists
                
                let cloudServiceController = SKCloudServiceController()
                
                cloudServiceController.requestCapabilities { capabilities, error in
                    if capabilities.contains(.musicCatalogPlayback) {
                        // The user has granted permission to your app to access their music library.
                        // You can now make requests to the Music Catalog API.
                        print("[flmusickit] The user has granted permission to your app to access their music library.")
                        
                        // get playlists
                        
                        MPMediaLibrary.requestAuthorization { (status: MPMediaLibraryAuthorizationStatus) in
                            if status == .authorized {
                                let query = MPMediaQuery.playlists()
                                let lists =  query.collections
                                
                                print("[flmusickit] playlists count \(String(describing: lists?.count))")
                                
                                var playlists =  [[String: String]]()
                                
                                if(lists != nil && lists?.isEmpty == false ){
                                    for pl in lists!{
                                        let playlistName =  pl.value(forProperty: MPMediaPlaylistPropertyName) ?? "Unknown"
                                        
                                        let playlistId = pl.value(forProperty: MPMediaPlaylistPropertyPersistentID) ?? "Unknown"
                                        
                                        playlists.append(["name": playlistName as! String, "id": "\(playlistId)"])
                                        
                                        
                                    }
                                }
                                
                                
                                
                                result (playlists)
                                
                                
                            } else {
                                print ("[flmusickit] User hasn't authorized access to their media library"
                                )
                            }
                            
                        }
                        
                        
                        
                    } else {
                        // The user has not granted permission to your app to access their music library.
                        // You should not make requests to the Music Catalog API.
                        print("[flmusickit] The user has not granted permission to your app to access their music library.")
                    }
                    
                }
                
                
                
                
                
            case "playPlaylist":
                
                let args = call.arguments as! [String: Any]
                let playlistId = args["playlistId"] as! String
                
                print ("[flmusickit] playPlaylist \(playlistId)")
                let mediaLibrary = MPMediaLibrary()
                
                //                fetch playlist
                let playlistPredicate = MPMediaPropertyPredicate(value: playlistId, forProperty: MPMediaPlaylistPropertyName)
                let playlistQuery = MPMediaQuery()
                playlistQuery.addFilterPredicate(playlistPredicate)
                
                
                
                let playlist = playlistQuery.collections ?? []
                
                
                if( playlist.isEmpty == false){
                    
                    
                    print("[flmusickit] \(playlist)")
                    
                    var allSongs: [MPMediaItem] = []
                      for pp in playlist {
                          allSongs.append(contentsOf: pp.items)
                      }
                    
                    
                    
                    let playlistItemCollection = MPMediaItemCollection(items: allSongs)
                    
                    

                    

                    player.setQueue(with: playlistItemCollection)
                    
                    player.repeatMode = .all
           
                    player.play()
                    
                    
                }else{
                    print("[flmusickit] No playlists")
                }
                
                
            
            case "pause":
                player.pause()
                result(true)

            case "play":
                player.play()
                result(true)

            case "stop":
                player.stop()
                result(true)

            case "next":
                print("[flmusickit] next song")
                player.skipToNextItem()
                result(true)
            
            case "previous":
                print("[flmusickit] next song")

                player.skipToPreviousItem()
                result(true)
            
            
                
            case "currentSong":
                let song = player.nowPlayingItem
                print("[flmusickit] current song \(String(describing: song))")

                if( song == nil){
                    result(nil)
                    return
                }
                var resultSong = [String : Any?]()
                
                resultSong["id"] = song?.persistentID
                resultSong["title"] = song?.title
                resultSong["artist"] = song?.artist
                resultSong["album"] = song?.albumTitle
                
                if let artwork = song?.artwork {
                    if let image = artwork.image(at: CGSize(width: 300, height: 300)) {
                        let imageData = image.pngData()
                        let base64String = imageData?.base64EncodedString(options: .endLineWithLineFeed)
                        
                        resultSong["albumArt"] = base64String
                            
                    }else{
                        resultSong["albumArt"] = nil
                    }
                }
                else{
                    resultSong["albumArt"] = nil
                }
                

                resultSong["duration"] = song?.playbackDuration


                result(resultSong)

            case "currentSongStream":

                result(true)                

                
            case "playerState":
                player.didChangeValue(forKey:
                                                    player.nowPlayingItem?.title ??
                "No song playing")


                
                let state: Int = player.playbackState.self.rawValue
                
                
                
                print("[flmusickit] player state \(state)")
                result(state)

            
            case "changeVolume":
                let args = call.arguments as! [String: Any]
                let volume = args["volume"] as! Float
                
                print ("[flmusickit] changeVolume \(volume)")
                
                result(true)


            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }
    
    
}
