//
//  EventModel.swift
//  flmusickit
//
//  Created by Mohamed Charaabi on 28/3/2023.
//

import Foundation


class EventModel{
var type: EventType
var data: Any
    
    init(type: EventType, data: Any) {
        self.type = type
        self.data = data
    }
    
    
    func toJson ( ) ->[String : Any?] {
        print("*********************************")
        var result = [String : Any?]()
        result["data"] = data
        result["type"] = type.self.rawValue

        
        return result
        
    }
    
    
}
