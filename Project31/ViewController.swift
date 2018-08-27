//
//  ViewController.swift
//  Project31
//
//  Created by Charles Martin Reed on 8/27/18.
//  Copyright © 2018 Charles Martin Reed. All rights reserved.
//

import WebKit
import UIKit

class ViewController: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate, WKNavigationDelegate, WKUIDelegate {
    @IBOutlet weak var addressBar: UITextField!
    @IBOutlet weak var stackView: UIStackView!
    
    //tracks the active web site - weak because it might go away at any time if the user deletes it
    weak var activeWebView: WKWebView?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setDefaultTitle()
        
        //we need two buttons in our nav bar - one to add a new web view and one to delete whichever web view the user doesn't want anymore
        let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addWebView))
        let delete = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteWebView))
        navigationItem.rightBarButtonItems = [delete, add]
        
    }
    
    func setDefaultTitle() {
        title = "Multibrowser"
    }
    
    //we need to detect when the user enters a new URL in the address bar
    //when the user presses return on their keyboard, this happens
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //if there's an activeWebview and if the user enters something into the address bar
        if let webView = activeWebView, let address = addressBar.text {
            if let url = URL(string: address) {
                webView.load(URLRequest(url: url))
            }
        }
        
        textField.resignFirstResponder()
        return true
        
    }
    
    @objc func addWebView() {
        //add a new WKWebView to our UIStackView, using addArrangedSubview() NOT addSubview(). StackView handles the arranging itself, we just add to the subView array.
        
        let webView = WKWebView()
        webView.uiDelegate = self
        
        //stackView handles arranging the views itself, we don't have to worry about constraints or autolayout
        stackView.addArrangedSubview(webView)
        
        //remember that by default iOS can only access HTTPs sites
        let url = URL(string: "https://www.google.com")!
        webView.load(URLRequest(url: url))
        
        //we're going to denote an active webView with a blue border, setting that visible when the user touches it
        webView.layer.borderColor = UIColor.blue.cgColor
        selectWebView(webView)
        
        //add the gesture recognizer to our webView
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(webViewTapped))
        recognizer.delegate = self
        webView.addGestureRecognizer(recognizer)
    }
    
    @objc func deleteWebView(_ webView: WKWebView) {
        //delete button should only work if there's a web view selected
        if let webView = activeWebView {
            if let index = stackView.arrangedSubviews.index(of: webView) {
                //find the location of the active web view inside the stack view, then remove it
                stackView.removeArrangedSubview(webView)
                
                //remove from view hiearachy as well - when you remove something from an arranged stack view, it's hidden but not destroyed. We call this method to destroy it properly and avoid memory leaks.
                webView.removeFromSuperview()
                
                //if no more web views, call setDefaultTitle to reset the user interface
                if stackView.arrangedSubviews.count == 0 {
                    setDefaultTitle()
                } else {
                    //find out whatever web view immediately follows the removed view and make THAT the selected web view
                    var currentIndex = Int(index)
                    
                    if currentIndex == stackView.arrangedSubviews.count {
                        currentIndex = stackView.arrangedSubviews.count - 1
                    }
                    
                    if let newSelectedWebView = stackView.arrangedSubviews[currentIndex] as? WKWebView {
                        selectWebView(newSelectedWebView)
                    }
                }
            }
        }
    }
    
    
    func selectWebView(_ webView: WKWebView) {
        //called when we want to activate a web view
        //URL requests should be sent here for navigation
        //view should be highlighted
        
        for view in stackView.arrangedSubviews {
            //set all views borderWidth to 0
            view.layer.borderWidth = 0
        }
        
        //set our selected view, the caller, to have a visible border width
        activeWebView = webView
        webView.layer.borderWidth = 3
    }
    
    @objc func webViewTapped(_ recognizer: UITapGestureRecognizer) {
        if let selectedWebView = recognizer.view as? WKWebView {
            selectWebView(selectedWebView)
        }
    }
    
    //we want our gesture reconizers to trigger alongside the ones built into WKWebView so we use this one to simultaneously trigger all of them at once.
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

}

