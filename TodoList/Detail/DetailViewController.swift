//
//  DetailViewController.swift
//  TodoList
//
//  Created by 박병훈 on 4/28/24.
//

import Foundation
import UIKit

class DetailViewController: UIViewController{
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
        
        self.hideKeyboardWhenTappedAround()
        
//        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
//        swipeRecognizer()
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
        
        btnView.layer.masksToBounds = false
        btnView.layer.shadowColor = UIColor.black.cgColor
        btnView.layer.shadowOffset = CGSize(width: 0, height: -1)
        btnView.layer.shadowOpacity = 0.6
        
        cancelBtn.layer.cornerRadius = 10
        addBtn.layer.cornerRadius = 10
        
    }
    
    @IBAction func cancelBtnClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addBtnClicked(_ sender: Any) {
        if assigneeTextField.text!.count > 20{
            showToast(message: "담당자 명은 최대 20자까지 작성할 수 있습니다.\n(\(assigneeTextField.text!.count)/20)")
            return
        }
        
        if contentTextView.text.count > 300{
            showToast(message: "할 일 내용은 최대 300자까지 작성할 수 있습니다.\n(\(contentTextView.text!.count)/300)")
            return
        }
        
        if assigneeTextField.text! != vm.assignee && contentTextView.text != vm.content{
            TodoAPI.shared.editDetail(id: vm.id,
                                      assignee: assigneeTextField.text!,
                                      content: contentTextView.text) { [self] result, status in
                if status{
                    assigneeTextField.text = result.assignee
                    contentTextView.text = result.content
                    createTextField.text = result.create_at
                    thumbnailImage.image = result.thumbnail
                    
                    showToast(message: "저장되었습니다.")
                }else{
                    showToast(message: "저장에 실패하였습니다.")
                }
            }
        }
    }
    
    func swipeRecognizer() {
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture(_:)))
        swipeRight.direction = UISwipeGestureRecognizer.Direction.right
        self.view.addGestureRecognizer(swipeRight)
    }
    
    @objc func respondToSwipeGesture(_ gesture: UIGestureRecognizer){
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction{
            case UISwipeGestureRecognizer.Direction.right:
                // 스와이프 시, 원하는 기능 구현.
                print("asdasdasd")
                let confirmAction = UIAlertAction(title: "확인", style: .default) { _ in
                    self.dismiss(animated: true, completion: nil)
                }
                
                showAlert("수정중인 내용이 있습니다.\n이대로 진행할까요?", confirmAction)
                
                self.dismiss(animated: true, completion: nil)
            default: break
            }
        }
    }
    
}

extension DetailViewController: UITextFieldDelegate, UITextViewDelegate{
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

//extension DetailViewController: UIGestureRecognizerDelegate {
//    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
//        
//        let confirmAction = UIAlertAction(title: "확인", style: .default) { _ in
//            print("확인")
//        }
//        
//        showAlert("확인", confirmAction)
//        
//        return true
//    }
//}
