//
//  LocalizedStringKey.swift
//  LNSwiftUIUtils
//
//  Created by Leo Natan on 21/10/2023.
//

import SwiftUI

public extension LocalizedStringKey {
	var stringKey: String {
		return Mirror(reflecting: self).descendant("key") as! String
	}
}

