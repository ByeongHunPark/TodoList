//
//  TodoListViewController.swift
//  TodoList
//
//  Created by 박병훈 on 4/26/24.
//

import UIKit
import SnapKit

class TodoListViewController: UIViewController {
    @IBOutlet weak var textFieldView : UIView!
    @IBOutlet weak var textBgView: UIView!
    @IBOutlet weak var textField : UITextField!
    @IBOutlet weak var todoListTabelView : UITableView!
    
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
        vm.todoList = []
        vm.page = 1
        indicatorStart(true)
        fetchTodoList()
        
    }
    
    private func setLayout(){
        textFieldView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(58)
        }
        
        textFieldView.layer.masksToBounds = false
        textFieldView.layer.shadowColor = UIColor.black.cgColor
        textFieldView.layer.shadowOffset = CGSize(width: 0, height: -1)
        textFieldView.layer.shadowOpacity = 0.6
        
        textBgView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(58)
        }
        
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
            make.left.right.equalToSuperview()
        }
        
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = view.center
        
        view.addSubview(activityIndicator)
        
        let backBarButtonItem = UIBarButtonItem(title: "뒤로", style: .plain, target: self, action: nil)
        self.navigationItem.backBarButtonItem = backBarButtonItem
        
    }
    
    func fetchTodoList(_ assignee: String? = nil) {
        guard !vm.isFetching else { return }
        vm.isFetching = true
        indicatorStart(true)
        if assignee == nil{
            TodoAPI.shared.list(page: vm.page) { [weak self] result in
                guard let self = self else { return }
                
                self.vm.todoList.append(contentsOf: result)
                self.vm.page += 1
                
                DispatchQueue.main.async {
                    self.todoListTabelView.reloadData()
                    self.vm.isFetching = false
                    self.indicatorStart(false)
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
                    self.indicatorStart(false)
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
            if vm.textBgViewYValue == 0{
                vm.textBgViewYValue = self.textBgView.frame.origin.y
            }
            
            if vm.textFieldViewYValue == 0 {
                vm.textFieldViewYValue = self.textField.frame.origin.y
            }
            
            if self.textBgView.frame.origin.y == vm.textBgViewYValue{
                vm.textBgViewYValue = self.textBgView.frame.origin.y
                self.textBgView.frame.origin.y -= keyboardSize.height
            }
            
            if self.textField.frame.origin.y == vm.textFieldViewYValue{
                vm.textFieldViewYValue = self.textField.frame.origin.y
                self.textField.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: Notification){
        if self.textBgView.frame.origin.y != vm.textBgViewYValue{
            self.textBgView.frame.origin.y = vm.textBgViewYValue
        }
        
        if self.textField.frame.origin.y != vm.textFieldViewYValue{
            self.textField.frame.origin.y = vm.textFieldViewYValue
        }
    }
    
    @IBAction func addTodoBtnClicked(_ sender: Any) {
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "addView") as! AddViewController
        vc.sendDelegate = self
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
        
        
    }
    
}

extension TodoListViewController: UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        if textField.text != ""{
            if vm.page != 1{
                vm.page = 1
            }
            
            filterTodoList(assignee: textField.text)
        }
        
        textField.resignFirstResponder()
        
        return true
    }
    
    private func filterTodoList(assignee: String?) {
        self.vm.todoList = []
        
        fetchTodoList(assignee)
        
        todoListTabelView.reloadData()
    }
}

extension TodoListViewController: UITableViewDelegate, UITableViewDataSource, UITableViewDataSourcePrefetching{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        vm.tableCount = vm.todoList.count
        
        return vm.tableCount
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "list_cell") as! TodoListTableCell
        
        if !vm.todoList.isEmpty{
            let formattedDateString = convertDateString(self.vm.todoList[indexPath.row].create_at)
            cell.assignee.text = self.vm.todoList[indexPath.row].assignee
            cell.content.text = self.vm.todoList[indexPath.row].content
            cell.create_at.text = formattedDateString
            cell.thumbnail.image = self.vm.todoList[indexPath.row].thumbnail
        }
        
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "detail") as! DetailViewController
        
        TodoAPI.shared.detail(id: self.vm.todoList[indexPath.row].id) { result in
            let formattedDateString = self.convertDateString(result.create_at)
            vc.vm.id = result.id
            vc.vm.assignee = result.assignee
            vc.vm.content = result.content
            vc.vm.create = formattedDateString!
            vc.vm.thumbnail = result.thumbnail
            
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        
        guard let lastIndexPath = indexPaths.last,
              lastIndexPath.row == vm.todoList.count - 1 else {
            return
        }
        
        if textField.text == "" && textField.text!.isEmpty{
            fetchTodoList()
        }else{
            fetchTodoList(self.textField.text)
        }
        
        
    }
    
}

protocol SendDelegate{
    func sendId(_ id: String)
}

extension TodoListViewController: SendDelegate{
    func sendId(_ id: String) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "detail") as! DetailViewController
        
        TodoAPI.shared.detail(id: id) { result in
            let formattedDateString = self.convertDateString(result.create_at)
            vc.vm.id = result.id
            vc.vm.assignee = result.assignee
            vc.vm.content = result.content
            vc.vm.create = formattedDateString!
            vc.vm.thumbnail = result.thumbnail
        }
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
