

import UIKit

class EmojiCheckoutCell: UITableViewCell {
    let detailLabel: UILabel
    let priceLabel: UILabel
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        priceLabel = UILabel()
        priceLabel.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        detailLabel = UILabel()
        detailLabel.font = UIFont.systemFont(ofSize: 13)
        detailLabel.textColor = .stripeDarkBlue

        super.init(style: style, reuseIdentifier: reuseIdentifier)
        installConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func installConstraints() {
        for view in [priceLabel, detailLabel] {
            view.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(view)
        }
       
        NSLayoutConstraint.activate([
           priceLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
           priceLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
           
           detailLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
           detailLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            ])
    }
    
    public func configure(with product: QuantityObject, numberFormatter: NumberFormatter) {
        priceLabel.text = numberFormatter.string(from: NSNumber(value: Float(product.quantity)))!
        detailLabel.text = product.printableObject.post.id
    }
}
