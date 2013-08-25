ASMCropViewController
=====================

Provides yet another UI for cropping images in iOS. Similar to the UI crop UI in the built in Photos app, but without the auto-zooming behavior.

<img src="//raw.github.com/amolloy/ASMCropViewController/master/Screenshots/ScreenshotForReadme.png">

## License

MIT License.

## Installation

### Cocoapods 
`Coming soon.`

## Usage

```objective-c
ASMCropImageViewController* controller = [[ASMCropImageViewController alloc] init];
controller.image = [UIImage imageNamed:@"IMG_7999.jpg"];
controller.aspectRatio = CGSizeMake(9, 16);  // Optional
	
UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:controller];
[self presentViewController:navController animated:YES completion:NULL];
```

By default, the crop frame is not constrained to any aspect ratio. You can change that without

```objective-c
controller.aspectRatio = CGSizeMake(9, 16);  // Optional
```

To go back to unconstrained, just set aspectRatio to CGSizeZero.

### Getting the cropped image

```objective-c
UIImage* croppedImage = [controller croppedImage];
```

This can be called at any time after the view has been presented, and can be called as often as you'd like.

## Notes

This is currently barely tested and has not been used in any production code. You have been warned!
