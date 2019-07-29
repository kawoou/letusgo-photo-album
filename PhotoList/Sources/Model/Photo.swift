//
//  Photo.swift
//  PhotoList
//
//  Created by Kawoou on 30/07/2019.
//  Copyright © 2019 kawoou. All rights reserved.
//

import Foundation

struct Photo: Codable {
    let id: Int
    let fileName: String
    let url: String
    let createdAt: Date
}
