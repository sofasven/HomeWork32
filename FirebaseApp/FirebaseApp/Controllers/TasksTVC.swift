//
//  TasksTVC.swift
//  FirebaseApp
//
//  Created by Sofa on 13.11.23.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage

class TasksTVC: UITableViewController {
    
    private var user: User?
    private var tasks = [Task]()
    var ref: DatabaseReference!

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let currentUser = Auth.auth().currentUser else { return }
        user = User(user: currentUser)
        ref = Database.database().reference(withPath: "users").child(user?.uid ?? "").child("tasks")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ref.observe(.value) { [weak self] snapshot in
            var tasks = [Task]()
            for item in snapshot.children {
                guard let snapshot = item as? DataSnapshot,
                      let task = Task(snapshot: snapshot) else { return }
                tasks.append(task)
            }
            self?.tasks = tasks
            self?.tableView.reloadData()
        }
    }
    
    @IBAction func addNewTaskAction(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "New task", message: "Enter task title", preferredStyle: .alert)
        alert.addTextField()
        let save = UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard let textField = alert.textFields?.first,
                  let text = textField.text,
                  let user = self?.user else { return }
            let uid = user.uid
            let task = Task(title: text, userId: uid)
            let taskRef = self?.ref.child(task.title.lowercased())
            taskRef?.setValue(task.convertToDictionary())
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(save)
        alert.addAction(cancel)
        present(alert, animated: true)
    }
    
    @IBAction func addNewImage(_ sender: UIBarButtonItem) {
        let storageRef = Storage.storage().reference()
        let imageKey = NSUUID().uuidString
        let imageRef = storageRef.child(imageKey)
        guard let imageData = #imageLiteral(resourceName: "image.jpeg").pngData() else { return }
        let uploadTask = imageRef.putData(imageData) { storageMetadata, error in
            print("\nstorageMetadata:\n\(storageMetadata)\n")
            print("\nerror:\n\(error)\n")
            
            let downloadTask = imageRef.getData(maxSize: 999999999999999) { data, error in
                if let data = data {
                    print("\n data: \n\(data)\n")
                    let image = UIImage(data: data)
                    print(image)
                } else {
                    print("\n error:\n\(error)\n")
                }
            }
        }
    }
    
    
    @IBAction func signOutAction(_ sender: UIBarButtonItem) {
        do {
            try Auth.auth().signOut()
        } catch {
            print(error)
        }
        navigationController?.popToRootViewController(animated: true)
    }
    
    
    
    private func toggleComplition(cell: UITableViewCell, isCompleted: Bool) {
        cell.accessoryType = isCompleted ? .checkmark : .none
    }
    
    // MARK: - Table view data source


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tasks.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let currentTask = tasks[indexPath.row]
        cell.textLabel?.text = currentTask.title
        toggleComplition(cell: cell, isCompleted: currentTask.isCompleted)
        return cell
    }
    
    // MARK: - Table view delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let _ = tableView.cellForRow(at: indexPath)  else { return }
        let task = tasks[indexPath.row]
        let isCompleted = !task.isCompleted
        task.ref.updateChildValues(["isCompleted" : isCompleted])
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool { true }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            guard editingStyle == .delete else { return }
            let task = tasks[indexPath.row]
            task.ref.removeValue()
        }

}
