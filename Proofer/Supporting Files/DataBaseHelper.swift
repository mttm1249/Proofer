//
//  DataBaseHelper.swift
//  Proofer
//
//  Created by Денис on 31.05.2022.
//

import UIKit
import CoreData

class DataBaseHelper {
    
    static let sharedInstance = DataBaseHelper()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // Save card
    func saveCard(imageData: Data?, name: String?, locationInfo: String?, dateInfo: String?, locationIsEnabled: Bool?) {
        let cardInstance = Card(context: context)
        cardInstance.image = imageData
        cardInstance.name = name
        cardInstance.locationInfo = locationInfo
        cardInstance.dateInfo = dateInfo
        cardInstance.withLocation = locationIsEnabled!
        do {
            try context.save()
            print("Card is saved in CoreData")
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // Fetch cards with filter by location status
    func fetchCards(withStatus status: Bool?) -> [Card] {
        var fetchingCard = [Card]()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Card")
        do {
            fetchingCard = try context.fetch(fetchRequest) as! [Card]
        } catch {
            print("Error while fetching the image")
        }
        return fetchingCard.filter({ $0 .withLocation == status })
    }
    
    // Fetch all cards
    func fetchAllCards() -> [Card] {
        var fetchingCard = [Card]()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Card")
        do {
            fetchingCard = try context.fetch(fetchRequest) as! [Card]
        } catch {
            print("Error while fetching the image")
        }
        return fetchingCard
    }
}
