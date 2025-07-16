//
//  MapView.swift
//  MapKitDemo
//
//  Created by Apprenant 13 on 24/03/2023.
//

import SwiftUI
import MapKit

struct MapView: View {
    
    @EnvironmentObject var appData: ApplicationData // importe les données partagées dans l'EnvironmentObject (voir MapModel)
    
    @Environment(\.managedObjectContext) var dbContext //accède à la db
    
    @FetchRequest(entity: Place.entity(), sortDescriptors: []) var places: FetchedResults<Place>
    
    @State var showPlaceDetail: Bool = false
    
    //Photo de profil
    @AppStorage(UserDefaults.Keys.profileIllustration.rawValue) var profileIllustration = ""
    
    var annotations : [PlaceAnnotation] { // fabrique les annotations de la carte
        
        var annotations = Array<PlaceAnnotation>()
        
            for place in places { // pour chaque Place de CoreData,
                
                
                
                var newPlaceAnnotation = PlaceAnnotation(name: place.wrappedName, placeObject: place, location: CLLocationCoordinate2D(latitude: place.wrappedLocationLat, longitude: place.wrappedLocationLon), SFSymbol: "star", symbolColor: .yellow)
                
                // customise l'aspect selon les relations
                if let lovedBy = place.lovedBy  {
                    if lovedBy.count > 0 {
                        newPlaceAnnotation.SFsymbol = "heart"
                        newPlaceAnnotation.symbolColor = Color.red
                    }
                }
                
                if let lovedBy = place.hatedBy  {
                    if lovedBy.count > 0 {
                        newPlaceAnnotation.SFsymbol = "cloud.bolt"
                        newPlaceAnnotation.symbolColor = Color.gray
                    }
                }
                
                if let lovedBy = place.favoriteBy  {
                    if lovedBy.count > 0 {
                        newPlaceAnnotation.SFsymbol = "star"
                        newPlaceAnnotation.symbolColor = Color.orange
                    }
                }
                
                if let lovedBy = place.seenBy  {
                    if lovedBy.count > 0 {
                        newPlaceAnnotation.SFsymbol = "checkmark.seal"
                        newPlaceAnnotation.symbolColor = Color.green
                    }
                }
                
                annotations.append(newPlaceAnnotation)
        }
        return annotations
    }
    
    var body: some View {
        NavigationStack{
            ZStack {
                
                // la carte (on lui donne une région, pas une position)
                Group {
                    Map(coordinateRegion: $appData.region, showsUserLocation: true, annotationItems: annotations, annotationContent: {placeAnnotation in // boucle sur chaque élément de "annotationItems", obligatoirement de type PlaceAnnotation
                        
                        // MapMarker(coordinate: place.location, tint: .red) // est le design standard d'annotation
                        
                        MapAnnotation(coordinate: placeAnnotation.location) {
                            
                      
                                
                                    // symbole
                                    ZStack {
                                        Circle()
                                            .frame(width: placeAnnotation.symbolSize, height: placeAnnotation.symbolSize)
                                            .foregroundColor(placeAnnotation.symbolColor)
                                            .opacity(0.5)
                                        
                                        Image(systemName: placeAnnotation.SFsymbol)
                                            .resizable()
                                            .scaledToFit()
                                            .foregroundColor(.white)
                                            .frame(width: placeAnnotation.symbolSize * 0.5, height: placeAnnotation.symbolSize * 0.5)
                                        
                                    }
                                    .onTapGesture {
                                        print("tap!")
                                        showPlaceDetail = true
                                        appData.selectedPlace = placeAnnotation.placeObject
                                        //shownPlace = placeAnnotation.placeObject
                                        
                                    }
                                   
                            
                                // label
                                Text(placeAnnotation.name)
                                    .font(Font.custom("Futura", size: 13))
                                    .foregroundColor(.black)
                                    .fontWeight(.bold)
                                    .background(.white)
                            
                            
                        }
                    })
                }
                
                
                // les boutons
                Group {
                    VStack {
                        // bouton pour nettoyer et ajouter des données dans CoreData
                        AddTestDataButtonView()
                            .offset(y: 40)
                        NavigationLink(destination: CheckDataView(), label: {
                            Image(systemName: "eye.circle.fill")
                                .padding()
                                .font(.largeTitle)
                                .foregroundColor(Color("mondrillanRed"))
                                .shadow(radius: 5,x: 2,y:2)
                        }).offset(y: 20)
                        
                        // bouton pour recentrer sur la position GPS
                        Button(action:{
                            appData.manager.requestLocation()
                        },label: {
                            ZStack{
                                Image(systemName: "location.circle.fill")
                                    .padding()
                                    .font(.largeTitle)
                                    .foregroundColor(Color("mondrillanBlue"))
                                
                            }
                        })
                        //Accès au profil
                        NavigationLink(destination: ProfileView(), label: {
                            ZStack {
                                Circle()
                                    .frame(maxWidth: 40, maxHeight: 40)
                                    .foregroundColor(.black)
                                    .shadow(radius: 5,x: 2,y:2)
                                Image(profileIllustration)
                                    .resizable()
                                    .mask(Circle())
                                    .frame(maxWidth: 38, maxHeight: 38)
                                    .shadow(radius: 5,x: 2,y:2)
                            }
                            
                        })
                        //accès au menu
                        NavigationLink(destination: MenuView(), label: {
                            ZStack{
                                Image(systemName: "paintpalette.fill")
                                    .padding()
                                    .symbolRenderingMode(.multicolor)
                                    .font(.largeTitle)
                                    .shadow(radius: 5,x: 2,y:2)
                            }
                        })
                        Spacer()
                            .frame(height: 50)
                    }
                    
                }
                .offset(x: -150, y: 200)
                
                // pop-up
                if showPlaceDetail, let selPlace = appData.selectedPlace {
                    PlaceDetailView(place: selPlace, showPlaceDetail: $showPlaceDetail)
                        .frame(alignment: .center)
                }
                
                
            }
            .ignoresSafeArea()
            .onAppear {
                appData.manager.requestWhenInUseAuthorization()
                appData.manager.requestLocation() // on lance une demande de position
                    
            }
            
            
        }
        
        
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
            .environmentObject(ApplicationData())

    }
}
