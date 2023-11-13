//
//  ViewController.swift
//  Neobis_iOS_ToDoAppj
//
//  Created by Interlink on 10/11/23.
//

import UIKit
class Task {
    var name: String
    var description: String
    var isComplete: Bool // Add this property
    
    init(name: String, description: String) {
        self.name = name
        self.description = description
        self.isComplete = false
    }
}


protocol TaskDelegate: AnyObject {
    func createTask(name: String, description: String)
    func updateTask(at indexPath: IndexPath, task: Task)
    func deleteTask(at indexPath: IndexPath)
}
class MainViewController: UIViewController, UIAdaptivePresentationControllerDelegate {
    
    @IBOutlet weak var tableView:UITableView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var editorButton: UIButton!
    // @IBOutlet weak var titleText: UILabel!
    
    var tasks: [Task] = []
    
    
    weak var delegate: TaskDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        // Add an observer for the "TasksUpdated" notification
        NotificationCenter.default.addObserver(self, selector: #selector(tasksUpdated), name: NSNotification.Name("TasksUpdated"), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        tableView.reloadData()
    }
    deinit {
        // Remove the observer to prevent memory leaks
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("TasksUpdated"), object: nil)
    }
    
    @objc func tasksUpdated(_ notification: Notification) {
        // Reload the table view when tasks are updated
        if let payload = notification.object as? Payload {
            createTask(name: payload.name, description: payload.description)
        }
        tableView.reloadData()
        print("array", tasks)
        print("tasksreallyupdated")
    }
    
    
    @IBAction func addButtonTapped(_ sender: UIButton) {
        addButton.isHidden = true
        //    editorButton.setTitle("x", for: .normal)
        
        let editorVC = storyboard?.instantiateViewController(withIdentifier: "EditorViewController") as! EditorViewController
        editorVC.delegate = self
        editorVC.mode = .create
        present(editorVC, animated: true, completion: nil)
    }
    
    @IBAction func editorButtonTapped(_ sender: UIButton) {
        addButton.isHidden = false
        //   editorButton.setTitle("редактор", for: .normal)
    }
    @IBSegueAction func editorViewController(_ coder: NSCoder) -> EditorViewController? {
        let vc = EditorViewController(coder: coder)
        
        if let indexPath = tableView.indexPathForSelectedRow {
            let task = tasks[indexPath.row]
            vc?.task = task
            vc?.indexPath = indexPath
        }
        
        vc?.delegate = self
        vc?.presentationController?.delegate = self
        
        return vc
    }
    
    
    //метод для удаления задачи
    
    
}

extension MainViewController: TaskDelegate {
func createTask(name: String, description: String) {
    tasks.append(Task(name: name, description: description))
    print("Tasks", tasks)
    tableView.reloadData()
}

func updateTask(at indexPath: IndexPath, task: Task) {
    tasks[indexPath.row] = task
    tableView.reloadRows(at: [indexPath], with: .automatic)
}

func deleteTask(at indexPath: IndexPath) {
    tasks.remove(at: indexPath.row)
    tableView.deleteRows(at: [indexPath], with: .automatic)
}
}



extension MainViewController: UITableViewDelegate, UITableViewDataSource {
func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return tasks.count
}

func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "checked cell", for: indexPath) as! CheckTableViewCell
        let task = tasks[indexPath.row]
        cell.set(title: task.name, checked: task.isComplete)
        cell.delegate = self // Set the delegate if needed
        return cell
}


func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let task = tasks[indexPath.row]
    let editorVC = storyboard?.instantiateViewController(withIdentifier: "EditorViewController") as! EditorViewController
    editorVC.task = task
    editorVC.delegate = self
    editorVC.indexPath = indexPath
    present(editorVC, animated: true, completion: nil)
}

func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return UITableView.automaticDimension
}

func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
    return 120
}

func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
    // Логика обработки нажатия на кнопку деталей
}

func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
        deleteTask(at: indexPath)
    }
}

func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
    let movedTask = tasks.remove(at: sourceIndexPath.row)
    tasks.insert(movedTask, at: destinationIndexPath.row)
}

// обработка свайпа для удаления задачи
func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (_, _, completionHandler) in
        self.deleteTask(at: indexPath)
        completionHandler(true)
    }
    deleteAction.backgroundColor = .red

    return UISwipeActionsConfiguration(actions: [deleteAction])
}
}

extension MainViewController: CheckTableViewCellDelegate {
    func checkTableViewCell(_ cell: CheckTableViewCell, didChangeCheckedState checked: Bool) {
    guard let indexPath = tableView.indexPath(for: cell) else {
        return
    }
    
    let updatedTask = tasks[indexPath.row]
    updatedTask.isComplete = checked
    
    // Update the model data
    tasks[indexPath.row] = updatedTask
}
}

