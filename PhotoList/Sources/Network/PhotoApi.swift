//
//  PhotoApi.swift
//  PhotoList
//
//  Created by Kawoou on 30/07/2019.
//  Copyright © 2019 kawoou. All rights reserved.
//

import Moya

enum PhotoApi {
    case list
    case upload(fileUrl: URL)
}

extension PhotoApi: TargetType {
    var baseURL: URL {
        return URL(string: "http://letusgo-summer-19.kawoou.kr")!
    }
    var path: String {
        switch self {
        case .list:
            return "/photo"
        case .upload:
            return "/photo"
        }
    }
    var headers: [String : String]? {
        return nil
    }
    var method: Method {
        switch self {
        case .list:
            return .get
        case .upload:
            return .post
        }
    }
    var sampleData: Data {
        return Data()
    }
    var task: Task {
        switch self {
        case .list:
            return .requestPlain
        case let .upload(fileUrl: url):
            return .uploadMultipart([
                MultipartFormData(provider: MultipartFormData.FormDataProvider.file(url), name: "image")
            ])
        }
    }
}
