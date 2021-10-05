

import Foundation

struct MusicInfoModel: Codable {
    var trackViewUrl : String
    var collectionId : Int
    var trackId : Int
    var artistName: String
    var trackName: String
    var collectionName: String
    var artworkUrl100: String
    var releaseDate: String
    var primaryGenreName: String
    
    var scoredate : Date
    var score : Int
    
    init(trackViewUrl: String,
         collectionId: Int,
         trackId: Int,
         artistName: String,
         trackName: String,
         collectionName: String,
         artworkUrl100: String,
         releaseDate: String,
         primaryGenreName: String,
         scoredate :Date,
         score : Int) {
        self.trackViewUrl = trackViewUrl
        self.collectionId = collectionId
        self.trackId = trackId
        self.artistName = artistName
        self.trackName = trackName
        self.collectionName = collectionName
        self.artworkUrl100 = artworkUrl100
        self.releaseDate = releaseDate
        self.primaryGenreName = primaryGenreName
        self.scoredate = scoredate
        self.score = score
    }
}



extension Encodable {

    var json: Data? {
        let encoder = JSONEncoder()
        return try? encoder.encode(self)
    }
}

extension Decodable {

    static func decode(json data: Data?) -> Self? {
        guard let data = data else { return nil }
        let decoder = JSONDecoder()
        return try? decoder.decode(Self.self, from: data)
    }
}

extension UserDefaults {

    /// - Warning:
    /// 2020.11.30追記) setCodable ではなく set という関数名にすると、String をセットしたいときに Codable と衝突して Codable 扱いとなってしまうため注意。
    func setCodable(_ value: Codable?, forKey key: String) {
        guard let json: Any = value?.json else { return } // 2020.02.23 追記参照
        self.set(json, forKey: key)
        synchronize()
    }

    func codable<T: Codable>(forKey key: String) -> T? {
        let data = self.data(forKey: key)
        let object = T.decode(json: data)
        return object
    }
}
