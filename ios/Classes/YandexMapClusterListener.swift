import Foundation
import YandexMapsMobile
import UIKit

class YandexMapClusterListener: NSObject, YMKClusterListener
{
    private var options: [String: Any]?
    private var textColor: UIColor = UIColor.black
    private var backgroundColor: UIColor = UIColor.white
    private var strokeColor: UIColor = UIColor.black
    private var fontSize: CGFloat = 15
    private var image: UIImage?
    private var textAlign: String?
    
    func onClusterAdded(with cluster: YMKCluster) {
        cluster.appearance.setIconWith(clusterImage(cluster.size))
    }
    
    func clusterImage(_ clusterSize: UInt) -> UIImage {
            let FONT_SIZE: CGFloat = self.fontSize
            let MARGIN_SIZE: CGFloat = 3 // TODO: add as dart param like fontSize
            let STROKE_SIZE: CGFloat = 3 // TODO: add as dart param like fontSize
            let scale = UIScreen.main.scale
            let text = (clusterSize as NSNumber).stringValue
            let font = UIFont.systemFont(ofSize: FONT_SIZE * scale)
            var size = text.size(withAttributes: [NSAttributedString.Key.font: font])
            let textRadius = sqrt(size.height * size.height + size.width * size.width) / 2
            let internalRadius = textRadius + MARGIN_SIZE * scale
            let externalRadius = internalRadius + STROKE_SIZE * scale
            var iconSize = CGSize(width: externalRadius * 2, height: externalRadius * 2)
            if (self.image != nil) {
                iconSize = CGSize(width: self.image!.size.width, height: self.image!.size.height)
            }
            // START DRAW
            UIGraphicsBeginImageContext(iconSize)
            let ctx = UIGraphicsGetCurrentContext()!

        if (self.image != nil) {
            let imageRect = CGRect(x: 0, y: 0, width: self.image!.size.width, height: self.image!.size.height)
            self.image!.draw(in: imageRect)
            // TODO: here add impact of textAlign!
            size = self.image!.size;
                (text as NSString).draw(
                    in: imageRect,
                    withAttributes: [
                        NSAttributedString.Key.font: font,
                        NSAttributedString.Key.foregroundColor: self.textColor])
                let image = UIGraphicsGetImageFromCurrentImageContext()!
                UIGraphicsEndImageContext()
            
                return image
        }
        
        ctx.setFillColor(self.strokeColor.cgColor)
            ctx.fillEllipse(in: CGRect(
                origin: .zero,
                size: CGSize(width: 2 * externalRadius, height: 2 * externalRadius)));

        ctx.setFillColor(self.backgroundColor.cgColor)
            ctx.fillEllipse(in: CGRect(
                origin: CGPoint(x: externalRadius - internalRadius, y: externalRadius - internalRadius),
                size: CGSize(width: 2 * internalRadius, height: 2 * internalRadius)));

        // Default align is center
        var textAlignPoint = CGPoint(x: externalRadius - size.width / 2, y: externalRadius - size.height / 2)
        if(textAlign != nil) {
            // TODO: add more aligns
            switch (textAlign) {
            case "left":
                textAlignPoint = CGPoint(x: 0, y: 0)
            default:
                textAlignPoint = CGPoint(x: externalRadius - size.width / 2, y: externalRadius - size.height / 2)
            }
        }
            (text as NSString).draw(
                in: CGRect(
                    origin: textAlignPoint,
                    size: size),
                withAttributes: [
                    NSAttributedString.Key.font: font,
                    NSAttributedString.Key.foregroundColor: self.textColor])
            let image = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            return image
        
        }
    
    public func loadImage(_ imageIcon: UIImage) {
        self.image = imageIcon
    }
    
    public func setOptions(_ params: [String: Any]) {
        self.options = params
        let textAlign = params["textAlign"] as? String
        if(textAlign != nil) {
            self.textAlign = textAlign
        }
        let textColor = params["textColor"] as! [String: CGFloat]
        if(textColor["r"] != nil && textColor["g"] != nil && textColor["b"] != nil) {
            self.textColor = UIColor.init(red: CGFloat(textColor["r"]!) / 255 , green: CGFloat(textColor["g"]!) / 255, blue: CGFloat(textColor["b"]!) / 255, alpha: 1.0)
        }
        let backgroundColor = params["backgroundColor"] as! [String: CGFloat]
        if(backgroundColor["r"] != nil && backgroundColor["g"] != nil && backgroundColor["b"] != nil) {
            self.backgroundColor = UIColor.init(red: CGFloat(backgroundColor["r"]!) / 255 , green: CGFloat(backgroundColor["g"]!) / 255, blue: CGFloat(backgroundColor["b"]!) / 255, alpha: 1.0)
        }
        let strokeColor = params["strokeColor"] as! [String: CGFloat]
        if(strokeColor["r"] != nil && strokeColor["g"] != nil && strokeColor["b"] != nil) {
            self.strokeColor = UIColor.init(red: CGFloat(strokeColor["r"]!) / 255 , green: CGFloat(strokeColor["g"]!) / 255, blue: CGFloat(strokeColor["b"]!) / 255, alpha: 1.0)
        }
        let fontSize = params["fontSize"] as! CGFloat
        if(fontSize != nil) {
            self.fontSize = fontSize
        }
    }
}
