//
//  LocalizedStringKey.swift
//  LNSwiftUIUtils
//
//  Created by Leo Natan on 21/10/2023.
//

import SwiftUI

public extension LocalizedStringKey {
	var stringKey: String {
		var rv: String!
		inspect(self) { label, value in
			guard label == "key" else { return }
			rv = (value as! String)
		}
		
		return rv!
	}
}

