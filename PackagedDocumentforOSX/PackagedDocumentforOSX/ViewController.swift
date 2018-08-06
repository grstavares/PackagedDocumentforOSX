//
//  ViewController.swift
//  PackagedDocumentforOSX
//
//  Created by Gustavo Tavares on 18/07/2018.
//  Copyright © 2018 brClouders. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    let kClipImageName = NSImage.Name("clip")
    
    @IBOutlet weak var imageView: ImageView!
    @IBOutlet weak var imageViewLabel: NSTextField!
    @IBOutlet weak var attachmentView: AttachmentView!
    @IBOutlet weak var attachedImageView: NSImageView!
    @IBOutlet weak var attachedImageViewHeighConstraint: NSLayoutConstraint!
    @IBOutlet weak var disclosureButton: NSButton!
    @IBOutlet weak var textView: NSTextView!
    
    private var disclosedDelta: Int = 0
    public var disclosed: Bool = false
    public var delegate: ViewControllerDelegate?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.textView.allowsUndo = true
        
        self.imageView.unregisterDraggedTypes()
        self.attachedImageView.unregisterDraggedTypes()

        self.imageView.delegate = self
        
    }

    override func viewWillAppear() {
        
        super.viewWillAppear()
        
        if let document = self.ourDocument {
            
            document.updateTextView(self.textView)
            document.updateImageView(self.imageView)
            
            if document.image != nil {self.attachedImageView.image = document.image}
            self.imageViewLabel.isHidden = document.image != nil
            
            self.disclosedDelta = Int(self.attachedImageView.frame.height - (self.attachedImageView.frame.height - self.disclosureButton.frame.height) - 8)
            if !(self.disclosureButton.state == (self.disclosed ? NSButton.StateValue.on : NSButton.StateValue.off)) {
                
                // Disclose the attachment view only if our disclosure button is out of sync.
                self.disclosureButton.state = self.disclosed ? NSButton.StateValue.on : NSButton.StateValue.off
                self.disclosed = false
                
            }
            
            self.view.window?.makeFirstResponder(self.textView)
            
        }
        
        
    }
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    
    // -------------------------------------------------------------------------------
    //  ourDocument
    //
    //  Accessor to reference our associated NSDocument through our window controller.
    // -------------------------------------------------------------------------------
    var ourDocument: MyTextPictDocument? {
        let windowController: WindowController? = self.view.window?.windowController as? WindowController
        return windowController?.document as? MyTextPictDocument
    }
    
    public func updateImage(image: NSImage) -> Void {
        
        self.imageView.image = image
        self.imageViewLabel.isHidden = true
        self.imageDidChange(self)
        
    }
    
    func imageDidChange(_ sender: Any?) {
        
        // Draw the paper clip image if we received a valid image.
        self.attachedImageView.image = self.imageView.image != nil ? NSImage.init(named: kClipImageName) : nil
        
        let document = self.ourDocument
        document?.updateImageModel(self.imageView.image)
        
        // Hide the image label if we have an image.
        self.imageViewLabel.isHidden = document?.image != nil
        
    }

    func disclose(animated: Bool) -> Void {
        
        let discloseAmount: CGFloat = self.imageView.frame.height
        
        // Adjust the height constraint by the amount of the image view's height,
        // causing the bottom of the header to be flush with the bottom of the overall disclosure view.
        //
        if animated {
            
            NSAnimationContext.runAnimationGroup({ (context) in
                
                context.timingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseInEaseOut)
                self.imageView.animator().isHidden = !(self.disclosureButton.state == NSButton.StateValue.on);
                if self.disclosureButton.state == NSButton.StateValue.on {
                    self.attachedImageViewHeighConstraint.animator().constant += discloseAmount
                } else {
                    self.attachedImageViewHeighConstraint.animator().constant -= discloseAmount
                }
                
            }, completionHandler: nil)
            
        } else {

            self.imageView.isHidden = !(self.disclosureButton.state == NSButton.StateValue.on);
            if self.disclosureButton.state == NSButton.StateValue.on {
                self.attachedImageViewHeighConstraint.constant += discloseAmount
            } else {
                self.attachedImageViewHeighConstraint.constant -= discloseAmount
            }

        }
        
        // Call our delegate (MyTextPictDocument) notifying the attachment view disclosure state changed,
        // so we can save this state as part of the document data.
        //
        self.delegate?.viewController(didDiscloseImage: self.disclosureButton.state == NSButton.StateValue.on)
        
    }
    
    @IBAction func discloseAction(sender: Any?) -> Void {self.disclosed = true}
    
    // -------------------------------------------------------------------------------
    //  updateImage:image
    //
    //  Our AttachmentView wants to set our image attachment update our data model.
    // -------------------------------------------------------------------------------
    func updateImage(_ image: NSImage) -> Void {

        self.imageView.image = image;
        self.imageViewLabel.isHidden = true;
        self.imageDidChange(self)

    }
    
    
    
}

extension ViewController: NSTextDelegate {
    
    func textDidChange(_ notification: Notification) {
        
        if let value = self.textView.textStorage?.string {
            self.ourDocument?.updateTextModel(value)
        }

    }
    
}

extension ViewController: ImageViewDelegate {

    func didChangeImage(_ image: NSImage?) {
        if let image = image {self.updateImage(image: image)}
    }

}

protocol ViewControllerDelegate {
    
    func viewController(didDiscloseImage: Bool)
    
}
