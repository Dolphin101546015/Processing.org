//
//  MSX2 Images Converter v3.90 (by Dolphin_Soft #101546015)
//                                                           
//  (for converting images to MSX Basic images file format, or as plain data (with palette for 16c modes)
//                                                         
//                      Vladivostok 2023
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Download Processing : https://processing.org/download
Run and Open PDE file inside, then press CTRL + R

[F1 ] : Enable Tile Generator (Auto switch mode to 16c 256x212): Enable Tiles Grid and Analyser + Rebuilder for Tile Tables
[SHIFT]+[F1] : Sprites Scanner

[F2 ] : Save current mode image in MSX2 Basic format with headers ( [SHIFT]+[F2] in Plain Format without headers)
[F3 ] : Open File Dialog
[F4 ] : Toogle Height of Output Images (256(*)/212) (Basic able to load images with 212 raws, even files stored with 256)
        Also in Tile Generator switch height 24/32 tile raws

[F5 ] : Toogle Auto Aspect Rate ( On(*) / Off )
[F6 ] : Select Interpolation Filter (Point, Linear(*), Bilinear, Trilinear)
[F8 ] : Preview mode with fast flicker for 256/2048(*) Output Images (3)
[F7 ] : Switch color mode (256/2048(*)/YJK colors/Palette 16c (256x212 / 512x212 / 256x424 / 512x424)) in cycle (1)
	With [SHIFT] - switch backward

[F9 ] : Switch backward Shader Filter(2), 1-pass on output surfaces (With SHIFT - apply to Source Image)
[F10] : Toogle Shader Filter (Enable/Disable(*))
[F11] : Switch forward  Shader Filter(2), 1-pass on output surfaces (With SHIFT - apply to Source Image)
[F12] : Reload source image (without reseting sellected options)

     [TAB]   : Switch Palette (Dynamic(*) / Custom Fixed) in palette modes, or colors range in YJK mode
[SHIFT] + [TAB]    : Switch Custom User Palette Sorting (Deny(*) / Allow)
    [SPACE]  : Try automaticaly find frame size on black background
    [ARROWS] : Slow Move output area in Lens window
[SHIFT] + [ARROWS] : Fast Move output area in Lens window

	  [CTRL] + [ARROWS] : Slow Resize output area in Lens window
[SHIFT] + [CTRL] + [ARROWS] : Fast Resize output area in Lens window

Additional numerical keyboard:

[PLUS ] : Increase Shader Filter strength
[MINUS] : Decrease Shader Filter strength
[MULT ] : Reset shader to default value

[CRTL] + [PLUS ]   : Slow Zoom Out (Proportionally Increase) output area in Lens window
[CRTL] + [MINUS]   : Slow Zoom In  (Proportionally Decrease) output area in Lens window
		     With [SHIFT] - the same changes are accelerated.
[CRTL] + [MULT ]   : Maximize the output area in the Lens window in X or Y, 
		     depending on the proportions of the image in the Lens
 
[ESC]   : Exit without saving outputs

(*) - Default value
(1) - 256 colors mode have coding output for Interlace, 2048 colors mode switch every output pixels between frames
(2) - One Shader Filter from: Sharpen, Contrast, Gamma, Solaris, Saturat, Temper, Emboss, Dithering, Denoise, Noise
      For apply several filters, apply every needed sequentially by pressing [SHIFT]+([F9] or [F11]) on every sellected filter.
(3) - Saving in 16M mode, generate YJK files with extended ranges (more than 19k colors), for MSX2+ SCREEN12
      All active shaders working also.  