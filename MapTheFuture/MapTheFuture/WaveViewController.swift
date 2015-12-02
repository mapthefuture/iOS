//
//  WaveViewController.swift
//  MapTheFuture
//
//  Created by Mac Bellingrath on 12/1/15.
//  Copyright © 2015 Mac Bellingrath. All rights reserved.
//

import UIKit
import OceanView



extension MainViewController{

     func updateWave() {
        self.rearOceanView.update(5)
        self.frontOceanView.update(3)
        self.performSelector(Selector("longPress:"), withObject: nil, afterDelay: 0.02)
    }
    
    func longPress(sender: UILongPressGestureRecognizer) {
        
        switch sender.state {
        
        case .Began:
            self.updateWave()
        case .Changed:
            break
        case .Ended:
            self.rearOceanView.update(0)
            self.frontOceanView.update(0)
            NSObject.cancelPreviousPerformRequestsWithTarget(self, selector: Selector("longPress:"), object: nil)
        default:
            self.updateWave()
        }
    }
}
