//
//  SigninViewController.swift
//  Happining_V2.1
//
//  Created by Tanthawat Khemavast on 3/10/14.
//  Copyright (c) 2014 Kan Boonprakub. All rights reserved.
//

import Foundation

class SigninViewController: UIViewController, UIPageViewControllerDataSource {
    var pageViewController : UIPageViewController!
    var pageTitles : Array<String> = ["Email", "Password", "Username"]
    var currentIndex : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.pageViewController = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
        self.pageViewController!.dataSource = self
        
        let startingViewController: SigninPageContentViewController = self.viewControllerAtIndex(0)!
        let viewControllers: NSArray = [startingViewController]
        self.pageViewController!.setViewControllers(viewControllers, direction: .Forward, animated: false, completion: nil)
        self.pageViewController!.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 30);
        
        self.addChildViewController(self.pageViewController)
        self.view.addSubview(self.pageViewController!.view)
        self.pageViewController!.didMoveToParentViewController(self)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController?
    {
        var index = (viewController as SigninPageContentViewController).pageIndex
        
        if (index == 0) || (index == NSNotFound) {
            return nil
        }
        
        index--
        
        println("Decreasing Index: \(String(index))")
        
        return self.viewControllerAtIndex(index)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController?
    {
        var index = (viewController as SigninPageContentViewController).pageIndex
        
        if index == NSNotFound {
            return nil
        }
        
        index++
        
        println("Increasing Index: \(String(index))")
        
        if (index == self.pageTitles.count) {
            return nil
        }
        
        return self.viewControllerAtIndex(index)
    }
    
    func viewControllerAtIndex(index: Int) -> SigninPageContentViewController?
    {
        if self.pageTitles.count == 0 || index >= self.pageTitles.count
        {
            return nil
        }
        
        // Create a new view controller and pass suitable data.
        let pageContentViewController = self.storyboard?.instantiateViewControllerWithIdentifier("SigninPageContentViewController") as SigninPageContentViewController
        pageContentViewController.inputType = self.pageTitles[index]
        pageContentViewController.pageIndex = index
        self.currentIndex = index
        
        return pageContentViewController
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int
    {
        return self.pageTitles.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int
    {
        return 0
    }

}