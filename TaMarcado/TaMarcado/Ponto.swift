//
//  Ponto.swift
//  TaMarcado
//
//  Created by Vivian Dias on 12/06/15.
//  Copyright (c) 2015 Ricardo Hochman. All rights reserved.
//

import Foundation
import CoreData

class Ponto: NSManagedObject{

    @NSManaged var endereco: String
    @NSManaged var nome: String
    @NSManaged var localizacao: AnyObject
    
}
