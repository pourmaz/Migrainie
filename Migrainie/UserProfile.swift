import Foundation

struct UserProfile: Codable {
    var username: String = ""
    var age: String = ""
    var sex: String = ""          // e.g. “Female”, “Male”, “Other”
    var heightCm: String = ""     // we keep as String for simple input
    var weightKg: String = ""
    
    var healthConditions: String = ""   // free text (e.g. “Asthma, Hypertension”)
    var medications: String = ""        // free text (e.g. “Propranolol 40 mg bid”)
    var allergies: String = ""          // optional but useful
}
//
//  UserProfile.swift
//  Migrainie
//
//  Created by Pourya Mazinani on 04/12/25.
//

