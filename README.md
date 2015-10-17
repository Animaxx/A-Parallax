# A-Parallax
Controls and background parallax effect.

# Recording from real device
![recording demo](https://raw.githubusercontent.com/Animaxx/A-Parallax/master/demoGif/demo.gif)

# Usage
First step, Add `#import "A_Parallax.h"` to your project

##### For setting parallax background:
In your UIViewController `[self A_ParallaxBackgroup:<#UIImage instance for your controller background #>];`

##### For set control to be a parallax element:

```Objective-C
[<#Your control instance#> A_SetParallax];
```


    Or you can set the depth and enable shadow for the parallax element:
```Objective-C
[<#Your control instance#> A_SetParallaxDepth:1.0 andShadow:YES];
```


    Delete parallax effect:
```Objective-C
[<#Your control instance#> A_DeleteParallax];
```

