
//  MenuController.swift
//  WeshApp
//
//  Created by rabzu on 26/03/2015.
//  Copyright (c) 2015 WeshApp. All rights reserved.
//

import UIKit
import RNFrostedSidebar


extension RNFrostedSidebar{
    public override func canBecomeFirstResponder() -> Bool {
        return true
    }
}

class MenuController: UITabBarController, RNFrostedSidebarDelegate, UIGestureRecognizerDelegate {

    var obj: ChannelTVC?
    let images = [ UIImage(named: "notifications")!,
                   UIImage(named: "nearBy")!,
                   UIImage(named: "chat")!,
                   UIImage(named: "profile")!,
                   UIImage(named: "settings")!]
    
    let colors = [UIColor.whiteColor(),
                  UIColor.whiteColor(),
                  UIColor.whiteColor(),
                  UIColor.whiteColor(),
                  UIColor.whiteColor()]
    
    var callout: RNFrostedSidebar?
    private let appDelegate = UIApplication.sharedApplication().delegate! as! AppDelegate

    override func viewDidLoad() {
        super.viewDidLoad()
        self.hidesBottomBarWhenPushed = true
        self.tabBar.hidden = true
        setUpMenu()
        //add gesture recogniser
        let swipeRight = UISwipeGestureRecognizer(target: self, action: "swipeRight:")
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
        appDelegate.window?.addGestureRecognizer(swipeRight)
//        self.view.addGestureRecognizer(swipeLeft)
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: "swipeLeft:")
        swipeLeft.direction = UISwipeGestureRecognizerDirection.Left
        appDelegate.window?.addGestureRecognizer(swipeLeft)
        //        self.view.addGestureRecognizer(swipeLeft)


    }
    
  
    func swipeRight(sender: UIView){
        callout?.show()
    }
    
    func swipeLeft(sender: UIView){
        callout?.dismiss()
    }
   

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    private func setUpMenu(){
        callout = RNFrostedSidebar(images: images, selectedIndices: NSIndexSet(index: 1), borderColors: colors)
        callout!.delegate = self
        callout!.tintColor = UIColor(red: 0x01/255, green: 0x51/255, blue: 0x5d/255, alpha: 0.5)

        NSNotificationCenter.defaultCenter().addObserver(     self,
                                                    selector: Selector("showMenu:"),
                                                        name: "ShowMenu",
                                                      object: nil)
        
    
    }
    

    //MARK: menu
    func showMenu(notification: NSNotification) {
        
        obj = notification.object as? ChannelTVC
        callout!.show()
        callout!.becomeFirstResponder()
        
    }
    
    deinit{
            NSNotificationCenter.defaultCenter().removeObserver(self)
            println("deinit")
    }
    
    
    func sidebar(sidebar: RNFrostedSidebar!, didTapItemAtIndex index: UInt) {
        


        switch index{

        
        
        
        case 0:
            //notification centre
            sidebar.dismissAnimated(true)

        case 1:
            //nearby
            sidebar.dismissAnimated(true)
            //                let nearbyVC = self.storyboard?.instantiateViewControllerWithIdentifier("NearbyVC") as UIViewController
            //                self.navigationController!.pushViewController(<#viewController: UIViewController#>, animated: <#Bool#>)
            self.selectedIndex = 0

        case 2:
            //chat
            sidebar.dismissAnimated(true)
        case 3://profile
            sidebar.dismissAnimated(true)
            self.selectedIndex = 1
            
        case 4:
            sidebar.dismissAnimated(true)
        default: break
        }
    }
    
    func sidebar(sidebar: RNFrostedSidebar!, didShowOnScreenAnimated animatedYesOrNo: Bool) {
            sidebar.becomeFirstResponder()
    }
    
//    - (void)sidebar:(RNFrostedSidebar *)sidebar didDismissFromScreenAnimated:(BOOL)animatedYesOrNo;
    func sidebar(sidebar: RNFrostedSidebar!, didDismissFromScreenAnimated animatedYesOrNo: Bool) {
        NSNotificationCenter.defaultCenter().postNotificationName("MenuDidHide", object: self)

        sidebar.resignFirstResponder()
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
