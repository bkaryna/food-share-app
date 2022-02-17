//
//  UserConversations.swift
//  food-share
//
//  Created by Karen on 17/02/2022.
//

import Foundation
import Firebase
import FirebaseAuth
import MessageKit

class UserConversations {
    public var conversationsList = [String:String]()
    public var messages: Array<MessageType> = Array()
    
    init() {
        fetchCurrentUsersConversationsList()
    }
    init(withUser: String) {
        fetchCurrentUsersConversationsList()
        fetchMessagesForConversation(withUser: withUser)
    }
    
    public func fetchCurrentUsersConversationsList() {
        let db = Firestore.firestore()
        let userID: String = Auth.auth().currentUser!.uid
        
        db.collection("Messages").whereField("Users", arrayContains: userID).addSnapshotListener { querySnapshot, error in
            guard (querySnapshot?.documents) != nil else {
                print("Error fetching documents: \(error!)")
                return
            }
            
            DispatchQueue.global().async {
                db.collection("Messages").whereField("Users", arrayContains: userID).getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print("Error getting documents: \(err)")
                    } else {
                        for document in querySnapshot!.documents {
                            let users = document.get("Users") as! [String]
                            var otherUser: String
                            if (users[0] != userID) {
                                otherUser = users[0]
                            } else {
                                otherUser = users[1]
                            }
                            
                            self.conversationsList[otherUser] = document.documentID
                        }
                    }
                }
            }
        }
    }
    
    public func fetchMessagesForConversation(withUser: String) {
        let db = Firestore.firestore()
        
        DispatchQueue.global().async{
            if (self.conversationsList[withUser] != nil) {
                db.collection("Messages").document(self.conversationsList[withUser]!).collection("ConversationHistory").order(by: "SentDate", descending: false)
                .addSnapshotListener { querySnapshot, error in
                    guard let documents = querySnapshot?.documents else {
                        print("Error fetching documents: \(error!)")
                        return
                    }
                    self.messages = documents.map { queryDocumentSnapshot -> Message in
                        let data = queryDocumentSnapshot.data()
                        let _content = data["Content"] as? String ?? ""
                        let _senderDisplayName = data["SenderDisplayName"] as? String ?? "Unknown User"
                        let _senderID = data["SenderID"] as? String ?? ""
                        let sentDateTimestamp = data["SentDate"] as? Timestamp ?? nil
                        let _sentDate = sentDateTimestamp!.dateValue()
                        let _messageID = queryDocumentSnapshot.documentID
                        
                        return Message(sender: Sender(senderId: _senderID, displayName: _senderDisplayName), messageID: _messageID, sentDate: _sentDate, content: _content)
                    }
                }}
            
        }
    }
    
    public func getUserConversationsList() -> [String:String] {
        return self.conversationsList
    }
}
