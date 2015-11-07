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
        do {
            let buscaRequest = NSFetchRequest(entityName: PontoManager.entityName)
            let buscaResultados = try managedContext.executeFetchRequest(buscaRequest) as? [NSManagedObject]
            if let resultados = buscaResultados as? [Ponto] {
                return resultados
            }
            
//            NSFetchRequest(entityName: "FetchRequest")
        } catch {
            
        }
        return Array<Ponto>()

    }
    
    func buscarPonto(index: Int) -> Ponto {
        let ponto: Ponto = buscarPontos()[index]
        return ponto
    }
    
    func salvarPonto() {
        var erro: NSError?
        do {
            try managedContext.save()
        } catch let error as NSError {
            erro = error
        }
        
        if let _ = erro {
            print("Não foi possível salvar esse ponto. Erro: \(erro), \(erro!.userInfo)")
        }
    }
    
    func removerTodos() {
        let arrayPonto: Array<Ponto> = buscarPontos()
        for ponto: Ponto in arrayPonto {
            managedContext.delete(ponto)
        }
    }
    
    func removerPonto(index: Int) {
        var arrayPonto: Array<Ponto> = buscarPontos()
        managedContext.deleteObject(arrayPonto[index] as NSManagedObject)
        salvarPonto()
    }
    
    func apagarPonto(ponto:Ponto) -> Bool
    {
        var error:NSError?
        let pontoNome = ponto.nome
        
        managedContext.deleteObject(ponto)
        do {
            try managedContext.save()
        } catch let error1 as NSError {
            error = error1
        }
        
        if let _ = error {
            print("Erro ao tentar remover a Ponto (\(pontoNome)): \(error)")
            return false
        } else {
            print("Ponto \(pontoNome) removida com sucesso")
        }
        return true
    }
    
    func salvarNovoPonto(nome: String, endereco: String, localizacao: CLLocation) {
        let ponto = novoPonto()
        ponto.setValue(nome, forKey: "nome")
        ponto.setValue(endereco, forKey: "endereco")
        
        _ = NSKeyedArchiver.archivedDataWithRootObject(localizacao)
        ponto.setValue(localizacao, forKey: "localizacao")
        
        salvarPonto()
    }
}