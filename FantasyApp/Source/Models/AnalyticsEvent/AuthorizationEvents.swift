//
//  AuthorizationEvents.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 05.12.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation

extension Analytics.Event {
    
    struct FirstScreen: AnalyticsEvent {
        var name: String { return "First Screen" }
    }

    struct SignIn: AnalyticsEvent {
        
        let source: Source
        
        enum Source: String {
            case FirstScreen, ForgotPassword
        };
        
        var name: String { return "Sign-In" }
        var props: [String : String]? {
            return ["Source": source.rawValue]
        }
        
    }
    
    struct ForgotPasswordSubmitted: AnalyticsEvent {
        var name: String { "Sign-In: Forgot Password" }
    }
    
    enum SignUpPassed: AnalyticsEvent {
        
        enum StartedSource: String {
            case Facebook, Email
        }
        
        enum PhotoSource: String {
            case Chosen, Taken
        }
        
        enum CompleteSource: String {
            case SignUp, Facebook
        }
        
        case started(from: StartedSource)
        case notice
        case name
        case gender
        case birthdayFilled
        case birthdayFailed
        case relation
        case sexuality
        case email
        case password
        case photo(from: PhotoSource)
        case photoUploadGood
        case photoUploadBad
        case completed(from: CompleteSource, timeSpent: Int)
        
        var name: String {
            switch self {
            case .started(_)     : return "Sign-Up: Started"
            case .notice         : return "Sign-Up: Notice Filled"
            case .name           : return "Sign-Up: Name Filled"
            case .gender         : return "Sign-Up: Gender Filled"
            case .birthdayFilled : return "Sign-Up: Birthday Filled"
            case .birthdayFailed : return "Sign-Up: Birthday Failed"
            case .relation       : return "Sign-Up: Relationship Status Filled"
            case .sexuality      : return "Sign-Up: Sexuality Filled"
            case .email          : return "Sign-Up: Email Filled"
            case .password       : return "Sign-Up: Password Filled"
            case .photo(_)       : return "Sign-Up: Photo Filled"
            case .photoUploadGood: return "Sign-Up: Photo Uploaded Well"
            case .photoUploadBad : return "Sign-Up: Photo Uploaded Failed"
            case .completed(_)   : return "Sign-Up: Completed"
                
            }
        }
        
        var props: [String : String]? {
            switch self {
            case .started(let from):
                return ["Type": from.rawValue]
                
            case .photo(let from):
                return ["Type": from.rawValue]
                
            case .completed(let from, let timeSpent):
                return [
                    "Source": from.rawValue,
                    "Time Spent": "\(timeSpent)"
                ]

            case .notice, .name, .gender, .birthdayFilled, .birthdayFailed, .relation, .sexuality, .email, .password, .photoUploadGood, .photoUploadBad:
                return nil
                
            }
        }
        
    }
    
}
