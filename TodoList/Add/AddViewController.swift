//
//  AddViewController.swift
//  TodoList
//
//  Created by 박병훈 on 4/29/24.
//

import Foundation
import UIKit
import SnapKit
import Photos
import PhotosUI

class AddViewController: UIViewController {
    @IBOutlet weak var naviBar: UINavigationBar!
    @IBOutlet weak var assigneeTextField: UITextField!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var pickedImageView: UIImageView!
    @IBOutlet weak var imageView: UIView!
    
    @IBOutlet weak var photoRemoveBtn: UIButton!
    @IBOutlet weak var photoAddBtn: UIButton!
    @IBOutlet weak var addBtnView: UIView!
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var overlayView: UIView!
    
    @IBOutlet weak var scrollView: UIView!
    var vm = AddViewModel()
    
    let imagePicker = UIImagePickerController()
    
    var sendDelegate: SendDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        assigneeTextField.delegate = self
        contentTextView.delegate = self
        imagePicker.delegate = self
        
        self.hideKeyboardWhenTappedAround()
        
        setLayout()
    }
    
    private func setLayout(){
        naviBar.isTranslucent = false
        naviBar.backgroundColor = .systemBackground
        
        contentTextView.layer.borderWidth = 0.4
        contentTextView.layer.borderColor = UIColor.systemGray4.cgColor
        contentTextView.layer.cornerRadius = 5
        contentTextView.isScrollEnabled = false
        
        contentTextView.text = vm.textViewPlaceHolder
        contentTextView.textColor = UIColor.systemGray4
        
        addBtnView.layer.masksToBounds = false
        addBtnView.layer.shadowColor = UIColor.black.cgColor
        addBtnView.layer.shadowOffset = CGSize(width: 0, height: -1)
        addBtnView.layer.shadowOpacity = 0.6
        
        addBtn.layer.cornerRadius = 10
        
        photoAddBtn.layer.cornerRadius = 10
        photoRemoveBtn.layer.cornerRadius = 10
        
        overlayView.layer.opacity = 0.5
    }
    
    
    @IBAction func photoAddBtnClicked(_ sender: Any) {
        albumAuth()
    }
    
    func albumAuth() {
        
        let confirmAction = UIAlertAction(title: "설정", style: .default) { _ in
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
        }
        
        switch PHPhotoLibrary.authorizationStatus() {
        case .denied:
            DispatchQueue.main.async {
                self.showAlert("사용자의 앨범에 접근권한이 없습니다\n설정으로 이동하여 권한을 허용해주세요", confirmAction)
            }
        case .authorized, .limited:
            DispatchQueue.main.async {
                self.openPhotoLibrary()
            }
        case .notDetermined, .restricted:
            DispatchQueue.main.async {
                PHPhotoLibrary.requestAuthorization { state in
                    if state == .authorized {
                        self.openPhotoLibrary()
                    } else {
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        default:
            break
        }
    }
    
    private func openPhotoLibrary() {
        DispatchQueue.main.async {
            if (UIImagePickerController.isSourceTypeAvailable(.photoLibrary)) {
                self.imagePicker.sourceType = .photoLibrary
                self.imagePicker.modalPresentationStyle = .currentContext
                self.present(self.imagePicker, animated: true, completion: nil)
            } else {
                print("앨범에 접근할 수 없습니다.")
            }
        }
    }
    
    @IBAction func photoRemoveBtnClicked(_ sender: Any) {
        pickedImageView.image = nil
        imageView.isHidden = true
    }
    
    @IBAction func addBtnClicked(_ sender: Any) {
//        if assigneeTextField.text!.count > 20 || contentTextView.text.count > 300{
//            let message = assigneeTextField.text!.count > 20 ? "담당자 명은 최대 20자까지 작성할 수 있습니다.\n(\(assigneeTextField.text!.count)/20)" : "할 일 내용은 최대 300자까지 작성할 수 있습니다.\n(\(contentTextView.text!.count)/300)"
//            
//            showToast(message: message)
//            
//            return
//        }
//        
//        
//        if assigneeTextField.text != "" && !assigneeTextField.text!.isEmpty && (contentTextView.text != "" && contentTextView.text != vm.textViewPlaceHolder) && (!contentTextView.text!.isEmpty  && contentTextView.text != vm.textViewPlaceHolder) && pickedImageView.image != nil{
//            
//            TodoAPI.shared.addTodo(assignee: assigneeTextField.text!,
//                                   content: contentTextView.text,
//                                   imageFile: pickedImageView.image!,
//                                   imageName: vm.imageName) { result in
//                if result != "실패"{
                    self.dismiss(animated: true)
                    self.sendDelegate?.sendId("ㅁㄴㅇ")
//                    self.sendDelegate?.sendId(result)
//                }else{
//                    self.showToast(message: "추가에 실패하셨습니다.")
//                }
//            }
//        }else{
//            let message = assigneeTextField.text == "" ? "assignee" : (contentTextView.text != "" && contentTextView.text != vm.textViewPlaceHolder) ? "content" : "image"
//            
//            showToast(message: "\(message)는 필수 항목입니다.")
//        }
    }
    
    @IBAction func cancelBtnClicked(_ sender: Any) {
        if assigneeTextField.text != "" || !assigneeTextField.text!.isEmpty || (contentTextView.text != "" && contentTextView.text != vm.textViewPlaceHolder) || (!contentTextView.text!.isEmpty  && contentTextView.text != vm.textViewPlaceHolder) || pickedImageView.image != nil{
            
            let confirmAction = UIAlertAction(title: "확인", style: .default) { _ in
                self.dismiss(animated: true)
            }
            
            showAlert("작성중인 내용이 있습니다.\n이대로 진행할까요?", confirmAction)
        }else{
            self.dismiss(animated: true)
        }
    }
    
}

extension AddViewController: UITextFieldDelegate, UITextViewDelegate{
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == vm.textViewPlaceHolder {
            textView.text = nil
            textView.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text = vm.textViewPlaceHolder
            textView.textColor = .lightGray
        }
    }
    
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

extension AddViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            print("image_info = \(pickedImage)")
            pickedImageView.image = pickedImage
            
            if let imageUrl = info[UIImagePickerController.InfoKey.imageURL] as? URL {
                let imageName = imageUrl.lastPathComponent
                print("Image Name: \(imageName)")
                vm.imageName = imageName
            }
        }
        imageView.isHidden = false
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}


