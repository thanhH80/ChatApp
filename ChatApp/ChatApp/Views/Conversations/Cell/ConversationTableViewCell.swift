//
//  ConversationTableViewCell.swift
//  ChatApp
//
//  Created by Thagion Jack on 21/06/2023.
//

import UIKit
import SDWebImage

class ConversationTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var profilePictureImageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var messContentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profilePictureImageView.makeCircle(withBorderColor: .white)
    }

    func configure(with model: ConversationModel) {
        nameLabel.text = model.name
        messContentLabel.text = model.lastestMessage.text
        
        let pathImage = "\(DatabasePath.images.dto)/\(model.ohterUserEmail)\(StringContant.avatarSuffix.rawValue)"

        StorageManager.shared.downloadWithURL(for: pathImage) { [weak self] result in
            switch result {
            case .success(let url):
                DispatchQueue.main.async {
                    self?.profilePictureImageView.sd_setImage(with: url)
                }
            case .failure(let error):
                print("Got error when fetching user's avatar \(error)")
            }
        }
    }
}
