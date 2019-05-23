//
//  ArticleViewController.swift
//  day09
//
//  Created by Artem KUPRIIANETS on 1/26/19.
//  Copyright © 2019 Artem KUPRIIANETS. All rights reserved.
//

import Foundation
import UIKit
import akupriia2019

final class ArticleViewController:UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    
    var article:Article?
    weak var tableC:MyTableViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.text = article?.title
        textView.text = article?.content
        if let d = article?.image {
            imageView.image = UIImage(data: d as Data)
        }
        else {
            imageView.image = nil
        }
        if article == nil {
            title = NSLocalizedString("New article", comment: "")
        }
        else {
            title = NSLocalizedString("Edit article", comment: "")
        }
    }
    
    
    @IBAction func takePicture(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker =  UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            present(imagePicker, animated: true, completion: nil)
        }
        else {
            let alert = UIAlertController(title: "Ooops", message: "No access to camera :(", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func choosePicture(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePicker =  UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            present(imagePicker, animated: true, completion: nil)
        }
        else {
            let alert = UIAlertController(title: "Ooops", message: "No access to photo library :(", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            return
        }
        imageView.image = selectedImage
    }
    
    @IBAction func done(_ sender: UIBarButtonItem) {
        guard let img = imageView.image,
        let title = textField.text,
        let content = textView.text else {
            let alert = UIAlertController(title: "Ooops", message: "Title, content and image are required!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        tableC = navigationController?.viewControllers[0] as? MyTableViewController
        if let a = article {
            a.title = title
            a.content = content
            a.image = UIImagePNGRepresentation(img) as NSData?
            a.modificationDate = NSDate()
            ArticleManager.shared.save()
            tableC?.tableView.reloadData()
        }
        else {
            let a = ArticleManager.shared.newArticle(title: title, content: content, language: Locale.current.languageCode, image: UIImagePNGRepresentation(img) as NSData?)
            tableC?.articles.insert(a, at: 0)
            tableC?.tableView.reloadData()
            print("Some shit article: \(String(describing: a))")
        }
        navigationController?.popViewController(animated: true)
    }
}
