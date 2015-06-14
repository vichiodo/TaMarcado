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

class MapaViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapa: MKMapView!
    @IBOutlet weak var btnLocalizacao: UIButton!
    
    
    var locationManager: CLLocationManager! = CLLocationManager()
    var locations: NSArray = []
    var userDef: NSUserDefaults!
    var mapaPoints: Array<MapaPoint>!
    
    var txtField: UITextField?
    
    lazy var pontos:Array<Ponto> = {
        return PontoManager.sharedInstance.buscarPontos()
        }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        let request = CLLocationManager.authorizationStatus()
        if request == CLAuthorizationStatus.NotDetermined{
            locationManager.requestWhenInUseAuthorization()
        }
        locationManager.startUpdatingLocation()
        mapa.userTrackingMode = MKUserTrackingMode.Follow
    }
    
    override func viewDidAppear(animated: Bool) {
        mapa.removeAnnotations(mapa.annotations)
        for var i = 0; i<pontos.count; ++i{
            var mp: MapaPoint!
            mp.criaPonto((pontos[i].localizacao as! CLLocation).coordinate, nome: pontos[i].nome, endereco: pontos[i].endereco)
            mp.adicionarPin(mapa)
            mapaPoints[i] = mp
        }
        
        mapa.addAnnotations(mapaPoints)
//        PontoManager.sharedInstance.pegarNovoLocal().adicionarPin(mapa)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func tipoMapa(sender: AnyObject) {
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
    
    @IBAction func marcar(sender: AnyObject) {
        locationManager.startUpdatingLocation()
        mapa.userTrackingMode = MKUserTrackingMode.Follow
        
        var nomeLocal: String = ""
        
        let alerta: UIAlertController = UIAlertController(title: "Nome do local", message: nil, preferredStyle: .Alert)
        alerta.addTextFieldWithConfigurationHandler { (textField: UITextField!) -> Void in
            textField.placeholder = "Nome"
            self.txtField = textField
        }
        let salvar:UIAlertAction = UIAlertAction(title: "", style: .Default, handler: { (ACTION) -> Void in
            nomeLocal = self.txtField!.text
            if nomeLocal == "" {
                nomeLocal = "Local"
            }
            var mapaPoint = MapaPoint()
            mapaPoint.criaPonto((self.locations.lastObject as! CLLocation).coordinate, nome: nomeLocal as String, endereco: "buscando...")
            mapaPoint.adicionarPin(self.mapa)
            
            PontoManager.sharedInstance.salvarNovoPonto(nomeLocal, endereco: mapaPoint.subtitle, localizacao: (self.locations.lastObject! as! CLLocation))
            

        })
        [alerta.addAction(salvar)]
        
        self.presentViewController(alerta, animated: true, completion: nil)
    }
    
    @IBAction func localizacaoAtual(sender: AnyObject) {
        locationManager.startUpdatingLocation()
        mapa.userTrackingMode = MKUserTrackingMode.Follow
        mapa.setRegion(MKCoordinateRegionMake(mapa.userLocation.coordinate, MKCoordinateSpanMake(0.01, 0.01)), animated: true)
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        self.locations = locations
    }
}

