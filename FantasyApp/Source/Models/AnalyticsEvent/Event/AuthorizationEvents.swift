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
        let isSuccess: Bool
        
        enum Source: String {
            case FirstScreen, Registration
        };
        
        var name: String { return "Sign-In" }
        var props: [String : String]? {
            return [
                "Source": source.rawValue,
                "Type"  : isSuccess ? "Success" : "Failed"
            ]
        }
        
    }
    
    struct ForgotPasswordSubmitted: AnalyticsEvent {
        var name: String { "Sign-In: Forgot Password" }
        
        let isSuccessful: Bool
        
        var props: [String : String]? {
            return ["Type": isSuccessful ? "Success" : "Failed"]
        }
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
        case onboarding1
        case onboarding2
        case onboarding3
        case notice
        case email
        case password
        case name
        case gender
        case birthdayFilled
        case birthdayFailed
        case lookingFor
        case sexuality
        case photo(from: PhotoSource)
        case photoUploadGood
        case photoUploadBad
        case completed(from: CompleteSource, timeSpent: Int)
        
        var name: String {
            switch self {
            case .started(_)     : return "Sign-Up: Started"
            case .onboarding1    : return "Sign-Up: Onboarding 1 Passed"
            case .onboarding2    : return "Sign-Up: Onboarding 2 Passed"
            case .onboarding3    : return "Sign-Up: Onboarding 3 Passed"
            case .notice         : return "Sign-Up: Notice Filled"
            case .email          : return "Sign-Up: Email Filled"
            case .password       : return "Sign-Up: Password Filled"
            case .name           : return "Sign-Up: Name Filled"
            case .gender         : return "Sign-Up: Gender Filled"
            case .birthdayFilled : return "Sign-Up: Birthday Filled"
            case .birthdayFailed : return "Sign-Up: Birthday Failed"
            case .lookingFor     : return "Sign-Up: Looking For Filled"
            case .sexuality      : return "Sign-Up: Sexuality Filled"
            case .photo(_)       : return "Sign-Up: Photo Filled"
            case .photoUploadGood: return "Sign-Up: Photo Uploaded Well"
            case .photoUploadBad : return "Sign-Up: Photo Uploaded Failed"
            case .completed(_, _)   : return "Sign-Up: Completed"
                
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

            case .onboarding1, .onboarding2, .onboarding3, .notice, .name, .gender, .birthdayFilled, .birthdayFailed, .lookingFor, .sexuality, .email, .password, .photoUploadGood, .photoUploadBad:
                return nil
                
            }
        }
        
    }
    
}
