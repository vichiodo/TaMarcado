//
//  ViewController.swift
//  TaMarcado
//
//  Created by Ricardo Hochman on 11/06/15.
//  Copyright (c) 2015 Ricardo Hochman. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapaViewController: UIViewController, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mapa: MKMapView!
    @IBOutlet weak var btnLocalizacao: UIBarButtonItem!
    @IBOutlet weak var btnMarcar: UIBarButtonItem!
    
    var locationManager: CLLocationManager! = CLLocationManager()
    var locations: NSArray = []
    var txtField: UITextField?
    
    // recupera os dados salvos no CoreData
    lazy var pontos:Array<Ponto> = {
        return PontoManager.sharedInstance.buscarPontos()
        }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // inicia o CLLocationManager
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        
        // se for a primeira vez, pede pro usuario autorizar a localização
        let request = CLLocationManager.authorizationStatus()
        if request == CLAuthorizationStatus.NotDetermined{
            locationManager.requestWhenInUseAuthorization()
        }
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: "longPressed:")
        self.view.addGestureRecognizer(longPressRecognizer)
        
        // busca pela localização atual
        locationManager.startUpdatingLocation()
        mapa.userTrackingMode = MKUserTrackingMode.Follow
        btnLocalizacao.image = UIImage(named: "localizacao-p")
        
        // atualiza o mapa com os pins nos respectivos lugares
        pontos = PontoManager.sharedInstance.buscarPontos()
        mapa.removeAnnotations(mapa.annotations)
        for var i = 0; i < pontos.count; ++i {
            var mp = MapaPoint()
            mp.criaPonto(((pontos[i].localizacao as! CLLocation).coordinate as CLLocationCoordinate2D), nome: pontos[i].nome, endereco: pontos[i].endereco)
            mapa.addAnnotation(mp)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func tipoMapa(sender: AnyObject) { // segmented control para os tipo de mapa
        switch (sender as! UISegmentedControl).selectedSegmentIndex{
        case 0:
            mapa.mapType = MKMapType.Standard
        case 1:
            mapa.mapType = MKMapType.Satellite
        case 2:
            mapa.mapType = MKMapType.Hybrid
        default:
            break
        }
    }
    
    @IBAction func marcar(sender: AnyObject) { // criar um pin novo
        locationManager.startUpdatingLocation()
        mapa.userTrackingMode = MKUserTrackingMode.Follow
        btnLocalizacao.image = UIImage(named: "localizacao-p")
        
        var nomeLocal: String = ""
        let alerta: UIAlertController = UIAlertController(title: "Nome do local", message: nil, preferredStyle: .Alert)
        alerta.addTextFieldWithConfigurationHandler { (textField: UITextField!) -> Void in
            textField.placeholder = "Nome"
            textField.autocapitalizationType = UITextAutocapitalizationType.Sentences
            textField.autocorrectionType = UITextAutocorrectionType.Yes
            self.txtField = textField
        }
        
        alerta.addAction(UIAlertAction(title: "Cancelar", style: .Cancel, handler: nil))
        
        let salvar: UIAlertAction = UIAlertAction(title: "Salvar", style: .Default, handler: { (ACTION) -> Void in
            nomeLocal = self.txtField!.text
            
            if (nomeLocal == "" || nomeLocal == " ") {
                nomeLocal = "Local"
            }
            
            var mp = MapaPoint()
            mp.criaPonto((self.locations.lastObject as! CLLocation).coordinate, nome: nomeLocal as String, endereco: "buscando...")
            mp.adicionarPin(self.mapa, adicionando: true)
        })
        [alerta.addAction(salvar)]
        
        self.presentViewController(alerta, animated: true, completion: nil)
    }
    
    @IBAction func localizacaoAtual(sender: AnyObject) {
        // encontra o usuario e mostra sua localização
        btnLocalizacao.image = UIImage(named: "localizacao-p")
        locationManager.startUpdatingLocation()
        mapa.userTrackingMode = MKUserTrackingMode.Follow
        mapa.setRegion(MKCoordinateRegionMake(mapa.userLocation.coordinate, MKCoordinateSpanMake(0.01, 0.01)), animated: true)
    }
    
    // metodo para atualizar a localização do usuario
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        if mapa.userTrackingMode == .None {
            btnLocalizacao.image = UIImage(named: "localizacao")
        }
        self.locations = locations
    }
    
    @IBAction func favoritos(sender: AnyObject) {
        if tableView.alpha == 0.0 {
            pontos = PontoManager.sharedInstance.buscarPontos()
            self.tableView.reloadData()
            self.btnLocalizacao.enabled = false
            self.btnMarcar.enabled = false
            
            UIView.animateWithDuration(0.25, animations: { () -> Void in
                self.tableView.alpha = 1.0
            })
        } else {
            self.btnLocalizacao.enabled = true
            self.btnMarcar.enabled = true
            
            UIView.animateWithDuration(0.25, animations: { () -> Void in
                self.tableView.alpha = 0.0
            })
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pontos.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: CellController = tableView.dequeueReusableCellWithIdentifier("CellController") as! CellController
        
        cell.nome.text = pontos[indexPath.row].nome
        cell.endereco.text = pontos[indexPath.row].endereco
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
                
                // atualiza o mapa com os pins nos respectivos lugares
                self.pontos = PontoManager.sharedInstance.buscarPontos()
                self.mapa.removeAnnotations(self.mapa.annotations)
                for var i = 0; i < self.pontos.count; ++i {
                    var mp = MapaPoint()
                    mp.criaPonto(((self.pontos[i].localizacao as! CLLocation).coordinate as CLLocationCoordinate2D), nome: self.pontos[i].nome, endereco: self.pontos[i].endereco)
                    mp.adicionarPin(self.mapa, adicionando: false)
                }
                
            } else {
                let alertController = UIAlertController(title: "Remoção", message: "Não foi possível remover o ponto", preferredStyle: .Alert)
                let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                alertController.addAction(defaultAction)
                self.presentViewController(alertController, animated: true, completion: nil)
            }
        }
        
        return [deleteAction]
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            self.tableView.alpha = 0.0
        })
        self.btnLocalizacao.enabled = true
        self.btnMarcar.enabled = true
        
        // se vier de um toque na tabela, foca nesse pin
        let localPonto = (pontos[indexPath.row].localizacao as! CLLocation).coordinate as CLLocationCoordinate2D
        var region = MKCoordinateRegionMakeWithDistance(localPonto, 500, 500)
        mapa.setRegion(region, animated: true)
    }
    
    func longPressed(longPress: UILongPressGestureRecognizer) {
        if (longPress.state == UIGestureRecognizerState.Began) {
            let touchLocation = longPress.locationInView(self.view)
            
            var nomeLocal: String = ""
            let alerta: UIAlertController = UIAlertController(title: "Nome do local", message: nil, preferredStyle: .Alert)
            alerta.addTextFieldWithConfigurationHandler { (textField: UITextField!) -> Void in
                textField.placeholder = "Nome"
                textField.autocapitalizationType = UITextAutocapitalizationType.Sentences
                textField.autocorrectionType = UITextAutocorrectionType.Yes
                self.txtField = textField
            }
            
            alerta.addAction(UIAlertAction(title: "Cancelar", style: .Cancel, handler: nil))
            
            let salvar: UIAlertAction = UIAlertAction(title: "Salvar", style: .Default, handler: { (ACTION) -> Void in
                nomeLocal = self.txtField!.text
                
                if (nomeLocal == "" || nomeLocal == " ") {
                    nomeLocal = "Local"
                }
                
                var mp = MapaPoint()
                var tapPoint: CLLocationCoordinate2D = self.mapa.convertPoint(touchLocation, toCoordinateFromView: self.view)

                mp.criaPonto(tapPoint, nome: nomeLocal as String, endereco: "buscando...")
                mp.adicionarPin(self.mapa, adicionando: true)
            })
            [alerta.addAction(salvar)]
            
            self.presentViewController(alerta, animated: true, completion: nil)
        }
        
    }
    
}

