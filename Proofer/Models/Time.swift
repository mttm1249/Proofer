//
//  Time.swift
//  Armageddon
//
//  Created by Денис on 26.04.2022.
//

import Foundation

class Time {
        
    func getData() -> String {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, d MMM yyyy HH:mm:ss"
        dateFormatter.locale = Locale(identifier: "ru_RU")
        let dateString = dateFormatter.string(from: date)
        return dateString
    }
}
