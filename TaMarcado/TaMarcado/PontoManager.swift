//
//  PontoManager.swift
//  TaMarcado
//
//  Created by Ricardo Hochman on 11/06/15.
//  Copyright (c) 2015 Ricardo Hochman. All rights reserved.
//

import CoreData
import UIKit
import MapKit

class PontoManager {
    static let sharedInstance = PontoManager()
    static let entityName: String = "Ponto"
    
    var novoLocal: MapaPoint! = MapaPoint()
    
    lazy var managedContext: NSManagedObjectContext = {
        var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.managedObjectContext!
    }()
    
    private init() {}
    
    func novoPonto() -> Ponto {
        return NSEntityDescription.insertNewObjectForEntityForName(PontoManager.entityName, inManagedObjectContext: managedContext) as! Ponto
    }
    
    func buscarPontos() -> Array<Ponto> {
        let buscaRequest = NSFetchRequest(entityName: PontoManager.entityName)
        var erro: NSError?
        let buscaResultados = managedContext.executeFetchRequest(buscaRequest, error: &erro) as? [NSManagedObject]
        if let resultados = buscaResultados as? [Ponto] {
            return resultados
        } else {
            println("Não foi possível buscar esse ponto. Erro: \(erro), \(erro!.userInfo)")
        }
        NSFetchRequest(entityName: "FetchRequest")
        return Array<Ponto>()
    }
    
    func buscarPonto(index: Int) -> Ponto {
        var ponto: Ponto = buscarPontos()[index]
        return ponto
    }
    
    func salvarPonto() {
        var erro: NSError?
        managedContext.save(&erro)
        
        if let e = erro {
            println("Não foi possível salvar esse ponto. Erro: \(erro), \(erro!.userInfo)")
        }
    }
    
    func removerTodos() {
        var arrayPonto: Array<Ponto> = buscarPontos()
        for ponto: Ponto in arrayPonto {
            managedContext.delete(ponto)
        }
    }
    
    func removerPonto(index: Int) {
        var arrayPonto: Array<Ponto> = buscarPontos()
        managedContext.deleteObject(arrayPonto[index] as NSManagedObject)
        salvarPonto()
    }
    
    func apagarPonto(var ponto:Ponto) -> Bool
    {
        var error:NSError?
        var pontoNome = ponto.nome
        
        managedContext.deleteObject(ponto)
        managedContext.save(&error)
        
        if let e = error {
            println("Erro ao tentar remover a Ponto (\(pontoNome)): \(error)")
            return false
        } else {
            println("Ponto \(pontoNome) removida com sucesso")
        }
        return true
    }
    
    func salvarNovoPonto(nome: String, endereco: String, localizacao: CLLocation) {
        let ponto = novoPonto()
        ponto.setValue(nome, forKey: "nome")
        ponto.setValue(endereco, forKey: "endereco")
        
        let archivedLocation = NSKeyedArchiver.archivedDataWithRootObject(localizacao)
        ponto.setValue(localizacao, forKey: "localizacao")
        
        salvarPonto()
    }
}