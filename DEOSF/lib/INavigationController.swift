//
//  INavigationController.swift
//  SwiftFrame
//
//  Created by 杨栋 on 2017/11/16.
//  Copyright © 2017年 杨栋. All rights reserved.
//

import UIKit

public class INavigationController: UINavigationController {
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        isNavigationBarHidden = true
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.mIsDidAppear  = true
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    //MARK: 屏幕属性
    override public var shouldAutorotate: Bool {
        return topViewController?.shouldAutorotate ?? true
    }
    
    /// 首次调用viewControllers.last的翻转方向，会被定义为App启动时的翻转方向，所以默认为AppViewController的翻转方向
    override public var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return topViewController?.supportedInterfaceOrientations ?? .all
    }
    
    //MARK: ====
    override open func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if !UIApplication.shared.mIsDidAppear {
            return
        }
        UIApplication.shared.mIsDidAppear = false
        view.endEditing(true)
        super.pushViewController(viewController, animated: animated)
    }
    
    override open func popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        if !UIApplication.shared.mIsDidAppear {
            return nil
        }
        UIApplication.shared.mIsDidAppear = false
        return super.popToViewController(viewController, animated: animated)!
    }
    
    override open func popViewController(animated: Bool) -> UIViewController? {
        let aviewController = viewControllers[viewControllers.count-1-1]
        _ = popToViewController(aviewController, animated: animated)
        return aviewController
    }
    
    override open func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        UIApplication.shared.mIsDidAppear = false
        viewControllerToPresent.relayoutViews(orientation: UIApplication.shared.statusBarOrientation)
        super.present(viewControllerToPresent, animated: flag, completion: completion)
    }
}
