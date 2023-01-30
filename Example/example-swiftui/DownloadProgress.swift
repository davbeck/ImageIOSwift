import Combine
import Foundation
import SwiftUI

let progressFormatter: NumberFormatter = {
	let formatter = NumberFormatter()
	formatter.numberStyle = .percent
	formatter.maximumFractionDigits = 0
	return formatter
}()

class ProgressController: ObservableObject {
	let objectWillChange = PassthroughSubject<Void, Never>()

	let progress: Progress
	private var observer: NSKeyValueObservation?

	var fractionCompleted: Double
	var isComplete: Bool

	init(progress: Progress) {
		self.progress = progress
		self.fractionCompleted = progress.fractionCompleted
		self.isComplete = progress.totalUnitCount == progress.completedUnitCount

		// the publisher version of this doesn't include `isPrior`
		self.observer = progress.observe(\.fractionCompleted, options: NSKeyValueObservingOptions.prior) { progress, change in
			guard change.isPrior else { return }
			DispatchQueue.main.async { [weak self] in
				self?.objectWillChange.send()
				self?.fractionCompleted = progress.fractionCompleted
				self?.isComplete = progress.totalUnitCount == progress.completedUnitCount
			}
		}
	}
}

struct DownloadProgress: View {
	@ObservedObject var progressController: ProgressController

	init(progress: Progress) {
		self.progressController = ProgressController(progress: progress)
	}

	var body: some View {
		Text(progressFormatter.string(from: NSNumber(value: progressController.fractionCompleted)) ?? "")
			.font(Font.footnote.monospacedDigit())
			.padding([.leading, .trailing], 5)
			.padding([.top, .bottom], 2)
			.background(Color.white.opacity(0.5))
			.cornerRadius(3)
			.padding()
			.opacity(progressController.isComplete ? 0 : 1)
			.animation(.default)
	}
}
