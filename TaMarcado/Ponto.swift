//
//  Ponto.swift
//  
//
//  Created by Ricardo Hochman on 11/06/15.
//
//

import Foundation
import CoreData

class Ponto: NSManagedObject {

    @NSManaged var localizacao: NSData
    @NSManaged var nome: String
    @NSManaged var endereco: String

}
