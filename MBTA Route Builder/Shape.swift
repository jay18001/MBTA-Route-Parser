//
//  Shape.swift
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
//"shape_id","shape_pt_lat","shape_pt_lon","shape_pt_sequence","shape_dist_traveled"

struct Shape: SqliteEncoding, CSVSerialization  {
    let id: String
    let lat: Double
    let lon: Double
    let sequence: Int
    
    private let shapeSqlite = ShapeSqlite()
    
    init?(csvString: String) {
        
        let parts = csvString.componentsSeparatedByString(",")
        
        guard parts.count == 5 else {
            return nil
        }
        
        self.id = parts[0].stringByReplacingOccurrencesOfString("\"", withString: "")
        self.lat = Double(parts[1].stringByReplacingOccurrencesOfString("\"", withString: "")) ?? 0
        self.lon = Double(parts[2].stringByReplacingOccurrencesOfString("\"", withString: "")) ?? 0
        self.sequence = Int(parts[3].stringByReplacingOccurrencesOfString("\"", withString: "")) ?? 0
    }
    
    
    static func createTable(db: Connection) throws {
        try ShapeSqlite().createTable(db)
    }
    
    func addRow(db: Connection) throws -> Int64 {
        return try shapeSqlite.insert(db, shape: self)
    }
    
    private struct ShapeSqlite {
        let shapes = Table("Shapes")
        let id = Expression<String>("shapeId")
        let lat = Expression<Double>("lat")
        let lon = Expression<Double>("lon")
        let sequence = Expression<Int>("sequence")
        
        func createTable(db: Connection) throws {
            try db.run(shapes.create(ifNotExists : true) { t in
                t.column(id)
                t.column(lat)
                t.column(lon)
                t.column(sequence)
                })
        }
        
        func insert(db: Connection, shape: Shape) throws -> Int64 {
            
            let insert = shapes.insert(id <- shape.id,
                                       lat <- shape.lat,
                                       lon <- shape.lon,
                                       sequence <- shape.sequence)
            
            return try db.run(insert)
            
        }
    }
}
