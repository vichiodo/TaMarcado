//
//  ListaViewController.swift
//  TaMarcado
//
//  Created by Ricardo Hochman on 11/06/15.
//  Copyright (c) 2015 Ricardo Hochman. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class ListaViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var tableView: UITableView!
    
    var pontoSelecionado:Ponto?
    var row:Int?
    
   lazy var pontos:Array<Ponto> = {
        return PontoManager.sharedInstance.buscarPontos()
    }()
        
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    override func viewWillAppear(animated: Bool) {
        pontos = PontoManager.sharedInstance.buscarPontos()
        self.tableView.reloadData()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pontos.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let ponto:Ponto = pontos[indexPath.row]
        
        var cell:CellController = tableView.dequeueReusableCellWithIdentifier("CellController") as! CellController
        
        cell.nome.text = ponto.nome
        cell.endereco.text = ponto.endereco
        
        return cell
    }
    
     func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {}
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        
        let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Apagar") { (action, indexPath) -> Void in
            var pontoSelecionado = self.pontos[indexPath.row]
            
            if PontoManager.sharedInstance.apagarPonto(pontoSelecionado) {
                self.pontos.removeAtIndex(indexPath.row)
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            } else {
                let alertController = UIAlertController(title: "Remoção", message: "Não foi possível remover o ponto", preferredStyle: .Alert)
                let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                alertController.addAction(defaultAction)
                self.presentViewController(alertController, animated: true, completion: nil)
            }
        }
        
        return [deleteAction]
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var indexPath = self.tableView.indexPathForSelectedRow()
        if(segue.identifier == "segue"){
        if let aux = segue.destinationViewController as? MapaViewController{
            aux.selectedCell = row
            aux.selected = true
            aux.linha = row
        
        }
        }
        
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
         row = indexPath.row
        
    }
}
