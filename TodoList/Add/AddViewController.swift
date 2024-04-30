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
    
    var vm = AddViewModel()
    
    let imagePicker = UIImagePickerController()
     
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
        
        contentTextView.text = "내용을 입력하세요"
        contentTextView.textColor = UIColor.systemGray4
        
        addBtnView.layer.masksToBounds = false
        addBtnView.layer.shadowColor = UIColor.black.cgColor
        addBtnView.layer.shadowOffset = CGSize(width: 0, height: -1)
        addBtnView.layer.shadowOpacity = 0.6
        
        addBtn.layer.cornerRadius = 10
    }
    
    
    @IBAction func photoAddBtnClicked(_ sender: Any) {
//        let imagePicker = UIImagePickerController()
//        imagePicker.sourceType = .photoLibrary
//        imagePicker.delegate = self
//        present(imagePicker, animated: true)
        
        albumAuth()
        
    }
    
    func albumAuth() {
        switch PHPhotoLibrary.authorizationStatus() {
        case .denied:
            self.showAlert("사용자의 앨범에 접근권이 없습니다\n설정으로 이동하여 권한을 허용해주세요")
        case .authorized:
            self.openPhotoLibrary()
        case .notDetermined, .restricted:
            PHPhotoLibrary.requestAuthorization { state in
                if state == .authorized {
                    self.openPhotoLibrary()
                } else {
                    self.dismiss(animated: true, completion: nil)
                }
            }
        default:
            break
        }
    }
    
    func showAlert(_ message: String){
        let alertVC = UIAlertController(
            title: "알림",
            message: message,
            preferredStyle: .alert
        )
        let cancelAction = UIAlertAction(
            title: "취소",
            style: .cancel,
            handler: nil
        )
        let confirmAction = UIAlertAction(title: "설정", style: .default) { _ in
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
        }
        alertVC.addAction(cancelAction)
        alertVC.addAction(confirmAction)
        self.present(alertVC, animated: true, completion: nil)
    }
    
    private func openPhotoLibrary() {
        if (UIImagePickerController.isSourceTypeAvailable(.photoLibrary)) {
            self.imagePicker.sourceType = .photoLibrary
            self.imagePicker.modalPresentationStyle = .currentContext
            self.present(self.imagePicker, animated: true, completion: nil)
        } else {
            print("앨범에 접근할 수 없습니다.")
        }
    }
    
    
    @IBAction func photoRemoveBtnClicked(_ sender: Any) {
        pickedImageView.image = nil
        imageView.isHidden = true
    }
    
    @IBAction func addBtnClicked(_ sender: Any) {
        print("add")
        self.dismiss(animated: false)
    }
    
    @IBAction func cancelBtnClicked(_ sender: Any) {
        self.dismiss(animated: false)
        
    }
    
}

extension AddViewController: UITextFieldDelegate, UITextViewDelegate{
    func textViewDidChange(_ textView: UITextView) {
        let size = CGSize(width: view.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        
        textView.constraints.forEach { (constraint) in
            
//            if estimatedSize.height <= 180 {
//                
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
    
    func textViewShouldReturn(_ textView: UITextView) -> Bool{
        textView.resignFirstResponder()
        
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
        }
        imageView.isHidden = false
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}


