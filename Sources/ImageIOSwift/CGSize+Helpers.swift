import CoreGraphics

extension CGSize {
	func scaled(toFit innerRect: CGSize) -> CGSize {
		let outerRect = self

		// the width and height ratios of the rects
		let wRatio = outerRect.width / innerRect.width
		let hRatio = outerRect.height / innerRect.height

		// calculate scaling ratio based on the smallest ratio.
		let ratio = (wRatio > hRatio) ? wRatio : hRatio

		// aspect fitted origin and size
		return CGSize(
			width: outerRect.width / ratio,
			height: outerRect.height / ratio
		)
	}

	func scaled(toFill innerRect: CGSize) -> CGSize {
		let outerRect = self

		// the width and height ratios of the rects
		let wRatio = outerRect.width / innerRect.width
		let hRatio = outerRect.height / innerRect.height

		// calculate scaling ratio based on the smallest ratio.
		let ratio = (wRatio < hRatio) ? wRatio : hRatio

		// aspect fitted origin and size
		return CGSize(
			width: outerRect.width / ratio,
			height: outerRect.height / ratio
		)
	}
}
