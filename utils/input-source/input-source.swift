import Carbon
import Foundation

func listSources() {
    let sources = TISCreateInputSourceList(nil, false).takeRetainedValue() as! [TISInputSource]
    for source in sources {
        let isSelectable = TISGetInputSourceProperty(source, kTISPropertyInputSourceIsSelectCapable)
        if let selectablePtr = isSelectable,
            Unmanaged<AnyObject>.fromOpaque(selectablePtr).takeUnretainedValue() as! Bool
        {
            let idPtr = TISGetInputSourceProperty(source, kTISPropertyInputSourceID)
            let id = Unmanaged<AnyObject>.fromOpaque(idPtr!).takeUnretainedValue() as! String
            print(id)
        }
    }
}

func setSource(id: String) {
    let filter = [kTISPropertyInputSourceID: id] as CFDictionary
    guard
        let sources = TISCreateInputSourceList(filter, false)?.takeRetainedValue()
            as? [TISInputSource],
        let target = sources.first
    else {
        fputs("Error: Source '\(id)' not found.\n", stderr)
        exit(1)
    }
    TISSelectInputSource(target)
}

func getCurrent() {
    let source = TISCopyCurrentKeyboardInputSource().takeUnretainedValue()
    let idPtr = TISGetInputSourceProperty(source, kTISPropertyInputSourceID)
    let id = Unmanaged<AnyObject>.fromOpaque(idPtr!).takeUnretainedValue()
    print(id)
}

let args = CommandLine.arguments
if args.count == 1 {
    getCurrent()
} else if args[1] == "list" {
    listSources()
} else {
    setSource(id: args[1])
}
