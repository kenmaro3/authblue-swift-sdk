//
//  CardBlurView.swift
//  authblue
//
//  Created by Kentaro Mihara on 2023/07/08.
//

import Foundation
import SwiftUI

// MARK: Custom Modifier since most of the text shares same modifier
struct CustomModifier: ViewModifier{
    var font: Font
    func body(content: Content) -> some View{
        content
            .font(font)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .shadow(radius: 15)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct CustomModifierWithKerning: ViewModifier{
    var font: Font
    func body(content: Content) -> some View{
        content
            .font(font)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .kerning(1.2)
            .shadow(radius: 15)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: Custom Blur View
// With the help of UiVisualEffect View
struct CustomBlurView: UIViewRepresentable{
    var effect: UIBlurEffect.Style
    var onChange: (UIVisualEffectView) -> ()
    
    func makeUIView(context: Context) -> UIVisualEffectView{
        let view = UIVisualEffectView(effect: UIBlurEffect(style: effect))
        return view
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context){
        DispatchQueue.main.async{
            onChange(uiView)
        }
    }
}


// MARK: Adjusting Blur Radius in UIVisualEffectView
extension UIVisualEffectView{
    // MARK: steps
    // Extracting private class BackDropView class
    // Then from that view extracting ViewEffects like gaussian blur & saturation
    // with the help of this we can achieve class morphism
    var backDrop: UIView?{
        // Private class
        return subView(forClass: NSClassFromString("_UIVisualEffectBackdropView"))
    }
    
    // MARK: Extracting Gaussian Blur From BackDropView
    var gaussianBlur: NSObject?{
        backDrop?.value(key: "filters", filter: "gaussianBlur")
    }
    
    
    // MARK: Extracting Saturation from backDropView
    var saturation: NSObject?{
        return backDrop?.value(key: "filters", filter: "colorSaturate")
    }
    
    // MARK: Updating Blur radius and saturation
    var gaussianBlurRadius: CGFloat{
        get{
            // MARK: we know the key for gaussian blur = "inputRadius"
            return gaussianBlur?.values?["inputRadius"] as? CGFloat ?? 0
        }
        set{
            gaussianBlur?.values?["inputRadius"] = newValue
            // Updating the backDrop view with the new filter updates
            applyNewEffects()
            
        }
    }
    
    func applyNewEffects(){
        // MARK: Animating the change
        UIVisualEffectView.animate(withDuration: 0.2){
            self.backDrop?.perform(Selector("applyRequestedFilterEffects"))
        }
    }
    
    var saturationAmount: CGFloat{
        get{
            // MARK: we know the key for gaussian blur = "inputAmount"
            return saturation?.values?["inputAmount"] as? CGFloat ?? 0
        }
        set{
            saturation?.values?["inputAmount"] = newValue
            applyNewEffects()
            
        }
    }
    
}

// MARK: Finding subview for class
extension UIView{
    func subView(forClass: AnyClass?) -> UIView?{
        return subviews.first{view in
            type(of: view) == forClass
        }
    }
}


// MARK: Custom key filtering
extension NSObject{
    // MARK: key values from NSOBject
    var values: [String: Any]?{
        get{
            return value(forKeyPath: "requestedValues") as? [String: Any]
        }
        set{
            setValue(newValue, forKeyPath: "requestedValues")
        }
    }
    func value(key: String, filter: String) -> NSObject?{
        (value(forKey: key) as? [NSObject])?.first(where: {obj in
            return obj.value(forKeyPath: "filterType") as? String == filter
        })
    }
}
