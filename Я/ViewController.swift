//
//  ViewController.swift
//  Я
//
//  Created by Shao Tianchi on 2018/2/20.
//  Copyright © 2018年 Shao Tianchi. All rights reserved.
//

import UIKit
import Photos
import MobileCoreServices

class ViewController: UIViewController {

    @IBOutlet weak var buttonsView: UIView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var emptyView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNeedsStatusBarAppearanceUpdate()
        let layer = CAGradientLayer()
        layer.frame = self.view.bounds
        layer.colors = [UIColor(hex: 0xe011cb).cgColor, UIColor(hex: 0xf8e745).cgColor]
        layer.startPoint = CGPoint(x: 0.5, y: 0)
        layer.endPoint = CGPoint(x: 0.5, y: 1)
        self.view.layer.insertSublayer(layer, at: 0)
        
        imageView.layer.shadowColor = UIColor.black.cgColor
        imageView.layer.shadowOffset = CGSize(width: 0, height: 0.5)
        imageView.layer.shadowRadius = 10
        imageView.layer.shadowOpacity = 0.6
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func reselect(_ sender: Any) {
        self.handleTap(nil)
    }
    
    @IBAction func handleTap(_ tap: UITapGestureRecognizer?) {
        let sheet = UIAlertController(title: "Choose a gif", message: nil, preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "From album", style: .default, handler: { (action) in
            self.choose()
        }))
        sheet.addAction(UIAlertAction(title: "Input URL", style: .default, handler: { (action) in
            self.showInput()
        }))
        
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(sheet, animated: true, completion: nil)
    }
    
    func showInput() {
        let alert = UIAlertController(title: "Input the URL", message: "Better copy first", preferredStyle: .alert)
        alert.addTextField { (textfield) in
            
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            guard let string = alert.textFields?[0].text, !string.isEmpty else {
                self.toast(message: "URL can not be empty")
                return
            }
            
            guard let url = URL(string: string) else {
                self.toast(message: "URL not correct, please check again")
                return
            }
            
            self.emptyView.isHidden = true
            self.indicator.alpha = 1
            self.indicator.startAnimating()
            
            self.download(url: url)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func choose() {
        func showPicker() {
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.allowsEditing = false
            picker.delegate = self
            self.present(picker, animated: true, completion: nil)
        }
        
        if PHPhotoLibrary.authorizationStatus() == .notDetermined  {
            PHPhotoLibrary.requestAuthorization({ (status) in
                if status == .authorized {
                    showPicker()
                }
            })
        } else {
            showPicker()
        }
    }
    
    func download(url: URL) {
        let session = URLSession(configuration: .default)
        let task = session.downloadTask(with: url) { (temp, response, error) in
            guard let temp = temp else {
                DispatchQueue.main.async {
                    self.toast(message: "Download failed, please try again")
                }
                return
            }
            do {
                try? FileManager.default.removeItem(atPath: GifPath.origin)
                try FileManager.default.moveItem(atPath: temp.path, toPath: GifPath.origin)
                DispatchQueue.main.async {
                    self.afterDownload(with: GifPath.origin)
                }
            } catch {
                DispatchQueue.main.async {
                    self.toast(message: "Download failed, please try again")
                }
            }
        }
        
        task.resume()
    }
    
    func afterDownload(with imagePath: String) {
        let image = UIImage.reversedGifImage(with: imagePath)
        image?.saveTo(GifPath.reversed)
        imageView.image = image
        imageView.isHidden = false
        indicator.alpha = 0
        indicator.stopAnimating()
        imageView.startAnimating()
        buttonsView.isHidden = false
    }
    
    func afterChoose(with image: UIImage) {
        imageView.image = image
        image.saveTo(GifPath.reversed)
        imageView.isHidden = false
        imageView.startAnimating()
        buttonsView.isHidden = false
        emptyView.isHidden = true
    }
    
    @IBAction func save(_ sender: Any) {
        func actSave() {
            do {
                try PHPhotoLibrary.shared().performChangesAndWait {
                    let result = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: nil)
                    var collectionRequest: PHAssetCollectionChangeRequest?
                    result.enumerateObjects {
                        collection, index, stop in
                        if collection.localizedTitle == "#Я#" {
                            collectionRequest = PHAssetCollectionChangeRequest(for: collection)
                        }
                    }
                    
                    if collectionRequest == nil {
                        collectionRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: "#Я#")
                    }
                    
                    let assetRequest = PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: URL(fileURLWithPath: GifPath.reversed))
                    if let placeholder = assetRequest?.placeholderForCreatedAsset {
                        let arr: NSArray = [placeholder]
                        collectionRequest?.addAssets(arr)
                    } else {
                        self.toast(message: "Save failed")
                    }
                }
                self.toast(message: "Save success")
                
                imageView.isHidden = true
                buttonsView.isHidden = true
                emptyView.isHidden = false
            } catch (let e as NSError) {
                print("error")
            }
        }
        
        let status = PHPhotoLibrary.authorizationStatus()
        if status == .authorized {
            actSave()
        } else if status == .notDetermined {
            PHPhotoLibrary.requestAuthorization({ (status) in
                if status != .authorized { return }
                actSave()
            })
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var action: (() -> Void)? = nil
        if let asset = info[UIImagePickerControllerPHAsset] as? PHAsset {
            let requestOptions = PHImageRequestOptions()
            requestOptions.isSynchronous = true
            
            PHImageManager.default().requestImageData(for: asset, options: requestOptions, resultHandler: { (imageData, UTI, _, _) in
                if let uti = UTI,let data = imageData, UTTypeConformsTo(uti as CFString, kUTTypeGIF), let image = UIImage.reversedGifImage(with: data) {
                    self.afterChoose(with: image)
                } else {
                    action = {
                        self.toast(message: "This photo is not gif")
                    }
                }
            })
        } else {
            action = {
                self.toast(message: "Cannot find this photo")
            }
        }
        
        picker.dismiss(animated: true) {
            action?()
        }
    }
}

