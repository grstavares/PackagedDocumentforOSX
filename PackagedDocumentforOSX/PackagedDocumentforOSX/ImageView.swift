//
//  ImageView.swift
//  PackagedDocumentforOSX
//
//  Created by Gustavo Tavares on 19/07/2018.
//  Copyright © 2018 brClouders. All rights reserved.
//

import Cocoa

class ImageView: NSImageView {

    var delegate: ImageViewDelegate?
    
    override func draw(_ dirtyRect: NSRect) {
        
        super.draw(dirtyRect)

    }
    
    //func setImage(_ image: NSImage?) -> Void {}
    
    func copy(_ sender: Any?) -> Void {
        
        if self.allowsCutCopyPaste {
            
            if let anImage = self.image, let imageData = anImage.tiffRepresentation {
                
                let pboard: NSPasteboard = NSPasteboard.general
                pboard.declareTypes([NSPasteboard.PasteboardType.tiff], owner: self)
                pboard.setData(imageData, forType: NSPasteboard.PasteboardType.tiff)
                
            }
            
        }
        
    }
    func paste(_ sender: Any?) -> Void {
        
        let pboard = NSPasteboard.general
        let classes: [AnyClass] = [NSImage.self]
        
        if pboard.canReadObject(forClasses: classes, options: [:]) {
            
            if let objetcs = pboard.readObjects(forClasses: classes, options: [:]) as? [NSImage], let image = objetcs.first {
                self.image = image
                self.delegate?.didChangeImage(self.image)
            }

        }

    }
    
    func cut(_ sender: Any?) -> Void {
        
        if self.allowsCutCopyPaste {
            self.copy(sender)
            self.image = nil
        }
        
        // Notify our delegate of the image change.
        self.delegate?.didChangeImage(self.image)
        
    }
    
    func delete(_ sender: Any?) -> Void {
        
        if self.allowsCutCopyPaste {
            self.image = nil
        }
        
        // Notify our delegate of the image change.
        self.delegate?.didChangeImage(self.image)
        
    }
    
    
}

protocol ImageViewDelegate {
    
    func didChangeImage(_ image: NSImage?) -> Void
    
}
