import SwiftUI
import AVFoundation

@main
struct BBBJoinerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            MainContentView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var audioEngine = AVAudioEngine()
    var mixer = AVAudioMixerNode()
    var systemAudioPlayer = AVAudioPlayerNode()
    var micAudioPlayer = AVAudioPlayerNode()

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupAudioEngine()
        requestMediaPermissions()
    }

    func setupAudioEngine() {
        let inputNode = audioEngine.inputNode
        let outputNode = audioEngine.outputNode

        // Attach nodes
        audioEngine.attach(mixer)
        audioEngine.attach(systemAudioPlayer)
        audioEngine.attach(micAudioPlayer)

        // Connect nodes
        let format = inputNode.inputFormat(forBus: 0)
        audioEngine.connect(inputNode, to: mixer, format: format)
        audioEngine.connect(systemAudioPlayer, to: mixer, format: format)
        audioEngine.connect(micAudioPlayer, to: mixer, format: format)
        audioEngine.connect(mixer, to: outputNode, format: format)

        // Start audio engine
        do {
            try audioEngine.start()
            print("Audio engine started successfully")
        } catch {
            print("Failed to start audio engine: \(error)")
        }
    }
    
    func requestMediaPermissions() {
        AVCaptureDevice.requestAccess(for: .audio) { granted in
            if granted {
                print("Microphone access granted")
            } else {
                print("Microphone access denied")
            }
        }

        AVCaptureDevice.requestAccess(for: .video) { granted in
            if granted {
                print("Camera access granted")
            } else {
                print("Camera access denied")
            }
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        audioEngine.stop()
    }
}
