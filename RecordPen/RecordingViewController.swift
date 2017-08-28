//
//  RecordingViewController.swift
//  RecordPen
//
//  Created by Michelle Chen on 2017/8/13.
//  Copyright © 2017年 Michelle Chen. All rights reserved.
//

import UIKit
import AVFoundation

class RecordingViewController: UIViewController, AVAudioRecorderDelegate{

    @IBOutlet weak var recordingLabel: UILabel!
    @IBOutlet weak var recordingButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    var audioRecorder: AVAudioRecorder!
    var meterTimer:Timer!
    var recordingDic = [["name":String(),"path":String()]]
    var isAudioRecordingGranted: Bool!
    var isRecording = false
    var isPlaying = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        checkRecordingPermisson()
               }
    func checkRecordingPermisson(){
        switch AVAudioSession.sharedInstance().recordPermission(){
        case AVAudioSessionRecordPermission.granted:
            isAudioRecordingGranted = true
            break
        case AVAudioSessionRecordPermission.denied:
            isAudioRecordingGranted = false
            break
        case AVAudioSessionRecordPermission.undetermined:
            //reference cycle
            AVAudioSession.sharedInstance().requestRecordPermission(){ [unowned self] allowed in
            DispatchQueue.main.async {
                if allowed {
                self.isAudioRecordingGranted = true
                }
                else{
                self.isAudioRecordingGranted = false
                }
                 }
            }
            break
        default:
            break
        }
    }
    func getDocumentsDirectory() -> URL{
         let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
         let documentsDirectory = paths[0]
        print("documentsDirectory: ",documentsDirectory)

         return documentsDirectory
    }
    func getFileUrl() -> URL
    {   var i = 0
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-"
        var filename = formatter.string(from: date)
        let calendar = Calendar.current
        
        let hour = String(calendar.component(.hour, from: date))
        let minutes = String(calendar.component(.minute, from: date))
        let seconds = String(calendar.component(.second, from: date))
        filename = filename + hour + minutes + seconds + ".m4a"
        let filePath = getDocumentsDirectory().appendingPathComponent(filename)
        let filePathString = filePath.path
        recordingDic[i]["name"] = filename
        recordingDic[i]["path"] = filePathString
        i += 1
        print("filename: ",filename)
        return filePath
    }
    func setupRecord(){
        if isAudioRecordingGranted==true{
        let recordingSession = AVAudioSession.sharedInstance()
            do{
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord, with: .defaultToSpeaker)
            try recordingSession.setActive(true)
                let settings = [
                    AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                    AVSampleRateKey: 44100,
                    AVNumberOfChannelsKey: 2,
                    AVEncoderAudioQualityKey:AVAudioQuality.high.rawValue
                ]
                audioRecorder = try AVAudioRecorder(url: getFileUrl(), settings: settings)
                audioRecorder.delegate = self
                audioRecorder.isMeteringEnabled = true
                audioRecorder.prepareToRecord()
            }
            catch let error{
                displayAlert(title: "錯誤", description: error.localizedDescription, aciton: "OK")
            }
        }
        else{
           displayAlert(title: "錯誤", description: "不能獲取你的麥克風權限", aciton: "OK")
        }
        
    }
    
     @IBAction func startRecording(_ sender: Any) {
        if isRecording==true{
            finishAudioRecording(success: true)
            isRecording=false
        }
        else{
           setupRecord()
            DispatchQueue.main.async {
            self.audioRecorder.record() //start or resume record to file
            }
           meterTimer = Timer.scheduledTimer(timeInterval: 0.1, target:self, selector:#selector(updateAudioMeter(timer:)), userInfo:nil, repeats:true)
            isRecording=true
            
        }
        
    }
    func finishAudioRecording(success:Bool){
        if success{
            audioRecorder.stop()
            audioRecorder=nil
            meterTimer.invalidate()
            print("record successfully")
        }
        else{
            displayAlert(title: "錯誤", description: "出現未預期的錯誤", aciton: "qq")
        }
    }

    func updateAudioMeter(timer: Timer){
        if audioRecorder.isRecording == true{
            let hr = Int((audioRecorder.currentTime / 60) / 60)
            let min = Int(audioRecorder.currentTime / 60)
            let sec = Int(audioRecorder.currentTime.truncatingRemainder(dividingBy: 60))
            let totalTimeString = String(format: "%02d:%02d:%02d", hr, min, sec)
            recordingLabel.text = totalTimeString
            audioRecorder.updateMeters()
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func displayAlert(title: String, description: String, aciton:String){
        let alert = UIAlertController(title: title, message: description, preferredStyle: .alert)
        let action = UIAlertAction(title: title, style: .default) { (result:UIAlertAction) in
             _ = self.navigationController?.popViewController(animated: true)
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? MainViewController{
             controller.recordArray = recordingDic
        }
    }
    

}
