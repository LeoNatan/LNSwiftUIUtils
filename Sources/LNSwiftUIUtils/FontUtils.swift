//
//  FontUtils.swift
//  LNSwiftUIUtils
//
//  Created by Leo Natan on 21/10/2023.
//

import SwiftUI
import UIKit

fileprivate extension UIFont {
	func with(weight: Weight?, width: Width?, symbolicTraits: CTFontSymbolicTraits) -> UIFont {
		var mergedsymbolicTraits = CTFontGetSymbolicTraits(self)
		mergedsymbolicTraits.formUnion(symbolicTraits)
		
		var traits = NSMutableDictionary(dictionary: CTFontCopyTraits(self))// fontDescriptor.fontAttributes[.traits] as? [String: Any] ?? [:]
		if let weight {
			traits[kCTFontWeightTrait as String] = weight
		}
		if let width {
			traits[kCTFontWidthTrait as String] = width
		}
		traits[kCTFontSymbolicTrait as String] = mergedsymbolicTraits.rawValue
		
		var fontAttributes: [UIFontDescriptor.AttributeName: Any] = [:]
		fontAttributes[.family] = familyName
		fontAttributes[.traits] = traits
		
		let rv_ = UIFont(descriptor: UIFontDescriptor(fontAttributes: fontAttributes), size: pointSize)
		let rv: UIFont
		if symbolicTraits != [] {
			rv = CTFontCreateCopyWithSymbolicTraits(rv_, 0, nil, mergedsymbolicTraits, symbolicTraits) ?? rv_
		} else {
			rv = rv_
		}
		
		print("Converted\n\t\(self)\nto\n\t\(rv)\n\n")
		
		return rv
	}
	
	func with(traits: CTFontSymbolicTraits) -> UIFont {
		return self.with(weight: nil, width: nil, symbolicTraits: traits)
	}
	
	func with(weight: UIFont.Weight) -> UIFont {
		return self.with(weight: weight, width: nil, symbolicTraits: [])
	}
	
	func with(width: UIFont.Width) -> UIFont {
		return self.with(weight: nil, width: width, symbolicTraits: [])
	}
	
	var bold: UIFont {
		return with(traits: .traitBold)
	}
	
	var italic: UIFont {
		return with(traits: .traitItalic)
	}
}

public extension UIFontDescriptor.SystemDesign {
	init?(_ design: SwiftUI.Font.Design) {
		switch design {
		case .default:
			self = .default
		case .serif:
			self = .serif
		case .rounded:
			self = .rounded
		case .monospaced:
			self = .monospaced
		@unknown default:
			self = .default
		}
	}
}

public extension UIFont.Weight {
	init?(_ weight: SwiftUI.Font.Weight) {
		var rawValue: CGFloat? = nil
		inspect(weight) { label, value in
			guard label == "value" else { return }
			rawValue = value as? CGFloat
		}
		guard let rawValue else { return nil }
		self = UIFont.Weight(rawValue)
	}
}

public extension UIFont.TextStyle {
	init(_ textStyle: SwiftUI.Font.TextStyle) {
		switch textStyle {
		case .largeTitle:
			self = .largeTitle
		case .title:
			self = .title1
		case .headline:
			self = .headline
		case .subheadline:
			self = .subheadline
		case .body:
			self = .body
		case .callout:
			self = .callout
		case .footnote:
			self = .footnote
		case .caption:
			self = .caption1
		case .title2:
			self = .title2
		case .title3:
			self = .title3
		case .caption2:
			self = .caption2
		@unknown default:
			self = .body
		}
	}
}

public extension SwiftUI.Font {
	var uiFont: UIFont? {
//		let test = toKeyValueDictionary(self, deep: true)
//		
//		
		var rv: UIFont?
		
		inspect(self) { label, value in
			guard label == "provider" else { return }
			
			inspect(value) { label, value in
				guard label == "base" else { return }
				
				guard let provider = SwiftUIFontProvider(from: value) else { return }
				
				rv = provider.uiFont
			}
		}
		
		return rv
	}
}

fileprivate enum SwiftUIFontProvider {
	case system(size: CGFloat, weight: Font.Weight?, design: Font.Design?)
	case textStyle(Font.TextStyle, weight: Font.Weight?, design: Font.Design?)
	case platform(CTFont)
	case named(UIFont)
	
	var uiFont: UIFont? {
		switch self {
		case let .system(size, weight, design):
			let rv: UIFont
			if let weight, let fontWeight = UIFont.Weight(weight) {
				rv = UIFont.systemFont(ofSize: size, weight: fontWeight)
			} else {
				rv = UIFont.systemFont(ofSize: size)
			}
			if let design, let systemDesign = UIFontDescriptor.SystemDesign(design), let designedDescriptor = rv.fontDescriptor.withDesign(systemDesign) {
				return UIFont(descriptor: designedDescriptor, size: rv.pointSize)
			}
			return rv
		case let .textStyle(textStyle, _, _):
			return UIFont.preferredFont(forTextStyle: UIFont.TextStyle(textStyle))
		case let .platform(font):
			return font as UIFont
		case let .named(font):
			return font
		}
	}
	
	init?(from reflection: Any) {
		let desc = String(describing: type(of: reflection))
		
		if let regex = try? NSRegularExpression(pattern: "ModifierProvider<(.*)>"), let match = regex.firstMatch(in: desc, range: NSRange(desc.startIndex..<desc.endIndex, in: desc)) {
			let modifier = desc[Range(match.range(at: 1), in: desc)!]
			
			var font: UIFont?
			
			inspect(reflection) { label, value in
				guard label == "base" else { return }
				guard let sFont = value as? Font else { return }
				font = sFont.uiFont
			}
			
			guard var font else { return nil }
			
			print(modifier)
			
			switch modifier {
			case "BoldModifier":
				font = font.bold
				break
			case "ItalicModifier":
				font = font.italic
				break
			case "MonospacedModifier":
				break
			case "MonospacedDigitModifier":
				break
			case "WeightModifier":
				if let weight = toKeyValueDictionary(reflection, deep: true).value(forKeyPath: "modifier.weight.value") as? CGFloat {
					font = font.with(weight: UIFont.Weight(rawValue: weight))
				}
				break
			case "WidthModifier":
				if let width = toKeyValueDictionary(reflection, deep: true).value(forKeyPath: "modifier.width") as? CGFloat {
					font = font.with(width: UIFont.Width(rawValue: width))
				}
				break
			case "LeadingModifier":
				break
			default:
				break
			}
			
			self = .named(font)
			return
		}
		
		switch desc {
		case "SystemProvider":
			var props: (
				size: CGFloat?,
				weight: Font.Weight?,
				design: Font.Design?
			) = (nil, nil, nil)
			
			inspect(reflection) { label, value in
				switch label {
				case "size":
					props.size = value as? CGFloat
				case "weight":
					props.weight = value as? Font.Weight
				case "design":
					props.design = value as? Font.Design
				default:
					return
				}
			}
			
			guard let size = props.size
			else { return nil }
			
			self = .system(
				size: size,
				weight: props.weight,
				design: props.design
			)
			
		case "TextStyleProvider":
			var props: (
				style: Font.TextStyle?,
				weight: Font.Weight?,
				design: Font.Design?
			) = (nil, nil, nil)
			
			inspect(reflection) { label, value in
				switch label {
				case "style":
					props.style = value as? Font.TextStyle
				case "weight":
					props.weight = value as? Font.Weight
				case "design":
					props.design = value as? Font.Design
				default:
					return
				}
			}
			
			guard let style = props.style
			else { return nil }
			
			self = .textStyle(
				style,
				weight: props.weight,
				design: props.design
			)
			
		case "PlatformFontProvider":
			var font: CTFont?
			
			inspect(reflection) { label, value in
				guard label == "font" else { return }
				font = (value as? CTFont?)?.flatMap { $0 }
			}
			
			guard let font else { return nil }
			self = .platform(font)
			
		case "NamedProvider":
			var name: String? = nil
			var size: CGFloat? = nil
			var textStyle: SwiftUI.Font.TextStyle? = nil
			
			inspect(reflection) { label, value in
				switch label {
				case "name":
					name = value as? String
					break
				case "size":
					size = value as? CGFloat
					break
				case "textStyle":
					textStyle = value as? SwiftUI.Font.TextStyle
					break
				default:
					break
				}
			}
			
			guard let name, let size else { return nil }
			
			let font = UIFont(name: name, size: size)
			guard var font else { return nil }
			
			if let textStyle {
				font = UIFontMetrics(forTextStyle: UIFont.TextStyle(textStyle)).scaledFont(for: font)
			}
			
			self = .named(font)
			
		default:
			return nil
		}
	}
}


