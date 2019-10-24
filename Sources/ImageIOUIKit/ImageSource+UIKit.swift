#if canImport(UIKit)
	import ImageIOSwift
	import UIKit
	
	extension ImageSource {
		/// Create an image from the image source
		///
		/// This method is fairly cheap to call because the returned CGImage is lazily loaded when it is first drawn.
		///
		/// - Parameters:
		///   - index: The frame of the image to generate (defaults to 0)
		///   - options: Any options to include when creating the image
		/// - Returns: A CGImage or nil if the underlying file doesn't include an image at that index or has invalide or incomplete data
		public func image(at index: Int = 0, options: ImageOptions? = nil) -> UIImage? {
			guard let cgImage = self.cgImage(at: index, options: options) else { return nil }
			
			let orientation = properties(at: index, options: options).orientation
			
			return UIImage(cgImage: cgImage, scale: 1, orientation: orientation)
		}
		
		/// Create a thumbnail from the image source.
		///
		/// Depending on the underlying image file and the options passed in, this may load a thumbnail that is embeded in the image, or create one, or return nil.
		///
		/// Typically, it is faster to load a complete image and draw it in a smaller view than it is to generate a thumbnail, both in terms of time and memory. However if you do need to generate a thumbnail, this method can be quit a bit faster and use *a lot* less memory than loading the image and drawing into a context.
		///
		/// - Parameters:
		///   - index: The frame of the image to generate (defaults to 0)
		///   - options: Any options to include when creating the image
		/// - Returns: A thumbnail representation of the image
		public func thumbnailImage(at index: Int = 0, options: ImageOptions? = nil) -> UIImage? {
			guard let cgImage = self.cgThumbnailImage(at: index, options: options) else { return nil }
			
			let orientation = properties(at: index, options: options).orientation
			
			return UIImage(cgImage: cgImage, scale: 1, orientation: orientation)
		}
		
		/// Create a thumbnail from the image source using a destination size.
		///
		/// 	Use this method to create a thumbnail targeted at a specific size. Note that the resulting image will always match the aspect ratio of the original image, so the resulting image size may not match the target size. You can use the `mode` option to control how the target size will be adopted.
		///
		/// - Parameter index: The frame of the image to generate (defaults to 0)
		/// - Parameter size: The target size of the thumbnail.
		/// - Parameter mode: How the thumbnail should be resized.
		/// - Parameter options: Any options to include when creating the image. `thumbnailMaxPixelSize` will be ingnored.
		public func thumbnailImage(at index: Int = 0, size: CGSize, mode: ResizingMode = .fit, options: ImageOptions = ImageOptions(shouldCache: true, shouldDecodeImmediately: true, createThumbnailBehavior: .ifAbsent)) -> UIImage? {
			guard let cgImage = self.cgThumbnailImage(at: index, size: size, mode: mode, options: options) else { return nil }
			
			let orientation = properties(at: index, options: options).orientation
			
			return UIImage(cgImage: cgImage, scale: 1, orientation: orientation)
		}
	}
#endif
