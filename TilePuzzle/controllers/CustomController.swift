//
//  CustomController.swift
//  TilePuzzle
//
//  Created by Joe Kovalik-Haas on 5/22/19.
//  Copyright © 2019 Joe. All rights reserved.
//

import UIKit

class CustomController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
	
	let persistenceManager = (UIApplication.shared.delegate as? AppDelegate)!.container
	var imageView: UIImageView!
	
	// image not selected label
	let unselectedLabel: UILabel = {
		let label = UILabel()
		label.backgroundColor = HomeController.backgroundColor
		label.text = "No Image Selected"
		label.textColor = HomeController.foregroundColor
		label.font = UIFont.boldSystemFont(ofSize: Globals.boldFont)
		label.textAlignment = .center
		label.frame = Globals.boardRect
		return label
	}()
	
	// button to access image picker
	let chooseButton: UIButton = {
		let button = UIButton()
		
		button.backgroundColor = HomeController.backgroundColor
		button.layer.borderColor = HomeController.foregroundColor.cgColor
		button.layer.borderWidth = 1.0
		button.layer.cornerRadius = 10
		button.showsTouchWhenHighlighted = true
		
		button.setTitle("Choose Image", for: .normal)
		button.titleLabel?.text = "Choose Image"
		button.titleLabel?.font = UIFont.boldSystemFont(ofSize: Globals.boldFont)
		button.setTitleColor(HomeController.foregroundColor, for: .normal)
		
		let width = (Globals.width - Globals.leftAlign * 2) / 2
		button.frame = CGRect(x: Globals.xCenter - width / 2, y: Globals.topAlign * 2,
							  width: width, height: Globals.smallTop)
		button.addTarget(self, action: #selector(openPhotos(_:)), for: .touchUpInside)
		return button
	}()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		navigationItem.title = "Custom Image Creation"
		navigationController?.navigationBar.tintColor = .white
		navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
		navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveImage(_:)))
		view.backgroundColor = HomeController.backgroundColor
		
		// image view
		imageView = UIImageView(frame: Globals.boardRect)
		imageView.backgroundColor = .clear
		imageView.layer.borderColor = HomeController.foregroundColor.cgColor
		imageView.layer.borderWidth = 1
		
		view.addSubview(unselectedLabel)
		view.addSubview(imageView)
		view.addSubview(chooseButton)
	}
	
	// open image selection
	@objc func openPhotos(_ sender: UIButton) {
		let imagePicker = UIImagePickerController()
		imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
		imagePicker.allowsEditing = true	// allows editing
		imagePicker.delegate = self
		imagePicker.mediaTypes = ["public.image"]
		self.present(imagePicker, animated: true, completion: nil)
	}
	
	// sets image on finishing image picker
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
		if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
			imageView.image = image
		} else if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
			imageView.image = image
		}
		picker.dismiss(animated: true, completion: nil)
	}
	
	// checks if image picker was canceled
	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		picker.dismiss(animated: true, completion: nil)
	}
	
	// saves image selected
	@objc func saveImage(_ sender: UIBarButtonItem) {
		if imageView.image == nil {
			return
		}
		// set up custom images
		var custom = persistenceManager!.fetchCustom()
		// limit to 20 custom images
		if custom.count >= 20 {
			return
		}
		let createCustom = Custom(context: persistenceManager!.context)

		let scaled = scaleImage(image: imageView.image!)	// scale data
		let imageStore = scaled.jpegData(compressionQuality: 1)	// save image as Data
		custom.append(createCustom.configure(completed: [0, 0, 0, 0], image: imageStore))
		persistenceManager!.save()	// save
		// pop to root controller
		navigationController?.popToRootViewController(animated: true)
	}
	
	// scale image
	func scaleImage(image: UIImage) -> UIImage {
		// get new size of image
		let size = CGFloat(768)	// image size
		let ratio = size / image.size.width
		let newSize = CGSize(width: size * ratio, height: size * ratio)
		let newRect = CGRect(x: 0, y: 0, width: size * ratio, height: size * ratio)
		
		// actual resizing
		UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
		image.draw(in: newRect)
		let newImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		
		return newImage!
	}
}
