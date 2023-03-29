//
//  Authentication_service.swift
//  flmusickit
//
//  Created by Mohamed Charaabi on 1/2/2023.
//

import Foundation
import MusicKit


class AuthenticationService{
    
    
    
    
    
    @available(iOS 15.0, *)
    func authenticate( initialStatus: MusicAuthorization.Status) async -> MusicAuthorization.Status {
        var status = initialStatus
        if #available(macOS 12.0, *) {
            
            switch initialStatus {
            case .notDetermined :
                  let authStatus =  Task {
                        let musicAuthorizationRequestStatus = await MusicAuthorization.request()
                        return musicAuthorizationRequestStatus
                    }
                status = await authStatus.value 
                default:
                break;
            }
        }else{
            status = MusicAuthorization.Status.restricted
        }
        return status
    }

}
