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

class ListaViewController: UITableViewController, UITableViewDataSource, UITableViewDelegate {
    var pontoSelecionado:Ponto?
    
   lazy var pontos:Array<Ponto> = {
        return PontoManager.sharedInstance.buscarPontos()
    }()
        
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewWillAppear(animated: Bool) {
        print("oi")
        pontos = PontoManager.sharedInstance.buscarPontos()
        self.tableView.reloadData()
        
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        
        return pontos.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let item:Ponto = pontos[indexPath.row]
        
        var cell:CellController = tableView.dequeueReusableCellWithIdentifier("CellController") as! CellController
        
        cell.nome.text = item.nome
        cell.endereco.text = item.endereco
        
        return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {}
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
