//
//  PlayerViewController.swift
//  ChatApp
//
//  Created by Thagion Jack on 15/06/2023.
//

import UIKit
import SDWebImage

class PlayerViewController: BaseViewController {
    
    @IBOutlet private weak var imageView: UIImageView!
    
    var urlImage: URL?
    
    class func create(with urlImage: URL?) -> PlayerViewController {
        let vc = PlayerViewController.instantiate(storyboard: .player)
        vc.urlImage = urlImage
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        customNavigationTitleView(title: "Photo")
    }
    
    private func setupUI() {
        navigationItem.largeTitleDisplayMode = .never
        imageView.sd_setImage(with: urlImage)
    }

}
