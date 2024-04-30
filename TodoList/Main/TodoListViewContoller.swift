//
//  ViewController.swift
//  TodoList
//
//  Created by 박병훈 on 4/26/24.
//

import UIKit
import SnapKit

class TodoListViewContoller: UIViewController {
    @IBOutlet var textFieldView : UIView!
    @IBOutlet var textField : UITextField!
    @IBOutlet var todoListTabelView : UITableView!
    
    var activityIndicator: UIActivityIndicatorView!
    let overlayView = UIView(frame: UIScreen.main.bounds)
    
    var vm = TodoListViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setLayout()
        
        todoListTabelView.delegate = self
        todoListTabelView.dataSource = self
        todoListTabelView.prefetchDataSource = self
        
        todoListTabelView.register(UINib(nibName: "TodoListTableCell", bundle: nil), forCellReuseIdentifier: "list_cell")
        
        textField.delegate = self
        
        self.hideKeyboardWhenTappedAround()
        
        vm.reloadData = { [weak self] in
            DispatchQueue.main.async {
                self?.todoListTabelView.reloadData()
                self?.indicatorStart(false)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("willAppear")
        vm.todoList = []
        vm.page = 1
        indicatorStart(true)
        fetchTodoList()
        
    }

    private func setLayout(){
        textFieldView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(58)
        }
        
        textFieldView.layer.masksToBounds = false
        textFieldView.layer.shadowColor = UIColor.black.cgColor
        textFieldView.layer.shadowOffset = CGSize(width: 0, height: -1)
        textFieldView.layer.shadowOpacity = 0.6
        
        textField.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        }
        
        textField.placeholder = "검색어를 입력하세요"
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        todoListTabelView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.bottom.equalTo(textFieldView.snp.top)
//            make.bottom.equalToSuperview()
            make.left.right.equalToSuperview()
        }
        
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = view.center
        
        view.addSubview(activityIndicator)
    }
    
    func fetchTodoList(_ assignee: String? = nil) {
        guard !vm.isFetching else { return }
        vm.isFetching = true
        
        if assignee == nil{
            TodoAPI.shared.list(page: vm.page) { [weak self] result in
                guard let self = self else { return }
                
                self.vm.todoList.append(contentsOf: result)
                self.vm.page += 1
                
                DispatchQueue.main.async {
                    self.todoListTabelView.reloadData()
                    self.vm.isFetching = false
                    print(self.vm.todoList.count)
                }
            }
        }else{
            TodoAPI.shared.list(page: vm.page, assignee: assignee) { [weak self] result in
                guard let self = self else { return }
                
                self.vm.todoList.append(contentsOf: result)
                self.vm.page += 1
                
                DispatchQueue.main.async {
                    self.todoListTabelView.reloadData()
                    self.vm.isFetching = false
                    print(self.vm.todoList.count)
                }
            }
        }
    }
    
    func indicatorStart(_ start:Bool){
        if start{
            view.addSubview(overlayView)
            activityIndicator.startAnimating()
        }else{
            overlayView.removeFromSuperview()
            activityIndicator.stopAnimating()
        }
    }
    
    @objc func keyboardDidShow(notification: Notification){
        
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue{
            if vm.textFieldViewYValue == 0{
                vm.textFieldViewYValue = self.textFieldView.frame.origin.y
            }
            
            if self.textFieldView.frame.origin.y == vm.textFieldViewYValue{
                vm.textFieldViewYValue = self.textFieldView.frame.origin.y
                self.textFieldView.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: Notification){
        if self.textFieldView.frame.origin.y != vm.textFieldViewYValue{
            self.textFieldView.frame.origin.y = vm.textFieldViewYValue
        }
    }
    
    @IBAction func addTodoBtnClicked(_ sender: Any) {
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "addView") as! AddViewController
        
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: false)
        
        
    }
    
}

extension TodoListViewContoller: UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        
        textField.resignFirstResponder()
        filterTodoList(assignee: textField.text)
        return true
    }
    
    private func filterTodoList(assignee: String?) {
//        guard let assignee = assignee, !assignee.isEmpty else {
//            vm.filteredTodoList = vm.todoList
//            todoListTabelView.reloadData()
//            return
//        }
//        
//        let lowercaseAssignee = assignee.lowercased()
//        vm.filteredTodoList = vm.todoList.filter { $0.assignee.lowercased().contains(lowercaseAssignee) }
        
        fetchTodoList(assignee)
        
        todoListTabelView.reloadData()
    }
}

extension TodoListViewContoller: UITableViewDelegate, UITableViewDataSource, UITableViewDataSourcePrefetching{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if textField.text != "" && !textField.text!.isEmpty{
//            vm.tableCount = vm.filteredTodoList.count
//        }else{
            vm.tableCount = vm.todoList.count
//        }
            
        return vm.tableCount
        
//        return 1
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "list_cell") as! TodoListTableCell
        
        

        if textField.text != "" && !textField.text!.isEmpty{
            let formattedDateString = convertDateString(self.vm.filteredTodoList[indexPath.row].create_at)
            
            cell.assignee.text = self.vm.filteredTodoList[indexPath.row].assignee
            cell.content.text = self.vm.filteredTodoList[indexPath.row].content
            cell.create_at.text = formattedDateString
            cell.thumbnail.image = self.vm.filteredTodoList[indexPath.row].thumbnail
        }else{
            let formattedDateString = convertDateString(self.vm.todoList[indexPath.row].create_at)
            
            cell.assignee.text = self.vm.todoList[indexPath.row].assignee
            cell.content.text = self.vm.todoList[indexPath.row].content
            cell.create_at.text = formattedDateString
            cell.thumbnail.image = self.vm.todoList[indexPath.row].thumbnail
        }
        
//        cell.assignee.text = "qqweqweqwe"
//        cell.content.text = "qwewww"
//        cell.create_at.text = "2024-04-30 19:00:00"
//        cell.thumbnail.image = UIImage(systemName: "photo")
        
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "detail") as! DetailViewContoller
        
//        if textField.text != "" && !textField.text!.isEmpty{
//            let formattedDateString = convertDateString(self.vm.filteredTodoList[indexPath.row].create_at)
////            vc.vm.assignee = self.vm.filteredTodoList[indexPath.row].assignee
////            vc.vm.content = self.vm.filteredTodoList[indexPath.row].content
////            vc.vm.create = formattedDateString!
////            vc.vm.thumbnail = self.vm.filteredTodoList[indexPath.row].thumbnail
//            vc.vm.id = self.vm.filteredTodoList[indexPath.row].id
//        }else{
//            let formattedDateString = convertDateString(self.vm.todoList[indexPath.row].create_at)
////            vc.vm.assignee = self.vm.todoList[indexPath.row].assignee
////            vc.vm.content = self.vm.todoList[indexPath.row].content
////            vc.vm.create = formattedDateString!
////            vc.vm.thumbnail = self.vm.todoList[indexPath.row].thumbnail
            vc.vm.id = self.vm.todoList[indexPath.row].id
//        }
        
        
//        vc.vm.assignee = "qqweqweqwe"
//        vc.vm.content = "qwewww\n\n\n\n\n\n\n\n\n\nasd"
//        vc.vm.create = "2024-04-30 19:00:00"
//        vc.vm.thumbnail = UIImage(systemName: "photo")
        
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        
        if textField.text == "" && textField.text!.isEmpty{
            guard let lastIndexPath = indexPaths.last,
                  lastIndexPath.row == vm.todoList.count - 1 else {
                return
            }
            
            
            fetchTodoList()
        }
        
    }
    
}
