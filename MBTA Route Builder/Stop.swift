//
//  Stop.swift
//  MBTA Route Builder
//
//  Copyright (c) 2016 Mountain Buffalo Limited.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the
//  Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software,
//  and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
//  PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
//  CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

import Foundation
import SQLite

//"stop_id","stop_code","stop_name","stop_desc","stop_lat","stop_lon","zone_id","stop_url","location_type","parent_station","wheelchair_boarding"
//"Wareham Village","","Wareham Village","",41.758333,-70.714722,"","",0,"",1

struct Stop: SqliteEncoding, CSVSerialization  {
    let id: String
    let code: String
    let name: String
    let desc: String
    let lat: Double
    let lon: Double
    let zoneId: String
    let stopURL: String
    let locationType: Int
    let parentStation: String
    
    private let stopSqlite = StopSqlite()
    
    init?(csvString: String) {
        
        let parts = csvString.componentsSeparatedByString(",")
        
        guard parts.count == 11 else {
            return nil
        }
        
        id = parts[0].stringByReplacingOccurrencesOfString("\"", withString: "")
        code = parts[1].stringByReplacingOccurrencesOfString("\"", withString: "")
        name = parts[2].stringByReplacingOccurrencesOfString("\"", withString: "")
        desc = parts[3].stringByReplacingOccurrencesOfString("\"", withString: "")
        lat = Double(parts[4].stringByReplacingOccurrencesOfString("\"", withString: "")) ?? 0
        lon = Double(parts[5].stringByReplacingOccurrencesOfString("\"", withString: "")) ?? 0
        zoneId = parts[6].stringByReplacingOccurrencesOfString("\"", withString: "")
        stopURL = parts[7].stringByReplacingOccurrencesOfString("\"", withString: "")
        locationType = Int(parts[8].stringByReplacingOccurrencesOfString("\"", withString: "")) ?? 0
        parentStation = parts[9].stringByReplacingOccurrencesOfString("\"", withString: "")
        
    }
    
    
    static func createTable(db: Connection) throws {
        try StopSqlite().createTable(db)
    }
    
    func addRow(db: Connection) throws -> Int64 {
        return try stopSqlite.insert(db, stop: self)
    }
    
    private struct StopSqlite {
        let stops = Table("Stops")
        let id = Expression<String>("id")
        let code = Expression<String>("code")
        let name = Expression<String>("name")
        let desc = Expression<String>("desc")
        let lat = Expression<Double>("lat")
        let lon = Expression<Double>("lon")
        let zoneId = Expression<String>("zoneId")
        let stopURL = Expression<String>("stopURL")
        let locationType = Expression<Int>("locationType")
        let parentStation = Expression<String>("parentStation")
        
        func createTable(db: Connection) throws {
            try db.run(stops.create(ifNotExists : true) { t in
                t.column(id, primaryKey: true)
                t.column(code)
                t.column(name)
                t.column(desc)
                t.column(lat)
                t.column(lon)
                t.column(zoneId)
                t.column(stopURL)
                t.column(locationType)
                t.column(parentStation)
                })
        }
        
        func insert(db: Connection, stop: Stop) throws -> Int64 {
            
            let insert = stops.insert(id <- stop.id,
                                      code <- stop.code,
                                      name <- stop.name,
                                      desc <- stop.desc,
                                      lat <- stop.lat,
                                      lon <- stop.lon,
                                      zoneId <- stop.zoneId,
                                      stopURL <- stop.stopURL,
                                      locationType <- stop.locationType,
                                      parentStation <- stop.parentStation)
            
            return try db.run(insert)
            
        }
    }
    
}