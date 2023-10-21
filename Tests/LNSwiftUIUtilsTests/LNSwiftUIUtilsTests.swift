//
//  LNSwiftUIUtilsTests.swift
//  LNSwiftUIUtilsTests
//
//  Created by Leo Natan on 21/10/2023.
//

import XCTest
import SwiftUI
@testable import LNSwiftUIUtils

final class LNSwiftUIUtilsTests: XCTestCase {
	@available(iOS 15, *)
	func testAttributeContainers() throws {
		var container = AttributeContainer()
		container.swiftUI.foregroundColor = .red
		container.swiftUI.backgroundColor = .blue
		
		var uikitContainer = container.swiftUIToUIKit
		XCTAssertEqual(uikitContainer.uiKit.foregroundColor, UIColor.systemRed)
		XCTAssertEqual(uikitContainer.uiKit.backgroundColor, UIColor.systemBlue)
		
		container = AttributeContainer()
		container.swiftUI.foregroundColor = .red
		container.swiftUI.backgroundColor = .blue
		container.uiKit.foregroundColor = .systemOrange
		container.uiKit.backgroundColor = .systemMint
		
		uikitContainer = container.swiftUIToUIKit
		XCTAssertNotEqual(uikitContainer.uiKit.foregroundColor, UIColor.systemRed)
		XCTAssertEqual(uikitContainer.uiKit.foregroundColor, UIColor.systemOrange)
		XCTAssertNotEqual(uikitContainer.uiKit.backgroundColor, UIColor.systemBlue)
		XCTAssertEqual(uikitContainer.uiKit.backgroundColor, UIColor.systemMint)
	}
	
	func testLocalizedStringKey() throws {
		XCTAssertEqual(LocalizedStringKey("test").stringKey, "test")
	}
	
	func testFontWeights() throws {
		XCTAssertEqual(UIFont.Weight(SwiftUI.Font.Weight.bold)!.rawValue, UIFont.Weight.bold.rawValue, accuracy: 0.01)
		XCTAssertEqual(UIFont.Weight(SwiftUI.Font.Weight.black)!.rawValue, UIFont.Weight.black.rawValue, accuracy: 0.01)
	}
	
	@available(iOS 16.0, *)
	func testFonts() throws {
		let sFont = SwiftUI.Font.custom("Avenir Next", size: 14, relativeTo: .headline).bold().italic().monospaced().monospacedDigit().smallCaps().lowercaseSmallCaps().uppercaseSmallCaps().weight(.black).width(.expanded).leading(.tight)
		let uiFont = sFont.uiFont
		print(uiFont)
	}
}

