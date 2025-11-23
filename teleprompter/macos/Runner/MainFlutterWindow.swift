import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
    
    // CRITICAL: Set window transparency for macOS
    // This is required because Flutter's backgroundColor: Colors.transparent is ignored
    // Without these settings, the window will show a black background
    self.isOpaque = false
    self.backgroundColor = .clear
    
    // Set Flutter view background to clear
    // This ensures the Flutter content renders with transparency
    let flutterView = flutterViewController.view
    flutterView.wantsLayer = true
    flutterView.layer?.backgroundColor = NSColor.clear.cgColor
    
    self.hasShadow = true
    
    // Note: window_manager and macos_window_utils will handle:
    // - level (always on top)
    // - styleMask (borderless, etc.)
    // - titlebar settings
    // - dynamic background color changes via setBackgroundColor()
  }
}

