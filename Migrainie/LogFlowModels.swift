//
//  LogFlowModels.swift
//  Migrainie
//
//  Created by Pourya Mazinani on 16/12/25.
//
import Foundation

// MARK: - Presets (renamed to avoid conflicts)

enum FlowStartPreset: String, CaseIterable, Identifiable {
    case justNow, oneHourAgo, other
    var id: String { rawValue }
}

enum FlowEndPreset: String, CaseIterable, Identifiable {
    case stillGoing, justNow, other
    var id: String { rawValue }
}

// MARK: - Pain location / Symptoms / Triggers

enum PainLocation: String, CaseIterable, Identifiable {
    case front, left, right, back, eyes, neck
    var id: String { rawValue }

    var title: String {
        switch self {
        case .front: return "Front"
        case .left:  return "Left"
        case .right: return "Right"
        case .back:  return "Back"
        case .eyes:  return "Eyes"
        case .neck:  return "Neck"
        }
    }

    var icon: String {
        switch self {
        case .front: return "arrow.up.circle"
        case .left:  return "arrow.left.circle"
        case .right: return "arrow.right.circle"
        case .back:  return "arrow.uturn.left.circle"
        case .eyes:  return "eye.circle"
        case .neck:  return "figure.walk.circle"
        }
    }
}

enum Symptom: String, CaseIterable, Identifiable {
    case pounding, pulsating, throbbing
    case worseMoving, nausea, vomiting
    case light, noise, neckPain
    case dizziness, congestion, insomnia
    case depressed, anxiety, smell
    case heat, tinnitus, fatigue
    case blurred, confusion

    var id: String { rawValue }

    var title: String {
        switch self {
        case .pounding: return "Pounding pain"
        case .pulsating: return "Pulsating pain"
        case .throbbing: return "Throbbing pain"
        case .worseMoving: return "Worse if moving"
        case .nausea: return "Nausea"
        case .vomiting: return "Vomiting"
        case .light: return "Sensitivity to light"
        case .noise: return "Sensitivity to noise"
        case .neckPain: return "Neck pain"
        case .dizziness: return "Giddiness"
        case .congestion: return "Nasal congestion"
        case .insomnia: return "Insomnia"
        case .depressed: return "Depressed mood"
        case .anxiety: return "Anxiety"
        case .smell: return "Sensitivity to smell"
        case .heat: return "Heat"
        case .tinnitus: return "Tinnitus"
        case .fatigue: return "Fatigue"
        case .blurred: return "Blurred vision"
        case .confusion: return "Confusion"
        }
    }

    var icon: String {
        switch self {
        case .pounding, .pulsating, .throbbing: return "bolt.circle"
        case .worseMoving: return "figure.walk.circle"
        case .nausea: return "face.smiling.inverse"
        case .vomiting: return "face.dashed"
        case .light: return "sun.max.circle"
        case .noise: return "speaker.wave.3.circle"
        case .neckPain: return "figure.walk.circle"
        case .dizziness: return "sparkles"
        case .congestion: return "nose"
        case .insomnia: return "bed.double.circle"
        case .depressed: return "cloud.circle"
        case .anxiety: return "brain.head.profile"
        case .smell: return "wind.circle"
        case .heat: return "thermometer.medium"
        case .tinnitus: return "ear"
        case .fatigue: return "battery.25"
        case .blurred: return "eye.slash"
        case .confusion: return "questionmark.circle"
        }
    }
}

enum Trigger: String, CaseIterable, Identifiable {
    case stress, lackSleep, skippedMeal
    case weather, alcohol, caffeine
    case dehydration, processed, smell

    var id: String { rawValue }

    var title: String {
        switch self {
        case .stress: return "Stress"
        case .lackSleep: return "Lack of sleep"
        case .skippedMeal: return "Skipped meal"
        case .weather: return "Very variable weather"
        case .alcohol: return "Alcohol"
        case .caffeine: return "Caffeine"
        case .dehydration: return "Dehydration"
        case .processed: return "Processed food"
        case .smell: return "Odd/Strong smell"
        }
    }

    var icon: String {
        switch self {
        case .stress: return "brain.head.profile"
        case .lackSleep: return "bed.double.circle"
        case .skippedMeal: return "fork.knife.circle"
        case .weather: return "cloud.bolt.rain.circle"
        case .alcohol: return "wineglass"
        case .caffeine: return "cup.and.saucer"
        case .dehydration: return "drop.circle"
        case .processed: return "takeoutbag.and.cup.and.straw"
        case .smell: return "wind"
        }
    }
}

// MARK: - Draft (renamed presets)

struct MigraineDraft {
    var startPreset: FlowStartPreset = .justNow
    var endPreset: FlowEndPreset = .stillGoing

    var startDate = Date()
    var endDate: Date? = Date()

    var severity: Int = 0
    var painLocation: PainLocation? = nil

    var symptoms: Set<Symptom> = []
    var triggers: Set<Trigger> = []
}

