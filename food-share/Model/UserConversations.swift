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
import Lottie

class UserConversations {
    public var conversationsList: Dictionary<String, String>
    public var messages: Array<MessageType>
    
    init() {
        self.conversationsList = Dictionary()
        self.messages = Array()
        fetchCurrentUsersConversationsList()
    }
    init(withUser: String) {
        self.conversationsList = Dictionary()
        self.messages = Array()
        fetchCurrentUsersConversationsList()
        fetchMessagesForConversation(withUser: withUser)
    }
    
    public func fetchCurrentUsersConversationsList() {
        let db = Firestore.firestore()
        let userID: String = Auth.auth().currentUser?.uid ?? ""
        
        DispatchQueue.global().async {
            db.collection("Messages").whereField("Users", arrayContains: userID).addSnapshotListener { querySnapshot, error in
                guard (querySnapshot?.documents) != nil else {
                    print("Error fetching documents: \(error!)")
                    return
                }
                
                print("Printing all fetched documents for user \(userID):")
                print(querySnapshot!.documents)
                
                
                for document in querySnapshot!.documents {
                    let users = document.get("Users") as! [String]
                    if (users.contains(userID)){
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
