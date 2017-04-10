//
//  ViewController.swift
//  FunChat
//
//  Created by Kemuel Clyde Belderol on 07/04/2017.
//  Copyright © 2017 Burst. All rights reserved.
//

import UIKit
import FirebaseDatabase

class ViewController: UIViewController {
    
    @IBOutlet weak var chatTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    
    
    var ref: FIRDatabaseReference!
    var chatId : Int = 00001
    var messages : [Message] = []
    var currentUser : String? = "admin"
    let cellSpacingHeight : CGFloat = 5
    
   // var lastID : Int = 0
    
  
    @IBAction func buttonSendMessage(_ sender: Any) {
        
        if let chatText = chatTextField.text {
            print("id : \(chatId)")
            chatId = chatId + 1
            
            let post : [String : Any] = ["chatText": chatText]
            ref.child("messages").child("\(chatId)").updateChildValues(post)
        } else {
            print("Error updating chat")
        }
        
        
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        ref = FIRDatabase.database().reference()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        tableView.backgroundColor = .lightGray
     
        
        

        listenToFireBase()
      
    }
    
    func addMessageToArray(anId : Any, chatInfo : NSDictionary) {
        if let chatText = chatInfo["chatText"] as? String,
            let messageId = anId as? String{
            let currentChatId = Int(messageId)
            
            let newMessage = Message(anId: currentChatId!, chatText: chatText)
            self.messages.append(newMessage)
        }
    }
    
    
    func listenToFireBase() {
        ref.child("messages").observe(.childAdded, with: { (snapshot) in
            print("Added", snapshot)
            
            guard let info = snapshot.value as? NSDictionary
                else{return}
            
            self.addMessageToArray(anId: snapshot.key, chatInfo: info)
            self.messages.sort(by: { (chat1,chat2) -> Bool in
                return chat1.id > chat2.id
            })
            
            if let lastMessage = self.messages.first {
                self.chatId = lastMessage.id
            }
            
            let indexPath = IndexPath(item: self.messages.count - 1, section: 0)
            self.tableView.insertRows(at: [indexPath], with: .right)
            
            self.tableView.reloadData()

            
        })
        
        
        ref.child("messages").observe(.childChanged, with: { (snapshot) in
            print("Changed :", snapshot)
            
            guard let info = snapshot.value as? NSDictionary,
            let chatId = Int(snapshot.key)
                else {return}
            
            guard let chatText = info["chatText"] as? String
                else {return}
            
            
            if let matchIndex = self.messages.index(where: { (chat) -> Bool in
                return chat.id == chatId
                
            }) {
                let changedMessage = self.messages[matchIndex]
                changedMessage.chatText = chatText
                let indexPath = IndexPath(row: matchIndex, section: 0)
                self.tableView.reloadRows(at: [indexPath], with: .fade)
            }
            
            
        })
        
        ref.child("messages").observe(.childMoved, with: { (snapshot) in
            print("Moved", snapshot)
            
            
        })
        
        
        ref.child("messages").observe(.childRemoved, with: { (snapshot) in
         print("Removed", snapshot)
            
            guard let deletedId = Int(snapshot.key)
                else {return}
            if let deletedIndex = self.messages.index(where: { (msg) -> Bool in
                return msg.id == deletedId
            }) {
                self.messages.remove(at: deletedIndex)
                let indexPath = IndexPath(row: deletedIndex, section: 0)
                self.tableView.deleteRows(at: [indexPath], with: .right)
                
            }
            
            
            
        })
        
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

    
}


extension ViewController :UITableViewDataSource,UITableViewDelegate {
    
//    
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return messages.count
//    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return cellSpacingHeight
//    }
//    
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let headerView = UIView()
//        headerView.backgroundColor = UIColor.clear
//        return headerView
//    }
//    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "chatCell") as? MessageTableViewCell
            else {return UITableViewCell()}
        let currentMessage = messages[indexPath.row]
        
        cell.chatLabel.text = currentMessage.chatText
        cell.backgroundColor = .clear
        cell.contentView.backgroundColor = .clear
        cell.containerView.backgroundColor = .white
        cell.containerView.layer.cornerRadius = 8.0
        cell.containerView.layer.masksToBounds = true
        
        
//        cell.layer.borderColor = UIColor.black.cgColor
//        cell.layer.borderWidth = 1
//        cell.layer.cornerRadius = 8
//        cell.clipsToBounds = true
        print("Chat ID: ", currentMessage.id)
        
        return cell
    
    }
}



