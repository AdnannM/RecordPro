//
//  ViewController.swift
//  RecordPro
//
//  Created by Adnann Muratovic on 11.08.21.
//

import UIKit
import AVFoundation

class RecordProViewController: UIViewController {

    // MARK: - Properties
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer?
    
    private var timer: Timer?
    private var elapsedTimeInSecunde: Int = 0
    
    // MARK: - ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated
    }
    
    // MARK: - Setup Timer
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { timer in
            self.elapsedTimeInSecunde += 1
            
            self.updateTimeLabel()
        })
    }
    
    // MARK: - Pause timer
    private func pauseTimer() {
        timer?.invalidate()
    }
    
    // MARK: - ResetTimer
    private func resetTimer() {
        timer?.invalidate()
        elapsedTimeInSecunde = 0
        updateTimeLabel()
    }
    
    // MARK: - Update TimeLabel
    private func updateTimeLabel() {
        let seconds = elapsedTimeInSecunde % 60
        let minutes = (elapsedTimeInSecunde / 60) % 60
        
        timeLabel.text = String(format: "%02d:%02d", minutes, seconds)
    }
    
    // MARK: Configure setup
    private func configure() {
        // Disable Stop/Play buttons when application launches
        stopButton.isEnabled = false
        playButton.isEnabled = false
        
        // Get the document directory. If fails just skip rest of code
        guard let directoryURL = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).first else {
            
            let alertMessage = UIAlertController(title: "Error", message: "Failed to get the document directory for recording the audio. Please try again!", preferredStyle: .alert)
            
            alertMessage.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alertMessage, animated: true, completion: nil)
            
            return
        }
        
        // Set the default audio file
        let audioFileURL = directoryURL.appendingPathComponent("MyAudioMemo.mp4")
        
        // Setup audio session
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            
            // Define the recorder setting
            let recorderSetting: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100.0,
                AVNumberOfChannelsKey: 2,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            
            // Initiate and prepare the recorder
            audioRecorder = try AVAudioRecorder(url: audioFileURL, settings: recorderSetting)
            audioRecorder.delegate = self
            audioRecorder.isMeteringEnabled = true
            audioRecorder.prepareToRecord()
        }
        catch {
            print(error)
        }
    }
    
    // MARK: - Button
    @IBAction func playButton(_ sender: UIButton) {
        if !audioRecorder.isRecording {
            guard let player = try? AVAudioPlayer(contentsOf: audioRecorder.url) else {
                print("Failed to initialize AVAudioPlayer")
                return
            }
            
            audioPlayer = player
            audioPlayer?.delegate = self
            audioPlayer?.play()
            startTimer()
        }
    }
    @IBAction func recordButton(_ sender: UIButton) {
        // Stop audio player before recording
        if let player = audioPlayer,player.isPlaying {
            player.stop()
            resetTimer()
        }
        
        if  !audioRecorder.isRecording {
            let audioSession = AVAudioSession.sharedInstance()
            
            do {
                try audioSession.setActive(true)
                
                // Start recording
                audioRecorder.record()
                startTimer()
                
                // Change the Pause image
                recordButton.setImage(UIImage(named: "Pause"), for: .normal)
            }
            catch {
                print(error.localizedDescription)
            }
        } else {
            // Pause recording
            audioRecorder.pause()
            pauseTimer()
            
            // Change to the Record Image
            recordButton.setImage(UIImage(named: "Record"), for: .normal)
        }
        
        stopButton.isEnabled = true
        playButton.isEnabled = false
    }
    @IBAction func stopButton(_ sender: UIButton) {
        recordButton.setImage(UIImage(named: "Record"), for: .normal)
        recordButton.isEnabled = true
        stopButton.isEnabled = false
        playButton.isEnabled = true
        
        // Stop the audio recorder
        audioRecorder?.stop()
        resetTimer()
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(false)
        }
        catch {
            print(error.localizedDescription)
        }
    }
}

// MARK: - Extension
extension RecordProViewController: AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            let alertMessage = UIAlertController(title: "Finish", message: "Successfully recorded the audio!", preferredStyle: .alert)
            
            alertMessage.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alertMessage, animated: true)
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        playButton.isSelected = false
        resetTimer()
        let alertMessage = UIAlertController(title: "Finish Playing", message: "Finish playing the recording!", preferredStyle: .alert)
        alertMessage.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertMessage, animated: true, completion: nil)
    }
}
