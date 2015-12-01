//
//  AudioRecordViewController.swift
//  MapTheFuture
//
//  Created by Mac Bellingrath on 11/28/15.
//  Copyright © 2015 Mac Bellingrath. All rights reserved.
//

import UIKit
import IQAudioRecorderController

class AudioRecordViewController: UIViewController, IQAudioRecorderControllerDelegate {

    
    
    @IBAction func recordButtonPressed(sender: AnyObject) {
        
        let recorderController = IQAudioRecorderController()
        recorderController.delegate = self
        self.presentViewController(recorderController, animated: true, completion: nil)
        
        
    }

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - AudioRecorder
    
    func audioRecorderController(controller: IQAudioRecorderController!, didFinishWithAudioAtPath filePath: String!) {
        //
    }
    func audioRecorderControllerDidCancel(controller: IQAudioRecorderController!) {
        print("canceled recording")
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
