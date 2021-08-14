//
//  RecordVideoViewController.swift
//  RecordPro
//
//  Created by Adnann Muratovic on 14.08.21.
//

import UIKit
import AVKit
import AVFoundation

class RecordVideoViewController: UIViewController {

    // MARK: - Properties
    @IBOutlet weak var cameraButton: UIButton!
    
    // Configure session
    var captureSession = AVCaptureSession()
    
    // Selecting device input
    var currentDevice: AVCaptureDevice!
    
    // Configure output device
    var videoFileOutput: AVCaptureMovieFileOutput!
    
    // Creating a Preview Layer and start the session
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    
    // Saving video data to a Movie File
    var isRecording = false
    
    // MARK: - ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()

    }
    
    // MARK: - Configure Video Player
    private func configure() {
        // Present the session for taking photo in high resolution
        captureSession.sessionPreset = AVCaptureSession.Preset.high
        
        // Get the back-facing camera for capturing videos
        guard let device = AVCaptureDevice.default(.builtInDualWideCamera,
                                                   for: .video,
                                                   position: .back)
        else {
            print("Failed to get the camera device")
            return
        }
        
        currentDevice = device
        
        // Get the input data source
        guard let captureDeviceInput = try? AVCaptureDeviceInput(device: currentDevice) else {
            return
        }
        
        // Configure the session with the output for capturing video
        videoFileOutput = AVCaptureMovieFileOutput()
        
        // Configure the session with the input and the output device
        captureSession.addInput(captureDeviceInput)
        captureSession.addOutput(videoFileOutput)
        
        // Provide a camera preview
        cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.addSublayer(cameraPreviewLayer!)
        cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        cameraPreviewLayer?.frame = view.layer.frame
        
        // Bring the camera button to fron
        view.bringSubviewToFront(cameraButton)
        
        // Start session
        captureSession.startRunning()
    }
    
    // MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "playVideo" {
            let playVideoViewController = segue.destination as! AVPlayerViewController
            let videoFileURL = sender as! URL
            playVideoViewController.player = AVPlayer(url: videoFileURL)
        }
    }
    
    // MARK: - Back to the Camera Screen
    @IBAction func unwindToCamera(sender: UIStoryboardSegue) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Action
    @IBAction func capture(_ sender: AnyObject) {
        
        if !isRecording {
            isRecording = true
            
            UIView.animate(withDuration: 0.5,
                           delay: 0.0,
                           options: [.repeat, .autoreverse, .allowUserInteraction],
                           animations: {
                            
                    self.cameraButton.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
                }, completion: nil)
                    let outputPath = NSTemporaryDirectory() + "output.mov"
                    let outputFileURL = URL(fileURLWithPath: outputPath)
                            
                    self.videoFileOutput?.startRecording(to: outputFileURL,
                                                     recordingDelegate: self)
        } else {
            isRecording = false
            
            UIView.animate(withDuration: 0.5,
                           delay: 1.0,
                           options: [],
                           animations: {
                            
                     self.cameraButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                
            }, completion: nil)
            
            cameraButton.layer.removeAllAnimations()
            videoFileOutput?.stopRecording()
        }
    }
}

// MARK: - Extension
extension RecordVideoViewController: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        guard error == nil else {
            print(error ?? "")
            return
        }
        
        performSegue(withIdentifier: "playVideo", sender: outputFileURL)
    }
}
