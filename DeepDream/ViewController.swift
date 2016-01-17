//
//  MenuViewController.swift
//  DeepDream
//
//  Created by Daniel Bessonov on 7/25/15.
//  Copyright (c) 2015 Daniel Bessonov. All rights reserved.
//

import Foundation
import UIKit


class ViewController: UIViewController
{
    @IBOutlet weak var imageView : UIImageView!
    var photo : UIImage!
    override func viewWillAppear(animated: Bool) {
        if(self.photo != nil)
        {
            imageView.image = photo
        }
    }
}