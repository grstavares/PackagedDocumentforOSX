//
//  AttachmentView.swift
//  PackagedDocumentforOSX
//
//  Created by Gustavo Tavares on 19/07/2018.
//  Copyright © 2018 brClouders. All rights reserved.
//

import Cocoa

class AttachmentView: NSView {

    var image: NSImage?
    var highlightForDragAcceptence: Bool = false
    
    public func commonInit() -> Void {
        
        // Register for all the image types we can display - include NSFilenamesPboardType for Finder drags.
        let dragTypes: [String] = NSImageRep.imageTypes
        let pasteboardTypes = dragTypes.compactMap {NSPasteboard.PasteboardType($0)}
        self.registerForDraggedTypes(pasteboardTypes)
        self.setKeyboardFocusRingNeedsDisplay(self.bounds)
        self.highlightForDragAcceptence = false
        
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        commonInit()
    }
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        commonInit()
    }
    
    override func draw(_ dirtyRect: NSRect) {
        
        super.draw(dirtyRect)
        
        if self.highlightForDragAcceptence {
            
            let context = NSGraphicsContext.current
            context?.saveGraphicsState()
            NSFocusRingPlacement.only.set()
            NSBezierPath(rect: NSInsetRect(self.bounds, 3, 3)).fill()
            context?.restoreGraphicsState()
            
        }

    }
    
    deinit {
        self.unregisterDraggedTypes()
    }
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        
        var dragOperation: NSDragOperation = NSDragOperation.generic
        if sender.draggingSourceOperationMask().contains(NSDragOperation.copy) {
            
            self.highlightForDragAcceptence = true
            self.setNeedsDisplay(self.bounds)
            dragOperation = NSDragOperation.copy

        }
        
        return dragOperation
        
    }
    
    override func draggingExited(_ sender: NSDraggingInfo?) {
        
        self.highlightForDragAcceptence = false
        self.setNeedsDisplay(self.bounds)
        
    }
    
    override func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation {

        var dragOperation: NSDragOperation = NSDragOperation.generic
        if sender.draggingSourceOperationMask().contains(NSDragOperation.copy) {

            // The sender is offering the type of operation we want,
            // return that we want the NSDragOperationCopy (cursor has a + image).
            //
            dragOperation = NSDragOperation.copy
            
        }
        
        return dragOperation
        
    }
    
    override func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
        return true
    }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        
        // Gets the dragging-specific pasteboard from the sender.
        let paste:NSPasteboard = sender.draggingPasteboard()
        
        let types:[NSPasteboard.PasteboardType] = [NSPasteboard.PasteboardType.tiff, NSPasteboard.PasteboardType.fileURL]
        
        // A list of types that we can accept.
        if let desiredType:NSPasteboard.PasteboardType = paste.availableType(from: types) {
            
            if desiredType == .tiff {
                
                if let carriedData = paste.data(forType: desiredType) {
                    self.image = NSImage(data: carriedData)
                }
                
            } else if desiredType == .fileURL {
                
                if let fileURLs = paste.readObjects(forClasses: [NSURL.self], options: [:]) as? [NSURL] {
                    
                    if let fileUrl = fileURLs.first, let loadedImage = NSImage.init(contentsOf: fileUrl as URL) {
                        self.image = loadedImage
                    } else {return false}
                    
                } else {return false}

            } else {return false}

            self.highlightForDragAcceptence = false
            self.setNeedsDisplay(self.bounds)
            return true
            
        } else {return false}

    }
    
}
