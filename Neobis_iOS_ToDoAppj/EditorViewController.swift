//
//  EditorViewController.swift
//  Neobis_iOS_ToDoAppj
//
//  Created by Interlink on 10/11/23.
//
import UIKit

struct Payload {
    var name: String
    var description: String
}

class EditorViewController: UIViewController {
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextView!
   @IBOutlet weak var buttonSave: UIButton!
   @IBOutlet weak var buttonCancel: UIButton!
    
    var task: Task?
    var indexPath: IndexPath?
    weak var delegate: TaskDelegate?
    enum EditorMode {
            case create, edit
        }
    var mode: EditorMode = .create
    override func viewDidLoad() {
        super.viewDidLoad()
      
        
    setupUI()
    }
    
   
        
    func setupUI() {
        print("setup")
        if let task = task {
            // Editing an existing task
            print("qwe")
            nameTextField.text = task.name
            descriptionTextField.text = task.description
        } else {
            // Creating a new task
            nameTextField.text = ""
            descriptionTextField.text = ""
        }

        // Add button targets
        buttonSave.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        buttonCancel.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
    }
    
    @IBAction  func saveButtonTapped() {
        print("saveButtonTapped")
        guard let name = nameTextField.text, let description = descriptionTextField.text else {
                return
            }

            let newTask = Task(name: name, description: description)

            if let _ = task, let indexPath = indexPath {
                print("Updated")
                // Update existing task
                delegate?.updateTask(at: indexPath, task: newTask)
            } else {
                print("Created")
                // Create a new task
                delegate?.createTask(name: name, description: description)
            }
            
            // Save the task to UserDefaults
            saveTaskToUserDefaults(task: newTask)
        print("Newtask", newTask.name, newTask.description)
            
            // Trigger synchronization
            let payload = Payload(name: name, description: description)
        NotificationCenter.default.post(name: NSNotification.Name("TasksUpdated"), object: payload)

            dismiss(animated: true, completion: nil)
    }

   func saveTaskToUserDefaults(task: Task) {
        // Load existing tasks from UserDefaults
        var savedTasks = loadTasksFromUserDefaults()

        // Convert the Task object to a dictionary
        let taskDictionary: [String: Any] = [
            "name": task.name,
            "description": task.description,
            "isComplete": task.isComplete
        ]

        // Add the task dictionary to the array
        savedTasks.append(taskDictionary)

        // Save the updated array back to UserDefaults
        UserDefaults.standard.set(savedTasks, forKey: "tasks")
    }

   func loadTasksFromUserDefaults() -> [[String: Any]] {
        // Load tasks from UserDefaults
        return UserDefaults.standard.array(forKey: "tasks") as? [[String: Any]] ?? []
    }

    func synchronizeTasks() {
        // Update the user interface (e.g., update the table view with tasks)
        
        NotificationCenter.default.post(name: NSNotification.Name("TasksUpdated"), object: nil)

        // Perform other synchronization actions if needed
    }
  

    
    @IBAction  func cancelButtonTapped() {
            dismiss(animated: true, completion: nil)
        }
    // функцию удаления задачи
    @objc func deleteButtonTapped() {
            guard let indexPath = indexPath else { return }
            delegate?.deleteTask(at: indexPath)
            dismiss(animated: true, completion: nil)
        }
}

