//
//  ViewController.swift
//  DeepDreamDalilabs
//
//  Created by Dhruv Shah on 7/25/15.
//  Copyright (c) 2015 Daniel Bessonov. All rights reserved.
//

import UIKit
import Photos
import Social

extension String {
    var floatValue: Float {
        return (self as NSString).floatValue
    }
}

class ViewController: UIViewController, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func uploadBtnPressed(sender: UIButton) {
        let version: Float = UIDevice.currentDevice().systemVersion.floatValue;
        if version >= 8.0 {
            self.presentImagePickerSheet();

        }
        else {
            let actionSheet = UIActionSheet(title: "Upload Photo to DeepDream", delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Take Photo or Video", "Photo Library");
            actionSheet.actionSheetStyle = .Default;
            actionSheet.showInView(self.view);

        }
    }

    func presentImagePickerSheet() {
        let presentImagePickerController: UIImagePickerControllerSourceType -> () = { source in
            let controller = UIImagePickerController()
            controller.delegate = self;
            var sourceType = source
            if (!UIImagePickerController.isSourceTypeAvailable(sourceType)) {
                sourceType = .PhotoLibrary
                println("Fallback to camera roll as a source since the simulator doesn't support taking pictures")
            }
            controller.sourceType = sourceType
            
            self.presentViewController(controller, animated: true, completion: nil)
        }
        
        let controller = ImagePickerSheetController()
        controller.maximumSelection = 1;
        controller.addAction(ImageAction(title: NSLocalizedString("Take Photo Or Video", comment: "Action Title"), secondaryTitle: NSLocalizedString("Upload This Photo", comment: "Action Title"), handler: { _ in
            presentImagePickerController(.Camera)
            }, secondaryHandler: { _, numberOfPhotos in
                let manager = PHImageManager.defaultManager();
                let width = CGFloat(controller.selectedImageAssets.first!.pixelWidth);
                let height = CGFloat(controller.selectedImageAssets.first!.pixelHeight);

                manager.requestImageForAsset(controller.selectedImageAssets.first, targetSize: CGSizeMake(width, height), contentMode: PHImageContentMode.AspectFit, options: nil) { (result, _) in
                    var imgName: String = controller.selectedImageAssets.first!.localIdentifier;
                    self.uploadImage(result);
                }
        }))
        controller.addAction(ImageAction(title: NSLocalizedString("Photo Library", comment: "Action Title"), handler: { _ in
            presentImagePickerController(.PhotoLibrary)
        }));
        controller.addAction(ImageAction(title: NSLocalizedString("Cancel", comment: "Action Title"), style: .Cancel, handler: { _ in
            println("Cancelled")
        }))
        presentViewController(controller, animated: true, completion: nil);
    }
    
    func uploadImage(image: UIImage!) {
        var url : String = "http://54.173.193.28/upload.php";
        var err: NSError?
        var imageData : NSData = UIImageJPEGRepresentation(image, 0.75);
        var d0 = ["UUID": NSUUID().UUIDString];

        let urlRequest = urlRequestWithComponents(url, parameters: d0 as Dictionary<String, String>, imageData: imageData);
        
        var imgURL : String!
        
        upload(urlRequest.0, data: urlRequest.1)
            .progress { (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) in
                println("\(totalBytesWritten) / \(totalBytesExpectedToWrite)")
            }
            .responseJSON { (request, response, JSON, error) in
                println("REQUEST \(request)")
                println("RESPONSE \(response)")
                println("JSON \(JSON)");
                
                
                if let statusesArray = JSON as? NSDictionary {
                    imgURL = statusesArray["imageURL"] as? String
                }
                
                if let url = NSURL(string: imgURL!)
                {
                    if let data = NSData(contentsOfURL: url)
                    {
                        var image = UIImage(data: data)
                        self.imageView.image = image
                    }
                }
                
                /*
                if let url = NSURL(string: imgURL!) {
                    if let data = NSData(contentsOfURL: url){
                        println("big booty hoe")
                        var image = UIImage(data: data)
                        let viewC: OuputImageViewController = self.storyboard?.instantiateViewControllerWithIdentifier("OutputIV") as! OuputImageViewController
                        viewC.image = image!;
                        self.navigationController?.presentViewController(OuputImageViewController(), animated: true, completion: nil)
                    }
                }
*/
                
                
            }
        
    }

    @IBAction func postToTwitter()
    {
        var SocialMedia :SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
        var image : UIImage!
        SocialMedia.completionHandler = {
            result -> Void in
            
            
            var getResult = result as SLComposeViewControllerResult;
            switch(getResult.rawValue) {
            case SLComposeViewControllerResult.Cancelled.rawValue: println("Cancelled")
            case SLComposeViewControllerResult.Done.rawValue: println("It's Work!")
            default: println("Error!")
            }
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        self.presentViewController(SocialMedia, animated: true, completion: nil)
        SocialMedia.setInitialText("Check out the awesome DeepDream app! #iOSDeepDreamApp")
        SocialMedia.addImage(image)
        
        
    }
    
    @IBAction func postToFacebook(sender: AnyObject) {
        var SocialMedia :SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
        var image : UIImage!
        SocialMedia.completionHandler = {
            result -> Void in
            
            var getResult = result as SLComposeViewControllerResult;
            switch(getResult.rawValue) {
            case SLComposeViewControllerResult.Cancelled.rawValue: println("Cancelled")
            case SLComposeViewControllerResult.Done.rawValue: println("It's Work!")
            default: println("Error!")
            }
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        self.presentViewController(SocialMedia, animated: true, completion: nil)
        SocialMedia.setInitialText("Check out the awesome DeepDream app! #iOSDeepDreamApp")
        SocialMedia.addImage(image)
    }

    // MARK: UIImagePickerControllerDelegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        println("img selected");
        println(editingInfo);
        

        self.uploadImage(image);
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func urlRequestWithComponents(urlString:String, parameters:Dictionary<String, String>, imageData:NSData) -> (URLRequestConvertible, NSData) {
        
        // create url request to send
        var mutableURLRequest = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        mutableURLRequest.HTTPMethod = Method.POST.rawValue
        let boundaryConstant = "myRandomBoundary12345";
        let contentType = "multipart/form-data;boundary="+boundaryConstant
        mutableURLRequest.setValue(contentType, forHTTPHeaderField: "Content-Type")
        
        
        
        // create upload data to send
        let uploadData = NSMutableData()
        
        // add image
        uploadData.appendData("\r\n--\(boundaryConstant)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        uploadData.appendData("Content-Disposition: form-data; name=\"file\"; filename=\"file.png\"\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        uploadData.appendData("Content-Type: image/png\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        uploadData.appendData(imageData)
        
        // add parameters
        for (key, value) in parameters {
            uploadData.appendData("\r\n--\(boundaryConstant)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
            uploadData.appendData("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n\(value)".dataUsingEncoding(NSUTF8StringEncoding)!)
        }
        uploadData.appendData("\r\n--\(boundaryConstant)--\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        
        // return URLRequestConvertible and NSData
        return (ParameterEncoding.URL.encode(mutableURLRequest, parameters: nil).0, uploadData)
    }
    
}


