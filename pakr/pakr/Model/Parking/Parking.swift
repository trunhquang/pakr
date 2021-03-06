//
//  Parking.swift
//  pakr
//
//  Created by Huynh Quang Thao on 4/5/16.
//  Copyright © 2016 Pakr. All rights reserved.
//
// 2016

import UIKit
import Parse

class Parking: NSObject, ParseModelProtocol {

    static let PKBusiness = "business"
    static let PKParkingName = "parking_name"
    static let PKCapacity = "capacity"
    static let PKAddressName = "address"
    static let PKCoordinate = "coordinate"
    static let PKVerified = "verified"
    static let PKVehicles = "vehicles"
    static let PKRegions = "regions"
    static let PKImageUrls = "images"
    static let PKSchedule = "schedule"
    
    var parkingId: String?
    
    let business: Business!
    var dateCreated: NSDate?
    let parkingName: String!
    let capacity: Int!
    var addressName: String!
    var coordinate: Coordinate!
    var verify: Bool! = false
    var vehicleList: [VehicleDetail]!
    var region: [String]!
    var imageUrl: [String]?
    var schedule: [TimeRange]!

    
    init(business: Business!, parkingName: String!, capacity: Int!, addressName: String, coordinate: Coordinate!, vehicleDetailList: [VehicleDetail]!, schedule: [TimeRange]!, region: [String]!) {
        self.business = business
        self.parkingName = parkingName
        self.capacity = capacity
        self.addressName = addressName
        self.coordinate = coordinate
        self.vehicleList = vehicleDetailList
        self.schedule = schedule
        self.region = region
    }
    
    init(dic: NSDictionary){
        var businessDescription = ""
        if dic["worktime_details"] != nil {
           businessDescription = dic["worktime_details"] as! String
        }
        var name = ""
        if dic["name"] != nil {
            name = dic["name"] as! String
        }
         business = Business(businessName:name, businessDescription: businessDescription , telephone: "")
         dateCreated = nil
         parkingName = name
         capacity = 0
        addressName = ""
        if dic["addr"] != nil {
            addressName = dic["addr"] as! String
        }
        
        let loc = dic["loc"] as! NSDictionary
        let coordinates = loc["coordinates"] as!NSArray
         coordinate = Coordinate(latitude: coordinates.lastObject as! Double, longitude: coordinates.firstObject as! Double)
         verify = false
        
        let vehicles = NSMutableArray()
        let vehicleType = dic["vehicle_type"] as! NSDictionary

        
        for key in vehicleType.allKeys{
            var max = ""
            var min = ""
            var note = ""
        let keyString = key as! String
            if dic ["price"] != nil{
                let price = dic ["price"] as! NSDictionary
                let  dicPrice = price[keyString] as! NSDictionary
                if dicPrice["max"] != nil {
                     max = dicPrice["max"] as!String
                }
                if dicPrice["min"] != nil {
                    min = dicPrice["min"] as!String
                }
                
            }

            if dic["note"] != nil {
                note = dic["note"] as! String
            }
            switch keyString {
            case "bike":
                let vehicleDetail = VehicleDetail(vehicleType: VehicleType.Bike, minPrice: min, maxPrice: max, note: note)
                vehicles.addObject(vehicleDetail)
            case "car":
                let vehicleDetail = VehicleDetail(vehicleType: VehicleType.Car, minPrice: min, maxPrice: max, note: note)
                vehicles.addObject(vehicleDetail)
            case "motor":
                let vehicleDetail = VehicleDetail(vehicleType: VehicleType.Motor, minPrice: min, maxPrice: max, note: note)
                vehicles.addObject(vehicleDetail)
            case "general":
                let vehicleDetail = VehicleDetail(vehicleType: VehicleType.General, minPrice: min, maxPrice: max, note: note)
                vehicles.addObject(vehicleDetail)
            default:
                break
            }
        }
         vehicleList =  vehicles.copy() as! [VehicleDetail]
        
         region = dic["region"] as! [String]
//         imageUrl = dic["pictures"] as? [String]
        imageUrl = ["https://www.dropbox.com/s/crpldiixsjpsdwu/do-xe-tu-dong-puzzle.jpg?dl=0"]
        let scheduls = NSMutableArray()
        var worktimes = []
        if dic["worktime"] != nil {
           worktimes = dic["worktime"] as! NSArray
        }
       
        for worktime in worktimes{
            var openTime = ""
            var closeTime = ""
            
//            let worktime1 = worktime as!NSArray
            if worktime.isKindOfClass(NSNull) {
                print("")
            }
            if !worktime.firstObject!!.isKindOfClass(NSNull){
                openTime = worktime.firstObject as! String
            }
            if !worktime.lastObject!!.isKindOfClass(NSNull){
                closeTime = worktime.lastObject as! String
            }

            let timeRange = TimeRange(openTime: openTime, closeTime: closeTime)
            scheduls.addObject(timeRange)
        }
         schedule = scheduls.copy() as! [TimeRange]
    }

    required init(pfObject: PFObject) {
        parkingId = pfObject.objectId
        
        parkingName = pfObject[Parking.PKParkingName] as! String
        capacity = pfObject[Parking.PKCapacity] as! Int
        addressName = pfObject[Parking.PKAddressName] as! String
        verify = pfObject[Parking.PKVerified] as! Bool
        region = pfObject[Parking.PKRegions] as! [String]
        imageUrl = pfObject[Parking.PKImageUrls] as? [String]
        
        business = Business(dict: pfObject[Parking.PKBusiness] as! NSDictionary)
        coordinate = Coordinate(pfObject: pfObject[Parking.PKCoordinate] as! PFGeoPoint)
        
        let vehicles = pfObject[Parking.PKVehicles] as! [NSDictionary]
        vehicleList = []
        for dict in vehicles {
            vehicleList.append(VehicleDetail(dict: dict))
        }
        
        schedule = []
        let schedules = pfObject[Parking.PKSchedule] as! [NSDictionary]
        for dict in schedules {
            schedule.append(TimeRange(dict: dict))
        }
        
        dateCreated = pfObject.createdAt
    }
    
    func toPFObject() -> PFObject {
        let parkingPF = PFObject(className: Constants.Table.Parking)
        
        parkingPF[Parking.PKParkingName] = parkingName
        parkingPF[Parking.PKCapacity] = capacity
        parkingPF[Parking.PKAddressName] = addressName
        parkingPF[Parking.PKVerified] = verify
        parkingPF[Parking.PKRegions] = region
        parkingPF[Parking.PKImageUrls] = imageUrl == nil ? NSNull() : imageUrl
        
        parkingPF[Parking.PKBusiness] = business.toDictionary()
        
        parkingPF[Parking.PKCoordinate] = coordinate.toGeoPointObject()
        
        var vehicles = [NSDictionary]()
        for v in vehicleList {
            vehicles.append(v.toDictionary())
        }
        parkingPF[Parking.PKVehicles] = vehicles
        
        var timeRanges = [NSDictionary]()
        for range in schedule {
            timeRanges.append(range.toDictionary())
        }
        parkingPF[Parking.PKSchedule] = timeRanges
        
        return parkingPF
    }
}


