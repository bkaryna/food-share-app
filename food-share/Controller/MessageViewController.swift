//
//  MessageViewController.swift
//  food-share
//
//  Created by Karen on 17/02/2022.
//

import UIKit
import MessageKit
import FirebaseAuth
import InputBarAccessoryView
import Firebase
import simd

class MessageViewController: MessagesViewController, InputBarAccessoryViewDelegate, MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    
    let userID = Auth.auth().currentUser!.uid
    let currentUser = Sender(senderId: Auth.auth().currentUser!.uid, displayName: Auth.auth().currentUser!.displayName ?? "Me")
    var otherUser: Sender = Sender(senderId: "", displayName: "")
    let db = Firestore.firestore()
    
    var userConversations = UserConversations()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        userConversations = UserConversations(withUser: self.currentUser.senderId)
//        userConversations.conversationsList["oCtxU80PjVM4BFA8bh9guXDeubz2"] = "V8LpJWRnhj6VJHiJYHEl"
        
        DispatchQueue.main.async {
            self.userConversations.fetchCurrentUsersConversationsList()
            print("Printing user conversations: \(self.userConversations.conversationsList)")
            self.userConversations.fetchMessagesForConversation(withUser: self.otherUser.senderId)
        }
        print("Printing user messages: \(userConversations.messages)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        maintainPositionOnKeyboardFrameChanged = true
        scrollsToLastItemOnKeyboardBeginsEditing = true
        
//        userConversations.fetchCurrentUsersConversationsList()
        
        messageInputBar.inputTextView.tintColor = UIColor(named: "AccentColor")
        messageInputBar.sendButton.setTitleColor(.systemTeal, for: .normal)
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
        
        print("view loaded with sender: \(otherUser)")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.messagesCollectionView.reloadData()
        }
        
    }
    
    func currentSender() -> SenderType {
        return Sender(senderId: Auth.auth().currentUser!.uid, displayName: Auth.auth().currentUser!.displayName ?? "Me")
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return userConversations.messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return userConversations.messages.count
    }
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? (UIColor(named: "AccentColor")as! UIColor) : .gray
    }
    
    private func insertNewMessage(_ message: Message) {//add the message to the messages array and reload it
        userConversations.messages.append(message)
        messagesCollectionView.reloadData()
        DispatchQueue.main.async {self.messagesCollectionView.scrollToLastItem(at: .bottom, animated: true)
        }
    }
    
    private func save(_ message: Message) {//Preparing the data as per our firestore collection
            let data: [String: Any] = ["Content": message.content,"SentDate": message.sentDate, "SenderID": message.sender.senderId, "SenderDisplayName": message.sender.displayName]
            
            //Writing it to the thread using the saved document reference we saved in load chat function
            
            var docReference: DocumentReference? = nil

            docReference = db.collection("Messages").document(userConversations.conversationsList[otherUser.senderId]!).collection("ConversationHistory").addDocument(data: data) {
                err in
                if let err = err {
                        print("Error adding document: \(err)")
                    } else {
                        print("Document added with ID: \(docReference!.documentID)")
                    }

            }
            self.messagesCollectionView.scrollToLastItem(at: .bottom, animated: true)
    }
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        //When use press send button this method is called.
        print("----Send button--")

        
        let message = Message(sender: currentUser, messageID: UUID().uuidString, sentDate: Date(), content: text)
    //calling function to insert and save message
        
        
        let components = inputBar.inputTextView.components
        messageInputBar.inputTextView.text = String()
        messageInputBar.invalidatePlugins()
 
        // Send button activity animation
        messageInputBar.sendButton.startAnimating()
        messageInputBar.inputTextView.placeholder = "Sending..."
//        DispatchQueue.global().async {
            // fake send request task
            self.insertNewMessage(message)
            self.save(message)
            
            
            self.messageInputBar.sendButton.stopAnimating()
            self.messageInputBar.inputTextView.placeholder = "Aa"
  
            //self.messagesCollectionView.scrollToBottom(animated: true)
            self.messagesCollectionView.reloadData()
//        }
    }
}
