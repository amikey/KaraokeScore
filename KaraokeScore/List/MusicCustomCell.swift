import UIKit
import SDWebImage
import Cartography

// CollectionViewのセル設定
class MusicCustomCell: UITableViewCell {
    
    public var title_label = UILabel()
    public var cellImageView2: UIImageView?
    public var artistName = UILabel()
    public var releaseDate = UILabel()
    public var primaryGenreName = UILabel()
    
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier )
        
        //商品画像のビュー
        var cellImageView2: UIImageView = {
            let imageView2 = UIImageView()
            return imageView2
        }()
        cellImageView2.layer.cornerRadius = 1
        cellImageView2.layer.masksToBounds = true
        cellImageView2.layer.borderColor = UIColor.gray.cgColor
        cellImageView2.layer.borderWidth = 0.1
        contentView.addSubview(cellImageView2)
        constrain(cellImageView2) {image in
            image.width == 100
            image.height == 100
            image.centerY == image.superview!.centerY
            image.left == image.superview!.left + 15
            
        }
        
        self.cellImageView2 = cellImageView2
        
        let fontsize : CGFloat = 15
        let widthsize : CGFloat = 140
        
        //タイトル
        let alert_bun = UILabel()
        alert_bun.font = UIFont.systemFont(ofSize: fontsize + 2)
        alert_bun.numberOfLines = 2
        contentView.addSubview(alert_bun)
        constrain(alert_bun,cellImageView2) {label, imageView in
            label.width == label.superview!.width - widthsize
            label.height >= 0
            label.top == imageView.superview!.top + 7.5
            label.right == label.superview!.right - 15
            
        }
        self.title_label = alert_bun
        
        //歌手名
        let author = UILabel()
        author.font = UIFont.systemFont(ofSize: fontsize)
        author.numberOfLines = 1
        contentView.addSubview(author)
        constrain(author,alert_bun) {label, last in
            label.width == label.superview!.width - widthsize
            label.height >= 0
            label.top == last.bottom + 5
            label.left == last.left
        }
        self.artistName = author
        
        
        //ジャンル名
        let genreLabel = UILabel()
        genreLabel.font = UIFont.systemFont(ofSize: fontsize)
        genreLabel.numberOfLines = 1
        contentView.addSubview(genreLabel)
        constrain(genreLabel,author) {label, last in
            label.width == label.superview!.width - widthsize
            label.height >= 0
            label.top == last.bottom + 5
            label.left == last.left
        }
        self.primaryGenreName = genreLabel
        
        
        
        //リリース年月日
        let alert_time = UILabel()
        alert_time.font = UIFont.systemFont(ofSize: fontsize)
        alert_time.numberOfLines = 1
        contentView.addSubview(alert_time)
        constrain(alert_time,genreLabel) {label, last in
            label.width == label.superview!.width - widthsize
            label.height >= 0
            label.top == last.bottom + 5
            label.left == last.left
        }
        self.releaseDate = alert_time
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpContents(item : MusicInfoModel) {
        
        guard let image = self.cellImageView2 else{ return }
        self.artistName.text = item.artistName
        
        let aa = String(item.releaseDate.prefix(10))
        
        self.releaseDate.text = aa
        self.primaryGenreName.text = item.primaryGenreName
        image.sd_setImage(with: URL(string: item.artworkUrl100), placeholderImage: UIImage(named: "dummy"))
        self.title_label.text = item.trackName
        
    }
}



