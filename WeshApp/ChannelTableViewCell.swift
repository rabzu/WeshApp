//
//  ChannelTableViewCell.swift
//  WeshApp
//
//  Created by rabzu on 05/02/2015.
//  Copyright (c) 2015 WeshApp. All rights reserved.
//

import UIKit
import Designables

protocol ChannetlTableViewCellDelegate{
        func pauseAction()
        func cellDidOpen()
        func cellDidClose()
}

class ChannelTableViewCell: UITableViewCell {
    
    let kBounceValue: CGFloat = 20.0
 
    @IBOutlet weak var pauseView: UIView!
    @IBOutlet weak var totem: UIImageView!
    @IBOutlet weak var title: WeshappLabel!
    @IBOutlet weak var subTitle: WeshappLabel!
    @IBOutlet weak var counter: NSLayoutConstraint!
    @IBOutlet weak var contentViewRightConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentViewLeftConstraint: NSLayoutConstraint!
      
    var delegate: ChannetlTableViewCellDelegate?
    var panRecognizer: UIPanGestureRecognizer?
    var panStartPoint: CGPoint?
    var startingRightConstant: CGFloat?

    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUpPan()
        
        
        }
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpPan()

    }
    
    
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func setUpPan(){
        panRecognizer = UIPanGestureRecognizer(target: self, action: "panThisCell:")
        panRecognizer!.delegate = self
        addGestureRecognizer(panRecognizer!)
    }

     func panThisCell(pan: UIPanGestureRecognizer){
        
        switch pan.state{
            case .Began:
                // store the initial position of the cell (i.e. the constraint value), to determine whether the cell is opening or closing.
                panStartPoint = pan.translationInView(contentView)
                startingRightConstant = contentViewRightConstraint.constant
            case .Changed:
                handlePanChange(pan)
            case .Ended:
                handePanEnded(pan)
                break
            case .Cancelled:
                
                if startingRightConstant == 0 {
                    //Cell was closed - reset everything to 0
                    resetConstraintToZero(true, endEditing: true)
                } else {
                    setConstraintToShowAllButtons(true, notifyDelegate: true)
                }

                break
            default:
                break
            }
        }
    private func handlePanChange(pan: UIPanGestureRecognizer){
        var currentPoint = pan.translationInView(contentView)
        var deltaX = currentPoint.x - panStartPoint!.x
        var panningLeft = false
        //1. determin if swiping is to the left/right
        if currentPoint.x < panStartPoint!.x{
            panningLeft = true
        }
        
        //The cell was closed and is now opening
        if self.startingRightConstant == 0 {
            if(!panningLeft){ //2.
                //Swipe from left to right to close the cell when finger is not lifted
                //left to right swipe results positiv value
                var constant = max(-deltaX, 0)
                if constant == 0 { //4. if constant is zero handle cell closing
                    resetConstraintToZero(true, endEditing: true)
                }else{ // 5. if not zero then set right hand side constraint
                    contentViewRightConstraint.constant = constant
                }
            } else{
                //otherwise if panning is from right to left, user is opening the cell.
                var constant = min(-deltaX, buttonTotalWidth())
                if constant == buttonTotalWidth(){
                        setConstraintToShowAllButtons(true, notifyDelegate: false)
                } else{ //if constant is not the total width pause button set the constant to the right constrait's constant
                    contentViewRightConstraint.constant = constant
                }
            }
            
        } else {  // the cell was at least partially open
            // 1. how much ajdustment has been made
            var adjustment = startingRightConstant! - deltaX
            if !panningLeft {
                //2.If the user is panning left to right, you must take the greater of the adjustment or 0.
                // If the adjustment has veered into negative numbers, that means the user has swiped beyond the edge of the cell, and the cell is closed
                var constant = max(adjustment, 0)
                //3. cell is closed
                if(constant == 0){
                    resetConstraintToZero(true, endEditing: false)
                } else {
                    contentViewRightConstraint.constant = constant
                }
            } else{
                //5.Panning right to left: If the adjustment is higher, then the user has swiped too far past the catch point.
                var constant = min(adjustment, buttonTotalWidth())
                //6. the cell is open; handle opening the cell.
                if constant == self.buttonTotalWidth(){
                    setConstraintToShowAllButtons(true, notifyDelegate: false)
                } else {
                    contentViewRightConstraint.constant = constant
                }
            }
        }
        
        //8. set the left cell
        contentViewLeftConstraint.constant = -contentViewRightConstraint.constant
    }

    private func handePanEnded(pan: UIPanGestureRecognizer){
        //1.Check whether the cell was laready open
        if startingRightConstant == 0 {
            //Cell was opening
            //2.if the cell was closed and its being open
            var halfPauseView = CGRectGetWidth(pauseView.frame) / 2
            //3. if cell has been opend more than the half oway of the pause view then open
            if contentViewRightConstraint.constant >= halfPauseView{
                //open all the way
                    setConstraintToShowAllButtons(true, notifyDelegate: true)
            } else{
                //if cell is not being open more than half oway of the view then re-close
                resetConstraintToZero(true, endEditing: true)
            }
        } else {
        //Cell was closing
        var pauseViewWidth = CGRectGetWidth(pauseView.frame) / 2
        if contentViewRightConstraint.constant >= pauseViewWidth{
            //Re-open all the way
            setConstraintToShowAllButtons(true, notifyDelegate: true)
        } else {
            resetConstraintToZero(true, endEditing: true)
            }
        }

    }
    
    //how far should the cell slide
    func buttonTotalWidth()->CGFloat{
        return CGRectGetWidth(frame) - CGRectGetMinX(pauseView.frame)
    }
    //Close the cell
    func resetConstraintToZero(animated: Bool, endEditing: Bool){
        
        //TODO: Delegate
        
        //1 If the cell started open and the constraint is already at the full open value, just bail
        if(startingRightConstant == 0 && contentViewRightConstraint.constant == 0){
            //Already closed, no bounce needed
            return
        }
        
        //2
        self.contentViewRightConstraint.constant = -kBounceValue
        self.contentViewLeftConstraint.constant = kBounceValue
        
        
        var completion =  { (value: Bool) -> () in
            
            self.contentViewLeftConstraint.constant = 0
            self.contentViewRightConstraint.constant = 0
            
            var comp = { (value2: Bool) -> () in
                //4.
                self.startingRightConstant = self.contentViewRightConstraint.constant
            }
            
            self.updateConstraintsIfNeeded(true, completion: comp)
            
        }
         self.updateConstraintsIfNeeded(true, completion: completion)

    }
    //Open the cell
    func setConstraintToShowAllButtons(animated: Bool, notifyDelegate: Bool){

        //TODO: Delegate

        //1. If the cell started open and the constraint is already at the full open value, just bail
        if !(startingRightConstant == buttonTotalWidth() && contentViewRightConstraint.constant == buttonTotalWidth()) {
            
            //2
            contentViewLeftConstraint.constant = -buttonTotalWidth() - kBounceValue
            contentViewRightConstraint.constant = buttonTotalWidth() + kBounceValue
        
            self.updateConstraintsIfNeeded(true, completion: { (value: Bool) -> () in
                
                self.contentViewLeftConstraint.constant = -self.buttonTotalWidth()
                self.contentViewRightConstraint.constant = self.buttonTotalWidth()
             
                
                self.updateConstraintsIfNeeded(true, completion:  { (value2: Bool) -> () in
                    //4.
                    self.startingRightConstant = self.contentViewRightConstraint.constant
                })
                
                }
                
)
        }
    }
    //Animation method
    func updateConstraintsIfNeeded(animated: Bool, completion:  Bool->()) {

        var duration = 0.0
        if animated { duration = 0.1 }
        var animations = { ()  in
            self.layoutIfNeeded()
        }
        
        UIView.animateWithDuration(duration, delay: 0,
                                           options: UIViewAnimationOptions.CurveEaseOut,
                                        animations: animations,
                                        completion: completion)
    }
    
    //MARK: UIGestureRecogniserDelegate
    //First, your UIPanGestureRecognizer can sometimes interfere with the one which handles the scroll action on the UITableView
    override func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    override func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailByGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
  
    override func prepareForReuse() {
        super.prepareForReuse()
        resetConstraintToZero(false, endEditing: false)
    }

}
