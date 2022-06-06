//
//  SettingsViewController.swift
//  Proofer
//
//  Created by Денис on 06.06.2022.
//

import UIKit

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
    private let userDefaults = UserDefaults.standard
    private let options = ["Показывать все записи",
                   "Показывать только с локацией",
                   "Показывать только без локации"]
    private var selectedOption: IndexPath?
    private var selectedOptionString: String?
    private var selectedTheme: String?
    
    // MARK: - IBOutlets

    @IBOutlet weak var settingsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        settingsTableView.delegate = self
        settingsTableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let loadedString = userDefaults.string(forKey: "optionText") {
            selectedOptionString = loadedString
        }
        checkForSelection()
    }
    
    // Options Enum
    private enum OptionsType {
        case all, withLocation, withoutLocation
    }
    
    private func getOption(type: OptionsType) -> String? {
        switch type {
        case .all:
            return "Показывать все записи"
        case .withLocation:
            return "Показывать только с локацией"
        case .withoutLocation:
            return "Показывать только без локации"
        }
    }
    
    // Check for previous selection
    private func checkForSelection() {
        switch selectedOptionString {
        case getOption(type: .all):
            selectedOption = [0, 0]
        case getOption(type: .withLocation):
            selectedOption = [0, 1]
        case getOption(type: .withoutLocation):
            selectedOption = [0, 2]
        case .none:
            selectedOption = [0, 0]
        case .some(_):
            break
        }
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = settingsTableView.dequeueReusableCell(withIdentifier: "optionCell", for: indexPath)
        let selectedCell = indexPath
        if selectedOption == selectedCell {
            cell.backgroundColor = #colorLiteral(red: 0.006242598873, green: 0.4581466317, blue: 0.8921137452, alpha: 1)
            cell.textLabel?.textColor = .white
        } else {
            cell.backgroundColor = .systemBackground
            cell.textLabel?.textColor = .label
        }
        cell.textLabel?.text = options[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        feedbackGenerator.impactOccurred()
        let optionText = options[indexPath.row]
        userDefaults.set(optionText, forKey: "optionText")
        selectedOption = indexPath
        switch selectedOption {
        case [0, 0]:
            userDefaults.set("0", forKey: "selectedOption")
        case [0, 1]:
            userDefaults.set("1", forKey: "selectedOption")
        case [0, 2]:
            userDefaults.set("2", forKey: "selectedOption")
        default :
            break
        }
        tableView.reloadData()
    }
}
