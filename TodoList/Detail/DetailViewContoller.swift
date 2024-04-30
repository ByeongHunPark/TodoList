//
//  DetailViewContoller.swift
//  TodoList
//
//  Created by 박병훈 on 4/28/24.
//

import Foundation
import UIKit

class DetailViewContoller: UIViewController{
    @IBOutlet weak var assigneeTextField: UITextField!
    @IBOutlet weak var createTextField: UITextField!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var thumbnailImage: UIImageView!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var addBtn: UIButton!
    
    @IBOutlet weak var scrollView: UIView!
    @IBOutlet weak var btnView: UIView!
    var vm = DetailViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        assigneeTextField.delegate = self
        contentTextView.delegate = self
        
        setLayout()
    }
    
    private func setLayout(){
        assigneeTextField.text = vm.assignee
        contentTextView.text = vm.content
        createTextField.text = vm.create
        thumbnailImage.image = vm.thumbnail
        
        createTextField.isUserInteractionEnabled = false
        
        contentTextView.layer.borderWidth = 0.4
        contentTextView.layer.borderColor = UIColor.systemGray4.cgColor
        contentTextView.layer.cornerRadius = 5
        contentTextView.isScrollEnabled = false
        
    }
    
    @IBAction func cancelBtnClicked(_ sender: Any) {
        print("cancel")
        self.dismiss(animated: false)
        
    }
    
    @IBAction func addBtnClicked(_ sender: Any) {
        if assigneeTextField.text!.count > 20{
            showToast(message: "담당자 명은 최대 20자까지 작성할 수 있습니다.\n(\(assigneeTextField.text!.count)/20)")
        }
        
        if contentTextView.text!.count > 300{
            showToast(message: "할 일 내용은 최대 300자까지 작성할 수 있습니다.\n(\(contentTextView.text!.count)/300)")
        }
        
        
        
        
    }
    
}

extension DetailViewContoller: UITextFieldDelegate, UITextViewDelegate{
    func textViewDidChange(_ textView: UITextView) {
        let size = CGSize(width: view.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        
        textView.constraints.forEach { (constraint) in
            
//            if estimatedSize.height <= 180 {
//            }
//            else {
//                if constraint.firstAttribute == .height {
//                    constraint.constant = estimatedSize.height
//                }
//            }
            
            if estimatedSize.height > 180 {
                if constraint.firstAttribute == .height {
                    constraint.constant = estimatedSize.height
                }
            }
        }
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
//        if textField.text?.count
        
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
//        if let char = text.cString(using: String.Encoding.utf8) {
//            let isBackSpace = strcmp(char, "\\b")
//            if isBackSpace == -92 {
//                return true
//            }
//        }
//        
//        guard textView.text!.count < 300 else {
//            textView.resignFirstResponder()
//            showToast(message: "할 일 내용은 최대 300자까지 작성할 수 있습니다.\n(\(textView.text!.count)/300)")
//            return false
//        }
        
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        if let char = string.cString(using: String.Encoding.utf8) {
//            let isBackSpace = strcmp(char, "\\b")
//            if isBackSpace == -92 {
//                return true
//            }
//        }
//        
//        guard textField.text!.count < 20 else {
//            textField.resignFirstResponder()
//            showToast(message: "담당자 명은 최대 20자까지 작성할 수 있습니다.\n(\(textField.text!.count)/20)")
//            return false
//        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        textField.resignFirstResponder()
        
        return true
    }
    
}
