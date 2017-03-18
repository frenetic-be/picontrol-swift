//
//  TutorialPageViewController.swift
//  PiControl
//
//  Created by Julien Spronck on 15/03/2017.
//  Copyright © 2017 Julien Spronck. All rights reserved.
//

import UIKit

class TutorialPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, pageViewControllerProtocol {
    
//    var pageIndex = 0
    var pages = [TutorialViewController]()
    
    var nPages = 6
    var pageIndex:Int {
        get {
            if let vc = self.viewControllers!.first! as? TutorialViewController {
                return pages.index(of: vc)!
            }
            return 0
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = self

        for n in 1...nPages {
            pages.append(storyboard?.instantiateViewController(withIdentifier: "TutorialPage\(n)") as! TutorialViewController)
        }
        
        for page in pages {
            page.delegate = self
        }
        
        
        if let firstPage = pages.first {
            setViewControllers([firstPage], direction: .forward, animated: true, completion: nil)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    private func setupPageControl() {
        let appearance = UIPageControl.appearance()
        appearance.pageIndicatorTintColor = UIColor.lightGray
        appearance.currentPageIndicatorTintColor = UIColor.white
        appearance.backgroundColor = UIColor.init(red: 70.0/255.0, green: 130.0/255.0, blue: 180.0/255.0, alpha: 1)
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        setupPageControl()
        return pages.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return pageIndex
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let vc = viewController as? TutorialViewController else {
            return nil
        }
        guard let viewControllerIndex = pages.index(of:vc) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        return pages[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let vc = viewController as? TutorialViewController else {
            return nil
        }
        guard let viewControllerIndex = pages.index(of:vc) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        
        guard pages.count > nextIndex else {
            return nil
        }
        
        return pages[nextIndex]
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // Get the new view controller using segue.destinationViewController.
//        // Pass the selected object to the new view controller.
//        
//    }
 
    // MARK: pageViewControllerProtocol
    func showPage(number: Int) {
        if number >= pages.count {
            return
        }
        setViewControllers([pages[number]], direction: .forward, animated: true, completion: nil)
    }
    
    func showNextPage() {
        if pageIndex < nPages-1 {
            showPage(number: pageIndex + 1)
        }
    }

}

