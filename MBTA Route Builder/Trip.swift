//
//  Trip.swift
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

//"route_id","service_id","trip_id","trip_headsign","trip_short_name","direction_id","block_id","shape_id","wheelchair_accessible"
//"shape_id","shape_pt_lat","shape_pt_lon","shape_pt_sequence","shape_dist_traveled"

import Cocoa
import SQLite

protocol CSVSerialization {
    init?(csvString: String)
}

protocol SqliteEncoding {
    static func createTable(db: Connection) throws
    func addRow(db: Connection) throws -> Int64
}

struct Trip: SqliteEncoding, CSVSerialization {
    let routeId: String
    let serviceId: String
    let tripId: String
    let tripShortName: String
    let headsign: String
    let directionId: String
    let blockId: String
    let shapeId: String
    
    private let tripSqlite = TripSqlite()
    
    init?(csvString: String) {
        
        let parts = csvString.componentsSeparatedByString(",")
        
        guard parts.count == 9 else {
            return nil
        }
        
        self.routeId = parts[0].stringByReplacingOccurrencesOfString("\"", withString: "")
        self.serviceId = parts[1].stringByReplacingOccurrencesOfString("\"", withString: "")
        self.tripId = parts[2].stringByReplacingOccurrencesOfString("\"", withString: "")
        self.tripShortName = parts[3].stringByReplacingOccurrencesOfString("\"", withString: "")
        self.headsign = parts[4].stringByReplacingOccurrencesOfString("\"", withString: "")
        self.directionId = parts[5].stringByReplacingOccurrencesOfString("\"", withString: "")
        self.blockId = parts[6].stringByReplacingOccurrencesOfString("\"", withString: "")
        self.shapeId = parts[7].stringByReplacingOccurrencesOfString("\"", withString: "")
    }
    
    static func createTable(db: Connection) throws {
        try TripSqlite().createTable(db)
    }
    
    func addRow(db: Connection) throws -> Int64 {
        return try tripSqlite.insert(db, trip: self)
    }
    
    private struct TripSqlite {
        let trips = Table("Trips")
        let routeId = Expression<String>("routeId")
        let serviceId = Expression<String>("serviceId")
        let tripId = Expression<String>("tripId")
        let tripShortName = Expression<String>("tripShortName")
        let headsign = Expression<String>("headsign")
        let directionId = Expression<String>("directionId")
        let blockId = Expression<String>("blockId")
        let shapeId = Expression<String>("shapeId")
        
        func createTable(db: Connection) throws {
            try db.run(trips.create(ifNotExists : true) { t in
                t.column(routeId)
                t.column(serviceId)
                t.column(tripId)
                t.column(tripShortName)
                t.column(headsign)
                t.column(directionId)
                t.column(blockId)
                t.column(shapeId)
                })
        }
        
        func insert(db: Connection, trip: Trip) throws -> Int64 {
            
            let insert = trips.insert(routeId <- trip.routeId,
                                      serviceId <- trip.serviceId,
                                      tripId <- trip.tripId,
                                      tripShortName <- trip.tripShortName,
                                      headsign <- trip.headsign,
                                      directionId <- trip.directionId,
                                      blockId <- trip.blockId,
                                      shapeId <- trip.shapeId)
            
            return try db.run(insert)
            
        }
    }
}
