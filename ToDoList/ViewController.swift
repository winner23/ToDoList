
import UIKit

class ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addTaskField: UITextField!
    
    var taskList: [TaskModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    
    @IBAction func addButtonTapped(_ sender: YTRoundedButton) {
        if addTaskField.text!.isEmpty {
            let alert = UIAlertController(title: "Worning!", message: "Task cannot be empty!", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        insertNewTask()
    }
    
    
    func insertNewTask() {
        
        
//        if taskList.contains(addTaskField.text!) {
//            let alert = UIAlertController(title: "Worning!", message: "This task already exists!", preferredStyle: UIAlertControllerStyle.alert)
//            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
//            self.present(alert, animated: true, completion: nil)
//            addTaskField.text = ""
//            return
//        }
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let task = TaskModel(context: context)
        
        task.name = addTaskField.text!
        taskList.append(task)
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        
        let indexPath = IndexPath(row: taskList.count - 1, section: 0)
        
        tableView.beginUpdates()
        tableView.insertRows(at: [indexPath], with: .automatic)
        tableView.endUpdates()
        
        addTaskField.text = ""
        view.endEditing(true)
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    override func viewWillAppear(_ animated: Bool) {
        //
        getData()
        //
        tableView.reloadData()
    }
    
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
    
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]?
    {

        let update = UITableViewRowAction(style: .normal, title: "Update") { action, index in

            self.addTaskField.text = self.taskList[indexPath.row].name

            self.deleteTask(indexPath: indexPath)
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
            
            
        }
        let delete = UITableViewRowAction(style: .default, title: "Delete") { action, index in
            
            self.deleteTask(indexPath: indexPath)
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
            
        }
        return [delete, update]
    }
    
    func deleteTask(indexPath: IndexPath){
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let task = taskList[indexPath.row]
        context.delete(task)
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        do{
            self.taskList = try context.fetch(TaskModel.fetchRequest())
        } catch {
            print("Fetching faild!")
        }
        
        
    }
    
}

