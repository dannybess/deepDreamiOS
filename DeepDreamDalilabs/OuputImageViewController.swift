//
//  OuputImageViewController.swift
//  DeepDreamDalilabs
//
//  Created by Dhruv Shah on 7/27/15.
//  Copyright (c) 2015 Daniel Bessonov. All rights reserved.
//

import Foundation
import UIKit

class OuputImageViewController: UIViewController {
    @IBOutlet var outputImage : UIImageView!
    var image: UIImage!;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        outputImage.image = image;
        outputImage.contentMode = UIViewContentMode.ScaleAspectFit
    }

}
