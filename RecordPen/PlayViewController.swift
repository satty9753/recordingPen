//
//  PlayViewController.swift
//  RecordPen
//
//  Created by Michelle Chen on 2017/8/26.
//  Copyright © 2017年 Michelle Chen. All rights reserved.
//

import UIKit
import AVFoundation

class PlayViewController: UIViewController,AVAudioPlayerDelegate {

    @IBOutlet weak var titleLabel: UILabel!
    var audioPlayer: AVAudioPlayer!
    var recordingArray = ["name":String(),"path":String()]
    var isPlaying = false
    var timer:Timer!
    @IBOutlet weak var processSlider: UISlider!
    @IBOutlet weak var playButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        titleLabel.text = recordingArray["name"]
        preparePlay()
        processSlider.maximumValue = Float(audioPlayer.duration)
        // execute every 0.1 seconds
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateSlider), userInfo: nil, repeats: true)
        }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    func getFileUrl()->URL{
        let path = recordingArray["path"]
        let url = URL(string: path!)
        return url!
       
    }
    
    func preparePlay(){
        do{
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            audioPlayer = try AVAudioPlayer(contentsOf: getFileUrl())
            audioPlayer.delegate = self
            audioPlayer.prepareToPlay()
        }
        catch{
            print("play error")
        }
    }
    

    @IBAction func pressToPlay(_ sender: Any) {
        if(isPlaying){
            audioPlayer.stop()
            playButton.setTitle("Stop", for: .normal)
            isPlaying = false
        }
        else{
            if FileManager.default.fileExists(atPath: getFileUrl().path){
                print("file exists.")
                audioPlayer.play()
                playButton.setTitle("Play", for: .normal)
                isPlaying = true
            }
        
    }
    }
    
    @IBAction func backToPreviousPage(_ sender: Any) {
        //terminate timer
        timer.invalidate()
        self.dismiss(animated: true, completion: nil)
       
    }
    //sharing files with UIActivityViewController
    @IBAction func shareFiles(_ sender: Any) {
        var sharingObject = [URL]()
        sharingObject.append(getFileUrl())
        let activityViewController = UIActivityViewController(activityItems: [ sharingObject ], applicationActivities: nil)
        self.present(activityViewController, animated: true, completion: nil)
        
    }
    //control AudioTime with slider
    @IBAction func changeAudioTime(_ sender: Any) {
        if (isPlaying){
        audioPlayer.stop()
        audioPlayer.currentTime = TimeInterval(processSlider.value)
        preparePlay()
        audioPlayer.play()
        }
        else{
        audioPlayer.currentTime = TimeInterval(processSlider.value)
        preparePlay()
        audioPlayer.play()
        }
    }
    func updateSlider(){
      processSlider.value = Float(audioPlayer.currentTime)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
