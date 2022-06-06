//
//  EditViewController.swift
//  Proofer
//
//  Created by Денис on 29.05.2022.
//

import UIKit

protocol DataSendingProtocol {
    func sendDataToMainVC(data: CardModel)
    func cardEditing(result: Bool)
    func deleteCard(result: Bool)
}

class EditViewController: UIViewController {
    
    private let time = Time()
    private var descriptionText: String?
    var currentCard = Card()
    var delegate: DataSendingProtocol!
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var cardImage: UIImageView!
    @IBOutlet weak var nameLabelEdit: UITextField!
    @IBOutlet weak var locationTextView: UITextView!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupImage()
        setupCardInfo()
        hideKeyboardWhenTappedAround()
    }
    
    // Painting texts on picked image
    private func textOnImage(drawText text: String, inImage image: UIImage, atPoint point: CGPoint) -> UIImage {
        let textColor = UIColor.white
        let bgColor = UIColor.darkGray
        let transparentBgColor = bgColor.withAlphaComponent(0.6)
        let textFont = UIFont(name: "Arial", size: 35)!
        
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(image.size, false, scale)
        
        let textFontAttributes = [
            NSAttributedString.Key.font: textFont,
            NSAttributedString.Key.foregroundColor: textColor,
            NSAttributedString.Key.backgroundColor: transparentBgColor,
        ] as [NSAttributedString.Key : Any]
        image.draw(in: CGRect(origin: CGPoint.zero, size: image.size))
        
        let rect = CGRect(origin: point, size: image.size)
        text.draw(in: rect, withAttributes: textFontAttributes)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    // Setup Card Info
    private func setupCardInfo() {
        nameLabelEdit.text = currentCard.name
        locationTextView.text = currentCard.locationInfo
        dateLabel.text = currentCard.dateInfo
    }
    
    // Prepearing image
    private func setupImage() {
        guard currentCard.image != nil else { return }
        let image = UIImage(data: currentCard.image!)
        let compressedImageData = (image!.compress(to: 1000))
        let compressedImage = UIImage(data: compressedImageData)
        let imageWithDate = textOnImage(drawText: currentCard.dateInfo!, inImage: compressedImage!, atPoint: CGPoint(x: 20, y: 20))
        let imageWithLocation = textOnImage(drawText: currentCard.locationInfo!, inImage: imageWithDate, atPoint: CGPoint(x: 20, y: 70))
        cardImage.image = imageWithLocation
    }
    
    // Save Button
    @IBAction func saveButton(_ sender: Any) {
        let imageData = cardImage.image?.pngData()
        let card = CardModel(name: nameLabelEdit.text, locationInfo: locationTextView.text, dateInfo: dateLabel.text, image: imageData)
        delegate.sendDataToMainVC(data: card)
        delegate.cardEditing(result: true)
        dismiss(animated: true)
    }
    
    // Share Button
    @IBAction func shareButton(_ sender: Any) {
        if nameLabelEdit.text != "" {
            descriptionText = nameLabelEdit.text!
        } else {
            descriptionText = "Без названия"
        }
        let image = cardImage.image
        let activityViewController : UIActivityViewController = UIActivityViewController(
            activityItems: [descriptionText!, image!], applicationActivities: nil)
        
        activityViewController.activityItemsConfiguration = [UIActivity.ActivityType.message] as? UIActivityItemsConfigurationReading
        
        activityViewController.isModalInPresentation = true
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    // Delete Button
    @IBAction func deleteButton(_ sender: Any) {
        let alertController = UIAlertController(title: "Удалить?", message: "", preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: "Да", style: .destructive) { action in
            self.delegate.deleteCard(result: true)
            self.dismiss(animated: true)
        }
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .default) { _ in }
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
}
