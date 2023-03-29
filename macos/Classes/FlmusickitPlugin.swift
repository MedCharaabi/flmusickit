import Cocoa
import FlutterMacOS
import MusicKit

public class FlmusickitPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flmusickit", binaryMessenger: registrar.messenger)
        let instance = FlmusickitPlugin()
        
        
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
 
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult)   {
        
        
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
            
            if #available(macOS 12.0, *) {
                let status  =  MusicAuthorization.currentStatus.self;
                
                Task{
                    let newStatus =  await AuthenticationService().authenticate(initialStatus: status);
                    result(newStatus.rawValue)
                    
                }
                
                
                
                
                
                
            } else {
                // Fallback on earlier versions
                result(MusicAuthorization.Status.restricted.rawValue)
            };
            
            
            
        case "getPlaylists":
            
            
            Task{
                
            }
            
            
        case "playback_control":

            let args = call.arguments as! [String: Any]
//            let action = args["action"] as! String
           
            guard  let action   = args["action"] as? String,  let enumAction = PlayerAction(rawValue: action) else {
                               return
                           }
            
            
            PlayerService.getInstance().playerControl(action:enumAction )
            
            
            

            
            
            
            
            
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }


}
