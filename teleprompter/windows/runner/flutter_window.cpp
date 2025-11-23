#include "flutter_window.h"

#include <optional>

#include "flutter/generated_plugin_registrant.h"
#include "flutter/method_channel.h"
#include "flutter/standard_method_codec.h"

FlutterWindow::FlutterWindow(const flutter::DartProject& project)
    : project_(project) {}

FlutterWindow::~FlutterWindow() {}

bool FlutterWindow::OnCreate() {
  if (!Win32Window::OnCreate()) {
    return false;
  }

  RECT frame = GetClientArea();

  // The size here must match the window dimensions to avoid unnecessary surface
  // creation / destruction in the startup path.
  flutter_controller_ = std::make_unique<flutter::FlutterViewController>(
      frame.right - frame.left, frame.bottom - frame.top, project_);
  // Ensure that basic setup of the controller was successful.
  if (!flutter_controller_->engine() || !flutter_controller_->view()) {
    return false;
  }
  RegisterPlugins(flutter_controller_->engine());
  SetChildContent(flutter_controller_->view()->GetNativeWindow());

  // Register method channel for window operations
  method_channel_ = std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
      flutter_controller_->engine()->messenger(), "com.teleprompter/window",
      &flutter::StandardMethodCodec::GetInstance());

  method_channel_->SetMethodCallHandler(
      [this](const flutter::MethodCall<flutter::EncodableValue>& call,
             std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        if (call.method_name() == "setMousePassThrough") {
          if (const bool* enabled = std::get_if<bool>(call.arguments())) {
            SetMousePassThrough(*enabled);
            result->Success(flutter::EncodableValue(true));
          } else {
            result->Error("INVALID_ARGUMENT", "Expected boolean argument");
          }
        } else if (call.method_name() == "setWindowOpacity") {
          if (const double* opacity = std::get_if<double>(call.arguments())) {
            SetWindowOpacity(*opacity);
            result->Success(flutter::EncodableValue(true));
          } else {
            result->Error("INVALID_ARGUMENT", "Expected double argument");
          }
        } else {
          result->NotImplemented();
        }
      });

  flutter_controller_->engine()->SetNextFrameCallback([&]() {
    this->Show();
  });

  // Flutter can complete the first frame before the "show window" callback is
  // registered. The following call ensures a frame is pending to ensure the
  // window is shown. It is a no-op if the first frame hasn't completed yet.
  flutter_controller_->ForceRedraw();

  return true;
}

void FlutterWindow::OnDestroy() {
  if (flutter_controller_) {
    flutter_controller_ = nullptr;
  }

  Win32Window::OnDestroy();
}

LRESULT
FlutterWindow::MessageHandler(HWND hwnd, UINT const message,
                              WPARAM const wparam,
                              LPARAM const lparam) noexcept {
  // Give Flutter, including plugins, an opportunity to handle window messages.
  if (flutter_controller_) {
    std::optional<LRESULT> result =
        flutter_controller_->HandleTopLevelWindowProc(hwnd, message, wparam,
                                                      lparam);
    if (result) {
      return *result;
    }
  }

  switch (message) {
    case WM_FONTCHANGE:
      flutter_controller_->engine()->ReloadSystemFonts();
      break;
  }

  return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
}

void FlutterWindow::SetMousePassThrough(bool enabled) {
  HWND hwnd = GetHandle();
  if (!hwnd) {
    return;
  }

  LONG_PTR exStyle = GetWindowLongPtr(hwnd, GWL_EXSTYLE);
  if (enabled) {
    // Enable mouse pass-through by adding WS_EX_TRANSPARENT
    // WS_EX_LAYERED should already be set from window creation
    exStyle |= WS_EX_TRANSPARENT;
  } else {
    // Disable mouse pass-through by removing WS_EX_TRANSPARENT
    exStyle &= ~WS_EX_TRANSPARENT;
  }

  SetWindowLongPtr(hwnd, GWL_EXSTYLE, exStyle);
  // Force window update to apply changes
  SetWindowPos(hwnd, nullptr, 0, 0, 0, 0,
               SWP_NOMOVE | SWP_NOSIZE | SWP_NOZORDER | SWP_FRAMECHANGED);
}

void FlutterWindow::SetWindowOpacity(double opacity) {
  HWND hwnd = GetHandle();
  if (!hwnd) {
    return;
  }

  // Clamp opacity to valid range [0.0, 1.0]
  BYTE alpha = static_cast<BYTE>(255 * (opacity < 0.0 ? 0.0 : (opacity > 1.0 ? 1.0 : opacity)));
  
  // Set layered window attributes for transparency
  SetLayeredWindowAttributes(hwnd, 0, alpha, LWA_ALPHA);
}
