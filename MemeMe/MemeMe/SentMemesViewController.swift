//
//  SentMemesView.swift
//  ImagePickerExperiment
//
//  Created by Dori Frost on 5/10/15.
//  Copyright (c) 2015 Dori.Frost. All rights reserved.
//

import Foundation
import UIKit

class SentMemesViewController: UITableViewController, UITableViewDataSource {
    internal var  memes: [Meme]!
    var numDis = 0
    var firstAppearance: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        let object = UIApplication.sharedApplication().delegate
        let appDelegate = object as! AppDelegate
        memes = appDelegate.memes
        firstAppearance = appDelegate.firstAppearance
        if memes.count == 0 && firstAppearance == true {
            let editorVC = self.storyboard!.instantiateViewControllerWithIdentifier("EditorView") as! EditorViewController
            presentViewController(editorVC, animated: true, completion: nil)
        }       
        
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)        
        let object = UIApplication.sharedApplication().delegate
        let appDelegate = object as! AppDelegate
        memes = appDelegate.memes
        appDelegate.firstAppearance = false
        tableView.reloadData()
        numDis++
        println("\(numDis)")
    }
    
    
 
     override func  tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.memes.count
    }
    
     override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("MemeCell") as! UITableViewCell
        let meme = self.memes[indexPath.row]
        // I used the Subtitle table view cell style to style the cell
        cell.textLabel?.text = "\(meme.topText) "
        cell.imageView?.image = meme.memedImage
                
        if let detailTextLabel = cell.detailTextLabel {
            detailTextLabel.text = "\(meme.bottomText)"        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let detailController = self.storyboard!.instantiateViewControllerWithIdentifier("MemeDetailViewController") as! MemeDetailViewController
        detailController.meme = self.memes[indexPath.row]
        detailController.memeIndex = indexPath.row
        navigationController!.pushViewController(detailController, animated: true)
        
    }

    //Click the + button on the nav toobar presents the editor view
    @IBAction func presentEditorView(sender: UIBarButtonItem) {
               //dismissViewControllerAnimated(true, completion: nil)
               goToEditor()
    }
    
    
    
    //Deleting sent memes:
    
    // Adding Edit button
    override func loadView() {
        super.loadView()
        navigationItem.leftBarButtonItem = self.editButtonItem()
    }
    
    //Selecting the delete editing style and deleting
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            let object = UIApplication.sharedApplication().delegate
            let appDelegate = object as! AppDelegate
            appDelegate.memes.removeAtIndex(indexPath.row)
            memes.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func goToEditor() {
        var storyboard = UIStoryboard (name: "Main", bundle: nil)
        var editorVC = storyboard.instantiateViewControllerWithIdentifier("EditorView") as! UIViewController
        presentViewController(editorVC, animated: true, completion: nil)
    }
    
   
    
   }
