//
//  ExtentionsforUIColor.swift
//  DonePaperApp
//
//  Created by TuanNguyen on 4/21/17.
//  Copyright © 2017 Done Paper. All rights reserved.
//

import UIKit
import Kingfisher

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int, a: CGFloat = 1.0) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        self.init(
            red: CGFloat(red) / 255.0,
            green: CGFloat(green) / 255.0,
            blue: CGFloat(blue) / 255.0,
            alpha: a
        )
    }
    
    convenience init(rgb: Int, a: CGFloat = 1.0) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF,
            a: a
        )
    }
    
    var toHexString: String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        return String(
            format: "%02X%02X%02X",
            Int(r * 0xff),
            Int(g * 0xff),
            Int(b * 0xff)
        )
    }
    
}

extension TimeInterval {
    
    func format2String(format:String? = "dd/MM/yy") -> String {
        
        let date = Date(timeIntervalSince1970: self)
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = Locale(identifier: "en_US")
        let myString = formatter.string(from: date)
        
        return myString
    }
}

extension String {
    func toDate(format:String? = "MMM dd") -> Date? {
        
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = Locale(identifier: "en_US")
        let myString = formatter.date(from: self)
        
        return myString
        
    }
}

func MongoObjectId() -> String {
    
    let data = NSMutableData()
    
    // get timestamp - first 4 bytes
    var date = UInt32(NSDate().timeIntervalSince1970).bigEndian
    data.append(&date, length: 4)
    
    // 3 bytes Just using a random number, but should be using device id and bigEndian
    var random1 = arc4random().bigEndian
    data.append(&random1, length: 3)
    
    // 2 bytes pid - big endian
    var pid = UInt32(ProcessInfo.processInfo.processIdentifier).bigEndian
    data.append(&pid, length: 2)
    
    // 3 bytes big endian counter - using a random number
    var random2 = arc4random().bigEndian
    data.append(&random2, length: 3)
    
    
    let d = Data(referencing: data)
    
    var token = ""
    for i in 0..<d.count {
        token = token + String(format: "%02.2hhx", arguments: [d[i]])
    }
    
    return token
    
}

extension UIImage {
    
    /// Returns a image that fills in newSize
    func resizeImage(targetSize: CGSize) -> UIImage {
        let size = self.size
        
        let widthRatio  = targetSize.width  / self.size.width
        let heightRatio = targetSize.height / self.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }   
}

extension UILabel {
    func from(html: String, icon: UIImage? = UIImage(named: "IconCoin")) {
        
        
        if let htmlData = html.data(using: String.Encoding.unicode) {
            do {
                
                let attStr = try NSMutableAttributedString(data: htmlData,
                                                             options: [.documentType : NSAttributedString.DocumentType.html],
                                                             documentAttributes: nil)
                
                
                let range =  NSString(string: attStr.string).range(of: "${worm}")
                
                if range.length > 0 {
                    
                    let attachment = NSTextAttachment()
                    attachment.image = icon
                    attachment.bounds.size.width = 15
                    attachment.bounds.size.height = 15
                    let attachmentString = NSAttributedString(attachment: attachment)
                    
                    
                    attStr.replaceCharacters(in: range, with: attachmentString)
                    
                }
                
                self.attributedText = attStr
                
            } catch let e as NSError {
                print("Couldn't parse \(html): \(e.localizedDescription)")
            }
        }
    }
    
    func setSubTextColor(pSubString : String, pColor : UIColor, fontname:UIFont) {
        let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: self.text!)
        
        let range = attributedString.mutableString.range(of: pSubString, options:NSString.CompareOptions.caseInsensitive)
        if range.location != NSNotFound {
            attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: pColor, range: range)
            attributedString.addAttribute(NSAttributedString.Key.font, value: fontname, range: range)
        }
        self.attributedText = attributedString
        
    }
    
    func from(html: String, hasIcon:UIImage) {
        
    }
}

public extension UIImage {
    public convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}

extension UIView {
    
    func dropShadow(scale: Bool = false, shadowColor:CGColor = UIColor.black.cgColor,shadowOpacity:Float = 0.05,shadowOffset:CGSize = CGSize(width: 0, height: 4)) {
        
        self.layer.masksToBounds = false
        self.layer.shadowColor = shadowColor
        self.layer.shadowOpacity = shadowOpacity
        self.layer.shadowOffset = shadowOffset
        self.layer.shadowRadius = 8
        
        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
//        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    // Name this function in a way that makes sense to you...
    // slideFromLeft, slideRight, slideLeftToRight, etc. are great alternative names
    func slideInFromLeft(_ duration: TimeInterval = 0.5, completionDelegate: CAAnimationDelegate? = nil) {
        // Create a CATransition animation
        let slideInFromLeftTransition = CATransition()
        
        // Set its callback delegate to the completionDelegate that was provided (if any)
        if let delegate: CAAnimationDelegate = completionDelegate {
            slideInFromLeftTransition.delegate = delegate
        }
        
        // Customize the animation's properties
        // slideInFromLeftTransition.type = kCATransitionPush
        slideInFromLeftTransition.type = CATransitionType.moveIn
        
        slideInFromLeftTransition.subtype = CATransitionSubtype.fromLeft
        
        slideInFromLeftTransition.duration = duration
        slideInFromLeftTransition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        slideInFromLeftTransition.fillMode = CAMediaTimingFillMode.removed
        
        // Add the animation to the View's layer
        self.layer.add(slideInFromLeftTransition, forKey: "slideInFromLeftTransition")
    }
    func slideInFromRight(_ duration: TimeInterval = 0.5, completionDelegate: CAAnimationDelegate? = nil) {
        // Create a CATransition animation
        let slideInFromRightTransition = CATransition()
        
        // Set its callback delegate to the completionDelegate that was provided (if any)
        if let delegate: CAAnimationDelegate = completionDelegate {
            slideInFromRightTransition.delegate = delegate
        }
        
        // Customize the animation's properties
        // slideInFromLeftTransition.type = kCATransitionPush
        slideInFromRightTransition.type = CATransitionType.moveIn
        
        slideInFromRightTransition.subtype = CATransitionSubtype.fromRight
        
        slideInFromRightTransition.duration = duration
        slideInFromRightTransition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        slideInFromRightTransition.fillMode = CAMediaTimingFillMode.removed
        
        // Add the animation to the View's layer
        self.layer.add(slideInFromRightTransition, forKey: "slideInFromRightTransition")
    }

}

extension Array {
    mutating func rearrange(from: Int, to: Int) {
        precondition(from != to && indices.contains(from) && indices.contains(to), "invalid indexes")
        insert(remove(at: from), at: to)
    }
}

extension String {
    func conver2ImxUrlStr(img:UIImageView) -> String {
      var imgXUrlString = self.replacingOccurrences(of: "https://s3.ap-south-1.amazonaws.com/skylabreadmoredev", with: "readmoreapp.imgix.net")
        let w = img.frame.size.width
        let h = img.frame.size.height
        let cropSize = "?w=\(w)&h=\(h)&auto=format&fit=crop&dpr=2.0&fm=jpg&q=40"
        imgXUrlString.append(cropSize)
        return imgXUrlString
    }
}


extension Kingfisher where Base: ImageView {
    public func setImageIMGIX(with resource: Resource?,
                         placeholder: Image? = nil,
                         options: KingfisherOptionsInfo? = nil,
                         progressBlock: DownloadProgressBlock? = nil,
                         completionHandler: CompletionHandler? = nil) -> RetrieveImageTask
    {
        var imgXUrl = resource?.downloadURL
        
        if let url = resource?.downloadURL.absoluteString {
            var imgXUrlString =  url.replacingOccurrences(of: "https://s3.ap-south-1.amazonaws.com/skylabreadmoredev", with: "https://readmoreapp.imgix.net")
            
            
            let w = self.base.bounds.size.width
            let h = self.base.bounds.size.height
            let ratio = UIScreen.main.scale
            
            let cropSize = "?w=\(w)&h=\(h)&auto=format&fit=crop&dpr=\(ratio)&fm=jpg&q=40"
            imgXUrlString.append(cropSize)
            imgXUrl = URL(string: imgXUrlString)
            
        }
        
        return self.setImage(with: imgXUrl, placeholder: placeholder, options: options, progressBlock: progressBlock, completionHandler: completionHandler)
    }
}
