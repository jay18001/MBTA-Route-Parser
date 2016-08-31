//
//  main.swift
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

enum DataType {
    case Trip
    case Shape
    case Stop
    
    var fileName: String {
        get {
            switch self {
            case .Trip:
                return "trips.txt"
            case .Shape:
                return "shapes.txt"
            case .Stop:
                return "stops.txt"
            }
        }
    }
}


extension String {
    func stringByAppendingPathComponent(str: String) -> String {
        return (self as NSString).stringByAppendingPathComponent(str)
    }
}

let fileDirectory = "/Users/Justin/Desktop/MBTA_GTFS"

let db = try Connection(fileDirectory.stringByAppendingPathComponent("MBTA.sqlite"))

let types: [DataType] = [.Trip, .Shape, .Stop]

for type in types {
    
    print("Starting \(type)")
    
    let filePath = fileDirectory.stringByAppendingPathComponent(type.fileName)
    
    let fileData = try? String(contentsOfFile: filePath)
    
    switch type {
    case .Trip:
        try Trip.createTable(db)
    case .Shape:
        try Shape.createTable(db)
    case .Stop:
        try Stop.createTable(db)
    }
    
    if let lines = fileData?.componentsSeparatedByString("\n") {
        
        try db.transaction {
            
            try lines.dropFirst().forEach {
                
                let data : SqliteEncoding?
                
                switch type {
                case .Trip:
                    data = Trip(csvString: $0)
                case .Shape:
                    data = Shape(csvString: $0)
                case .Stop:
                    data = Stop(csvString: $0)
                }
                
                try data?.addRow(db)
            }
        }
    }
}

print("Done")