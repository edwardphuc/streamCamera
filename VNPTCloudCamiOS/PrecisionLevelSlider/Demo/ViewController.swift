//
//  ViewController.swift
//  Demo
//
//  Created by muukii on 2016/11/28.
//  Copyright © 2016 muukii. All rights reserved.
//

import UIKit

import PrecisionLevelSlider

class ViewController: UIViewController {

    @IBOutlet weak var markLb: UILabel!
  @IBOutlet weak var whiteLarge: PrecisionLevelSlider!
  @IBOutlet weak var whiteMidium: PrecisionLevelSlider!
  @IBOutlet weak var whiteSmall: PrecisionLevelSlider!

  @IBOutlet weak var blakLarge: PrecisionLevelSlider!
  @IBOutlet weak var blakMidium: PrecisionLevelSlider!
  @IBOutlet weak var blackSmall: PrecisionLevelSlider!

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    markLb.text = "12:00"
    whiteSmall.isContinuous = false
    blakLarge.addTarget(self, action: #selector(whiteLargeValueChanged(slider:)), for: .valueChanged)
    
    let whiteLongColor = UIColor.black
    let whiteShortColor = UIColor(white: 0.2, alpha: 1)

    whiteLarge.longNotchColor = whiteLongColor
    whiteLarge.shortNotchColor = whiteShortColor
    whiteLarge.minimumValue = 0
    whiteLarge.maximumValue = 24
    whiteLarge.value = 3
    whiteLarge.addTarget(self, action: #selector(whiteLargeValueChanged(slider:)), for: .valueChanged)
    

    whiteMidium.longNotchColor = whiteLongColor
    whiteMidium.shortNotchColor = whiteShortColor

    whiteSmall.longNotchColor = whiteLongColor
    whiteSmall.shortNotchColor = whiteShortColor

    
    let blackLongColor = UIColor.white
    let blackShortColor = UIColor(white: 1, alpha: 0.8)

    blakLarge.longNotchColor = blackLongColor
    blakLarge.shortNotchColor = blackShortColor

    blakMidium.longNotchColor = blackLongColor
    blakMidium.shortNotchColor = blackShortColor

    blackSmall.longNotchColor = blackLongColor
    blackSmall.shortNotchColor = blackShortColor

  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  func whiteLargeValueChanged(slider: PrecisionLevelSlider) {
    print(slider.value)
    markLb.text = "\(slider.value)"
  }

}

