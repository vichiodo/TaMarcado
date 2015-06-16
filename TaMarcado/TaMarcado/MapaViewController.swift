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
    var ponto:Ponto?
    
    var selectedCell:AnyObject?
    var linha:Int?
    var selected:AnyObject?

    
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
        let image = UIImage(named: "localp") as UIImage!
        btnLocalizacao.setImage(image, forState: .Normal)
    }
    
    override func viewDidAppear(animated: Bool) {
        pontos = PontoManager.sharedInstance.buscarPontos()
        mapa.removeAnnotations(mapa.annotations)
        for var i = 0; i<pontos.count; ++i{
            var mp = MapaPoint()
            mp.criaPonto(((pontos[i].localizacao as! CLLocation).coordinate as CLLocationCoordinate2D), nome: pontos[i].nome, endereco: pontos[i].endereco)
            mp.adicionarPin(mapa)
        
        }
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
        let image = UIImage(named: "localp") as UIImage!
        btnLocalizacao.setImage(image, forState: .Normal)
        
        var nomeLocal: String = ""
        
        let alerta: UIAlertController = UIAlertController(title: "Nome do local", message: nil, preferredStyle: .Alert)
        alerta.addTextFieldWithConfigurationHandler { (textField: UITextField!) -> Void in
            textField.placeholder = "Nome"
            self.txtField = textField
        }
        let salvar:UIAlertAction = UIAlertAction(title: "Salvar", style: .Default, handler: { (ACTION) -> Void in
            nomeLocal = self.txtField!.text
            if (nomeLocal == "" || nomeLocal == " ") {
                nomeLocal = "Local"
            }
            var mapaPoint = MapaPoint()
            mapaPoint.criaPonto((self.locations.lastObject as! CLLocation).coordinate, nome: nomeLocal as String, endereco: "buscando...")
            mapaPoint.adicionarPin2(self.mapa)
            
            //PontoManager.sharedInstance.salvarNovoPonto(nomeLocal, endereco: mapaPoint.subtitle, localizacao: (self.locations.lastObject! as! CLLocation))
        })
        [alerta.addAction(salvar)]
        
        self.presentViewController(alerta, animated: true, completion: nil)
    }
    
    @IBAction func localizacaoAtual(sender: AnyObject) {
        let image = UIImage(named: "localp") as UIImage!
        btnLocalizacao.setImage(image, forState: .Normal)
        locationManager.startUpdatingLocation()
        mapa.userTrackingMode = MKUserTrackingMode.Follow
        mapa.setRegion(MKCoordinateRegionMake(mapa.userLocation.coordinate, MKCoordinateSpanMake(0.01, 0.01)), animated: true)
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        if mapa.userTrackingMode == .None {
            let image = UIImage(named: "local") as UIImage!
            btnLocalizacao.setImage(image, forState: .Normal)
        }
        self.locations = locations
    }
}

