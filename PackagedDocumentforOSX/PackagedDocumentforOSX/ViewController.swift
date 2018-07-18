//
//  ViewController.swift
//  PackagedDocumentforOSX
//
//  Created by Gustavo Tavares on 18/07/2018.
//  Copyright © 2018 brClouders. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    public var disclosed: Bool = false
    public var delegate: ViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

protocol ViewControllerDelegate {
    
    func viewController(didDiscloseImage: Bool)
    
}
