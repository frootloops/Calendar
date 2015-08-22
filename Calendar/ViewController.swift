//
//  ViewController.swift
//  Calendar
//
//  Created by Arsen Gasparyan on 21/08/15.
//  Copyright (c) 2015 Arsen Gasparyan. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    private var collectionView: UICollectionView!
    private let today = NSDate()
    private var from: NSDate?
    private var to: NSDate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .Vertical
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        collectionView = CalendarCollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.blackColor()
        collectionView.allowsMultipleSelection = true
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.registerClass(CalendarHeaderCollectionReusableView.self,
            forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "Header")
        collectionView.registerClass(CalendarDayCollectionViewCell.self, forCellWithReuseIdentifier: "Day")
        
        view.addSubview(collectionView)

    }
    
    // MARK: UICollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 12
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let month = today.dateByAddingMonths(section)
        let days = month.numberOfDaysInMonth()
        let weekday = month.firstDayOfMonth().weekday()
        
        
        return days + weekday
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Day", forIndexPath: indexPath) as! CalendarDayCollectionViewCell
        cell.backgroundColor = UIColor.blackColor()
        cell.date = dateForIndexPath(indexPath)
        cell.from = false
        cell.makeActive()
        
        if from != nil && cell.date != nil && cell.date! == from! {
            cell.from = true
        }
        
        if to != nil && cell.date != nil && cell.date! == to! {
            cell.to = true
        }
        
        if from != nil && cell.date != nil && cell.date! < from! {
            cell.makeInactive()
        }
        
        if to != nil && cell.date != nil && cell.date! > to! {
            cell.makeInactive()
        }
        
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        if (kind == UICollectionElementKindSectionHeader) {
            var header = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "Header", forIndexPath: indexPath) as! CalendarHeaderCollectionReusableView
            header.backgroundColor = UIColor.clearColor()
            header.date = dateForFirstDayOfSection(indexPath.section)
            
            if from != nil && dateForFirstDayOfSection(indexPath.section) > from! {
                header.alpha = 0.5
            }
            
            
            return header
        }
        
        return UICollectionReusableView()
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSizeMake(view.frame.width, 50)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let size = view.bounds.width / 7
        return CGSize(width: size, height: size)
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if from != nil && to != nil {
            from = nil
            to = nil
        }
        
        if from == nil {
            from = dateForIndexPath(indexPath)
            
            let cell = collectionView.cellForItemAtIndexPath(indexPath) as! CalendarDayCollectionViewCell
            cell.moveHighlightViewToPoint(view.convertPoint(CGPointZero, toView: cell))
            
            collectionView.performBatchUpdates({ () -> Void in
                self.collectionView.reloadItemsAtIndexPaths(collectionView.indexPathsForVisibleItems())
            }, completion: { (_) -> Void in
            })
            
        } else {
            to = dateForIndexPath(indexPath)
            
            let cell = collectionView.cellForItemAtIndexPath(indexPath) as! CalendarDayCollectionViewCell
            cell.moveHighlightViewToPoint(view.convertPoint(CGPointZero, toView: cell))
            
            collectionView.performBatchUpdates({ () -> Void in
                self.collectionView.reloadItemsAtIndexPaths(collectionView.indexPathsForVisibleItems())
                }, completion: { (_) -> Void in
            })
        }
    }
    
    // MARK: Private area
    
    private func dateForFirstDayOfSection(section: Int) -> NSDate {
        return today.firstDayOfMonth().dateByAddingMonths(section)
    }
    
    private func offsetForSection(section: Int) -> Int {
        let firstDayOfMonth = dateForFirstDayOfSection(section)
        // NSCalendar.currentCalendar().weekdaySymbols
        
        return firstDayOfMonth.weekday() - 1
    }
    
    private func dateForIndexPath(indexPath: NSIndexPath) -> NSDate? {
        let month = today.dateByAddingMonths(indexPath.section).firstDayOfMonth()
        let offset = offsetForSection(indexPath.section)
        
        if indexPath.row >= offset {
            return month.dateByAddingDays(indexPath.row - offset)
        }
        return nil
    }
}

class CalendarCollectionView: UICollectionView {
}

class CalendarHeaderCollectionReusableView: UICollectionReusableView {
    internal var date: NSDate! {
        didSet {
            titleLabel.text = date.strftime(dateFormat).capitalizedString
        }
    }
    
    private var dateFormat = "MMMM yyyy"
    private var titleLabel : UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        var rect = bounds
        let font = UIFont(name: "HelveticaNeue-Medium", size: 17.5)
        rect.size.height = 30.0
        rect.origin.x = 10
        rect.origin.y = frame.size.height - rect.size.height
        titleLabel = UILabel(frame: rect)
        titleLabel.font = font
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.textAlignment = .Left
        addSubview(titleLabel)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class CalendarDayCollectionViewCell: UICollectionViewCell {
    override var selected: Bool {
        didSet {}
    }
    
    internal var from = false {
        didSet {
            if from == true {
                titleLabel.textColor = UIColor.blackColor()
                highlightView.hidden = true
            }
        }
    }
    internal var to = false {
        didSet {
            if to == true {
                titleLabel.textColor = UIColor.blackColor()
                highlightView.hidden = true
            }
        }

    }
    
    internal var date: NSDate? {
        didSet {
            if let current = date {
                titleLabel.text = "\(current.day())"
                highlightView.hidden = false
                bgView.hidden = false
            } else {
                titleLabel.text = ""
                highlightView.hidden = true
                bgView.hidden = true
            }
        }
    }
    
    private var titleLabel: UILabel!
    private var highlightView: UIView!
    private var bgView: UIView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let viewSize = contentView.bounds.size
        let highlightViewInset:CGFloat = viewSize.height * 0.1; // bounds of highlight view 10% smaller than cell
        highlightView = UIView(frame: CGRectInset(contentView.frame, highlightViewInset, highlightViewInset))
        highlightView.layer.cornerRadius = CGRectGetHeight(highlightView.bounds) / 2
        highlightView.backgroundColor = getColor()
        
        bgView = UIView(frame: CGRectInset(contentView.frame, highlightViewInset, highlightViewInset))
        bgView.layer.cornerRadius = CGRectGetHeight(highlightView.bounds) / 2
        bgView.backgroundColor = UIColor.whiteColor()
        
        titleLabel = UILabel(frame: bounds)
        titleLabel.font = UIFont(name: "HelveticaNeue-Light", size: 20.0)
        titleLabel.textAlignment = .Center
        titleLabel.textColor = UIColor.whiteColor()

        contentView.addSubview(bgView)
        contentView.addSubview(highlightView)
        contentView.addSubview(titleLabel)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal func moveHighlightViewToPoint(point: CGPoint) {
        let currentCenter = highlightView.center
        
        titleLabel.textColor = UIColor.blackColor()
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.highlightView.center = point
        }) { (_) -> Void in
            self.highlightView.hidden = true
            self.highlightView.center = currentCenter
        }
    }
    
    internal func makeInactive() {
        titleLabel.textColor = UIColor.blackColor()
        alpha = 0.5
    }
    
    internal func makeActive() {
        titleLabel.textColor = UIColor.whiteColor()
        alpha = 1
    }
    
    private func getColor() -> UIColor {
        if arc4random_uniform(4) + 1 == 1 { return UIColor(red: 255/255.0, green: 174/255.0, blue: 15/255.0, alpha: 1) }
        if arc4random_uniform(4) + 1 == 2 { return UIColor(red: 255/255.0, green: 38/255.0, blue: 2/255.0, alpha: 1) }
        if arc4random_uniform(4) + 1 == 2 { return UIColor(red: 255/255.0, green:102/255.0, blue: 4/255.0, alpha: 1) }
        return UIColor(red: 3/255.0, green: 188/255.0, blue: 39/255.0, alpha: 1)
    }
}

public func ==(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs === rhs || lhs.compare(rhs) == .OrderedSame
}

public func <(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.compare(rhs) == .OrderedAscending
}

extension NSDate: Comparable { }

