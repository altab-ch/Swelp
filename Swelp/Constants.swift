//
//  Constants.swift
//  Swelp
//
//  Created by Mathieu Knecht on 24.05.15.
//  Copyright (c) 2015 Mathieu Knecht. All rights reserved.
//

import Foundation

struct User {
    static let ClassName = "User"
    static let FirstName = "USER_FIRSTNAME"
    static let LastName = "USER_LASTNAME"
    static let Id = "USER_ID"
    static let Gender = "USER_GENDER"
    static let Locale = "USER_LOCALE"
    static let Email = "USER_EMAIL"
    static let npa = "USER_NPA"
    static let AvatarFile = "USER_AVATARFILE"
    static let skills = "USER_SKILLS"
    static let contacts = "USER_CONTACTS"
}

struct SkillCategory {
    static let ClassName = "SkillCategory"
    static let Title = "title"
    static let Description = "description"
    static let Keywords = "keywords"
    static let Skills = "Skills"
}

struct Skill {
    static let ClassName = "Skills"
    static let Title = "title"
    static let Description = "description"
    static let Keywords = "keywords"
    static let SkillCategoryID = "skillCategoryID"
}

struct Message {
    static let ClassName = "Message"
    static let ChatID = "ChatID"
    static let User = "User"
    static let Text = "Text"
    static let Image = "Image"
    static let GeoLocation = "Geolocation"
    static let createdAt = "createdAt"
}

struct Recent {
    static let ClassName = "Recent"
    static let ChatID = "ChatID"
    static let LastUser = "LastUser"
    static let LastMessage = "LastMessage"
    static let Date = "Date"
    static let User = "User"
    static let Counter = "Counter"
    static let Contact = "Contact"
}

struct Installation {
    static let User = "User"
}