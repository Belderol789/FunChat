//
//  Student.swift
//  FireBaseTest
//
//  Created by mahmoud khudairi on 4/6/17.
//  Copyright © 2017 mahmoud khudairi. All rights reserved.
//

import Foundation
class Message {
    var id : Int
    var chatText : String


    init() {
        id = 0
        chatText = ""
   
    }
    init(anId :Int , chatText : String) {
        self.id = anId
        self.chatText = chatText
 
    
    }
}
