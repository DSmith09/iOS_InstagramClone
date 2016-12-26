//
//  PostImageViewController.swift
//  ParseStarterProject-Swift
//
//  Created by David on 12/22/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse

class PostImageViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    private let ALERT_ACTION_OK = "OK"
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var addADescriptionField: UITextField!
    
    @IBAction func chooseAnImageButton(_ sender: Any) {
        chooseImage()
    }
    
    @IBAction func postImageButton(_ sender: Any) {
        postImageToParse()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func chooseImage() -> Void {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        // Set to true for filtering capabilities
        imagePicker.allowsEditing = false
        self.present(imagePicker, animated: true)
    }
    
    internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        postImageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
    }
    
    private func postImageToParse() -> Void {
        let post = PFObject(className: "Posts")
        if self.addADescriptionField.text == nil || (self.addADescriptionField.text?.isEmpty)! {
            self.addADescriptionField.text = "default"
        }
        post["message"] = self.addADescriptionField.text
        post["userID"] = PFUser.current()?.objectId
        if let image = postImageView.image {
            let imageData = UIImageJPEGRepresentation(image, 0.5)
            let imageFile = PFFile(name: "\(self.addADescriptionField.text!).jpeg", data: imageData!)
            post["image"] = imageFile
            post.saveInBackground(block: {
                (success, error) in
                if error != nil {
                    print(error!)
                    self.createAlert(title: "Could Not Post Image", message: "Try Again Later")
                } else {
                    self.createAlert(title: "Image Posted", message: "Your Image was posted successfully")
                    self.addADescriptionField.text = ""
                    self.postImageView.image = nil
                }
            })
        } else {
            self.createAlert(title: "Cannot Post", message: "Add an Image First Before Posting")
        }
        
    }
    
    private func createAlert(title: String, message: String) -> Void {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: ALERT_ACTION_OK, style: .default, handler: {
            (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
}
