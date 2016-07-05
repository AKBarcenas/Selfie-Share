//
//  ViewController.swift
//  Selfie Share
//
//  Created by Alex on 7/4/16.
//  Copyright © 2016 Alex Barcenas. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, MCSessionDelegate, MCBrowserViewControllerDelegate {
    // The collection view displaying the images.
    @IBOutlet weak var collectionView: UICollectionView!
    // All of the images used by the app.
    var images = [UIImage]()
    
    // Identifies the user.
    var peerID: MCPeerID!
    // Handles multipeer conectivity.
    var mcSession: MCSession!
    // Handles session creation and session advertisement.
    var mcAdvertiserAssistant: MCAdvertiserAssistant!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Selfie Share"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Camera, target: self, action: #selector(importPicture))
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(showConnectionPrompt))
        
        peerID = MCPeerID(displayName: UIDevice.currentDevice().name)
        mcSession = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .Required)
        mcSession.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
     * Function Name: collectionView
     * Parameters: collectionView - the collection view that wants information.
     *   section - the section inside of the collection view.
     * Purpose: This method specifies that the number of items in all sections is the number of images
     *   in the app.
     * Return Value: Int
     */
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    /*
     * Function Name: collectionView
     * Parameters: collectionView - the collection view that wants information.
     *   indexPath - the index path that specifies an item location.
     * Purpose: This method reuses a cell to display an image in a cell.
     * Return Value: UICollectionViewCell
     */
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ImageView", forIndexPath: indexPath)
        
        if let imageView = cell.viewWithTag(1000) as? UIImageView {
            imageView.image = images[indexPath.item]
        }
        
        return cell
    }
    
    /*
     * Function Name: importPicture
     * Parameters: None
     * Purpose: This method presents a view controller that allows the user to pick images.
     * Return Value: None
     */
    
    func importPicture() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        presentViewController(picker, animated: true, completion: nil)
    }
    
    /*
     * Function Name: imagePickerController
     * Parameters: picker - the image picker controller that is handling this method.
     *   info - information about the image being chosen or edited.
     * Purpose: This method checks to see if an image was chosen and updates the images being used by the
     *   app if one was chosen.
     * Return Value: None
     */
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        var newImage: UIImage
        
        if let possibleImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            newImage = possibleImage
        } else if let possibleImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            newImage = possibleImage
        } else {
            return
        }
        
        dismissViewControllerAnimated(true, completion: nil)
        
        images.insert(newImage, atIndex: 0)
        collectionView.reloadData()
    }
    
    /*
     * Function Name: imagePickerControllerDidCancel
     * Parameters: picker - the image picker controller that is handling this method.
     * Purpose: This method dismisses the image picker controller when the cancel button is chosen.
     * Return Value: None
     */
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    /*
     * Function Name: showConnectionPrompt
     * Parameters: None
     * Purpose: This method prompts the user what type of connection they want to make.
     * Return Value: None
     */
    
    func showConnectionPrompt() {
        let ac = UIAlertController(title: "Connect to others", message: nil, preferredStyle: .ActionSheet)
        ac.addAction(UIAlertAction(title: "Host a session", style: .Default, handler: startHosting))
        ac.addAction(UIAlertAction(title: "Join a session", style: .Default, handler: joinSession))
        ac.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        presentViewController(ac, animated: true, completion: nil)
    }
    
    /*
     * Function Name: startHosting
     * Parameters: action - the action associated with calling this method.
     * Purpose: This method creates a session that the user is the host of.
     * Return Value: None
     */
    
    func startHosting(action: UIAlertAction!) {
        mcAdvertiserAssistant = MCAdvertiserAssistant(serviceType: "hws-project25", discoveryInfo: nil, session: mcSession)
        mcAdvertiserAssistant.start()
    }
    
    /*
     * Function Name: joinSession
     * Parameters: action - the action associated with calling this method.
     * Purpose: This method allows the user to join a session made by another user.
     * Return Value: None
     */
    
    func joinSession(action: UIAlertAction!) {
        let mcBrowser = MCBrowserViewController(serviceType: "hws-project25", session: mcSession)
        mcBrowser.delegate = self
        presentViewController(mcBrowser, animated: true, completion: nil)
    }

}

