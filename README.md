# PackagedDocument

## Description

"PackagedDocument" is a text editing application for opening, editing and saving packaged documents using NSDocument and NSFileWrapper. It is also equipped to demonstrate how to save packaged documents to iCloud.

File Format and NSFileWrapper:
Choices you make in designing your document format can impact network transfer performance to and from iCloud for your app’s documents. The most important choice is to be sure to use a file package for your document format.  If your document data format consists of multiple distinct pieces, use a file package for your document file format. A file package, which you access by way of an NSFileWrapper object, lets you store the elements of a document as individual files and folders that can be read and written separately—while still appearing to the user as a single file. The iCloud upload and download machinery makes use of this factoring of content within a file package; only changed elements are uploaded or downloaded.

Three distinctive components of the document format:
This sample demonstrates the use of NSFileWrapper by writing three distinctive files: text, image and plist files.
Each document window allows the user to add text and an image.  The plist file is used as an internal metadata file used to hold misc information about that document, in particular the disclosure state of the image section of the window.  It writes and reads the plist file using NSPropertyListSerialization.

## Setting up your Xcode project to support iCloud Documents

### Turn on code signing:
Go to your Xcode target, select “General”, refer to the “Signing” section, click “Enable Development Signing”.  Make sure “Automatic manage signing” is checked and then select the your team in the Team Popup.

If you get the following error, you did not set development Team:
“Signing for ‘PackagedDocument. requires a development team. Select a development team in the project editor.”

### Set your own appID, one that is registered in your team Portal Developer page.
Go to your Xcode target, select “General”, refer to the “Identity” section and change the “Bundle Identifier” to your own.

### Turn on iCloud Capability.
Go to your Xcode target, select “Capabilities” page, refer to iCloud, turn it on.  Uncheck “Key-Value storage” (its not used by this sample), and check “iCloud Documents”.  Pick the container you want to use, typically this is set to the “Use default container” if your container id matches your app’s bundle ID, and then prefixed with “iCloud.”

### Log in to iCloud on each Mac that is used.
Every Mac machine you test must be logged into iCloud with the same account.  Refer to System Preferences -> iCloud, and sign in with your iCloud Account.  Make sure iCloud Drive is checked.

## Build Requirements

macOS 10.12 or later

## Runtime Requirements

macOS 10.12 or later

Copyright (C) 2012-2017 Apple Inc. All rights reserved.

url: https://developer.apple.com/library/archive/samplecode/PackagedDocument/Introduction/Intro.html

## Swift Version:
This version was created by Gustavo Tavares and is free to copy, reuse and everything...
