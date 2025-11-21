//
//  MGSong.swift
//  MGNetworkKitApp
//
//  Created by 刘远明 on 2025/11/21.
//

import UIKit
import MGNetworkKit
import MGNetworkMacros
import Alamofire

@MGAPI(path: "/restserver/ting", method: .post)
public struct MGSongRequest: Codable {
    let channel : String?
    let format : String?
    let from : String?
    let kflag : String?
    let method : String?
    let aoperator : String?
    let version : String?
    
    enum CodingKeys: String, CodingKey {
        case channel = "channel"
        case format = "format"
        case from = "from"
        case kflag = "kflag"
        case method = "method"
        case aoperator = "operator"
        case version = "version"
    }
//    public init(from decoder: Decoder) throws {
//        let values = try decoder.container(keyedBy: CodingKeys.self)
//        channel = try values.decodeIfPresent(String.self, forKey: .channel)
//        format = try values.decodeIfPresent(String.self, forKey: .format)
//        from = try values.decodeIfPresent(String.self, forKey: .from)
//        kflag = try values.decodeIfPresent(String.self, forKey: .kflag)
//        method = try values.decodeIfPresent(String.self, forKey: .method)
//        aoperator = try values.decodeIfPresent(String.self, forKey: .aoperator)
//        version = try values.decodeIfPresent(String.self, forKey: .version)
//    }
}

public struct MGSong: Codable {
    let content: [Song]?
    let error_code:String?

    enum CodingKeys: String, CodingKey {
        case error_code
        case content
    }
}

public struct Song: Codable  {
    let type: Int?
    let count: Int?
    let name:String?
    let comment:String?
    let web_url:String?
    let pic_s192:String?
    let pic_s444:String?
    let pic_s260:String?
    let pic_s210:String?

    let color:String?
    let bg_color:String?
    let bg_pic:String?
    let content:[Content]  = [Content]()

    enum CodingKeys: String, CodingKey {
        case type
        case count
        case name
        case comment
        case web_url
        case pic_s192
        case pic_s444
        case pic_s260
        case pic_s210

        case color
        case bg_color
        case bg_pic
        case content
    }
}

public struct Content: Codable  {
    let title:String?
    let author:String?
    let song_id:String?
    let album_id:String?
    let album_title:String?
    let rank_change:String?
    let all_rate:String?
    let biaoshi:String?
    let pic_big:String?
    let pic_small:String?

    enum CodingKeys: String, CodingKey {
        case title
        case author
        case song_id
        case album_id
        case album_title
        case rank_change
        case all_rate
        case biaoshi
        case pic_big
        case pic_small
    }
}
