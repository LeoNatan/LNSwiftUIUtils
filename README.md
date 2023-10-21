# LNSwiftUIUtils
An assorted collection of SwiftUI utilities.

Currently, the following utilities are offered:

- Expose the `stringKey` in `LocalizedStringKey`
- A conversion method from `SwiftUI.Font` to `UIFont`
  - Known limitation: the `.monospaced()`, `monospacedDigits()`, `leading()` and small cap modifiers are currently not supported
- A utility method in `AttributeContainer` to convert SwiftUI scope attributes to UIKit scope
  - Known limitation: Currently, only the `foregroundColor`, `backgroundColor` and `font` attributes are converted
