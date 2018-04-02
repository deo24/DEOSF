//
//  iSwizzle.swift
//  Teset
//
//  Created by 杨栋 on 2017/11/15.
//  Copyright © 2017年 杨栋. All rights reserved.
//

import UIKit

public let kViewControllerName                 = "viewController_name"
public let kViewControllerAnimation            = "viewController_animation"
public let kViewControllerArgument             = "viewController_argument"
public let kViewControllerCompletion           = "viewController_completion"

@objc public enum Message:Int {
    case clear,push,pushNib,argument,dismiss,back,present
}

//MARK:协议
@objc public protocol RelayoutViewsProtocol {
    func relayoutViews(orientation:UIInterfaceOrientation)
}

@objc public protocol OnMessageProtocol {
    func onMessage(obj:Any!,type:Message,arg:Any?)
}

//MARK: UIViewController
private var kMParentViewController      = "_kMParentViewController"
private var kMFromViewController        = "_kMFromViewController"

public extension UIViewController {
    
    @objc var mParentViewController:UIViewController?{
        set(vc){
            willChangeValue(forKey: kMParentViewController)
            objc_setAssociatedObject(self, &kMParentViewController, vc, .OBJC_ASSOCIATION_ASSIGN)
            didChangeValue(forKey: kMParentViewController)
        }
        
        get{
            return objc_getAssociatedObject(self, &kMParentViewController) as? UIViewController
        }
    }
    
    @objc var mFromViewController:UIViewController?{
        set(vc){
            willChangeValue(forKey: kMFromViewController)
            objc_setAssociatedObject(self, &kMFromViewController, vc, .OBJC_ASSOCIATION_ASSIGN)
            didChangeValue(forKey: kMFromViewController)
        }
        
        get{
            return objc_getAssociatedObject(self, &kMFromViewController) as? UIViewController
        }
    }
}

public extension UIViewController {
    
    private class func iSwizzle (c:AnyClass,oriSEL:Selector,newSEL:Selector){
        //获取实例方法
        var oriMethod = class_getInstanceMethod(c, oriSEL)
        let newMethod:Method?
        
        if oriMethod == nil {
            //获取静态方法
            oriMethod = class_getClassMethod(c, oriSEL)
            newMethod = class_getClassMethod(c, newSEL)
        }else{
            newMethod = class_getInstanceMethod(c, newSEL)
        }
        
        guard let _oriMethod=oriMethod, let _newMethod=newMethod else {
            return
        }
        
        //自身已经有了就添加不成功，直接交换即可
        if(class_addMethod(c, oriSEL, method_getImplementation(_newMethod), method_getTypeEncoding(_newMethod))){
            //添加成功一般情况是因为，origSEL本身是在c的父类里。这里添加成功了一个继承方法。
            class_replaceMethod(c, newSEL, method_getImplementation(_oriMethod), method_getTypeEncoding(_oriMethod));
        }else{
            method_exchangeImplementations(_oriMethod, _newMethod);
        }
    }
    
    static public let callSwizzle:Void  = UIViewController.validateISwizzle()
    
    private class func validateISwizzle() -> Void{
        iSwizzle(c: self, oriSEL: #selector(viewDidLoad), newSEL: #selector(iSwizzle_viewDidLoad))
        iSwizzle(c: self, oriSEL: #selector(viewWillAppear), newSEL: #selector(iSwizzle_viewWillAppear))
        iSwizzle(c: self, oriSEL: #selector(viewDidAppear), newSEL: #selector(iSwizzle_viewDidAppear))
        iSwizzle(c: self, oriSEL: #selector(viewWillDisappear), newSEL: #selector(iSwizzle_viewWillDisappear))
        iSwizzle(c: self, oriSEL: #selector(viewDidDisappear), newSEL: #selector(iSwizzle_viewDidDisappear))
    }
    
    @objc private func iSwizzle_viewDidLoad(){
        if #available(iOS 11.0,*) {
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
    }
    
    @objc private func iSwizzle_viewWillAppear(animated:Bool){
        NotificationCenter.default.addObserver(self, selector: #selector(checkOrientation), name:.UIApplicationDidChangeStatusBarFrame, object: nil)
    }
    
    @objc private func iSwizzle_viewDidAppear(animated:Bool){
        UIApplication.shared.mIsDidAppear = true
    }
    
    @objc private func iSwizzle_viewWillDisappear(animated:Bool){
        NotificationCenter.default.removeObserver(self, name: .UIApplicationDidChangeStatusBarFrame, object: nil)
    }
    
    @objc private func iSwizzle_viewDidDisappear(animated:Bool){
        
    }
    
    @objc private func checkOrientation(){
        relayoutViews(orientation: UIApplication.shared.statusBarOrientation)
    }
}

extension UIViewController : OnMessageProtocol,RelayoutViewsProtocol {
    //MARK: == RelayoutViewsProtocol ==
    open func relayoutViews(orientation: UIInterfaceOrientation) {
//        print("relayoutViews(\(NSStringFromClass(classForCoder)))")
    }
    
    //MARK: == OnMessageProtocol ==
    open func onMessage(obj: Any!, type: Message, arg: Any?) {
        guard let parentViewController = mParentViewController else {
            assertionFailure("\(NSStringFromClass(classForCoder)) 's parentViewController is nil")
            return
        }
        parentViewController.onMessage(obj: obj, type: type, arg: arg)
    }
}

//MARK: UIView
private var kMParentView = "_kMParentView"

extension UIView:RelayoutViewsProtocol {
    open func relayoutViews(orientation:UIInterfaceOrientation) {
    }
}

public extension UIView {
    @objc var mParentView:UIView?{
        set(vc){
            willChangeValue(forKey: kMParentView)
            objc_setAssociatedObject(self, &kMParentView, vc, .OBJC_ASSOCIATION_ASSIGN)
            didChangeValue(forKey: kMParentView)
        }
        
        get{
            return objc_getAssociatedObject(self, &kMParentView) as? UIView
        }
    }
}
