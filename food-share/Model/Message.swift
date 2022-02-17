//
//  Message.swift
//  food-share
//
//  Created by Karen on 17/02/2022.
//

import Foundation
import MessageKit

struct Message: MessageType {
    var sender: SenderType
    
    var messageId: String
    
    var sentDate: Date
    
    var kind: MessageKind
    var content: String
    
    init(sender: SenderType, messageID: String, sentDate: Date, content: String) {
        self.sender = sender
        self.messageId = messageID
        self.sentDate = sentDate
        self.kind = .text(content)
        self.content = content
    }
}
