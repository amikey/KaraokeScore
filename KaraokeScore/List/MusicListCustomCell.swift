import UIKit
import SDWebImage
import Cartography

// CollectionViewのセル設定
class MusicListCustomCell: UITableViewCell {
    
    public var title_label = UILabel()
    public var cellImageView2: UIImageView?
    public var artistName = UILabel()
    public var releaseDate = UILabel()
    public var primaryGenreName = UILabel()
    public var score = UILabel()
    public var scoredate = UILabel()
    
    
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
        
        //スコア記録日
        let scoredate_label = UILabel()
        scoredate_label.font = UIFont.systemFont(ofSize: fontsize - 2)
        scoredate_label.numberOfLines = 1
        //scoredate_label.textColor = UIColor.hex(string: "#ff5266", alpha: 1.0)
        contentView.addSubview(scoredate_label)
        constrain(scoredate_label) {label in
            label.width >= 0
            label.height >= 0
            label.bottom == label.superview!.bottom - 5
            label.right == label.superview!.right - 8
        }
        self.scoredate = scoredate_label
        
        //点
        let po_label = UILabel()
        po_label.text = "点"
        po_label.font = UIFont.boldSystemFont(ofSize: fontsize + 5)
        po_label.numberOfLines = 1
        po_label.textColor = UIColor.hex(string: "#ff5266", alpha: 1.0)
        contentView.addSubview(po_label)
        constrain(po_label) {label in
            label.width >= 0
            label.height >= 0
            label.bottom == label.superview!.bottom - 25
            label.right == label.superview!.right - 8
        }
        
        //スコア
        let score_label = UILabel()
        score_label.font = UIFont.boldSystemFont(ofSize: fontsize + 33)
        score_label.numberOfLines = 1
        score_label.textColor = UIColor.hex(string: "#ff5266", alpha: 1.0)
        contentView.addSubview(score_label)
        constrain(score_label,po_label) {label ,last in
            label.width >= 0
            label.height >= 0
            label.bottom == label.superview!.bottom - 18
            label.right == last.left - 5
        }
        self.score = score_label
        
        
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
        
        self.score.text = String(item.score)

        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.locale = Locale(identifier: "ja_JP")
        dateFormatter.timeZone = TimeZone(identifier:  "Asia/Tokyo")
        dateFormatter.dateFormat = "記録日:yyyy年M月d日"
        let dateString = dateFormatter.string(from: item.scoredate)
        self.scoredate.text = dateString
        
    }
}



