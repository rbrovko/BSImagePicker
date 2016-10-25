// The MIT License (MIT)
//
// Copyright (c) 2015 Joakim Gyllström
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import UIKit

protocol PreviewViewControllerProtocol {
    func changeOrientation(previewController:PreviewViewController, burstIdentifier identifier: String?, newOrientation: UIImageOrientation)
}

final class PreviewViewController : UIViewController, UIScrollViewDelegate {
    var imageView: UIImageView?
    private let fullscreen = true
    
    private var scrollView : UIScrollView!
    
    var burstIdentifier : String?
    
    var delegate : PreviewViewControllerProtocol?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        view.backgroundColor = UIColor.whiteColor()
        
        imageView = UIImageView(frame: view.bounds)
        imageView?.contentMode = .ScaleAspectFit
        imageView?.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
//        let tapRecognizer = UITapGestureRecognizer()
//        tapRecognizer.numberOfTapsRequired = 1
//        tapRecognizer.addTarget(self, action: #selector(PreviewViewController.toggleFullscreen))
//        view.addGestureRecognizer(tapRecognizer)
        
        let scrollView = UIScrollView()
        scrollView.frame = self.view.frame
        scrollView.delegate = self
        
        let widthScale = self.view.bounds.size.width / (self.imageView?.bounds.width)!
        let heightScale = self.view.bounds.size.height / (self.imageView?.bounds.height)!
        let maxScale = max(widthScale, heightScale)
        
        scrollView.minimumZoomScale = CGFloat(1.0)
        scrollView.maximumZoomScale = CGFloat(3.0)
        
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        
        self.view.addSubview(scrollView)
        scrollView.addSubview(imageView!)
        
        imageView?.center = scrollView.center
        
        self.scrollView = scrollView
    
        
        let downSwipe = UISwipeGestureRecognizer.init(target: self, action: #selector(self.didDownSwipe))
        downSwipe.direction = .Down
        scrollView.addGestureRecognizer(downSwipe)
        
        let rightSwipe = UISwipeGestureRecognizer.init(target: self, action: #selector(self.rotateSwipe))
        rightSwipe.direction = .Right
        
        let leftSwipe = UISwipeGestureRecognizer.init(target: self, action: #selector(self.rotateSwipe))
        leftSwipe.direction = .Left
        
        scrollView.addGestureRecognizer(leftSwipe)
        scrollView.addGestureRecognizer(rightSwipe)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        self.toggleNavigationBar()
        self.toggleStatusBar()
        self.toggleBackgroundColor()

        self.imageView?.frame = self.view.bounds
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func loadView() {
        super.loadView()
    }
    
    func rotateSwipe(sender: UISwipeGestureRecognizer){
        guard sender.state != .Began else {
            return
        }
        
//        let newImage = self.rotate(sourceImage: (self.imageView?.image!)!, for90DegreeRight: sender.direction == .Right)
        
        let orientations :  [UIImageOrientation] = [.Up, .Right, .Down, .Left]
        
        let oldOrientation = self.imageView?.image?.imageOrientation
        var newOrientationIndex = orientations.indexOf(oldOrientation!)! + (sender.direction == .Right ? 1 : -1)
        
        if newOrientationIndex >= orientations.count {
            newOrientationIndex = 0
        }
        
        if newOrientationIndex < 0 {
            newOrientationIndex = orientations.count - 1
        }
        
        let newOrientation = orientations[newOrientationIndex]
        
        let newImage = UIImage.init(CGImage : (self.imageView?.image!.CGImage)!,
                                    scale: self.imageView!.image!.scale,
                                    orientation: newOrientation)

        
        UIView.animateWithDuration(0.3, animations: {
            self.imageView?.frame = self.view.bounds
            self.imageView?.center = self.scrollView.center
            
            let rotationsRadians = (sender.direction == .Right ? 90 : -90) * M_PI / 180
            
            self.imageView?.transform = CGAffineTransformMakeRotation(CGFloat(rotationsRadians))
            
            }) { (isFinish) in
               
                guard isFinish else {
                    return
                }
                
                
               self.imageView?.transform = CGAffineTransformMakeRotation(0)
               self.imageView?.image = newImage
        }
        
        if let delegate = self.delegate {
            delegate.changeOrientation(self, burstIdentifier: self.burstIdentifier, newOrientation: newOrientation)
        }
    }
    
    func rotate(sourceImage image: UIImage, for90DegreeRight isRightRotation: Bool) -> UIImage{
        let targetWidth = Int(image.size.height)
        let targetHeight = Int(image.size.width)
        
        let imageRef = image.CGImage!
        let bitmapInfo = CGImageGetBitmapInfo(imageRef)
        let colorSpaceInfo = CGImageGetColorSpace(imageRef)
        
        var bitmap : CGContextRef
        
        if image.imageOrientation == .Up || image.imageOrientation == .Down {
            bitmap = CGBitmapContextCreate(nil, targetHeight, targetWidth, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo!, bitmapInfo.rawValue)!;
            
        } else {
            
            
            bitmap = CGBitmapContextCreate(nil, targetWidth, targetHeight, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo!, bitmapInfo.rawValue)!;
            
        }
        
        let degree = isRightRotation ? 90.0 : -90.0
        let radians = degree * M_PI / 180
        
        CGContextRotateCTM(bitmap, CGFloat(radians))
        CGContextTranslateCTM(bitmap, 0, isRightRotation ? CGFloat(-targetHeight) : CGFloat(-targetWidth))
        
        CGContextDrawImage(bitmap, CGRectMake(0, 0, CGFloat(targetHeight), CGFloat(targetWidth)), imageRef);
        let ref = CGBitmapContextCreateImage(bitmap);
        let newImage = UIImage(CGImage:ref!)
        
//        CGContextRelease(bitmap);
//        CGImageRelease(ref);
        
        return newImage;
        
    }
    
    func didDownSwipe(sender: UISwipeGestureRecognizer){
        guard sender.state != .Began else {
            return
        }
        
        self.navigationController?.popViewControllerAnimated(false)
    }
    
    func toggleFullscreen() {
//        fullscreen = !fullscreen
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.toggleNavigationBar()
            self.toggleStatusBar()
            self.toggleBackgroundColor()
        })
    }
    
    func toggleNavigationBar() {
        navigationController?.setNavigationBarHidden(fullscreen, animated: true)
    }
    
    func toggleStatusBar() {
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    func toggleBackgroundColor() {
        let aColor: UIColor
        
        if self.fullscreen {
            aColor = UIColor.blackColor()
        } else {
            aColor = UIColor.whiteColor()
        }
        
        self.view.backgroundColor = aColor
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return fullscreen
    }
    
    private func updateMinZoomScaleForSize(size: CGSize) {
        let widthScale = size.width / (self.imageView?.bounds.width)!
        let heightScale = size.height / (self.imageView?.bounds.height)!
        let scale = min(widthScale, heightScale)
        
        
        scrollView.zoomScale = scale
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        updateMinZoomScaleForSize(view.bounds.size)
    
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
}
