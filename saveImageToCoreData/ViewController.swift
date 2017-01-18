//
//  ViewController.swift
//  saveImageToCoreData
//
//  Created by Suraj MAC3 on 18/01/17.
//  Copyright © 2017 Suraj MAC3. All rights reserved.
//

import UIKit
import CoreData

class imageCollectionViewCell : UICollectionViewCell{
    
    @IBOutlet weak var imgProfile: UIImageView!
}


class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource,UINavigationControllerDelegate,UIImagePickerControllerDelegate {

    
    
//TODO: - General
    let delObj = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var base64String : NSString = NSString()
    var imageDataArray : [NSData] = []
    
    var imagesss  = [NSManagedObject]()
    
//TODO: - Controls
    
    @IBOutlet weak var colMain: UICollectionView!
    
    
    let imgPicker : UIImagePickerController = UIImagePickerController()
    
//TODO: - Let's Play
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        colMain.delegate = self
        colMain.dataSource = self
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
         fetchFromCoreData()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    
//TODO: - Function
    
    /**
     Save Data to Core Data
     
     - parameter profilepic: profilepic as NSDATA
     */
    func StoreDataToLocal(profilepic:NSData){
        
        //One
        let managedContext = self.delObj.managedObjectContext
        
        let entity = NSEntityDescription.entityForName("Image", inManagedObjectContext: managedContext)
        
        let checkIn = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
        
        checkIn.setValue(profilepic, forKey: "profileImage")
        
        do{
            //Activity Indicator
           // UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            
            try managedContext.save()
            self.imagesss.append(checkIn)
            print("Data Saved")
            self.colMain.reloadData()
        }catch let error as NSError{
            print("could not save \(error), \(error.userInfo)")
        }
    }
    
    /**
     REtrive data from core data
     */
    func fetchFromCoreData(){
        let managedContext = self.delObj.managedObjectContext
        
        let fetchRequest = NSFetchRequest(entityName: "Image")
        
        do{
            let result = try managedContext.executeFetchRequest(fetchRequest)
            imagesss = result as! [NSManagedObject]
            self.colMain.reloadData()
        }catch let error as NSError{
            print("Fetch time error:\(error)")
        }
    }
    
    
    func askToChangeImage(){
        let alert = UIAlertController(title: "Let's get a picture", message: "Choose a picture method", preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        self.imgPicker.delegate = self
        
        
        //Add AlertAction to select image from library
        let libButton = UIAlertAction(title: "Select photo from library", style: UIAlertActionStyle.Default) { (UIAlertAction) -> Void in
            self.imgPicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            self.imgPicker.delegate = self
            self.imgPicker.allowsEditing = true
            self.presentViewController(self.imgPicker, animated: true, completion: nil)
        }
        
        //Check if Camera is available, if YES then provide option to camera
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)){
            let cameraButton = UIAlertAction(title: "Take a picture", style: UIAlertActionStyle.Default) { (UIAlertAction) -> Void in
                self.imgPicker.sourceType = UIImagePickerControllerSourceType.Camera
                self.imgPicker.allowsEditing = true
                self.presentViewController(self.imgPicker, animated: true, completion: nil)
            }
            alert.addAction(cameraButton)
        } else {
            print("Camera not available")
            
        }
        
        
        let cancelButton = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (UIAlertAction) -> Void in
            print("Cancel Pressed")
        }
        
        alert.addAction(libButton)
        alert.addAction(cancelButton)
        self.presentViewController(alert, animated: true, completion: nil)
    }

    
//TODO: - UICollectionView Datasource Method implementation
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return imagesss.count
    }
   
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CellID", forIndexPath: indexPath) as! imageCollectionViewCell
        
        let data = imagesss[indexPath.row]
        
        
        let img = UIImage(data: data.valueForKey("profileImage") as! NSData)
        cell.imgProfile.image = img
        
        cell.imgProfile.layer.cornerRadius = cell.imgProfile.frame.height / 2
        cell.imgProfile.clipsToBounds = true
        
        return cell
    }
    
//TODO: - UIImagePickerDelegate Method
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject])
    {
        let pickedImage : UIImage = info[UIImagePickerControllerEditedImage] as! UIImage
        
        //let imageData = UIImageJPEGRepresentation(pickedImage, 0.8)
        let imageData : NSData = UIImageJPEGRepresentation(pickedImage,0.8)!
        
        StoreDataToLocal(imageData)
        base64String = imageData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController){
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    
//TODO: - UIButton Action
    
    @IBAction func btnLoadClick(sender: AnyObject) {
         fetchFromCoreData()
    }
    @IBAction func btnCaptureClick(sender: AnyObject) {
         askToChangeImage()
    }
}

