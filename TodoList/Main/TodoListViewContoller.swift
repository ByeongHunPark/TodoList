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
    
    var vm = TodoListViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setLayout()
        
        todoListTabelView.delegate = self
        todoListTabelView.dataSource = self
        
        todoListTabelView.register(UINib(nibName: "TodoListTableCell", bundle: nil), forCellReuseIdentifier: "list_cell")
        
        textField.delegate = self
        
        self.hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        TodoAPI.shared.list { [weak self] listmodel in
            self?.vm.todoList = listmodel
        }
    }

    private func setLayout(){
        textFieldView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(58)
        }
        
//        textFieldView.layer.borderWidth = 1
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
    
}

extension TodoListViewContoller: UITextFieldDelegate{
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        
        textField.resignFirstResponder()

        return true
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension TodoListViewContoller: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if vm.todoList.count > 20{
            vm.tableCount = vm.page
        }else{
            vm.tableCount = vm.todoList.count
        }
        
        if textField.text != ""{
            vm.tableCount = vm.searchTodoList.count
        }
        
        
        return vm.tableCount
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "list_cell") as! TodoListTableCell
        
        cell.assignee.text = "test"
        cell.content.text = "testtesttesttesttesttest\ntesttesttesttesttest"
        cell.create_at.text = "2024-04-28"
        cell.thumbnail.image = UIImage(systemName: "pencil")

        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "detail") as! DetailViewContoller
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
