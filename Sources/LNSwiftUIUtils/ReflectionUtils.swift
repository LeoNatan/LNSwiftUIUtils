//
//  ReflectionUtils.swift
//  LNSwiftUIUtils
//
//  Created by Leo Natan on 21/10/2023.
//

import Foundation

internal func inspect(_ object: Any, with action: (Mirror.Child) -> Void) {
	Mirror(reflecting: object).children.forEach(action)
}

internal func toKeyValueDictionary(_ object: Any, deep: Bool = false) -> NSDictionary {
	var rv = Dictionary<String, Any>()
	
	inspect(object) { label, value in
		guard let label else {
			return
		}
		
		rv["description"] = String(describing: type(of: object))
		if deep == false {
			rv[label] = value
		} else {
			let deep = toKeyValueDictionary(value, deep: true)
			rv[label] = deep.count == 0 ? value : deep
		}
	}
	
	return rv as NSDictionary
}
