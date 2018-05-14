//
//  CreditsViewController.swift
//  Aliens
//
//  Created by Ibrahim Syed on 7/31/17.
//  Copyright © 2017 Ibrahim Syed. All rights reserved.
//

import UIKit
import SpriteKit

class CreditsViewController: UIViewController {
    @IBAction func goBack(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
