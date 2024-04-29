//
//  AddViewController.swift
//  TodoList
//
//  Created by 박병훈 on 4/29/24.
//

import Foundation
import UIKit
import SnapKit

class AddViewController: UIViewController {
    @IBOutlet weak var naviBar: UINavigationBar!
    @IBOutlet weak var assigneeTextField: UITextField!
    @IBOutlet weak var contentTextView: UITextView!
    
    @IBOutlet weak var addBtnView: UIView!
    @IBOutlet weak var addBtn: UIButton!
    
    var vm = AddViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        assigneeTextField.delegate = self
        contentTextView.delegate = self
        setLayout()
    }
    
    private func setLayout(){
        naviBar.isTranslucent = false
        naviBar.backgroundColor = .systemBackground
        
        contentTextView.layer.borderWidth = 0.4
        contentTextView.layer.borderColor = UIColor.systemGray4.cgColor
        contentTextView.layer.cornerRadius = 5
        contentTextView.isScrollEnabled = false
        
        contentTextView.text = "내용을 입력하세요"
        contentTextView.textColor = UIColor.systemGray4
        
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow), name: UIResponder.keyboardDidShowNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
//        assigneeTextField.snp.makeConstraints { make in
//            make.height.equalTo(50)
//        }
//        
//        contentTextView.snp.makeConstraints { make in
//            make.height.equalTo(50)
//        }
        
        addBtnView.layer.masksToBounds = false
        addBtnView.layer.shadowColor = UIColor.black.cgColor
        addBtnView.layer.shadowOffset = CGSize(width: 0, height: -1)
        addBtnView.layer.shadowOpacity = 0.6
        
        addBtn.layer.cornerRadius = 10
    }
    
//    @objc func keyboardDidShow(notification: Notification){
//        
//        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue{
//            if vm.textFieldViewYValue == 0{
//                vm.textFieldViewYValue = self.textFieldView.frame.origin.y
//            }
//            
//            if self.textFieldView.frame.origin.y == vm.textFieldViewYValue{
//                vm.textFieldViewYValue = self.textFieldView.frame.origin.y
//                self.textFieldView.frame.origin.y -= keyboardSize.height
//            }
//        }
//    }
//    
//    @objc func keyboardWillHide(notification: Notification){
//        if self.textFieldView.frame.origin.y != vm.textFieldViewYValue{
//            self.textFieldView.frame.origin.y = vm.textFieldViewYValue
//        }
//    }
    
    @IBAction func cancelBtnClicked(_ sender: Any) {
        self.dismiss(animated: false)
        
    }
    
}

extension AddViewController: UITextViewDelegate{
    func textViewDidChange(_ textView: UITextView) {
        let size = CGSize(width: view.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        
        textView.constraints.forEach { (constraint) in
            
            if estimatedSize.height <= 180 {
                
            }
            else {
                if constraint.firstAttribute == .height {
                    constraint.constant = estimatedSize.height
                }
            }
        }
    }
    
    func textViewShouldReturn(_ textView: UITextView) -> Bool{
        textView.resignFirstResponder()
        
        return true
    }
    
}

extension AddViewController: UITextFieldDelegate{
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
