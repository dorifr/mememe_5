//
//   MemeCollectionViewController.swift
//  ImagePickerExperiment
//
//  Created by Dori Frost on 5/11/15.
//  Copyright (c) 2015 Dori.Frost. All rights reserved.
//

import Foundation

import UIKit

class MemeCollectionController: UICollectionViewController, UICollectionViewDataSource, UINavigationControllerDelegate {
    
      var memes: [Meme]!
    
    
    
    
    
    
      override func viewWillAppear(animated: Bool) {
        let object = UIApplication.sharedApplication().delegate
        let appDelegate = object as! AppDelegate
        memes = appDelegate.memes
        tabBarController?.tabBar.hidden = false
        collectionView?.reloadData()
       
    }
    
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        println("Counting")
        println(" Number of cells \(self.memes.count)")
        return self.memes.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MemeCollectionViewCell", forIndexPath: indexPath) as! MemeCollectionViewCell
        let meme = memes[indexPath.item]
        cell.memeImageView.image = meme.memedImage
        return cell
      }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath:NSIndexPath)
    {        
        let detailController = storyboard!.instantiateViewControllerWithIdentifier("MemeDetailViewController") as! MemeDetailViewController
        detailController.meme = memes[indexPath.row]
        navigationController!.pushViewController(detailController, animated: true)
        
    }
    
    @IBAction func presentEditorView(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
   
    
    

    
}
