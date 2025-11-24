import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    
    self.contentViewController = flutterViewController
    
    // Ensure the view resizes with the window
    flutterViewController.view.autoresizingMask = [.width, .height]

    RegisterGeneratedPlugins(registry: flutterViewController)

    // Ensure the window is opaque and standard
    self.isOpaque = true
    self.backgroundColor = .windowBackgroundColor
    
    // Ensure style mask allows resizing
    self.styleMask.insert([.titled, .resizable, .miniaturizable, .closable, .fullSizeContentView])
    
    // Restore standard title bar
    self.titlebarAppearsTransparent = false
    
    // Set window level to normal
    self.level = .normal
    
    // Ensure Flutter view is opaque
    flutterViewController.backgroundColor = .black
    
    // Set minimum size to prevent window from being too small
    self.minSize = NSSize(width: 600, height: 400)
    
    // FORCE initial window size and position natively
    // This runs before Flutter draws, preventing the "1cm window" glitch
    let windowSize = NSSize(width: 1000, height: 700)
    let screenFrame = NSScreen.main?.frame ?? NSRect(x: 0, y: 0, width: 1920, height: 1080)
    let windowOrigin = NSPoint(
      x: (screenFrame.width - windowSize.width) / 2,
      y: (screenFrame.height - windowSize.height) / 2
    )
    
    self.setFrame(NSRect(origin: windowOrigin, size: windowSize), display: true)
    self.center()
    
    // Call super last to ensure our settings stick
    super.awakeFromNib()
  }

  // Override orderFront to enforce size just before showing
  override func orderFront(_ sender: Any?) {
    let windowSize = NSSize(width: 1000, height: 700)
    let screenFrame = NSScreen.main?.frame ?? NSRect(x: 0, y: 0, width: 1920, height: 1080)
    let windowOrigin = NSPoint(
      x: (screenFrame.width - windowSize.width) / 2,
      y: (screenFrame.height - windowSize.height) / 2
    )
    
    self.setFrame(NSRect(origin: windowOrigin, size: windowSize), display: true)
    super.orderFront(sender)
  }
}

