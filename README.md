# ImageIO.Swift

[![CI Status](http://img.shields.io/travis/davbeck/ImageIOSwift.svg?style=flat)](https://travis-ci.org/davbeck/ImageIOSwift)
[![Version](https://img.shields.io/cocoapods/v/ImageIOSwift.svg?style=flat)](http://cocoapods.org/pods/ImageIOSwift)
[![License](https://img.shields.io/cocoapods/l/ImageIOSwift.svg?style=flat)](http://cocoapods.org/pods/ImageIOSwift)
[![Platform](https://img.shields.io/cocoapods/p/ImageIOSwift.svg?style=flat)](http://cocoapods.org/pods/ImageIOSwift)

ImageIO.Swift makes working with images on Apple platforms easy. It's [SDWebImage](https://github.com/SDWebImage/SDWebImage), [FLAnimatedImage](https://github.com/Flipboard/FLAnimatedImage) and [Concorde](https://github.com/contentful-labs/Concorde) all in one!

- Download images asychronously.
- Animate GIFs, [PNGs](https://en.wikipedia.org/wiki/APNG) and (in iOS 13) HEICs!
- Incrementally load interlaced and [progressive JPEGs](https://www.liquidweb.com/kb/what-is-a-progressive-jpeg/).
- Generate thumbnails directly from the file (especially useful for HEIC images because they often embed pre-rendered thumbnails).
- Examine image details and exif metadata.

## Usage

### SwiftUI (ImageIOSwiftUI)

`URLImageSourceView` works a lot like an `img` tag in html.

```swift
// display an image downloaded from a URL
URLImageSourceView(
	url: url, 
	isAnimationEnabled: true,
	label: Text("Alt text")
)
```

If an image url is shown in multiple places on the same screen (like a single user's profile picture on a news feed layout) it will only be downloaded and loaded into memory once. It will also be intelligently cached so that subsequent requests will re-use memory and downloaded data.

If you want to load an image source separately, you can use `ImageSourceView`:

```swift
// display an image source, animating if possible
ImageSourceView(
	imageSource: imageSource,
	isAnimationEnabled: true,
	label: Text("Alt text")
)
```

Finally, if you want to customize how an image is rendered, you can provide your own content to either `URLImageSourceView` or `ImageSourceView`:

```swift
// places an animation progress bar at the bottom of the image
URLImageSourceView(
	url: url,
	isAnimationEnabled: true,
	label: Text("Alt text")
) { imageSource, animationFrame, label in
	StaticImageSourceView(imageSource: imageSource, animationFrame: animationFrame, label: label)
		.aspectRatio(contentMode: .fit)
		.overlay(
			Rectangle()
				.fill(Color.blue.opacity(0.5))
				.frame(height: 10)
				.relativeWidth(Length(imageSource.progress(atFrame: animationFrame))),
			alignment: .bottomLeading
		)
}
```

The content callback is called every time image data is updated or an animation frame changes. By default, `StaticImageSourceView` is used to display an image frame, and you can use it as a base for your customization.

If you want to provide a placeholder while the image loads, the recommended way to do that is with a `ZStack`:

```swift
// load an image, clipped by a circle with a gray background and placeholder image
ZStack {
	Image(systemName: "person.fill")
		.foregroundColor(Color(white: 0.4))
	URLImageSourceView(url: user.picture.medium)
		.frame(width: 36, height: 36)
}
.frame(width: 36, height: 36)
.background(Color(white: 0.8))
.clipShape(Circle())
```

This way images that load incrementally will be shown as they load.

### UIKit (ImageIOUIKit)

`ImageSourceView` handles loading and displaying images.

```swift
// display an image downloaded from a URL
let view = ImageSourceView()
view.isAnimationEnabled = true
view.load(url)
```

If an image url is shown in multiple places on the same screen (like a single users profile picture on a news feed layout) it will only be downloaded and loaded into memory once. It will also be intelligently cached so that subsequent requests will re-use memory and downloaded data.

You can also set an image source directly:

```swift
let view = ImageSourceView()
view.isAnimationEnabled = true
view.imageSource = imageSource
```

You can access the views `imageSource` (regardless of whether you set it directly or loaded it from a url) and subscribe to it's `didUpdateData` notification to track it's download. To get updates for different animation frames, you can either subclass `ImageSourceView` or use KVO with `displayedImage`.

The UIKit module also includes extensions on `ImageSource` to access `UIImage`s that are correctly orriented (a feature that `CGImage` doesn't account for).

### ImageSource

You can think of `CG/NS/UIImage` as a single frame of pixels. `ImageSource` sits a level below that, providing access to almost anything an image *file* provides, including metadata and multiple representations. For instance, animated images have multiple image frames as well as timing metadata.

You can access things like `count` (the number of frames in an animated image) or `typeIdentifier` to get the kind of file it is. But it's primary use is to generate images:

```swift
imageSource.cgImage(at: 3) // frame 3
// with UIKit integration:
imageSource.image(at: 3)
```

You can provide options on how the image gets generated.

```swift
// decode the image data immediately instead of lazily when it gets drawn for the first time
// this is especially useful if you're loading images in a background thread before passing them to the main thread
var options = ImageSource.ImageOptions()
options.shouldDecodeImmediately = false
imageSource.cgImage(options: options)
```

Creating thumbnails is similar:

```swift
imageSource.cgThumbnailImage(size: thumbnailSize, mode: .fill)
```

Note that image sources don't support cropping, so it will always return an image with the same aspect ratio as the original. If the image contains an embed thumbnail, this can be quit faster than normal thumnail rendering.

Because images sources can reference a file on disk, you can load metadata for an image without loading the entire file into memory. This is especially useful for getting an images size.

```swift
ImageSource(url: fileURL).properties(at: 0)?.imageSize
```

Note that if the image source is being loaded incrementally or references an invalid file, the size will be nil.

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Installation

### [Swift Package Manager](https://swift.org/package-manager/)

In Xcode 11 you can add ImageIOSwift as a package in your project settings using the Github URL of the project. You can then link to the packages you need (ImageIOSwift, ImageIOSwiftUI or ImageIOUIKit).

On macOS, you can use is on the command line by adding the following to your Package.swift:

```swift
dependencies: [
	.package(url: "https://github.com/davbeck/ImageIOSwift.git", from: "0.5.0"),
],
```

Note that because ImageIO is not available on Linux (or any non-Apple platform) that this package cannot be used there.

### [CocoaPods](http://cocoapods.org)

Add the following line to your Podfile:

```ruby
pod 'ImageIOSwift'
# one of both of these
pod 'ImageIOSwiftUI'
pod 'ImageIOUIKit'
```

## License

ImageIOSwift is available under the MIT license. See the LICENSE file for more info.

## Sample Image Sources

- [http://nokiatech.github.io/heif/examples.html](http://nokiatech.github.io/heif/examples.html)
- [http://littlesvr.ca/apng/gif_apng_webp1.html](http://littlesvr.ca/apng/gif_apng_webp1.html)
- [https://github.com/recurser/exif-orientation-examples](https://github.com/recurser/exif-orientation-examples)
- [https://en.wikipedia.org/wiki/APNG](https://en.wikipedia.org/wiki/APNG)