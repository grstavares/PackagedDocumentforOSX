//
//  Document.swift
//  PackagedDocumentforOSX
//
//  Created by Gustavo Tavares on 18/07/2018.
//  Copyright © 2018 brClouders. All rights reserved.
//

import Cocoa

class MyTextPictDocument: NSDocument {

    let imageFileName = "Image.png"
    let textFileName = "Text.txt"
    let metadataFileName = "MetaData.plist"
    let metadataDisclosedKey = "disclosedKey"
    let metadataaValue2Key = "value2"

    var notes: String = ""
    var image: NSImage?
    var metadataDict: MetaData
    var documentFileWrapper: FileWrapper?
    var kTextFileEncoding: String.Encoding = .utf8
    
    override init() {
        
        // Setup our internal default metaData dictionary,
        // (used to illustrate reading/writing plist data to our file package).
        //
        // Note: these are the default values.
        // If a document was previously saved to disk "readFromFileWrapper" will load the real metadata.
        //
        
        self.metadataDict = MetaData(disclosedKey: true, value2: "someText")
        super.init()

    }

    override class var autosavesInPlace: Bool {
        return true
    }

    override func canAsynchronouslyWrite(to url: URL, ofType typeName: String, for saveOperation: NSDocument.SaveOperationType) -> Bool {
        return true
    }
    
    override func makeWindowControllers() {
        // Returns the Storyboard that contains your Document window.
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        let windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("WindowController")) as! WindowController
        self.addWindowController(windowController)
        self.ourViewController?.delegate = self
        self.ourViewController?.disclosed = self.metadataDict.disclosedKey
        
    }

    func setDisplayName(_ name: String?) {
        
        guard let name = name else {return}
        if let url = URL(string: name) {
            super.displayName = url.deletingPathExtension().description
        } else {
            super.displayName = name
        }
    
    }

    override func data(ofType typeName: String) throws -> Data {
        // Insert code here to write your document to data of the specified type. If outError != nil, ensure that you create and set an appropriate error when returning nil.
        // You can also choose to override fileWrapperOfType:error:, writeToURL:ofType:error:, or writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
        throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
    }

    override func read(from data: Data, ofType typeName: String) throws {
        // Insert code here to read your document from the given data of the specified type. If outError != nil, ensure that you create and set an appropriate error when returning false.
        // You can also choose to override readFromFileWrapper:ofType:error: or readFromURL:ofType:error: instead.
        // If you override either of these, you should also override -isEntireFileLoaded to return false if the contents are lazily loaded.
        throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
    }

    // MARK: Accessors

    var ourWindowController: NSWindowController {
        
        return self.windowControllers[0]
        
    }
    
    var ourViewController: ViewController? {
        
        return self.ourWindowController.contentViewController as? ViewController
        
    }
    
    // MARK Package Support

    // -------------------------------------------------------------------------------
    //  fileWrapper(ofType)
    //
    //  Called when the user saves this document or when autosave is performed.
    //  Create and return a file wrapper that contains the contents of this document,
    //  formatted for our specified type.
    // -------------------------------------------------------------------------------
    override func fileWrapper(ofType typeName: String) throws -> FileWrapper {
        
        // If the document was not read from file or has not previously been saved,
        // it doesn't have a file wrapper, so create one.
        //
        if self.documentFileWrapper == nil {self.documentFileWrapper = FileWrapper(directoryWithFileWrappers: [:])}
        
        let files = documentFileWrapper?.fileWrappers ?? [:]
        
        // If there isn't a wrapper for the text file, create one too.
        if let textWrapper = files[textFileName] {self.documentFileWrapper?.removeFileWrapper(textWrapper)}

        if let textValue = ourViewController?.textView.string, let textData = textValue.data(using: kTextFileEncoding) {
            
            let textFileWrapper = FileWrapper.init(regularFileWithContents: textData)
            textFileWrapper.preferredFilename = textFileName
            self.documentFileWrapper?.addFileWrapper(textFileWrapper)
            
        }
        
        // If the document file wrapper doesn't contain a file wrapper for an image and the image is not nil,
        // then create a file wrapper for the image and add it to the document file wrapper.

        if files[imageFileName] == nil && self.image != nil {
            
            let representions = self.image!.representations
            var imageData = NSBitmapImageRep.representationOfImageReps(in: representions, using: .png, properties: [:])
            if imageData == nil {
                
                imageData = self.image!.tiffRepresentation
                let imageRep = NSBitmapImageRep(data: imageData!)
                imageData = imageRep?.representation(using: .png, properties: [:])
                
            }

            if imageData != nil {
                
                let imageFileWrapper = FileWrapper(regularFileWithContents: imageData!)
                imageFileWrapper.preferredFilename = imageFileName
                self.documentFileWrapper?.addFileWrapper(imageFileWrapper)
                
            }
            
        }
        
        // Check if we already have a meta data file wrapper, first remove the old one if it exists.
        if let metadataFileWrapper = files[metadataFileName] {self.documentFileWrapper?.removeFileWrapper(metadataFileWrapper)}
        
        // Write the new file wrapper for our meta data.
        let encoder = PropertyListEncoder()
        let plistData = try encoder.encode(metadataDict)
        let plistWrapper = FileWrapper(regularFileWithContents: plistData)
        plistWrapper.preferredFilename = metadataFileName
        self.documentFileWrapper?.addFileWrapper(plistWrapper)
        
        return self.documentFileWrapper!;
        
    }
    
    // -------------------------------------------------------------------------------
    //  read(from, ofType)
    //
    //  Set the contents of this document by reading from a file wrapper of a specified type,
    //  and return YES if successful.
    // -------------------------------------------------------------------------------
    override func read(from fileWrapper: FileWrapper, ofType typeName: String) throws {
        
        /*
         When opening a document, look for the image and text file wrappers. For each wrapper,
         extract the data from it and keep the file wrapper itself. The file wrappers are kept
         so that, if the corresponding data hasn't been changed, they can be resused during a
         save and thus the source file itself can be reused rather than rewritten. This avoids
         the overhead of syncing data unnecessarily. If the data related to a file wrapper changes
         (a new image is added or the text is edited), the corresponding file wrapper object is
         disposed of and a new file wrapper created on save (see fileWrapperOfType:error:).
         */
        
        let files = fileWrapper.fileWrappers ?? [:]
        
        // Load the text file from it's wrapper.
        if let imageWrapper = files[imageFileName],
            let imageData = imageWrapper.regularFileContents,
            let docodedImage = NSImage.init(data: imageData) {
            
            self.image = docodedImage
            
        }
        
        // Load the image file from it's wrapper.
        if let textWrapper = files[textFileName],
            let textData = textWrapper.regularFileContents,
            let decodedText = String.init(data: textData, encoding: kTextFileEncoding) {
            
            self.notes = decodedText
            
        }
        
        // Load the metaData file from it's wrapper.
        let decoder = PropertyListDecoder()
        if let metadataWrapper = files[metadataFileName],
            let metadataData = metadataWrapper.regularFileContents,
            let decodedMetadata = try? decoder.decode(MetaData.self, from: metadataData) {
            
            self.metadataDict = decodedMetadata
            
        }
        
        self.documentFileWrapper = fileWrapper;

    }

    var entireRange: NSRange {
        
        if let targetTextView = self.ourViewController?.textView {
            return NSRange.init(location: 0, length: targetTextView.string.count)
        } else {return NSRange.init(location: 0, length: 0)}
        
    }
    
    func updateTextView(_ textView: NSTextView) -> Void {
        
        if self.notes.count > 0 {
            
            textView.replaceCharacters(in: self.entireRange, with: self.notes)
            
        }
        
        
    }
    
    func updateImageView(_ imageView: NSImageView?) -> Void {
        
        imageView?.image = self.image
        
    }
    
    func updateTextModel(_ string: String) -> Void {
        
        if let document = self.documentFileWrapper, let fileWrappers = document.fileWrappers {
            
            let textWrapper:FileWrapper? = fileWrappers[textFileName]
            if textWrapper != nil {document.removeFileWrapper(textWrapper!)}
            
        }
        
        self.updateChangeCount(.changeDone)
        
    }
    
    func updateImageModel(_ image: NSImage?) -> Void {

        self.image = image
        
        if let document = self.documentFileWrapper, let fileWrappers = document.fileWrappers {
            
            let imageWrapper:FileWrapper? = fileWrappers[imageFileName]
            if imageWrapper != nil {document.removeFileWrapper(imageWrapper!)}

        }
        
        self.updateChangeCount(.changeDone)
        
    }
    
    
}

extension MyTextPictDocument: ViewControllerDelegate {
    
    func viewController(didDiscloseImage: Bool) {
        
        self.metadataDict.disclosedKey = didDiscloseImage
        self.updateChangeCount(.changeDone)
        
    }

}

struct MetaData: Codable {
    
    var disclosedKey: Bool
    var value2: String?
    
}
