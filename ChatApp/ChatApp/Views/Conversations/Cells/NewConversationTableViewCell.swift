//
//  NewConversationTableViewCell.swift
//  ChatApp
//
//  Created by Thagion Jack on 12/07/2023.
//

import UIKit
import SDWebImage

class NewConversationTableViewCell: UITableViewCell {

    @IBOutlet private weak var userAvaterImageView: UIImageView!
    @IBOutlet private weak var userNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userAvaterImageView.makeCircle(withBorderColor: .white)
    }

    func config(with model: SearchResult) {
        userNameLabel.text = model.name
        let pathImage = "\(DatabasePath.images.dto)/\(model.email)\(StringContant.avatarSuffix.rawValue)"

        StorageManager.shared.downloadWithURL(for: pathImage) { [weak self] result in
            switch result {
            case .success(let url):
                DispatchQueue.main.async {
                    self?.userAvaterImageView.sd_setImage(with: url)
                }
            case .failure(let error):
                print("Got error when fetching user's avatar \(error)")
            }
        }
    }
}
