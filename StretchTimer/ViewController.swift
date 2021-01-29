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
    @IBOutlet weak var setTimeLabel: UILabel!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var pauseButton: UIButton!
    
    var calendar: Calendar = Calendar.current
    var numSetOrMin = 0
    var timeStarted: Date?
    let workSystemSoundID: SystemSoundID = 1022
    let restSystemSoundID: SystemSoundID = 1016
    var isStandingMode = true
    var timer: Timer?
    var timePaused: Date?
    var isPaused = false
    
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
        if isPaused {
            timeStarted?.addTimeInterval(Date().timeIntervalSince(timePaused!))
            pauseButton.setTitle("Pause", for: .normal)
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(executeEverySecond), userInfo: nil, repeats: true)
        } else {
            pauseButton.setTitle("Resume", for: .normal)
            timer?.invalidate()
            timer = nil
            timePaused = Date()
        }
        isPaused = !isPaused
    }
    
    @IBAction func resetButtonPressed(_ sender: Any) {
        initialSetup()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.shared.isIdleTimerDisabled = true
        
        initialSetup()
    }
    
    func initialSetup() {
        showCurrentTime()
        
        if isStandingMode {
            numSetOrMin = 0
            setBetweenLabel.text = ":"
        } else {
            numSetOrMin = 1
            setBetweenLabel.text = "-"
        }
        timeStarted = Date().addingTimeInterval(1.0)

        setLabel.text = String(numSetOrMin)
        setTimeLabel.text = "0"
        
        AudioServicesPlaySystemSound(workSystemSoundID)

        if !isPaused {
            timer?.invalidate()
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(executeEverySecond), userInfo: nil, repeats: true)
        }
    }
    
    @objc
    func executeEverySecond() {
        showCurrentTime()
        showSet()
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
    
    func showSet() {
        var numSetSeconds = Int(Date().timeIntervalSince(timeStarted!))
        if isStandingMode {
            numSetSeconds += 1
            if numSetSeconds == 1200 {
                setLabel.textColor = .green
                setBetweenLabel.textColor = .green
                setTimeLabel.textColor = .green
                AudioServicesPlaySystemSound(restSystemSoundID)
            } else if numSetSeconds == 3600 {
                numSetSeconds = 0
                setLabel.textColor = .white
                setBetweenLabel.textColor = .white
                setTimeLabel.textColor = .white
                AudioServicesPlaySystemSound(workSystemSoundID)
            }
            setLabel.text = String(numSetSeconds / 60)
            setTimeLabel.text = String(numSetSeconds % 60)
        } else {
            numSetSeconds += 1
            if numSetSeconds > 60 {
                numSetSeconds = 0
                setTimeLabel.textColor = .white

                numSetOrMin += 1
                setLabel.text = String(numSetOrMin)
                
            } else if numSetSeconds == 30 {
                AudioServicesPlaySystemSound(restSystemSoundID)
            } else if numSetSeconds == 31 {
                setTimeLabel.textColor = .green
            } else if numSetSeconds == 60 {
                AudioServicesPlaySystemSound(workSystemSoundID)
            }
            setTimeLabel.text = String(numSetSeconds)
        }
    }
    
    func getTwoDigit(_ num: Int) -> String {
        if num < 10 {
            return "0\(num)"
        } else {
            return String(num)
        }
    }
}

