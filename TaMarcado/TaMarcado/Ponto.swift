//
//  Ponto.swift
//  TaMarcado
//
//  Created by Bruno Faganello Neto on 15/06/15.
//  Copyright (c) 2015 Ricardo Hochman. All rights reserved.
//

import Foundation
import CoreData

class Ponto: NSManagedObject {

    @NSManaged var endereco: String
    @NSManaged var localizacao: AnyObject
    @NSManaged var nome: String

}
