//
//  MyControllerMenu.swift
//  VirtualC64
//
//  Created by Dirk Hoffmann on 25.01.18.
//

import Foundation

extension MyController {
    
    @objc override open func validateMenuItem(_ item: NSMenuItem) -> Bool {
  
        // View menu
        if item.action == #selector(MyController.toggleStatusBarAction(_:)) {
            item.title = statusBar ? "Hide Status Bar" : "Show Status Bar"
            return true
        }
        
        // Keyboard menu
        if item.action == #selector(MyController.toggleShiftKey(_:)) {
            item.state = c64.keyboard.shiftKeyIsPressed() ? .on : .off
            return true
        }
        if item.action == #selector(MyController.toggleCommodoreKey(_:)) {
            item.state = c64.keyboard.commodoreKeyIsPressed() ? .on : .off
            return true
        }
        if item.action == #selector(MyController.toggleCtrlKey(_:)) {
            item.state = c64.keyboard.ctrlKeyIsPressed() ? .on : .off
            return true
        }
        if item.action == #selector(MyController.toggleRunstopKey(_:)) {
            item.state = c64.keyboard.runstopKeyIsPressed() ? .on : .off
            return true
        }
        
        // Disk menu
        if item.action == #selector(MyController.driveAction(_:)) {
            item.title = c64.iec.isDriveConnected() ? "Power off" : "Power on"
            return true
        }
        if item.action == #selector(MyController.insertBlankDisk(_:)) {
            return c64.iec.isDriveConnected()
        }
        if item.action == #selector(MyController.driveEjectAction(_:)) {
            return c64.iec.isDriveConnected() && c64.vc1541.hasDisk()
        }
        if item.action == #selector(MyController.exportDisk(_:)) {
            return c64.vc1541.hasDisk()
        }

        // Tape menu
        if item.action == #selector(MyController.playOrStopAction(_:)) {
            item.title = c64.datasette.playKey() ? "Press Stop" : "Press Play"
            return c64.datasette.hasTape()
        }
        if item.action == #selector(MyController.rewindAction(_:)) {
            return c64.datasette.hasTape()
        }
        if item.action == #selector(MyController.ejectTapeAction(_:)) {
            return c64.datasette.hasTape()
        }
        
        // Cartridge menu
        if item.action == #selector(MyController.finalCartridgeIIIaction(_:)) {
            return c64.expansionport.cartridgeType() == CRT_FINAL_III
        }
        
        // Debug menu
        if item.action == #selector(MyController.pauseAction(_:)) {
            return c64.isRunning();
        }
        if item.action == #selector(MyController.continueAction(_:)) ||
            item.action == #selector(MyController.stepIntoAction(_:)) ||
            item.action == #selector(MyController.stepOutAction(_:)) ||
            item.action == #selector(MyController.stepOverAction(_:)) ||
            item.action == #selector(MyController.stopAndGoAction(_:)) {
            return c64.isHalted();
        }
        if item.action == #selector(MyController.markIRQLinesAction(_:)) {
            item.state = c64.vic.showIrqLines() ? .on : .off
        }
        if item.action == #selector(MyController.markDMALinesAction(_:)) {
            item.state = c64.vic.showDmaLines() ? .on : .off
        }
        if item.action == #selector(MyController.hideSpritesAction(_:)) {
            item.state = c64.vic.hideSprites() ? .on : .off
        }

        if item.action == #selector(MyController.traceAction(_:)) {
            return c64.developmentMode();
        }
        if item.action == #selector(MyController.traceC64CpuAction(_:)) {
            item.state = c64.cpu.tracingEnabled() ? .on : .off
        }
        if item.action == #selector(MyController.traceIecAction(_:)) {
            item.state = c64.iec.tracingEnabled() ? .on : .off
        }
        if item.action == #selector(MyController.traceVC1541CpuAction(_:)) {
            item.state = c64.vc1541.cpu.tracingEnabled() ? .on : .off
        }
        if item.action == #selector(MyController.traceViaAction(_:)) {
            item.state = c64.vc1541.via1.tracingEnabled() ? .on : .off
        }
        
        if item.action == #selector(MyController.dumpStateAction(_:)) {
            return c64.developmentMode();
        }

        return true
    }
   
    // -----------------------------------------------------------------
    // Action methods (File menu)
    // -----------------------------------------------------------------
    
    @IBAction func saveScreenshotDialog(_ sender: Any!) {
    
    // NSArray *fileTypes = @[@"tif", @"jpg", @"gif", @"png", @"psd", @"tga"];
    
        // Create and show save panel
        let savePanel = NSSavePanel()
        savePanel.canSelectHiddenExtension = true
        savePanel.allowedFileTypes = ["tif", "jpg", "gif", "png", "psd", "tga"]
        savePanel.prompt = "Export"
        savePanel.title = "Export"
        savePanel.nameFieldLabel = "Export As:"
        if savePanel.runModal() != .OK {
            return
        }
    
        // Save image
        if let url = savePanel.url {
            track("Saving screenshot to file \(url)")
            let image = screenshot()
            let data = image?.tiffRepresentation
            do {
                try data?.write(to: url)
                track("Image saved successfully")
            } catch {
                track("Cannot save image to file")
            }
        }
    }
    
    @IBAction func quicksaveScreenshot(_ sender: Any!) {
        
    /*
    NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDesktopDirectory, NSUserDomainMask, YES);
    NSString *desktopPath = [paths objectAtIndex:0];
    NSString *filePath = [desktopPath stringByAppendingPathComponent:@"Untitled.png"];
    NSURL *url = [NSURL fileURLWithPath:filePath];
    
    NSLog(@"Quicksaving screenshot to file %@", url);
    
    NSImage *image = [self screenshot];
    NSData *data = [image TIFFRepresentation];
    [data writeToURL:url atomically:YES];
 */
    }
    
    
    // -----------------------------------------------------------------
    // Action methods (View menu)
    // -----------------------------------------------------------------

    @IBAction func toggleStatusBarAction(_ sender: Any!) {
        
        let undo = undoManager()
        undo?.registerUndo(withTarget: self) {
            targetSelf in targetSelf.toggleStatusBarAction(sender)
        }
        
        showStatusBar(!statusBar)
    }
    
    
    @objc public func showStatusBar(_ value: Bool) {
        
        if !statusBar && value {
            
            greenLED.isHidden = false
            redLED.isHidden = false
            progress.isHidden = false
            tapeProgress.isHidden = false
            driveIcon.isHidden = !c64.vc1541.hasDisk()
            driveEject.isHidden = !c64.vc1541.hasDisk()
            tapeIcon.isHidden = !c64.datasette.hasTape()
            cartridgeIcon.isHidden = !c64.expansionport.cartridgeAttached()
            cartridgeEject.isHidden = !c64.expansionport.cartridgeAttached()
            info.isHidden = false
            clockSpeed.isHidden = false
            clockSpeedBar.isHidden = false
            warpIcon.isHidden = false
            
            shrink()
            window?.setContentBorderThickness(24, for: .minY)
            adjustWindowSize()
            statusBar = true
        }
 
        if statusBar && !value {
            
            greenLED.isHidden = true
            redLED.isHidden = true
            progress.isHidden = true
            tapeProgress.isHidden = true
            driveIcon.isHidden = true
            driveEject.isHidden = true
            tapeIcon.isHidden = true
            cartridgeIcon.isHidden = true
            cartridgeEject.isHidden = true
            info.isHidden = true
            clockSpeed.isHidden = true
            clockSpeedBar.isHidden = true
            warpIcon.isHidden = true
            
            expand()
            window?.setContentBorderThickness(0, for: .minY)
            adjustWindowSize()
            statusBar = false
        }
    }
        
    // -----------------------------------------------------------------
    // Action methods (Keyboard menu)
    // -----------------------------------------------------------------


    @IBAction func shiftAction(_ sender: Any!) {
        simulateUserPressingKey(C64KeyFingerprint(C64KEY_SHIFT))
    }
    
    // >>>>
    @IBAction func shiftCommodoreKeyAction(_ sender: Any!) {
        simulateUserPressingKey(withShift: C64KeyFingerprint(C64KEY_COMMODORE))
    }
    @IBAction func shiftCtrlKeyAction(_ sender: Any!) {
        simulateUserPressingKey(withShift: C64KeyFingerprint(C64KEY_CTRL))
    }
    @IBAction func shiftRunstopKeyAction(_ sender: Any!) {
        simulateUserPressingKey(withShift: C64KeyFingerprint(C64KEY_RUNSTOP))
    }
    @IBAction func shiftRestoreAction(_ sender: Any!) {
        simulateUserPressingKey(withShift: C64KeyFingerprint(C64KEY_RESTORE))
    }
    @IBAction func shiftLeftarrowAction(_ sender: Any!) {
        simulateUserPressingKey(withShift: C64KeyFingerprint(C64KEY_LEFTARROW))
    }
    @IBAction func shiftUparrowAction(_ sender: Any!) {
        simulateUserPressingKey(withShift: C64KeyFingerprint(C64KEY_UPARROW))
    }
    @IBAction func shiftPowndAction(_ sender: Any!) {
        simulateUserPressingKey(withShift: C64KeyFingerprint(C64KEY_POUND))
    }
    // <<<<
    
    @IBAction func commodoreKeyAction(_ sender: Any!) {
        simulateUserPressingKey(C64KeyFingerprint(C64KEY_COMMODORE))
    }
    @IBAction func ctrlKeyAction(_ sender: Any!) {
        simulateUserPressingKey(C64KeyFingerprint(C64KEY_CTRL))
    }
    @IBAction func runstopAction(_ sender: Any!) {
        simulateUserPressingKey(C64KeyFingerprint(C64KEY_RUNSTOP))
    }
    @IBAction func restoreAction(_ sender: Any!) {
        simulateUserPressingKey(C64KeyFingerprint(C64KEY_RESTORE))
    }
    @IBAction func runstopRestoreAction(_ sender: Any!) {
        simulateUserPressingKey(withRunstop: C64KeyFingerprint(C64KEY_RESTORE))
    }
    @IBAction func leftarrowAction(_ sender: Any!) {
        simulateUserPressingKey(C64KeyFingerprint(C64KEY_LEFTARROW))
    }
    @IBAction func uparrowAction(_ sender: Any!) {
        simulateUserPressingKey(C64KeyFingerprint(C64KEY_UPARROW))
    }
    @IBAction func powndAction(_ sender: Any!) {
        simulateUserPressingKey(C64KeyFingerprint(C64KEY_POUND))
    }
    @IBAction func clearKeyAction(_ sender: Any!) {
        simulateUserPressingKey(C64KeyFingerprint(C64KEY_CLR))
    }
    @IBAction func homeKeyAction(_ sender: Any!) {
        simulateUserPressingKey(C64KeyFingerprint(C64KEY_HOME))
    }
    @IBAction func insertKeyAction(_ sender: Any!) {
        simulateUserPressingKey(C64KeyFingerprint(C64KEY_INST))
    }
    @IBAction func deleteKeyAction(_ sender: Any!) {
        simulateUserPressingKey(C64KeyFingerprint(C64KEY_DEL))
    }
    
    // -----
    
    @IBAction func toggleShiftKey(_ sender: Any!) {
        c64.keyboard.toggleShiftKey()
        c64.keyboard.dump()
    }
    @IBAction func toggleCommodoreKey(_ sender: Any!) {
        c64.keyboard.toggleCommodoreKey()
        c64.keyboard.dump()
    }
    @IBAction func toggleCtrlKey(_ sender: Any!) {
        c64.keyboard.toggleCtrlKey()
        c64.keyboard.dump()
    }
    @IBAction func toggleRunstopKey(_ sender: Any!) {
        c64.keyboard.toggleRunstopKey()
        c64.keyboard.dump()
    }
    
    // ----
    
    @IBAction func loadDirectoryAction(_ sender: Any!) {
        simulateUserTypingText("LOAD \"$\",8")
    }
    @IBAction func listAction(_ sender: Any!) {
        simulateUserTypingText("LIST")
    }
    @IBAction func loadFirstFileAction(_ sender: Any!) {
        simulateUserTypingText("LOAD \"*\",8,1")
    }
    @IBAction func runProgramAction(_ sender: Any!) {
        simulateUserTypingText("RUN")
    }
    @IBAction func formatDiskAction(_ sender: Any!) {
        simulateUserTypingText("OPEN 1,8,15,\"N:TEST, ID\": CLOSE 1")
    }

 
    // -----------------------------------------------------------------
    // Action methods (Disk menu)
    // -----------------------------------------------------------------

    @IBAction func driveAction(_ sender: Any!) {
        
        track()
        if c64.iec.isDriveConnected() {
            c64.iec.disconnectDrive()
        } else {
            c64.iec.connectDrive()
        }
    }
    
    @IBAction func driveEjectAction(_ sender: Any!) {
        
        if !c64.vc1541.diskModified() ||
            showDiskIsUnsafedAlert() == .alertFirstButtonReturn {
            
            c64.vc1541.ejectDisk()
        }
    }

    @IBAction func insertBlankDisk(_ sender: Any!) {
        
        if !c64.vc1541.diskModified() ||
            showDiskIsUnsafedAlert() == .alertFirstButtonReturn {

            c64.insertDisk(ArchiveProxy.make())
        }
    }
    
    @IBAction func exportDisk(_ sender: Any!) {

        let nibName = NSNib.Name(rawValue: "ExportDiskDialog")
        let exportPanel = ExportDiskController.init(windowNibName: nibName)
        exportPanel.showSheet(withParent: self)
    }
    
    // -----------------------------------------------------------------
    // Action methods (Datasette menu)
    // -----------------------------------------------------------------
    
    @IBAction func playOrStopAction(_ sender: Any!) {
        track()
        if c64.datasette.playKey() {
            c64.datasette.pressStop()
        } else {
            c64.datasette.pressPlay()
        }
    }
    
    @IBAction func rewindAction(_ sender: Any!) {
        track()
        c64.datasette.rewind()
    }

    @IBAction func ejectTapeAction(_ sender: Any!) {
        track()
        c64.datasette.ejectTape()
    }

    
    // -----------------------------------------------------------------
    // Action methods (Cartridge menu)
    // -----------------------------------------------------------------

    @IBAction func finalCartridgeIIIaction(_ sender: Any!) {
        // Dummy action method to enable menu item validation
    }
    
    @IBAction func finalCartridgeIIIfreezeAction(_ sender: Any!) {
        c64.expansionport.pressFirstButton()
    }
    
    @IBAction func finalCartridgeIIIresetAction(_ sender: Any!) {
        c64.expansionport.pressSecondButton()
    }
    
    // -----------------------------------------------------------------
    // Action methods (Debug menu)
    // -----------------------------------------------------------------

    @IBAction func hideSpritesAction(_ sender: Any!) {

        let undo = undoManager()
        undo?.registerUndo(withTarget: self) {
            targetSelf in targetSelf.hideSpritesAction(sender)
        }
        
        c64.vic.setHideSprites(!c64.vic.hideSprites())
    }
  
    @IBAction func markIRQLinesAction(_ sender: Any!) {
    
        let undo = undoManager()
        undo?.registerUndo(withTarget: self) {
            targetSelf in targetSelf.markIRQLinesAction(sender)
        }
        
        c64.vic.setShowIrqLines(!c64.vic.showIrqLines())
    }
    
    @IBAction func markDMALinesAction(_ sender: Any!) {
    
        let undo = undoManager()
        undo?.registerUndo(withTarget: self) {
            targetSelf in targetSelf.markDMALinesAction(sender)
        }
        
        c64.vic.setShowDmaLines(!c64.vic.showDmaLines())
    }
    
    @IBAction func traceAction(_ sender: Any!) {
        // Dummy target to make menu item validatable
    }
    
    @IBAction func dumpStateAction(_ sender: Any!) {
        // Dummy target to make menu item validatable
    }

    @IBAction func traceC64CpuAction(_ sender: Any!) {
        
        let undo = undoManager()
        undo?.registerUndo(withTarget: self) {
            targetSelf in targetSelf.traceC64CpuAction(sender)
        }
        
        c64.cpu.setTraceMode(!c64.cpu.tracingEnabled())
    }
  
    @IBAction func traceIecAction(_ sender: Any!) {
        
        let undo = undoManager()
        undo?.registerUndo(withTarget: self) {
            targetSelf in targetSelf.traceIecAction(sender)
        }
        
        c64.iec.setTraceMode(!c64.iec.tracingEnabled())
    }
 
    @IBAction func traceVC1541CpuAction(_ sender: Any!) {
        
        let undo = undoManager()
        undo?.registerUndo(withTarget: self) {
            targetSelf in targetSelf.traceVC1541CpuAction(sender)
        }
        
        c64.vc1541.cpu.setTraceMode(!c64.vc1541.cpu.tracingEnabled())
    }
  
    @IBAction func traceViaAction(_ sender: Any!) {
        
        let undo = undoManager()
        undo?.registerUndo(withTarget: self) {
            targetSelf in targetSelf.traceViaAction(sender)
        }
        
        c64.vc1541.via1.setTraceMode(!c64.vc1541.via1.tracingEnabled())
        c64.vc1541.via2.setTraceMode(!c64.vc1541.via2.tracingEnabled())
    }
    
    @IBAction func dumpC64(_ sender: Any!) { c64.dump() }
    @IBAction func dumpC64CPU(_ sender: Any!) { c64.cpu.dump() }
    @IBAction func dumpC64CIA1(_ sender: Any!) {c64.cia1.dump() }
    @IBAction func dumpC64CIA2(_ sender: Any!) { c64.cia2.dump() }
    @IBAction func dumpC64VIC(_ sender: Any!) { c64.vic.dump() }
    @IBAction func dumpC64SID(_ sender: Any!) { c64.sid.dump() }
    @IBAction func dumpC64Memory(_ sender: Any!) { c64.mem.dump() }
    @IBAction func dumpVC1541(_ sender: Any!) { c64.vc1541.dump() }
    @IBAction func dumpVC1541CPU(_ sender: Any!) { c64.vc1541.dump() }
    @IBAction func dumpVC1541VIA1(_ sender: Any!) { c64.vc1541.dump() }
    @IBAction func dumpVC1541VIA2(_ sender: Any!) { c64.vc1541.via2.dump() }
    @IBAction func dumpVC1541Memory(_ sender: Any!) { c64.vc1541.mem.dump() }
    @IBAction func dumpKeyboard(_ sender: Any!) { c64.keyboard.dump() }
    @IBAction func dumpC64JoystickA(_ sender: Any!) { c64.joystickA.dump() }
    @IBAction func dumpC64JoystickB(_ sender: Any!) { c64.joystickB.dump(); gamePadManager.listDevices()}
    @IBAction func dumpIEC(_ sender: Any!) { c64.iec.dump() }
    @IBAction func dumpC64ExpansionPort(_ sender: Any!) { c64.expansionport.dump() }
    
    // -----------------------------------------------------------------
    // Action methods (Toolbar)
    // -----------------------------------------------------------------
    
    @IBAction @objc func resetAction(_ sender: Any!) {
        
        let document = self.document as! MyDocument
        document.updateChangeCount(.changeDone)
        
        rotateBack()
        c64.powerUp()
        refresh()
    }
    
}
