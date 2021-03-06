//
//  ImageShowerControlleer.swift
//  Calculator
//
//  Created by Jing Wei Li on 11/26/17.
//  Copyright © 2017 Jing Wei Li. All rights reserved.
//  Props to Stanford CS193P for image fetch code
//

import UIKit

class ImageShowerControlleer: UIViewController, UITextFieldDelegate{

    @IBOutlet weak var myTextField: UITextField!
    @IBOutlet weak var result: UILabel!
    fileprivate var imageView = UIImageView()
    
    @IBOutlet weak var scrollView: UIScrollView!{
        didSet{
            // to zoom we have to handle viewForZooming(in scrollView:)
            scrollView.delegate = self
            // and we must set our minimum and maximum zoom scale
            scrollView.minimumZoomScale = 0.5
            scrollView.maximumZoomScale = 2.5
            // most important thing to set in UIScrollView is contentSize
            scrollView.contentSize = imageView.frame.size
            scrollView.addSubview(imageView)
        }
    }
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    
    private var image: UIImage? {
        get {
            return imageView.image
        }
        set{
            imageView.image = newValue
            imageView.sizeToFit()
            scrollView?.contentSize = imageView.frame.size
            //in prepare, when outlets are not set, this would crash
            //optional chaining fixes this issue
            spinner?.stopAnimating()
        }
    }
    var imageURL: URL? {
        didSet {
            image = nil
            if view.window != nil { // if we're on screen
                fetchImage() // then fetch image
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        myTextField.resignFirstResponder() // collapse keyboard upon pressing return
        return true
    }
    
    
    private func fetchImage() {
        if let url = imageURL {
            // this next line of code can throw an error
            // and it also will block the UI entirely while access the network
            // we really should be doing it in a separate thread
            
            //start a multithreading session
            // w/o weak self : the closure keeps the vc in the heap even after back button
            // is pressed
            spinner.startAnimating()
            DispatchQueue.global(qos: .userInitiated).async{ [weak self] in // fetch img in another queue
                let urlContents = try? Data(contentsOf: url)//blocks the main queue
                if let imageData = urlContents, url == self?.imageURL { // prevents double-calling of this fn
                    DispatchQueue.main.async {
                        // self is optional -> self may be nil, thus displays no image
                        // got the img, send it back to main queue and update scrollview
                        self?.image = UIImage(data: imageData)
                    }
                }
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        imageURL = URL(string:"https://avatars1.githubusercontent.com/u/10605755?s=400&u=ecb512ec917134e043585510545e9d6b3a14d9a5&v=4");
        myTextField.delegate = self
    }

    
    @IBAction func showText(_ sender: UIButton) {
        let text: String = myTextField.text!
        result.text = text
        let fetchedImg = URL(string: text)
        imageURL = fetchedImg
        self.view.endEditing(true)//collapse keyboard
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if image == nil { // we're about to appear on screen so, if needed,
            fetchImage() // fetch image
        }
    }
}

extension ImageShowerControlleer : UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
