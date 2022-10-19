//
//  PH_CardsControllerVC.swift
//  PhantomSol
//
//  Created by Apple on 19/10/22.
//

import UIKit

class PH_CardsControllerVC: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var photos = [PH_PhotoModel]()
    var albums = [PH_AlbumsModel]()
    var isAlbum = false
    
    private func swipeGestureInit(){
        let swipeFromBottom = UISwipeGestureRecognizer(target: self, action: #selector(funcForGesture))
        swipeFromBottom.direction = .up
        collectionView.addGestureRecognizer(swipeFromBottom)
        
        let swipeFromTop = UISwipeGestureRecognizer(target: self, action: #selector(funcForGesture))
        swipeFromTop.direction = .down
        collectionView.addGestureRecognizer(swipeFromTop)
    }
    
    private func collectionViewInit(){
        collectionView.collectionViewLayout = CardsCollectionViewLayout()
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(UINib(nibName: "PH_PhotoViewCell", bundle: nil), forCellWithReuseIdentifier: "PH_PhotoViewCell")
    }
    
    private func makeAPICall(){
        let networkManager = NetworkManager()
        networkManager.get(urlString: baseUrl+photosExtensionURL){(data) in
            let decoder = JSONDecoder()
            if let data = data{
                do {
                    let images = try decoder.decode([PH_PhotoModel].self, from: data)

                    
                    DispatchQueue.main.async {
                        self.photos.removeAll()
                        self.photos.append(contentsOf: images)
                        self.collectionView.reloadData()
                    }
                }catch {
                    print(error)
                }
            }
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    private func getAlbumsFromAPI(){
        let networkManager = NetworkManager()
        networkManager.get(urlString: baseUrl+albumsExtensionURL){(data) in
            let decoder = JSONDecoder()
            if let data = data{
                do {
                    let albums = try decoder.decode([PH_AlbumsModel].self, from: data)
                    
                    DispatchQueue.main.async {
                        self.albums.removeAll()
                        self.albums.append(contentsOf: albums)
                        self.collectionView.reloadData()
                    }
                }catch {
                    print(error)
                }
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        swipeGestureInit()
        collectionViewInit()
        makeAPICall()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    @objc func funcForGesture(sender: UISwipeGestureRecognizer){
        
        switch sender.direction{
        case.up:
            isAlbum = true
            self.getAlbumsFromAPI()
            break
        case .down:
            isAlbum = false
            self.makeAPICall()
            break
        default:
            break
        }
    }
}


extension PH_CardsControllerVC : UICollectionViewDataSource,UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PH_PhotoViewCell", for: indexPath) as! PH_PhotoViewCell
        if isAlbum {
            let data = albums[indexPath.row]
            cell.PH_BackgroundVw.layer.cornerRadius = 7.0
            cell.PH_Placeholder.text = data.title ?? ""
            cell.PH_ImgVw.image = UIImage(named: "ic_album_placeholder")
        }else{
            let data = photos[indexPath.row]
            cell.PH_BackgroundVw.layer.cornerRadius = 7.0
            cell.PH_ImgVw.layer.cornerRadius = 7.0
            cell.PH_ImgVw.loadImageFromURL(url: data.url ?? "")
            cell.PH_Placeholder.text = data.title ?? ""
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return isAlbum ? albums.count : photos.count
    }
    
}
