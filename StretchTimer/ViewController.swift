//
//  ViewController.swift
//  StretchTimer
//
//  Created by Sungil Brian Hong on 1/26/21.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var setLabel: UILabel!
    @IBOutlet weak var setBetweenLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var pauseButton: UIButton!
    
    var calendar: Calendar = Calendar.current
    var timeStarted: Date?
    let workSystemSoundID: SystemSoundID = 1022
    let restSystemSoundID: SystemSoundID = 1016
    var isStandingMode = true
    var timer: Timer?
    var timePaused: Date?
    var isPaused = false
    
    // ui methods
    
    @IBAction func segmentSelectionChanged(_ sender: Any) {
        switch segmentControl.selectedSegmentIndex {
        case 0:
            // Standing mode
            isStandingMode = true
        case 1:
            // Stretch mode
            isStandingMode = false
        default:
            break
        }
        initialSetup()
    }
    
    @IBAction func pauseButtonPressed(_ sender: Any) {
        isPaused = !isPaused
        if !isPaused {
            // resume is pressed.
            timeStarted?.addTimeInterval(Date().timeIntervalSince(timePaused!))
            pauseButton.setTitle("Pause", for: .normal)
            executeEverySecond()
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(executeEverySecond), userInfo: nil, repeats: true)
        } else {
            // pause is pressed.
            pauseButton.setTitle("Resume", for: .normal)
            timer?.invalidate()
            timer = nil
            timePaused = Date()
        }
    }
    
    @IBAction func resetButtonPressed(_ sender: Any) {
        initialSetup()
    }
    
    // other methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.shared.isIdleTimerDisabled = true
        
        initialSetup()
    }
    
    func initialSetup() {
        if isStandingMode {
            setBetweenLabel.text = ":"
        } else {
            setBetweenLabel.text = "-"
        }

        timeStarted = Date()
        executeEverySecond()

        if isPaused {
            timePaused = Date()
        } else {
            timer?.invalidate()
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(executeEverySecond), userInfo: nil, repeats: true)
        }
    }
    
    @objc
    func executeEverySecond() {
        showCurrentTime()
        showSetAndCount()
    }
    
    func showCurrentTime() {
        let date = Date()
        var hour = calendar.component(.hour, from: date)
        var isAM = true
        if hour > 12 {
            hour -= 12
            isAM = false
        }
        let min = calendar.component(.minute, from: date)
        let second = calendar.component(.second, from: date)
        timeLabel.text = "\(getTwoDigit(hour)):\(getTwoDigit(min)):\(getTwoDigit(second))\(isAM ? "am" : "pm")"
    }
    
    func showSetAndCount() {
        let totalSeconds = Int(Date().timeIntervalSince(timeStarted!))
        if isStandingMode {
            if totalSeconds % 3600 == 0 {
                setLabel.textColor = .white
                setBetweenLabel.textColor = .white
                countLabel.textColor = .white
                if !isPaused {
                    AudioServicesPlaySystemSound(workSystemSoundID)
                }
            } else if totalSeconds % 1200 == 0 {
                setLabel.textColor = .green
                setBetweenLabel.textColor = .green
                countLabel.textColor = .green
                AudioServicesPlaySystemSound(restSystemSoundID)
            }
        } else {
            if totalSeconds % 60 == 0 {
                countLabel.textColor = .white
                if !isPaused {
                AudioServicesPlaySystemSound(workSystemSoundID)
                }
                
            } else if totalSeconds % 60 == 30 {
                AudioServicesPlaySystemSound(restSystemSoundID)
                countLabel.textColor = .green
            }
        }
        setLabel.text = String(totalSeconds / 60)
        countLabel.text = String(totalSeconds % 60)
    }
    
    func getTwoDigit(_ num: Int) -> String {
        if num < 10 {
            return "0\(num)"
        } else {
            return String(num)
        }
    }
}

