//
//  ViewController.swift
//  ImagePickerExperiment
//
//  Created by Dori Frost on 4/28/15.
//  Copyright (c) 2015 Dori.Frost. All rights reserved.
//

import UIKit

class EditorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var pickImage: UILabel!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var navBar: UIToolbar!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    //show Sent Memes view when starting the app with existing listed memes. - Currently not working because memes not persist in memory.
    var editedMeme: Meme?
    
    
    // Different text styling when typing and when displaying
    let typingModeTextAttributes = [
        NSFontAttributeName : UIFont(name: "Arial", size: 20)!,
        NSStrokeWidthAttributeName : 0.0
    ]
    
    let displayModeTextAttributes = [
        NSStrokeColorAttributeName : UIColor.blackColor(),
        NSForegroundColorAttributeName : UIColor.whiteColor(),
        NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 30)!,
        NSStrokeWidthAttributeName : -3.0
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        topTextField.text = "Please type your header text here"
        topTextField.textAlignment = .Center
        bottomTextField.text = "Please type your footer text here"
        bottomTextField.textAlignment = .Center
        
        // Different text styling when typing and when displaying
        
        topTextField.defaultTextAttributes = typingModeTextAttributes
        bottomTextField.defaultTextAttributes = typingModeTextAttributes    
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navBar.hidden = false
        toolBar.hidden = false
        // Subscribe to keyboard notifications to allow the lower text field to rise
        self.subscribeToKeyboardNotifications()
        
        if let meme = editedMeme {
            prepareForEdit(meme)
            shareButton.enabled = true
        }

    }
    
    func prepareForEdit(meme: Meme)  {
        topTextField.text = meme.topText
        imagePickerView.image = meme.image
        bottomTextField.text = meme.bottomText
        topTextField.hidden = false
        bottomTextField.hidden = false
        pickImage.hidden = true
        
    }

    
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if bottomTextField.isFirstResponder() {
            self.view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if bottomTextField.isFirstResponder() {
            self.view.frame.origin.y += getKeyboardHeight(notification)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.unsubscribeFromKeyboardNotifications()
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name:
            UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name:
            UIKeyboardWillHideNotification, object: nil)
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }
    
    
    
    //image picker management
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.imagePickerView.image = image
            self.shareButton.enabled = true
       }
        self.dismissViewControllerAnimated(true, completion: nil)
        pickImage.hidden = true
        bottomTextField.hidden = false
        topTextField.hidden = false
        toolBar.hidden = false

    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func pickAnImageFromAlbum (sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func pickAnImageFromCamera (sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }

   
    // editing meme text fields and changing styles according to typing/displaying mode
   
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.defaultTextAttributes = typingModeTextAttributes
        textField.clearsOnBeginEditing = false
        textField.backgroundColor = UIColor.whiteColor()
        textField.borderStyle = .RoundedRect
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        textField.defaultTextAttributes = displayModeTextAttributes
        textField.backgroundColor = UIColor.clearColor()
        textField.borderStyle = .None
        return true
    }
    
    
    //flow when pressing activity bottom - selecting activity - creating memed image and creating meme object

    @IBAction func shareMeme(sender: UIBarButtonItem) {
        let memedImage = generateMemedImage()
        var activityItems = [memedImage]
        let controller = UIActivityViewController( activityItems: activityItems, applicationActivities: nil)
        presentViewController(controller, animated: true, completion: nil)
        controller.completionWithItemsHandler =  { (s, ok, items, err) -> Void in
            if ok == true {
            self.shareButton.enabled = true
            self.save()
            self.dismissViewControllerAnimated( true, completion: nil)
            //self.goToMemeList()
             }
        }
        
    }
    
    func save() {
        //Create the meme
        var meme = Meme(topText: self.topTextField.text, bottomText: self.bottomTextField.text, image: self.imagePickerView.image!, memedImage: self.generateMemedImage())
        let object = UIApplication.sharedApplication().delegate
        let appDelegate = object as! AppDelegate
        appDelegate.memes.append(meme)
        var memesLength = appDelegate.memes.count
    }
    
    func generateMemedImage() -> UIImage {
        toolBar.hidden = true
        navBar.hidden = true
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        self.view.drawViewHierarchyInRect(self.view.frame,
            afterScreenUpdates: true)
        let memedImage : UIImage =
        UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        toolBar.hidden = false
        navBar.hidden = false
        return memedImage
    }

    
    func goToMemeList() {
        var storyboard = UIStoryboard (name: "Main", bundle: nil)
        var tabBarVC = storyboard.instantiateViewControllerWithIdentifier("MemeTabBar") as! UIViewController
        presentViewController(tabBarVC, animated: true, completion: nil)
    }
    
    func goToEditor() {
        var storyboard = UIStoryboard (name: "Main", bundle: nil)
        var editorVC = storyboard.instantiateViewControllerWithIdentifier("EditorView") as! UIViewController
        presentViewController(editorVC, animated: true, completion: nil)
    }
    
}

