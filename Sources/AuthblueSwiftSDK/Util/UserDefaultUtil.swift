//
//  File.swift
//
//
//  Created by Kentaro Mihara on 2023/10/10.
//

import Foundation

func setName(_ value: String){
    let userDefaults = UserDefaults.standard
    userDefaults.set(value, forKey: "authblue_personal_name")
}

func setBirthday(_ value: String){
    let userDefaults = UserDefaults.standard
    userDefaults.set(value, forKey: "authblue_personal_birthday")
}

func setAge(_ value: String){
    let userDefaults = UserDefaults.standard
    userDefaults.set(value, forKey: "authblue_personal_age")
}

func setSex(_ value: String){
    let userDefaults = UserDefaults.standard
    userDefaults.set(value, forKey: "authblue_personal_sex")
}

func setAddress(_ value: String){
    let userDefaults = UserDefaults.standard
    userDefaults.set(value, forKey: "authblue_personal_address")
}

func setPhone(_ value: String){
    let userDefaults = UserDefaults.standard
    userDefaults.set(value, forKey: "authblue_personal_phone")
}

func setEmail(_ value: String){
    let userDefaults = UserDefaults.standard
    userDefaults.set(value, forKey: "authblue_personal_email")
}

func setIsOverlayVisible(_ value: Bool){
    let userDefaults = UserDefaults.standard
    userDefaults.set(value, forKey: "is_overlay_visible")
}

