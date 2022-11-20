//
//  ChatListViewController.swift
//  food-share
//
//  Created by Karen on 16/02/2022.
//

import Foundation
import UIKit
import Firebase
import FirebaseAuth

class MessageListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var messageListTable: UITableView!
    var userConversations = UserConversations()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messageListTable.register(UITableViewCell.self, forCellReuseIdentifier: "chatListCell")
        messageListTable.delegate = self
        messageListTable.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userConversations.conversationsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "chatListCell", for: indexPath)
        let test = Array(userConversations.conversationsList)[indexPath.row].key
        
        cell.textLabel?.text = "Tony" //name of the conversation
        cell.accessoryType = .disclosureIndicator //indicates that the element is tappable
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        //Show chat messages
        let vc = MessageViewController()
    
        let test = Array(userConversations.conversationsList)[indexPath.row].key
      
        print("-----test-----\n\(test)")
        vc.otherUser = Sender(senderId: test, displayName: getUserDisplayName(userID: test))
//        vc.title = getUserDisplayName(userID: test)
        vc.title = "Tony"
        
       
        print("-----test-----\n\(vc.otherUser)")
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
}
