//
//  AttributeContainerUtils.swift
//	LNSwiftUIUtils
//
//  Created by Leo Natan on 21/10/2023.
//

import Foundation
import SwiftUI

@available(iOS 15, *)
public extension AttributeContainer {
	var swiftUIToUIKit: AttributeContainer {
		var rv = self
		if let font = rv.swiftUI.font, rv.uiKit.font == nil {
			rv.uiKit.font = font.uiFont
		}
		if let foregroundColor = rv.swiftUI.foregroundColor, rv.uiKit.foregroundColor == nil {
			rv.uiKit.foregroundColor = UIColor(foregroundColor)
		}
		if let backgroundColor = rv.swiftUI.backgroundColor, rv.uiKit.backgroundColor == nil {
			rv.uiKit.backgroundColor = UIColor(backgroundColor)
		}
		
		return rv
	}
}

