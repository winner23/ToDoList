
import UIKit

class ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addTaskField: UITextField!
    @IBOutlet weak var addButton: YTRoundedButton!
    
    //List of tasks
    var taskList: [TaskModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    //Action for button Add
    @IBAction func addButtonTapped(_ sender: YTRoundedButton) {
        if addTaskField.text!.isEmpty {
            showWarningMsg(textMsg: "Task cannot be empty!")
            return
        }
        insertNewTask()
    }
    
    private func showWarningMsg(textMsg: String) {
        let alert = UIAlertController(title: "Warning!", message: textMsg, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    //Append new task to list
    private func insertNewTask() {
        
        for taskChk in taskList {
            //check for task already exists!
            if taskChk.name == addTaskField.text! {
                showWarningMsg(textMsg: "This task already exists!")
                addTaskField.text = ""
                return
            }
        }
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let task = TaskModel(context: context)
        task.name = addTaskField.text!

        taskList.append(task)
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        
        let indexPath = IndexPath(row: taskList.count - 1, section: 0)
        //update interface
        tableView.beginUpdates()
        tableView.insertRows(at: [indexPath], with: .automatic)
        tableView.endUpdates()
        //clearing of the tasks text field
        addTaskField.text = ""
        view.endEditing(true)
    }
    
    
    //Replacing of existing task and append to the end
    func replaceTask(indexPath: IndexPath){
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let task = taskList[indexPath.row]
        context.delete(task)
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        do{
            taskList = try context.fetch(TaskModel.fetchRequest())
        } catch {
            showWarningMsg(textMsg: "Fetching faild!")
            exit(500)
        }
        tableView.beginUpdates()
        tableView.deleteRows(at: [indexPath], with: .automatic)
        tableView.endUpdates()
    }
    
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    //Update if data when app appear on the screen
    override func viewWillAppear(_ animated: Bool) {
        getData()
        //Update GUI
        tableView.reloadData()
    }
    
    //Get data from CoreData
    func getData() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        do{
        taskList = try context.fetch(TaskModel.fetchRequest())
        } catch {
            print("Fetching faild!")
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskList.count
    }
    
    //Fill
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let taskText = taskList[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell") as! TaskCell
        cell.taskTitle.text = taskText.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    //Swipe for manage buttons
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]?
    {
        //
        let update = UITableViewRowAction(style: .normal, title: "Update") { action, index in

            self.addTaskField.text = self.taskList[indexPath.row].name
            self.replaceTask(indexPath: indexPath)
        }
        //
        let delete = UITableViewRowAction(style: .default, title: "Delete") { action, index in
            
            self.replaceTask(indexPath: indexPath)
            
        }
        return [delete, update]
    }
    
    
    
}

