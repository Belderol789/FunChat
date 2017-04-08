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
    var chatId : Int! = 0
    var messages : [Message] = []
    var lastID : Int = 00001
    
  
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
  
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        ref = FIRDatabase.database().reference()
        listenToFireBase()
      
    }
    
    func addMessageToArray(id : Any, chatInfo : NSDictionary) {
        if let chatText = chatInfo["chatText"] as? String,
            let id = id as? String{
            let currentChatId = Int(id)
            
            let newMessage = Message(id: currentChatId!, chatText: chatText)
            self.messages.append(newMessage)
        }
    }
    
    
    func listenToFireBase() {
        ref.child("messages").observe(.childAdded, with: { (snapshot) in
            print("Added", snapshot)
            
            guard let info = snapshot.value as? NSDictionary
                else{return}
            
            self.addMessageToArray(id: snapshot.key, chatInfo: info)
            self.messages.sort(by: { (chat1,chat2) -> Bool in
                return chat1.id < chat2.id
            })
            
            if let lastMessage = self.messages.last {
                self.lastID = lastMessage.id
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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "chatCell") as? MessageTableViewCell
            else {return UITableViewCell()}
        let currentMessage = messages[indexPath.row]
        
        cell.chatLabel.text = currentMessage.chatText
        print("Chat ID: ", currentMessage.id)
        
        return cell
    
    }
}



