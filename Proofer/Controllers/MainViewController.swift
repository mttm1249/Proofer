//
//  MainViewController.swift
//  Proofer
//
//  Created by Денис on 29.05.2022.
//

import UIKit
import CoreData
import CoreLocation

class MainViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, DataSendingProtocol, CLLocationManagerDelegate, UISearchControllerDelegate {
    
    private let userDefaults = UserDefaults.standard
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
    private let locationManager = CLLocationManager()
    private let currentLocation = CLLocation()
    private let searchController = UISearchController(searchResultsController: nil)
    
    private let time = Time()
    private var arrayOfCards = [Card]()
    private var filteredArrayOfCards: [Card] = []
    private var wasEdited = false
    private var needToDelete = false
    private var locationIsEnabled = true
    private var cardIndexPath: IndexPath?
    private var locationString: String?
    private var searchBy: String?
    var imageWasAdded: Bool? {
        didSet {
            saveButtonOutlet.isEnabled = true
        }
    }
    private var isSearchBarEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    private var isFiltering: Bool {
        return searchController.isActive && !isSearchBarEmpty
    }
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var saveButtonOutlet: UIButton!
    @IBOutlet weak var cardImageThumbnail: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var locationSwitcher: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        saveButtonOutlet.isEnabled = false
        hideKeyboardWhenTappedAround()
        setupSearchBar()
        registerCustomCell()
        setupLocationManager()
        checkLocationServices()
        setupMenu()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
        collectionView.reloadData()
    }
    
    // Load cards data from CoreData
    private func loadData() {
        switch userDefaults.string(forKey: "selectedOption") {
        case "0":
            arrayOfCards = DataBaseHelper.sharedInstance.fetchAllCards()
        case "1":
            arrayOfCards = DataBaseHelper.sharedInstance.fetchCards(withStatus: true)
        case "2":
            arrayOfCards = DataBaseHelper.sharedInstance.fetchCards(withStatus: false)
        case .none:
            arrayOfCards = DataBaseHelper.sharedInstance.fetchAllCards()
        case .some(_):
            break
        }
    }
    
    // Searching menu
    private enum SearchType {
        case name, date
    }
    
    private func getSearchType(type: SearchType) -> String? {
        switch type {
        case .name:
            return "name"
        case .date:
            return "date"
        }
    }
    
    private func setupMenu() {
        let handler: (_ action: UIAction) -> () = { action in
            print(action.identifier)
            switch action.identifier.rawValue {
            case "SearchByName":
                self.searchController.searchBar.placeholder = "Поиск по названию"
                self.searchBy = self.getSearchType(type: SearchType.name)
            case "SearchByDate":
                self.searchController.searchBar.placeholder = "Поиск по дате"
                self.searchBy = self.getSearchType(type: SearchType.date)
            default:
                break
            }
        }
        
        let actions = [
            UIAction(title: "По названию", identifier: UIAction.Identifier("SearchByName"), handler: handler),
            UIAction(title: "По дате", identifier: UIAction.Identifier("SearchByDate"), handler: handler)
        ]
        
        let menu = UIMenu(title: "Искать:",  children: actions)
        let rightBarButton = UIBarButtonItem(title: "", image: UIImage(systemName: "doc.text.magnifyingglass"), menu: menu)
        self.navigationItem.rightBarButtonItem = rightBarButton
    }
    
    func filterContentForSearchText(_ searchText: String) {
        filteredArrayOfCards = arrayOfCards.filter { (card: Card) -> Bool in
            if searchBy == "name" {
                return card.name!.lowercased().contains(searchText.lowercased())
            } else if searchBy == "date" {
                return card.dateInfo!.lowercased().contains(searchText.lowercased())
            }
            return card.name!.lowercased().contains(searchText.lowercased())
        }
        collectionView.reloadData()
    }
    
    
    // SearchBar
    private func setupSearchBar() {
        searchController.delegate = self
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Поиск по названию"
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    // Location
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue: CLLocationCoordinate2D = manager.location!.coordinate
        locationString = "\(locValue.latitude), \(locValue.longitude)"
    }
    
    private func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorization()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAlert(
                    title: "Location Services are Disabled",
                    message: "To enable it go: Settings > Privacy > Location Services and turn On"
                )
            }
        }
    }
    
    private func checkLocationAuthorization() {
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse:
            locationIsEnabled = true
        case .denied:
            locationIsEnabled = false
            locationString = "Геолокация не доступна"
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAlert(
                    title: "Your Location is not Available",
                    message: "To give permission Go to: Setting > Proofer > Location"
                )
            }
            break
        case .notDetermined:
            locationIsEnabled = false
            locationString = "Геолокация не доступна"
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            locationIsEnabled = false
            locationString = "Геолокация не доступна"
        case .authorizedAlways:
            locationIsEnabled = true
        @unknown default:
            print("New case is available")
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        
        alert.addAction(okAction)
        present(alert, animated: true)
    }
    
    // SendingData protocol methods
    func sendDataToMainVC(data: CardModel) {
        editCard(at: cardIndexPath!, with: data)
        
        collectionView.reloadData()
    }
    
    func cardEditing(result: Bool) {
        wasEdited = result
    }
    
    func deleteCard(result: Bool) {
        needToDelete = result
        if needToDelete == true {
            arrayOfCards.remove(at: cardIndexPath!.row)
            deleteCard(at: cardIndexPath!)
        }
        collectionView.reloadData()
    }
    
    // Save Action
    @IBAction func saveButton(_ sender: Any) {
        let imageData = cardImageThumbnail.image?.pngData()
        DataBaseHelper.sharedInstance.saveCard(imageData: imageData, name: nameTextField.text, locationInfo: locationString, dateInfo: time.getData(), locationIsEnabled: locationIsEnabled)
        loadData()
        collectionView.reloadData()
        reset()
        saveButtonOutlet.isEnabled = false
        feedbackGenerator.impactOccurred()
    }
    
    // Reset
    private func reset() {
        nameTextField.text = ""
        cardImageThumbnail.image = nil
    }
    
    // Delete Action
    private func deleteCard(at indexPath: IndexPath) {
        let context = AppDelegate.getContext()
        let fetchRequest: NSFetchRequest<Card> = Card.fetchRequest()
        
        if let arrayOfCards = try? context.fetch(fetchRequest) {
            let card = arrayOfCards[indexPath.row]
            context.delete(card)
        }
        do {
            try context.save()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    // Editing Action
    private func editCard(at indexPath: IndexPath, with model: CardModel) {
        let context = AppDelegate.getContext()
        let fetchRequest: NSFetchRequest<Card> = Card.fetchRequest()
        let arrayOfCards = try? context.fetch(fetchRequest)
        let editableCard = arrayOfCards![cardIndexPath!.row]
        editableCard.name = model.name
        do {
            try context.save()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    // MARK: - UICollectionView
    
    func registerCustomCell() {
        let customCell = UINib(nibName: "CardCell", bundle: nil)
        self.collectionView.register(customCell,forCellWithReuseIdentifier: "CardCell")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isFiltering {
            return filteredArrayOfCards.count
        }
        return arrayOfCards.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CardCell", for: indexPath) as? CardCell {
            if isFiltering {
                cell.setup(filteredArrayOfCards[indexPath.row])
            } else {
                cell.setup(arrayOfCards[indexPath.row])
            }
            cell.layer.borderWidth = 0.5
            cell.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1).cgColor
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        cardIndexPath = indexPath
        performSegue(withIdentifier: "editCard", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editCard" {
            let editVC = segue.destination as! EditViewController
            if let indexPath = self.collectionView.indexPathsForSelectedItems?.last {
                let currentCard = isFiltering ? filteredArrayOfCards[indexPath.item] : arrayOfCards[indexPath.item]
                editVC.currentCard = currentCard
                editVC.delegate = self
            }
        }
    }
    
    // ImagePicker Button
    @IBAction func imageButton(_ sender: Any) {
        chooseImagePicker(source: .camera)
    }
    
    // Location Switch
    @IBAction func locationSwitchButton(_ sender: Any) {
        locationIsEnabled.toggle()
        if locationIsEnabled {
            let locationIcon = UIImage(systemName: "location")
            locationManager.startUpdatingLocation()
            locationSwitcher.image = locationIcon
            print("Location service is ON")
        } else {
            let locationIconSlash = UIImage(systemName: "location.slash")
            locationManager.stopUpdatingLocation()
            locationSwitcher.image = locationIconSlash
            locationString = "Геолокация была отключена"
            print("Location service is OFF")
        }
    }
}


