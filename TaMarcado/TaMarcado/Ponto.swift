//
//  Ponto.swift
//  TaMarcado
//
//  Created by Bruno Faganello Neto on 15/06/15.
//  Copyright (c) 2015 Ricardo Hochman. All rights reserved.
//

import Foundation
import CoreData
import MapKit
import AddressBook

class Ponto: NSManagedObject {

    @NSManaged var endereco: String
    @NSManaged var localizacao: AnyObject
    @NSManaged var nome: String

    
    func mapItem() -> MKMapItem {
        let addressDictionary = [String(kABPersonAddressStreetKey): endereco]
        let placemark = MKPlacemark(coordinate: (localizacao as! CLLocation).coordinate, addressDictionary: addressDictionary)
        
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = nome
        
        return mapItem
    }
    
}
