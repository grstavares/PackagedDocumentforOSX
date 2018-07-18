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
    var metadataDict: Dictionary<String, Any>
    var documentFileWrapper: FileWrapper?
    
    override init() {
        
        // Setup our internal default metaData dictionary,
        // (used to illustrate reading/writing plist data to our file package).
        //
        // Note: these are the default values.
        // If a document was previously saved to disk "readFromFileWrapper" will load the real metadata.
        //

        self.metadataDict = [metadataDisclosedKey: true, metadataaValue2Key: "someText"]

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
        self.ourViewController?.disclosed = self.metadataDict[metadataDisclosedKey] as? Bool ?? false
        
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
        // TODO
        return FileWrapper.init()
    }
    
    // -------------------------------------------------------------------------------
    //  read(from, ofType)
    //
    //  Set the contents of this document by reading from a file wrapper of a specified type,
    //  and return YES if successful.
    // -------------------------------------------------------------------------------
    override func read(from fileWrapper: FileWrapper, ofType typeName: String) throws {
        // TODO
    }

}

extension MyTextPictDocument: ViewControllerDelegate {
    
    func viewController(didDiscloseImage: Bool) {
        // TODO
    }

}

