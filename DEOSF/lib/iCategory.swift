//
//  iCategory.swift
//  Teset
//
//  Created by 杨栋 on 2017/11/14.
//  Copyright © 2017年 杨栋. All rights reserved.
//

import Foundation
import UIKit

private var kIsDidAppear    = "_kIsDidAppear"

public extension Bundle{
    var namespace:String{
        return Bundle.main.infoDictionary!["CFBundleName"] as? String ?? ""
    }
}

public extension UIApplication{
    var mIsDidAppear:Bool{
        set(b){
            willChangeValue(forKey: kIsDidAppear)
            objc_setAssociatedObject(self, &kIsDidAppear, b, .OBJC_ASSOCIATION_ASSIGN)
            didChangeValue(forKey: kIsDidAppear)
        }
        
        get{
            return (objc_getAssociatedObject(self, &kIsDidAppear) as? Bool) ?? true
        }
    }
}

public extension UIViewController {
    func findVC(name:String) -> UIViewController?{
        guard name == NSStringFromClass(self.classForCoder) else{
            for child in childViewControllers {
                let childName = NSStringFromClass(child.classForCoder)
                if childName == name {
                    return child
                }else {
                    if let temp = child.findVC(name: name) {
                        return temp
                    }
                }
            }
            return nil
        }
        return self
    }
}
