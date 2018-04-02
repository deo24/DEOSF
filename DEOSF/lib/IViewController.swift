//
//  IViewController.swift
//  SwiftFrame
//
//  Created by 杨栋 on 2017/11/16.
//  Copyright © 2017年 杨栋. All rights reserved.
//

import UIKit

public class IViewController: UIViewController {
    //MARK: 生命周期
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.red
    }
    
    /// 这里为启动屏的翻转方向
//    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
//        return .landscapeLeft
//    }
    
    //MARK: OnMessageProtocol
    override public func onMessage(obj: Any!, type: Message, arg: Any?) {
        switch type {
        case .push:
            guard let dic = arg as? [String:Any],
                let name = dic[kViewControllerName] as? String,
                let cls_new = NSClassFromString("\(Bundle.main.namespace)" + "." + "\(name)") as? UIViewController.Type,
                let navigationController = navigationController
                else {
                    return
            }
            let bIs = (dic[kViewControllerAnimation] as? Bool) ?? false
            for vc in navigationController.viewControllers {
                let className_new = NSStringFromClass(cls_new)
                if let vc_new = vc.findVC(name: className_new) {
                    if vc_new.parent != nil && vc_new.parent != navigationController {
                        navigationController.popToViewController(vc_new.parent!, animated: bIs)
                    }else{
                        navigationController.popToViewController(vc_new, animated: bIs)
                    }
                    return
                }
            }
            let aviewController = cls_new.init()
            aviewController.mParentViewController = self
            aviewController.mFromViewController = obj as? UIViewController
            navigationController.pushViewController(aviewController, animated: bIs)
            aviewController.onMessage(obj: obj, type: .argument, arg: dic[kViewControllerArgument])
        case .pushNib:
            guard let dic = arg as? [String:Any],
                let name = dic[kViewControllerName] as? String,
                let cls_new = NSClassFromString("\(Bundle.main.namespace)" + "." + "\(name)") as? UIViewController.Type,
                let navigationController = navigationController
                else {
                    return
            }
            let bIs = (dic[kViewControllerAnimation] as? Bool) ?? false
            for vc in navigationController.viewControllers {
                let className_new = NSStringFromClass(cls_new)
                if let vc_new = vc.findVC(name: className_new) {
                    if vc_new.parent != nil && vc_new.parent != navigationController {
                        navigationController.popToViewController(vc_new.parent!, animated: bIs)
                    }else{
                        navigationController.popToViewController(vc_new, animated: bIs)
                    }
                    return
                }
            }
            let aviewController = cls_new.init(nibName: name, bundle: nil)
            aviewController.mParentViewController = self
            aviewController.mFromViewController = obj as? UIViewController
            navigationController.pushViewController(aviewController, animated: bIs)
            aviewController.onMessage(obj: obj, type: .argument, arg: dic[kViewControllerArgument])
        case .argument:
            guard   let dic = arg as? [String:Any],
                let name = dic[kViewControllerName] as? String,
                let cls_new = NSClassFromString("\(Bundle.main.namespace)" + "." + "\(name)") as? UIViewController.Type,
                let navigationController = navigationController
                else {
                    return
            }
            let className_new = NSStringFromClass(cls_new)
            let action = { (vc:UIViewController)->Void in
                vc.onMessage(obj: obj, type: type, arg: dic[kViewControllerArgument])
            }
            if  let presentedViewController = navigationController.presentedViewController,
                className_new == NSStringFromClass(presentedViewController.classForCoder) {
                action(presentedViewController)
            }else {
                for vc in navigationController.viewControllers {
                    if let vc_new = vc.findVC(name: className_new) {
                        action(vc_new)
                        break
                    }
                }
            }
        case .present:
            guard   let dic = arg as? [String:Any],
                let name = dic[kViewControllerName] as? String,
                let cls_new = NSClassFromString("\(Bundle.main.namespace)" + "." + "\(name)") as? UIViewController.Type,
                let navigationController = navigationController
                else {
                    return
            }
            let bIs = (dic[kViewControllerAnimation] as? Bool) ?? false
            let completion = dic[kViewControllerCompletion] as? ()->()
            let aviewController = cls_new.init()
            aviewController.mParentViewController = self
            aviewController.mFromViewController = obj as? UIViewController
            navigationController.present(aviewController, animated: bIs, completion: completion)
            aviewController.onMessage(obj: obj, type: .argument, arg: dic[kViewControllerArgument])
        case .dismiss:
            guard   let dic = arg as? [String:Any],
                let navigationController = navigationController
                else {
                    return
            }
            
            let bIs = (dic[kViewControllerAnimation] as? Bool) ?? false
            let completion = dic[kViewControllerCompletion] as? ()->()
            navigationController.dismiss(animated: bIs, completion: completion)
        case .back:
            guard   let dic = arg as? [String:Any],
                let navigationController = navigationController else{
                    return
            }
            let bIs = (dic[kViewControllerAnimation] as? Bool) ?? false
            let arr:[UIViewController] = navigationController.viewControllers
            if arr.count>1 {
                let preController = arr[arr.count-2]
                navigationController.popToViewController(preController, animated: bIs)
            }
        default:
            break
        }
    }
}

extension IViewController:UINavigationControllerDelegate{
    open func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        viewController.relayoutViews(orientation: UIApplication.shared.statusBarOrientation)
    }
}
