////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                                                                //
//  MSX2 Images Converter v3.90 (by Dolphin_Soft #101546015)                                                                      //
//                                                                                                                                //
//            (for converting images to MSX Basic images file format, or as plain data (with palette for 16c modes)               //
//                                                                                                                                //
//                                                        Vladivostok 2023                                                        //
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                                                                //
// Download Processing : https://processing.org/download                                                                          //
// Run and Open PDE file inside, then press CTRL + R                                                                              //
//                                                                                                                                //
//  [F1 ] : Enable Tile Generator (Auto switch mode to 16c 256x212): Enable Tiles Grid and Analyser + Rebuilder for Tile Tables   //
//  [SHIFT]+[F1] : Sprites Scanner                                                                                                //
//                                                                                                                                //
//  [F2 ] : Save current mode image in MSX2/2+ Basic format with headers ( [SHIFT]+[F2] in Plain Format without headers)          //
//  [F3 ] : Open File Dialog                                                                                                      //
//  [F4 ] : Toogle Height of Output Images (256(*)/212) (Basic able to load images with 212 raws, even files stored with 256)     //
//          Also in Tile Generator switch height 24(*)/32 tile raws                                                               //
//                                                                                                                                //
//  [F5 ] : Toogle Auto Aspect Rate ( On(*) / Off )                                                                               //
//  [F6 ] : Select Interpolation Filter (Point, Linear(*), Bilinear, Trilinear)                                                   //
//  [F8 ] : Preview mode with fast flicker for 256/2048(*) Output Images (3)                                                      //
//  [F7 ] : Switch color mode (256/2048(*)/YJK colors/Palette 16c ( 256x212 / 512x212 / 256x424 / 512x424 )) in cycle (1)         //
//          With [SHIFT] - switch backward                                                                                        //
//                                                                                                                                //
//  [F9 ] : Switch backward Shader Filter(2), 1-pass on output surfaces (With SHIFT - apply to Source Image)                      //
//  [F10] : Toogle Shader Filter (Enable/Disable(*))                                                                              //
//  [F11] : Switch forward  Shader Filter(2), 1-pass on output surfaces (With SHIFT - apply to Source Image)                      //
//  [F12] : Reload source image (without reseting sellected options)                                                              //
//                                                                                                                                //
//  [TAB]   : Switch Palette (Dynamic(*) / Custom Fixed) in palette modes, or colors range in YJK mode                            //
//  [SHIFT] + [TAB]    : Prevent Dynamic Palette Autobuilder to rebuilding Palette Range                                          //
//                                                                                                                                //
//  [SPACE] : Try automaticaly find frame size on black background                                                                //
//  [ARROWS]: Slow Move output area in Lens window                                                                                //
//  [SHIFT] + [ARROWS] : Fast Move output area in Lens window                                                                     //
//                                                                                                                                //
//  [CTRL]  + [ARROWS] : Slow Resize output area in Lens window                                                                   //
//  [SHIFT] + [CTRL] + [ARROWS] : Fast Resize output area in Lens window                                                          //
//                                                                                                                                //
//  Additional numerical keyboard:                                                                                                //
//                                                                                                                                //
//  [PLUS ] : Increase Shader Filter strength                                                                                     //
//  [MINUS] : Decrease Shader Filter strength                                                                                     //
//  [MULT ] : Reset shader to default value                                                                                       //
//                                                                                                                                //
//  [CTRL] + [PLUS ]   : Slow Zoom Out (Proportionally Increase) output area in Lens window                                       //
//  [CTRL] + [MINUS]   : Slow Zoom In  (Proportionally Decrease) output area in Lens window                                       //
//                       With [SHIFT] - the same changes are accelerated.                                                         //
//  [CTRL] + [MULT ]   : Maximize the output area in the Lens window by Width or Height,                                          // 
//                       depending on the proportions of the Image in the Lens                                                    //
//  [CTRL]             : Apply current filter to native showed Image fragment                                                     // 
//  [CTRL] + [C]       : Copy current Palette set to buffer                                                                       // 
//  [CTRL] + [V]       : Pastecurrent Palette from buffer to any Custom Palette set                                               // 
//                                                                                                                                //
//  [ESC]   : Exit without saving outputs                                                                                         //
//                                                                                                                                //
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                                                                //
//  (*) - Default value                                                                                                           //
//  (1) - 256 colors mode have coding output for Interlace, 2048 colors mode switch every output pixels between frames.           //
//  (2) - One Shader Filter from: Sharpen, Contrast, Gamma, Solaris, Saturat, Temper, Emboss, Dithering, Denoise, Noise,          //
// For applying several filters, use every you needed sequentially by pressing [SHIFT]+([F9] or [F11]) on every sellected filter. //
//  (3) - Saving in 16M mode, generate YJK files with extended ranges (more than 19k colors), for MSX2+ SCREEN12                  //
//        All active shaders working also.                                                                                        //
//                                                                                                                                //
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

String      ImgOut="Z:\\basic\\img";
String      SourceImage="yenn.png";
//String      SourceImage="sp16_colored_new2.png";


//                          Custom Palette (16 colors 0xRRGGBB)
static int customPAL[][]={
                          {0x000000,0x000000,0x60A060,0x80C080,0x6040E0,0x8060E0,0xA06040,0x60A0C0,    
                           0xC06040,0xC08060,0xC0C060,0xC0C080,0x408020,0xA060A0,0xA0A0A0,0xE0E0E0},   //  MSX1 Palette
                          {0x000000,0x000000,0x20C020,0x60E060,0x2020E0,0x4060E0,0xA02020,0x40C0E0,    
                           0xE02020,0xE06060,0xC0C020,0xC0C080,0x208020,0xC040A0,0xA0A0A0,0xE0E0E0},   //  MSX2 Palette                        
                          {0x000000,0x000080,0x800000,0x800080,0x008000,0x008080,0x606000,0x606060,    
                           0xE08000,0x0000E0,0xE00000,0xE000E0,0x00E000,0x00E0E0,0xE0E000,0xE0E0E0},   //  MSX Screen 8 Palette (Fixed Sprite colors)
                          {0x000000,0x0000A0,0xA00000,0xA000A0,0x00A000,0x00A0A0,0xA0A000,0xA0A0A0,
                           0x000000,0x0000E0,0xE00000,0xE000E0,0x00E000,0x00E0E0,0xE0E000,0xE0E0E0},   //  ZX Spectrum Palette
                          {0x000000,0x202020,0x404040,0x606060,0x808080,0xA0A0A0,0xC0C0C0,0xE0E0E0,    
                           0xE00000,0x800000,0x00E000,0x008000,0x0000E0,0x000080,0xA000A0,0x00A0A0},   //  Custom User Palette 0
                          {0x000000,0x202020,0x404040,0x606060,0x808080,0xA0A0A0,0xC0C0C0,0xE0E0E0,    
                           0xE00000,0x800000,0x00E000,0x008000,0x0000E0,0x000080,0xA000A0,0x00A0A0},   //  Custom User Palette 1
                          {0x000000,0x202020,0x404040,0x606060,0x808080,0xA0A0A0,0xC0C0C0,0xE0E0E0,    
                           0xE00000,0x800000,0x00E000,0x008000,0x0000E0,0x000080,0xA000A0,0x00A0A0},   //  Custom User Palette 2
                          {0x000000,0x000000,0x000000,0x000000,0x000000,0x000000,0x000000,0x000000,    
                           0xE0E0E0,0xE0E0E0,0xE0E0E0,0xE0E0E0,0xE0E0E0,0xE0E0E0,0xE0E0E0,0xE0E0E0},   //  Custom User Palette 3
                          };
int         customPAL_num      = 0;                           
int         max_customPAL      = 7;                           
boolean     allow_sorting_PAL  = false;                           

PShader     cut_colors;
PShader     repaint;

int[] pal_buf = new int[16];
int[] cv    = new int[260];
int[] ci    = new int[260];
int[] co    = {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15};
byte[] tnt  = new byte[32*32];
byte[] tct  = new byte[32*32*8*2+7];
byte[] tpt  = new byte[32*32*8*2+7];
int         ps;
int         num=0; 
int         tmp=0;


float       ScaleY = 0.9;
String      coder;
String      color_mode;
int         filter_mode;
int         coder_mode;
int         yjk_mode;
int         color_mode_code;
int         flick;
int         odd, cnt;
int         j, i, c;
int         oj, ok;
int         x, y;
float       dx, dy;
int         old_w, old_h;
int         old_x, old_y;
float       old_dx, old_dy;
int         fullX;
int         fullY;
int         outY; 
int         lx, ly;
float       ldx, ldy;
float       min, max, val;
int         r1, g1, b1;
int         r2, g2, b2, rgb;
int         r3, g3, b3;
int         r4, g4, b4;
int         y1, y2, y3, y4, yt;
int         k,  k2;
int         st;
PGraphics   ImgShow;
PGraphics   Screen;
PGraphics   Preview;
PGraphics   Interlaced;
PImage      ImgPreview;
PImage      Img;
PImage      P0;
PImage      P1;
PGraphics   Lens;
PFont       font;
color       mouse_clr;
int         blinkXOR=0;

boolean     new_image            = true;  
boolean     auto_aspect          = true;  
boolean     need_redraw          = true;
boolean     apply_Basic_header   = true; 
boolean     apply_shader         = false; 
boolean     image_sellected      = false; 
boolean     flicker              = false; 
boolean     doNotRescale         = false; 
boolean     TilesEnabled         = false; 
boolean     TilesReady           = false; 
boolean     SpritesEnabled       = false; 
boolean     SpritesReady         = false; 
boolean     CustomPal            = false; 
boolean     fix_Palette          = false; 
            
boolean     key_LEFT  = false, key_RIGHT = false, key_UP      = false, key_DOWN   = false;
boolean     key_F1    = false, key_F2    = false, key_F3      = false, key_F4     = false;
boolean     key_F5    = false, key_F6    = false, key_F7      = false, key_F8     = false;
boolean     key_F9    = false, key_F10   = false, key_F11     = false, key_F12    = false;
boolean     key_SPACE = false, key_SHIFT = false, key_CTRL    = false, key_RMULT  = false;
boolean     key_PLUS  = false, key_MINUS = false, key_RPLUS   = false, key_RMINUS = false; 
boolean     key_DEL   = false, key_PGDOWN= false, key_TAB     = false;
boolean     mouse_LB  = false, mouse_MB  = false, mouse_RB    = false, osc_Over   = false;
boolean     key_C     = false, key_V     = false;

// FPS Counter Data
int         tim   = 0;
float       fc    = 0;
float       maxfc = 0;
float       ofc   = 0;

int         shaderNum;
int         shaderMax;

Filter[]    filter;

class    Filter {
  public String  name     = null;
  public PShader shader   = null;
  public float   val_min  = 0.0;
  public float   val_max  = 0.0;
  public float   reset_val= 0.0;
  public float   val      = 0.0;
            Filter(String name, String shader, float val_min, float reset_val, float val_max) {
                  this.name       = new String(name);
                  this.shader     = new PShader();
                  this.shader     = loadShader(shader);
                  this.val_max    = val_max;
                  this.val_min    = val_min;
                  this.reset_val  = reset_val;
                  this.val        = reset_val;
            }
}

void buildRange() {
        int tcol=0;
        int t=0, i=0, curY=fullY;
        ps=0;
        boolean fnd=false;
// Palette indexing
        if (color_mode_code>5) curY<<=1;
        for (t=0; t<16; t++) cv[t]=0;
        Interlaced.filter(cut_colors);
        Interlaced.loadPixels();
        for (j=0; j < curY; j++) {
            if (ps>255) break;
            for (i=0; i < fullX; i++) {
              tcol=Interlaced.pixels[i+(j<<9)]&0x00FFFFFF;
              for (t=0; t<=ps; t++) 
                  if (tcol==cv[t]) { ci[t]++; fnd=true; break; }
              if (!fnd) { 
                  cv[ps]=tcol; 
                  ci[ps]=1; 
                  ps++;
              }
              if (ps>255) break;
              fnd=false;
            }
        }
// Get 16
        for (t=0; t<16; t++){
           int max=0;
           for (i=t; i<ps; i++) 
               if (ci[i]>max) { max=ci[i]; num=i; }
           if (max>ci[t]) { 
               tmp=ci[t]; ci[t]=ci[num]; ci[num]=tmp; 
               tmp=cv[t]; cv[t]=cv[num]; cv[num]=tmp; 
             } 
        }
        
// Sorting
   //if ((allow_sorting_PAL)) {
        if (ps<16) {
          for (t=ps; t<16; t++) cv[t]=0;
          ps=16;
        }

        for (t=15; t>0; t--)
           for (i=t-1; i>=0; i--) 
               if (cv[t]<cv[i]) { tmp=cv[t]; cv[t]=cv[i]; cv[i]=tmp;}
/*
     }
        println();
        for (t=0; t<16; t++)
          print(hex(cv[t])+",");
          */
               
}

void convertSC57(){
     if (CustomPal){ 
        for (int t=0; t<16; t++) {cv[t]=customPAL[customPAL_num][t]; co[t]=t;}
        if ((CustomPal)&&(allow_sorting_PAL))
          for (int t=15; t>0; t--)
             for (i=t-1; i>=0; i--) 
                   if (cv[t]<cv[i]) { 
                       tmp=cv[t]; cv[t]=cv[i]; cv[i]=tmp;
                       tmp=co[t]; co[t]=co[i]; co[i]=tmp;
                   }
     } else if (!fix_Palette) buildRange();
     Interlaced.copy(Img, x, y, (int)(dx), (int)(dy), 0, 0, fullX, outY);
     if (apply_shader) Interlaced.filter(filter[shaderNum].shader);
     repaint.set("inPAL", cv);
     Interlaced.filter(repaint);
}

void save_SC57() {
        int tcol=0;
        int t=0, i=0, y_step=1;
        String code = "10 SCREEN 5;20 BLOAD"+(char)34+"img.s50"+(char)34+",s;40";
        String OutFile;

// Save to SC5-7
        if (color_mode_code>5) { y_step=2;}
        for (j=0; j<y_step; j++) {
            OutFile=ImgOut+".s5"+j;
            if ((color_mode_code==5)||(color_mode_code==7))  OutFile=ImgOut+".s7"+j;
            println("Saving: "+OutFile);
            OutputStream outp = createOutput(OutFile);
            try {
                if (!key_SHIFT) {
                    outp.write(0xFE); 
                    outp.write(0x00); outp.write(0x00); 
                    if ((color_mode_code==5)||(color_mode_code==7))  {
                        outp.write(0xA6); outp.write(0xFA); 
                    } else {
                        outp.write(0x9F); outp.write(0x76);
                    }
                    outp.write(0x00); outp.write(0x00);
                }
        
                int col=0;
                Interlaced.loadPixels();
                for (int m=0; m<212; m++) {
                    for (i=0; i<fullX; i++) {
                        int offs=(m*y_step+j)*512+i;
                        tcol=Interlaced.pixels[offs];
                        tmp=15;
                        for (t=0; t<16; t++) 
                            if ((cv[t]&0xFFFFFF)==(tcol&0xFFFFFF)) { tmp=t; break; }
                        tmp=co[tmp];
                        if ((i&1)==0) tmp<<=4;
                        col|=tmp;
                        if ((i&1)==1) {outp.write(col&0xFF);col=0;}
                    }
                }
                Interlaced.updatePixels();
    
    // Skip to palette by zero
                if (!key_SHIFT) {
                    if ((color_mode_code==5)||(color_mode_code==7))  t=9856; else t=3200;
                    for (i=0; i < t; i++) outp.write(0);
    // Write Palette
                    for (i=0; i < 16; i++) {
                      outp.write(((cv[i]>>17)&0x70)|((cv[i]>>5)&7));
                      outp.write((cv[i]>>13)&7);
                    }
                    for (i=0; i < 32-ps*2; i++) outp.write(0);
                }
                outp.flush();
                outp.close();
            }
            catch(Exception e) {
                  println("Message: " + e);
            }
        }
        OutFile=ImgOut+".pal";
        OutputStream outp = createOutput(OutFile);
        if (key_SHIFT) {
            try {
                  for (i=0; i < 16; i++) {
                      outp.write(((cv[i]>>17)&0x70)|((cv[i]>>5)&7));
                      outp.write((cv[i]>>13)&7);
                  }
                  for (i=0; i < 32-ps*2; i++) outp.write(0);
                  outp.flush();
                  outp.close();
            }
            catch(Exception e) {
                  println("Message: " + e);
            }
        } else {
            try {
                  outp.write(0xFE); 
                  if (color_mode_code==4)  {
                         outp.write(0x80); outp.write(0x76); 
                  } else {
                         outp.write(0x80); outp.write(0xFA);
                  }
                  outp.write(0x20); outp.write(0x00);
                  outp.write(0x00); outp.write(0x00);

                  for (i=0; i < 16; i++) {
                      outp.write(((cv[i]>>17)&0x70)|((cv[i]>>5)&7));
                      outp.write((cv[i]>>13)&7);
                  }
                  for (i=0; i < 32-ps*2; i++) outp.write(0);
                  outp.flush();
                  outp.close();
            }
            catch(Exception e) {
                  println("Message: " + e);
            }

        }
        if (apply_Basic_header){
            if (color_mode_code==5)
                code = "10 SCREEN 7;20 BLOAD"+(char)34+"img.s70"+(char)34+",s;40";
            if (color_mode_code==6)
                code = "10 SCREEN 5,,,,,3;20 BLOAD"+(char)34+"img.s50"+(char)34+",s:SET PAGE1,1;30 BLOAD"+(char)34+"img.s51"+(char)34+",s;40";
            if (color_mode_code==7)
                code = "10 SCREEN 7,,,,,3;20 BLOAD"+(char)34+"img.s70"+(char)34+",s:SET PAGE1,1;30 BLOAD"+(char)34+"img.s71"+(char)34+",s;40 ";
            if ((CustomPal)&&(customPAL_num==0)) code+="'"; 
            code+="COLOR=RESTORE;50 IFNOTSTRIG(0)GOTO50;60 RUN"+(char)34+"img.bas"+(char)34+";";
            String[] list = split(code, ';');
            saveStrings(ImgOut+".bas",list);
        }
                
}

void GetSprites(){
  int num=0;
  int f1=0, f2=0;
  int t=0, i=0, j=0;
  int c1=0, c2=0, c3=0, cf=0;
  int tcol=0;
  int pt1=0;
  int pt2=0;
  int max=0,maxn=0;
        if ((key_SHIFT)&&((frameCount&7)==0)) blinkXOR^=0xFFFFFF;   
        Interlaced.loadPixels();
        for (i=0; i<32*32*8; i++) {tct[i]  =0; tpt[i]  =0;}
        for (num=0; num < 256; num++) { //2*maxY
            f1=(num&15)*16;
            f2=(num>>4)*16;
            
            tct[(int)((num>>5)*1024+(num&31)*4+512  )]=(byte)((num&24)*2+128);
            tct[(int)((num>>5)*1024+(num&31)*4+512+1)]=(byte)(((num>>1)&3)*16);
            tct[(int)((num>>5)*1024+(num&31)*4+512+2)]=(byte)((num&31)*4+(num&32)*4);

            tct[(int)((num>>5)*1024+(num&31)*4+512  +8192)]=(byte)((num&24)*2+128);
            tct[(int)((num>>5)*1024+(num&31)*4+512+1+8192)]=(byte)(((num>>1)&3)*16);
            tct[(int)((num>>5)*1024+(num&31)*4+512+2+8192)]=(byte)((num&31)*4+(num&32)*4);
            
            for (t=f2; t<f2+16; t++){
                for (j=0; j<16; j++) ci[j]=0;
    //Scan tile line and optimize colors
                for (i=f1; i<f1+16; i++){
                   tcol=Interlaced.pixels[i+t*512]&0xFFFFFF;
                   for (j=0; j<16; j++) {
                     if (tcol==(cv[j]&0xFFFFFF)) ci[j]++;
                     if (tcol==0) break;
                   }
                }
                ci[co[0]]=0;
                maxn=0; max=0; cf=0; 
                for (j=0; j<16; j++) if (ci[j]>0) cf++;
                if (cf>3) for (i=f1; i<f1+16; i++) Interlaced.pixels[i+t*512]^=blinkXOR;
                else {
                    maxn=0; max=0; 
                    for (j=0; j<16; j++) if (max<ci[j]) {max=ci[j]; maxn=j;}
                    c1=maxn; ci[maxn]=0;
      
                    maxn=0; max=0; 
                    for (j=0; j<16; j++) if (max<ci[j]) {max=ci[j]; maxn=j;}
                    c2=maxn; ci[maxn]=0;

                    if (c1>c2) {c1^=c2; c2^=c1; c1^=c2;}
                    c3=16;
                    
                    if (cf==3) {
                          maxn=0; max=0; 
                          for (j=0; j<16; j++) if (max<ci[j]) {max=ci[j]; maxn=j;}
                          c3=maxn; ci[maxn]=0;
      
                          if (c1>c3) {c1^=c3; c3^=c1; c1^=c3;}
                          if (c2>c3) {c2^=c3; c3^=c2; c2^=c3;}
                          if (c1>c2) {c1^=c2; c2^=c1; c1^=c2;}
                    }
                    
                    pt1=0; pt2=0;
                    for (i=f1;   i<f1+8;  i++) {
                       pt1<<=1; pt2<<=1;
                       tcol=Interlaced.pixels[i+t*512]&0xFFFFFF;
                       if ((c1!=0)&&(tcol==(cv[c1]&0xFFFFFF))) pt1++;
                       if ((c2!=0)&&(tcol==(cv[c2]&0xFFFFFF))) pt2++;
                       if ((c3==(c1|c2))&&(tcol==(cv[c3]&0xFFFFFF))) {pt1|=1; pt2|=1;}
                    }
                    tpt[(int)(f2*64+f1*4+(t&15))   ]=(byte)pt1;
                    tpt[(int)(f2*64+f1*4+(t&15)+32)]=(byte)pt2;
                    pt1=0; pt2=0;
                    for (i=f1+8;   i<f1+16;  i++) {
                       pt1<<=1; pt2<<=1;
                       tcol=Interlaced.pixels[i+t*512]&0xFFFFFF;
                       if ((c1!=0)&&(tcol==(cv[c1]&0xFFFFFF))) pt1++;
                       if ((c2!=0)&&(tcol==(cv[c2]&0xFFFFFF))) pt2++;
                       if ((c3==(c1|c2))&&(tcol==(cv[c3]&0xFFFFFF))) {pt1|=1; pt2|=1;}
                    }
                    tpt[(int)(f2*64+f1*4+(t&15)+16)]=(byte)pt1;
                    tpt[(int)(f2*64+f1*4+(t&15)+48)]=(byte)pt2;
                    tct[(int)(f2*64+f1*2+(t&15)   )]=(byte)co[c1];
                    tct[(int)(f2*64+f1*2+(t&15)+16)]=(byte)(co[c2]|64);
                   if ((c3!=16)&&(c3!=(c1|c2))) for (i=f1; i<f1+16; i++) Interlaced.pixels[i+t*512]^=blinkXOR;
                }
            }
        }
        Interlaced.updatePixels();

}

void SaveSprites(){
        String code = "";
        String OutFile;
// Save Sprite Pattern Table
            OutFile=ImgOut+".spt";
            println("Saving: "+OutFile);
            OutputStream outp = createOutput(OutFile);
            try {
                if (!key_SHIFT) {
                    outp.write(0xFE); 
                    outp.write(0x00); outp.write(0x00); 
                    outp.write(0xFF); outp.write(0x3F); 
                    outp.write(0x00); outp.write(0x00);
                }
                for (i=0;i<32*32*8*2;i++)
                  outp.write(tpt[i]); 
                outp.flush();
                outp.close();
            }
            catch(Exception e) {
                  println("Message: " + e);
            }

// Save Sprite Color Table
            OutFile=ImgOut+".sct";
            println("Saving: "+OutFile);
            outp = createOutput(OutFile);
            try {
                if (!key_SHIFT) {
                    outp.write(0xFE); 
                    outp.write(0x00); outp.write(0x00); 
                    outp.write(0xFF); outp.write(0x3F); 
                    outp.write(0x00); outp.write(0x00);
                }
                for (i=0;i<32*32*8*2;i++)
                  outp.write(tct[i]); 
                outp.flush();
                outp.close();
            }
            catch(Exception e) {
                  println("Message: " + e);
            }

// Palette
            OutFile=ImgOut+".pal";
            outp = createOutput(OutFile);
            try {
                if (!key_SHIFT) {
                    outp.write(0xFE); 
                    outp.write(0x80); outp.write(0xFA); 
//                    outp.write(0x80); outp.write(0x76); 
                    outp.write(0x20); outp.write(0x00); 
                    outp.write(0x00); outp.write(0x00);
                }
                for (i=0; i < 16; i++) {
                      outp.write(((cv[i]>>17)&0x70)|((cv[i]>>5)&7));
                      outp.write((cv[i]>>13)&7);
                }
                outp.flush();
                outp.close();
            }
            catch(Exception e) {
                  println("Message: " + e);
            }
            if (apply_Basic_header){
                code ="10 SCREEN 7,2,,,,0;20 BLOAD"+(char)34+"img.pal"+(char)34+",S:COLOR=RESTORE;30 BLOAD"+(char)34+"img.spt"+(char)34+",S,&H0;";
                code+="40 BLOAD"+(char)34+"img.sct"+(char)34+",S,&H4200-512;50 _TURBO ON;60 SET PAGE0,1:CLS:SET PAGE0,0;70 Z=VDP(9):SP=0:VDP(2)=31:LINE(0,0)-(511,127),15,BF,XOR;";
                code+="80 G=SP"+(char)92+"2:VDP(6)=G:VDP(5)=((SP+16)*8)OR7:VDP(12)=0;81 LINE(0,SP*4+64)-(511,SP*4+3+64),15,BF,XOR;82 LINE(0,G*8)-(511,G*8+7),15,BF,XOR;90 VDP(9)=Z:S=1:AD=((SP*8)OR132)*&H80;";
                code+="91 POKE&HC200,255:IFPEEK(&HFBEC)=251GOTO150;92 IF STRIG(0) GOTO 140;";
                code+="95 S=STICK(0):IF (S<>1) AND (S<>5) GOTO91;96 VDP(9)=ZOR2:LINE(0,SP*4+64)-(511,SP*4+3+64),15,BF,XOR;97 LINE(0,G*8)-(511,G*8+7),15,BF,XOR;";
                code+="100 SP=(SP+(S=1)-(S=5))AND15;110 TIME=0;120 IF TIME<12 GOTO 120;130 IFPEEK(&HFBEC)<>251GOTO80;";
                code+="140 POKE&HC200,SP;150 _TURBO OFF;160 SP=PEEK(&HC200):G=SP"+(char)92+"2:IF SP=255 GOTO200;";
                code+="170 A$="+(char)34+"Bank"+(char)34+"+MID$(HEX$(SP),1,1);171 BSAVEA$+"+(char)34+".SPT"+(char)34+",G*2048,G*2048+2047,S;";
                code+="172 BSAVEA$+"+(char)34+".SCT"+(char)34+",&H4000+SP*1024,&H3FFF+(SP+1)*1024,S;";
                code+="200 END;";

                String[] list = split(code, ';');
                saveStrings(ImgOut+"_Spr.bas",list);
            }
        System.gc();
}

void GetTiles(){
  int num=0;
  int f1=0, f2=0;
  int t=0, i=0, j=0;
  int c1=0, c2=0;
  int tcol=0;
  int pt=0;
  int max=0,maxn=0;
  int maxY=0;
//        if (fullY==212) maxY=28; else maxY=32;
        maxY=32;
// Fill Name Table
        Interlaced.loadPixels();
        for (num=0; num < 32*maxY; num++) {
            tnt[num] = (byte)((num+128) & 255);
            f1=(num&31)*8;
            f2=(num>>5)*8;
            for (t=f2; t<f2+8; t++){
                for (j=0; j<16; j++) ci[j]=0;
    //Scan tile line and optimize colors
                for (i=f1; i <f1+8; i++){
                   tcol=Interlaced.pixels[i+t*512]&0xFFFFFF;
                   for (j=0; j<16; j++) {
                     if (tcol==(cv[j]&0xFFFFFF)) ci[j]++;
                     if (tcol==0) break;
                   }
                }
                maxn=0; max=0; 
                for (j=0; j<16; j++) if (max<ci[j]) {max=ci[j]; maxn=j;}
                c1=maxn; ci[maxn]=0;
  
                maxn=0; max=0; 
                for (j=0; j<16; j++) if (max<ci[j]) {max=ci[j]; maxn=j;}
                c2=maxn; ci[maxn]=0;
    
                pt=0;
                for (i=f1; i <f1+8; i++){
                   tcol=Interlaced.pixels[i+t*512]&0xFFFFFF;
                   if (tcol==(cv[c1]&0xFFFFFF)) pt<<=1;
                   else { 
                     if (tcol!=cv[c2]) Interlaced.pixels[i+t*512]=cv[c2]&0xFFFFFF;
                     pt<<=1; pt++;
                   }
                }
     // Fill Pattern Table
                tpt[(int)(f2*32+f1+(t&7))]=(byte)pt;
     // Fill Color Table                        
                c1=co[c1]; c2=co[c2];

                tct[(int)(f2*32+f1+(t&7))]=(byte)((c2<<4)|c1);
            }
        }
        Interlaced.updatePixels();
}

void ShowGrid(int step){
        Interlaced.loadPixels();
        for (j=0; j < 256; j+=step)
          for (i=0; i < 256; i++) {
            Interlaced.pixels[i+j*512]^=0x060A0A;
            Interlaced.pixels[j+i*512]^=0x060A0A;
          }
        Interlaced.updatePixels();
}

void SaveTiles(){
        String code = "";
        String OutFile;
// Name Table
            OutFile=ImgOut+".s4n";
            println("Saving: "+OutFile);
            OutputStream outp = createOutput(OutFile);
            try {
                if (!key_SHIFT) {
                    outp.write(0xFE); 
                    outp.write(0x00); outp.write(0x00); 
                    outp.write(0x00); outp.write(0x04); 
                    outp.write(0x00); outp.write(0x00);
                }
                for (i=0;i<32*32;i++)
                  outp.write(tnt[i]); 
                outp.flush();
                outp.close();
            }
            catch(Exception e) {
                  println("Message: " + e);
            }

// Pattern Table
            OutFile=ImgOut+".s4p";
            println("Saving: "+OutFile);
            outp = createOutput(OutFile);
            try {
                if (!key_SHIFT) {
                    outp.write(0xFE); 
                    outp.write(0x00); outp.write(0x00); 
                    outp.write(0x00); outp.write(0x20); 
                    outp.write(0x00); outp.write(0x00);
                }
                for (i=0;i<32*32*8;i++)
                  outp.write(tpt[i]); 
                outp.flush();
                outp.close();
            }
            catch(Exception e) {
                  println("Message: " + e);
            }

// Color Table
            OutFile=ImgOut+".s4c";
            println("Saving: "+OutFile);
            outp = createOutput(OutFile);
            try {
                if (!key_SHIFT) {
                    outp.write(0xFE); 
                    outp.write(0x00); outp.write(0x00); 
                    outp.write(0x00); outp.write(0x20); 
                    outp.write(0x00); outp.write(0x00);
                }
                for (i=0;i<32*32*8;i++)
                  outp.write(tct[i]); 
                outp.flush();
                outp.close();
            }
            catch(Exception e) {
                  println("Message: " + e);
            }

// Palette
            OutFile=ImgOut+".pal";
            outp = createOutput(OutFile);
            try {
                if (!key_SHIFT) {
                    outp.write(0xFE); 
                    outp.write(0x80); outp.write(0x1B); 
                    outp.write(0x20); outp.write(0x00); 
                    outp.write(0x00); outp.write(0x00);
                }
                for (i=0; i < 16; i++) {
                      outp.write(((cv[i]>>17)&0x70)|((cv[i]>>5)&7));
                      outp.write((cv[i]>>13)&7);
                }
                outp.flush();
                outp.close();
            }
            catch(Exception e) {
                  println("Message: " + e);
            }
            if (apply_Basic_header){
                code = "10 SCREEN4:VDP(10)=VDP(10)OR128:VDP(2)=7:VDP(9)=VDP(9)OR2;";
                code+="20 BLOAD"+(char)34+"img.s4p"+(char)34+",S:BLOAD"+(char)34+"img.s4n"+(char)34+",S,&H4000;";
                code+="30 BLOAD"+(char)34+"img.pal"+(char)34+",S:";
                if ((CustomPal)&&(customPAL_num==0)) code+="'"; 
                code+="COLOR=RESTORE;40 BLOAD"+(char)34+"img.s4c"+(char)34+",S,&H2000;50 IF NOTSTRIG(0)GOTO50;60 RUN"+(char)34+"img.bas"+(char)34;
                String[] list = split(code, ';');
                saveStrings(ImgOut+".bas",list);
            }
        System.gc();
}
 
 
void fileSelected(File selection) {
        if (selection == null) {
            need_redraw=true;
            return;
        } else {
            SourceImage=selection.getAbsolutePath();
            image_sellected=true;
        }
}

void SetFont() {
        Screen=createGraphics(1920, 1080, P3D);
        font = createFont( "Boeing.ttf", 300, true );
        Preview=createGraphics(512, 512, P3D);
        ImgPreview=createImage(512, 512, RGB);;
        P0=createImage(256, 256, RGB);
        P1=createImage(256, 256, RGB);
        Interlaced=createGraphics(512, 512, P3D);
        textFont( font );
        textAlign( LEFT );
}

void interpolation(PGraphics srf, int mod) {
        if ((mod<2)||(mod>5)) {
            println("Wrong sampling mode for", srf);
            return;
        }
        ((PGraphicsOpenGL) srf).textureSampling(mod);
        need_redraw = true;
}

void Open_Image() {
        if (Img!=null) g.removeCache(Img);
        if (ImgShow!=null) g.removeCache(ImgShow);
        if (Lens!=null) g.removeCache(Lens);
        System.gc();
        Img=loadImage(SourceImage);
        ImgShow=createGraphics(Img.width, Img.height, P3D);
      
        x   = 0; y = 0; st = 1;

        lx    = Img.width;
        ly    = Img.height;
        ldx   = Img.width  / 800.0;
        ldy   = Img.height / 800.0;

        if (Img.width<=Img.height) {
              x  = 0;
//              y -=(Img.width-dx)/2;
              dx = Img.width;
              dy = dx / (256.0/fullY);
              if (y<0) y=0;
              lx  = (int)(dx/ldy);
              ldx = ldy; 
              ly  = 800;
        } else {
              y  = 0;
//              x -=(Img.height-dy)/2;
              dy = Img.height;
              dx = dy / (fullY/256.0);
              if (x<0) x=0;
              ly  = (int)(dy/ldx); 
              ldy = ldx; 
              lx  = 800;
        }
        if ((x+dx)>Img.width)  x=(int)(Img.width-dx);
        if ((y+dy)>Img.height) y=(int)(Img.height-dy);
        Lens=createGraphics(lx, ly, P3D);
        Lens.copy(Img, 0, 0, Img.width, Img.height, 0, 0, lx, ly);
        ScaleSrc();
        SetCropBorders();
        need_redraw = true;

}

void SetCropBorders(){
int ox=0,oy=0;
int trs=0;
boolean fnd=false;
   Img.loadPixels();
   do {  oy=0;
         do { trs=Img.pixels[(oy++)*Img.width+ox];
              trs=((trs>>16)&255)|((trs>>8)&255)|(trs&255);
              if (trs>5) fnd=true;
         } while (oy<Img.height);
         ox++;
   } while (!fnd);
   x=ox-1; ox=Img.width; fnd=false; 
   do {  ox--;
         oy=0;
         do { trs=Img.pixels[(oy++)*Img.width+ox];
             trs=((trs>>16)&255)|((trs>>8)&255)|(trs&255);
             if (trs>5) fnd=true;
         } while (oy<Img.height);
   } while (!fnd);
   oy=0; dx=ox-x+1; fnd=false;
   do {  ox=0;
         do { trs=Img.pixels[oy*Img.width+(ox++)];
              trs=((trs>>16)&255)|((trs>>8)&255)|(trs&255);
              if (trs>5) fnd=true;
         } while (ox<Img.width);
         oy++;
   } while (!fnd);
   y=oy-1;
   if ((y+dy)>Img.height) dy=Img.height-y;

   Img.updatePixels();
}

private void maximized() {
    try {       
        final com.jogamp.newt.opengl.GLWindow window = (com.jogamp.newt.opengl.GLWindow) getSurface().getNative();
        window.getScreen().getDisplay().getEDTUtil().invoke(false, new Runnable() {
            @Override
            public void run() {
                window.setMaximized(true, true); // both horizontal and vertical
            }
        });
    } catch (Exception e) {
        System.err.println("Could not make window maximized");
    }
}

void setup() {
//      String[] fontList = PFont.list();
//      printArray(fontList);

      frameRate(175);
      size(1920,1030,P3D); // - windowed mode
      maximized();
      noSmooth();
      
//      smooth(8);

        old_w = width; 
        old_h = height;

        shaderNum = 0;
        shaderMax = 9;
        filter    = new Filter[shaderMax+1];
        filter[0] = new Filter("0. Sharpen" ,  "sharp.glsl",  0.0,    0.15,2.0);
        filter[1] = new Filter("1. Contrast", "contra.glsl", -3.0,    1.0, 3.0);
        filter[2] = new Filter("2. Gamma"   ,  "gamma.glsl",  0.0,    1.0, 4.0);
        filter[3] = new Filter("3. Saturat" , "satura.glsl", -4.0,    1.0, 4.0);
        filter[4] = new Filter("4. Solaris" ,  "solar.glsl", -3.0,    0.0, 3.0);
        filter[5] = new Filter("5. Temper"  , "temper.glsl",  0.1539, 1.0, 3.0);
        filter[6] = new Filter("6. Emboss"  , "emboss.glsl", -2.0,    0.0, 2.0);
        filter[7] = new Filter("7. Dithering","dither.glsl", -2.0,    0.5, 2.0);
        filter[8] = new Filter("8. Denoise",  "denoise.glsl", 0.001,  0.3, 3.0);
        filter[9] = new Filter("9. Noise",    "noise.glsl",  -2.0,    0.3, 2.0);

        repaint     = loadShader("repaint.glsl");
        cut_colors  = loadShader("cut.glsl");
        background(0);
        SetFont();
        textFont( font );
        textAlign(LEFT, BOTTOM);
        blendMode(REPLACE );
        background(0, 0, 0, 255);
      
        flick=0;
        coder_mode=1;
        color_mode_code = 3;
      
        fullX = 256;
        fullY = 212;
        yjk_mode=248; // Full YJK mode 19k colors
        Open_Image();
        
//      NEAR=2, LINEAR=3, BILINEAR=4, and TRILINEAR=5
      
        filter_mode = 2;
        interpolation(Screen,  2);
        interpolation(Lens,    2);
        interpolation(Interlaced,  filter_mode);
        interpolation(ImgShow,     filter_mode);
        interpolation(Preview,     filter_mode);
        interpolation(Lens,        filter_mode);
        Screen.noSmooth();
        Lens.noSmooth();
        ScaleSrc();
}

void ScaleSrc() {
        if ((color_mode_code>5)||(color_mode_code==3)) outY=fullY*2; else outY=fullY;
        Interlaced.copy(Img, x, y, (int)(dx), (int)(dy), 0, 0, fullX, outY);
        Lens.copy(Img, 0, 0, Img.width, Img.height, 0, 0, lx, ly);

        if (apply_shader) {
          Interlaced.filter(filter[shaderNum].shader);
          Lens.filter(filter[shaderNum].shader);
        }
        if (color_mode_code>3) convertSC57();
        if (color_mode_code<3) coder();
        else flicker = false;
        if (color_mode_code==3) CodeYJK();
}

void coder() {
        int offs=0;
        ImgPreview.copy(Interlaced, 0, 0, fullX, fullY*2, 0, 0, fullX, fullY*2);
        Interlaced.beginDraw();
        Interlaced.loadPixels();
        ImgPreview.loadPixels(); P0.loadPixels(); P1.loadPixels();
        odd = 1; cnt = 0;
        for (int j = 0; j < fullY; j++) {
            for (int i = 0; i < 256; i++) {
                  offs=(j<<9)+i;
                  b2 = ImgPreview.pixels[offs];
                  r2 = (b2>>16) & 0xF0;
                  g2 = (b2>> 8) & 0xF0;
                  b2&= 0xF0;
                  if (color_mode_code==2) Interlaced.pixels[offs] =(r2<<16)|(g2<<8)|b2;
                  r1 = (r2<<1) & 32; r2 &= 0xE0; r1 += r2; if (r1>255) r1=255;
                  g1 = (g2<<1) & 32; g2 &= 0xE0; g1 += g2; if (g1>255) g1=255;
                  b1 = (b2<<1) & 64; b2 &= 0xC0; b1 += b2; if (b1>255) b1=255;
                  int c1=(r1<<16)|(g1<<8)|b1;
                  int c2=(r2<<16)|(g2<<8)|b2;
                  offs=(j<<8)+i;
                  if (color_mode_code==1) {
                        P0.pixels[offs] = c2;
                        P1.pixels[offs] = c1;
                        int k=(j<<1);
                        Interlaced.pixels[( k   <<9)+i] = c2;
                        Interlaced.pixels[((k+1)<<9)+i] = c1;
                  } else {
                        odd^=1;
                        if (odd==0){
                              P0.pixels[offs] = c2;
                              P1.pixels[offs] = c1;
                        } else {
                              P0.pixels[offs] = c1;
                              P1.pixels[offs] = c2;
                        }
                        if (++cnt==256) { odd ^= 1; cnt = 0;}
                  }
            }
        }
        P1.updatePixels(); P0.updatePixels(); Interlaced.updatePixels();
        Interlaced.updatePixels();
        Interlaced.endDraw();
}

void Save_MSX(){
        OutputStream outp = createOutput(ImgOut+".s80");
        println("Saving: "+ImgOut+".s80");
        try {
              if (apply_Basic_header){
                    outp.write(0xFE); 
                    outp.write(0x00); outp.write(0x00); 
                    outp.write(0x00); outp.write(0xD4); 
                    outp.write(0x00); outp.write(0x00);
              }
              P0.loadPixels();
              for (i=0; i<256*fullY;i++) {
                    rgb  = (P0.pixels[i] >>19) & 0x1C;
                    rgb |= (P0.pixels[i] >> 8) & 0xE0;
                    rgb |= (P0.pixels[i] >> 6) & 0x03;
                    outp.write(rgb);
              }
              P0.updatePixels();
              outp.flush();
              outp.close();
        }
        catch(Exception e) {
              println("Message: " + e);
        }
      
        outp = createOutput(ImgOut+".s81");
        println("Saving: "+ImgOut+".s81");
        try {
              if (apply_Basic_header){
                  outp.write(0xFE); 
                  outp.write(0x00); outp.write(0x00); 
                  outp.write(0x00); outp.write(0xD4); 
                  outp.write(0x00); outp.write(0x00);
              }
              P1.loadPixels();
              for (i=0; i<256*fullY;i++) {
                  rgb  = (P1.pixels[i] >>19) & 0x1C;
                  rgb |= (P1.pixels[i] >> 8) & 0xE0;
                  rgb |= (P1.pixels[i] >> 6) & 0x03;
                  outp.write(rgb);
              }
              P1.updatePixels();
              outp.flush();
              outp.close();
          }
          catch(Exception e) {
              println("Message: " + e);
          }
          if (apply_Basic_header){
            String code = "10 SCREEN 8,,,,,";
            if (color_mode_code==1) code+="3";
            else  code+="2";
            code+=";20 BLOAD"+(char)34+"img.s80"+(char)34+",s:SET PAGE1,1;30 BLOAD"+(char)34+"img.s81"+(char)34+",s;40 IFNOTSTRIG(0)GOTO40;50 RUN"+(char)34+"img.bas"+(char)34+";";
            String[] list = split(code, ';');
            saveStrings(ImgOut+".bas",list);
          }
        System.gc();
}

int YJK2RGB(int y, int j, int k){
int r=0, g=0, b=0;
//  K&=31;
//  J&=31;
//  if (K>31) K-=64;
//  if (J>31) J-=64;
  r=(j+y);
  g=(k+y);
  b=(y*5-2*j-k)/4;
//  B=Y-J-K/5;
//  B=((5*Y-5*J-K)/4);
//  y=(2r+4g+b)/7;
//  y*7=(2r+4g+b)
//  B=(Y*7-2*R-4*G);
  if (r<0) r=0;
  if (g<0) g=0;
  if (b<0) b=0;

  if (r>255) r=255;
  if (g>255) g=255;
  if (b>255) b=255;
  
  return (r<<16)|(g<<8)|b;
}

void RGB2YJK(int offs){
        b1 = Interlaced.pixels[offs];
        b2 = Interlaced.pixels[offs+1];
        b3 = Interlaced.pixels[offs+2];
        b4 = Interlaced.pixels[offs+3];
        r1 = (b1>>16)&255; g1 = (b1>>8)&255; b1&=255;
        r2 = (b2>>16)&255; g2 = (b2>>8)&255; b2&=255;
        r3 = (b3>>16)&255; g3 = (b3>>8)&255; b3&=255;
        r4 = (b4>>16)&255; g4 = (b4>>8)&255; b4&=255;
        y1 = (((b1<<2)+(r1<<1)+g1)>>3);
        y2 = (((b2<<2)+(r2<<1)+g2)>>3);
        y3 = (((b3<<2)+(r3<<1)+g3)>>3);
        y4 = (((b4<<2)+(r4<<1)+g4)>>3);

        r1+=r2+r3+r4; r1>>=2;
        g1+=g2+g3+g4; g1>>=2;
        b1+=b2+b3+b4; b1>>=2;
//        b1+=b4; b1>>=1;
        yt=(y1+y2+y3+y4)>>2;

        if ((ok==255)&&(oj==255)) {ok=g1-yt; oj=r1-yt;}
        j = (int)((r1-yt+oj)/2); k = (g1-yt+ok)/2;
        //if ((ok-k)<-2) { j=123; k-=(ok-k)/1; y1+=(ok-k)/6; y2+=(ok-k)/9; y3-=(ok-k)/9; y4-=(ok-k)/6;}
        if ((oj-j)<-0) { j+=(oj-j)/3; y1+=(oj-j)/6; y2+=(oj-j)/9; y3-=(oj-j)/9; y4-=(oj-j)/6;}
        else
        if ((oj-j)>0) { j-=4; y1+=(oj-j)/6; y2+=(oj-j)/9; y3+=(oj-j)/8; y4+=(oj-j)/6;}
        oj=j;
        ok=k;

        y1&=yjk_mode; y2&=yjk_mode; y3&=yjk_mode; y4&=yjk_mode;
        Interlaced.pixels[offs]  = YJK2RGB(y1,j,k);
        Interlaced.pixels[offs+1]= YJK2RGB(y2,j,k);
        Interlaced.pixels[offs+2]= YJK2RGB(y3,j,k);
        Interlaced.pixels[offs+3]= YJK2RGB(y4,j,k);
}

void CodeYJK(){
        Interlaced.beginDraw();
        Interlaced.loadPixels();
        for (int m=0; m<fullY*2-1;m++){
          oj=255;
          ok=255;

          for (i=0; i<64;i++)
              RGB2YJK(((m<<7)+i)<<2);
        }
        Interlaced.updatePixels();
        Interlaced.endDraw();

}

void SaveYJK(){
        Interlaced.copy(Img, x, y, (int)(dx), (int)(dy), 0, 0, fullX, fullY*2);
        if (apply_shader) Interlaced.filter(filter[shaderNum].shader);
        String yjk_ext=".s";
        if (yjk_mode==240) yjk_ext+="B";
        else  yjk_ext+="C";

        OutputStream outp = createOutput(ImgOut+yjk_ext+"0");
        println("Saving: "+ImgOut+yjk_ext+"0");
        int offs;
        try {
              if (apply_Basic_header){
                    outp.write(0xFE); 
                    outp.write(0x00); outp.write(0x00); 
                    outp.write(0x00); outp.write(0xD4); 
                    outp.write(0x00); outp.write(0x00);
              }
              Interlaced.loadPixels();
              for (int m=0; m<fullY;m++) 
              {
                  ok=255; oj=255;
                  for (i=0; i<64;i++) {
                        offs=((m<<8)+i)<<2;
                        RGB2YJK(offs);
                        y1-=j>>2; if (y1<0) y1=0;
                        y2-=j>>2; if (y2<0) y2=0;
                        y3-=j>>2; if (y3<0) y3=0;
                        y4-=j>>2; if (y4<0) y4=0;

                        y1&=yjk_mode; y2&=yjk_mode; y3&=yjk_mode; y4&=yjk_mode;

                        j>>=3; k>>=3;
                        if (k>31) k-=64;
                        if (j>31) j-=64;
                        y1|=k&7; y2|=(k>>3)&7;
                        y3|=j&7; y4|=(j>>3)&7;

                        outp.write(y1); outp.write(y2); outp.write(y3); outp.write(y4);
                  }
              }
              outp.flush();
              outp.close();
        }
        catch(Exception e) {
              println("Message: " + e);
        }
      
        outp = createOutput(ImgOut+yjk_ext+"1");
        println("Saving: "+ImgOut+yjk_ext+"1");
        try {
              if (apply_Basic_header){
                  outp.write(0xFE); 
                  outp.write(0x00); outp.write(0x00); 
                  outp.write(0x00); outp.write(0xD4); 
                  outp.write(0x00); outp.write(0x00);
              }
              for (int m=0; m<fullY;m++)
              {
                  ok=255; oj=255;
                  for (i=0; i<64;i++) {
                        offs=((m<<8)+i+128)<<2;
                        RGB2YJK(offs);
                        if ((y1&7)>0) y1+=4;
                        if ((y2&7)>0) y2+=4;
                        if ((y3&7)>0) y3+=4;
                        if ((y4&7)>0) y4+=4;
                        if (y1>255) y1=255;
                        if (y2>255) y2=255;
                        if (y3>255) y3=255;
                        if (y4>255) y4=255;

                        y1&=yjk_mode; y2&=yjk_mode; y3&=yjk_mode; y4&=yjk_mode;

                        k2=j&7; 
                        if (k2>0) 
                          if (j<0) j-=3; else j+=3; 
                        k2=k&7; 
                        if (k2>0) 
                          if (k<0) k-=3; else k+=3;
                        
                        k>>=3; j>>=3;
                        if (k>31) k-=64;
                        if (j>31) j-=64;
                        y1|=k&7; y2|=(k>>3)&7;
                        y3|=j&7; y4|=(j>>3)&7;
                        outp.write(y1); outp.write(y2); outp.write(y3); outp.write(y4);
                  }
              }
              outp.flush();
              outp.close();
          }
          catch(Exception e) {
              println("Message: " + e);
          }
          if (apply_Basic_header){
            String code = "10 SCREEN ";
            if (yjk_mode==240) code+="11";
            else code+="12";
            code+=",,,,,2;20 BLOAD"+(char)34+"img.s";
            if (yjk_mode==240) code+="B";
            else code+="C";
            code+="0"+(char)34+",s:SET PAGE1,1:CLS;";
            code+="30 BLOAD"+(char)34+"img.s";
            if (yjk_mode==240) code+="B";
            else code+="C";
            code+="1"+(char)34+",s;40 IFNOTSTRIG(0)GOTO40;50 RUN"+(char)34+"img.bas"+(char)34+";";
            String[] list = split(code, ';');
            saveStrings(ImgOut+".bas",list);
          }
        System.gc();
}

void Render_Info(){
          Screen.beginDraw();
          Screen.blendMode(REPLACE );
          Screen.background(20,25,25);

//          Screen.textFont(font);
          Screen.textSize(15);
          if (color_mode_code==1) color_mode="332 bits (256x212 + 256x424 Screen 8)";
          if (color_mode_code==2) color_mode="443 bits (MSX2 2048 colors)";
          if (color_mode_code==3)
              if (yjk_mode==248) color_mode="YJK MSX2+ (19268 colors)";
              else color_mode="YJK MSX2+ (12499 colors)";
          if (color_mode_code==4) 
              if (!TilesEnabled) color_mode="16 Colors (256x"+fullY+" Screen 5)";
              else              color_mode="16 Colors (256x"+fullY+" Screen 2/4)";
          if (color_mode_code==5) color_mode="16 Colors (512x212 Screen 7)";
          if (color_mode_code==6) color_mode="16 Colors (256x424 Screen 5)";
          if (color_mode_code==7) color_mode="16 Colors (512x424 Screen 7)";
          Screen.fill( 0, 255, 170, 255);
          Screen.text("[F1] TileGen                [F2] Save        [F3] Open         [F4] 212/256", 600,  Screen.height-45);
          Screen.text("[F4] AutoAspect        [F6] Filter       [F7] Mode         [F8] Flicker", 600,  Screen.height-25);
          Screen.text("Shader    [F9] <-      [F10] On/Off      [F11] ->         [F12] Reset Shader", 600,  Screen.height-5);
          Screen.text("Mode:",             20,  995);
          Screen.text("Filter:",           20, 1015);
          Screen.text("Shader:",          200, 1015);
          Screen.text("Coding Mode:",      20, 1035);
          if (color_mode_code>3) Screen.text("Sorting:",         200, 1035);
          Screen.text("Flicker:",          20, 1055);
          Screen.text("Auto Aspect:",      20, 1075);
          Screen.text("X:",               200, 1055);
          Screen.text("Y: ",              200, 1075);
          Screen.text("dx:",              280, 1055);
          Screen.text("dy: ",             280, 1075);
          Screen.text("Scale X: ",        366, 1055);
          Screen.text("Scale Y: ",        366, 1075);
          Screen.fill( 0, 175, 120, 255);
          Screen.text(color_mode,         125,  995);
          if (filter_mode==2)      Screen.text("Nearest",   125, 1015);
          else if (filter_mode==3) Screen.text("Linear",    125, 1015);
          else if (filter_mode==4) Screen.text("Bilinear",  125, 1015);
          else if (filter_mode==5) Screen.text("Trilinear", 125, 1015);
          if (apply_shader) {
                Screen.text(filter[shaderNum].name, 280, 1015);
                if (shaderNum!=5) Screen.text(filter[shaderNum].val,               363, 1015);
                else              Screen.text((int)(filter[shaderNum].val*6600.0), 366, 1015);
          }
          else Screen.text("None",        280, 1015);
    
          if ((coder_mode==1) && (color_mode_code<6)) 
               Screen.text("Flicker",     125, 1035);
          else Screen.text("Interlace",   125, 1035);
          if (color_mode_code>3)
            if (allow_sorting_PAL) Screen.text("Allow",         280, 1035);
            else                   Screen.text("Deny",          280, 1035);

          if (flicker) Screen.text("On",  125, 1055);
          else         Screen.text("Off", 125, 1055);
          
          if (auto_aspect)
                       Screen.text("On",  125, 1075);
          else Screen.text(       "Off",  125, 1075);

          Screen.text(x,                  220, 1055);
          Screen.text(y,                  220, 1075);
          Screen.text((int)dx,            310, 1055);
          Screen.text((int)dy,            310, 1075);
          Screen.text(dx/256,             420, 1055);
          Screen.text(dy/fullY,           420, 1075);

          Screen.fill( 0, 255, 170, 255);
          Screen.text("MSX  PC",                    486, 1015); //566
          Screen.fill( 255, 150, 150);
          Screen.text(":  R",                       542, 1035);
          Screen.text(hex((mouse_clr>>16)&255,2),   520, 1035);
          Screen.text(binary((mouse_clr>>20)&15,4), 482, 1035);
          Screen.fill( 150, 255, 150);
          Screen.text(":  G",                       542, 1055);
          Screen.text(hex((mouse_clr>>8 )&255,2),   520, 1055);
          Screen.text(binary((mouse_clr>>12)&15,4), 482, 1055);
          Screen.fill( 150, 150, 255);
          Screen.text(":  B",                       542, 1075);
          Screen.text(hex((mouse_clr    )&255,2),   520, 1075);
          Screen.text(binary((mouse_clr>> 5)&7,3),  490, 1075);

          Screen.endDraw();
}

void draw() {
          if (keyPressed) need_redraw = true;

          if (need_redraw) {

              if (key_F1) {
                  if (key_SHIFT) { SpritesEnabled ^= true;  TilesEnabled  = false; fullY=256; }
                  else           { SpritesEnabled  = false; TilesEnabled ^= true;  } 
                      color_mode_code=4; 
                      need_redraw = true;
                      fullX=256;
//                      fullY=212;
                      key_F1         = false;
              }

              if (key_PGDOWN) {
                  key_PGDOWN=false;
              }

              if ((key_F8)&&(color_mode_code<3)) {
                  if (color_mode_code<4) flicker     ^= true;
                  key_F8       = false;
              }
          
              if (!flicker) {
                  need_redraw = false;
    
                  if (keyPressed) {
                    need_redraw = true;
                  }

    
                  if ((key_F4)&&(!SpritesEnabled)) {
                      if (fullY==256) { fullY=212; }
                      else  { fullY=256; }
                      if ((color_mode_code==1)||(color_mode_code>4)) { fullY=212; }
                      key_F4      = false;
                  }
    
    
                  if ((old_w != width) || (old_h != height)) {
                      need_redraw = true;
                      old_w=width; 
                      old_h=height;
                  }

                  if ((old_x!=x)||(old_y!=y)||(old_dx!=dx)||(old_dy!=dy)) need_redraw=true;
                  old_x =x;  old_y=y;
                  old_dx=dx; old_dy=dy;
      
                  if (key_SHIFT )  if (Img.width>Img.height) st = Img.width/150; else st = Img.height/150;
                  else {
                    st = 1;
                    blinkXOR=0xFFFFFF;
                  }
      
                  if (key_CTRL) {
                      if (key_RMULT)   {
                          if (Img.width<=Img.height) {
                              x  = 0;
                              y -=(Img.width-dx)/2;
                              dx = Img.width;
                              dy = dx / (256.0/fullY);
                              if (y<0) y=0;
                          } else {
                              y  = 0;
                              x -=(Img.height-dy)/2;
                              dy = Img.height;
                              dx = dy / (fullY/256.0);
                              if (x<0) x=0;
                          }
                          if ((x+dx)>Img.width)  x=(int)(Img.width-dx);
                          if ((y+dy)>Img.height) y=(int)(Img.height-dy);
                      }
                      if (!auto_aspect)   {
                          if ((key_UP)||(key_RMINUS))   {
                            outY=fullY;
                            if (color_mode_code>6) outY<<=1; 
 
                            if ((dy-st)<outY) dy=outY; 
                            else dy -= st;
                          }
                          if ((key_DOWN)||(key_RPLUS)) {
                              if ((y+dy+st)>Img.height)         y -= st;
                              if (y<st)                         y  = 0;
                              dy += st;
                              if ((y==0)&&((y+dy)>=Img.height)) dy  = Img.height;
                          }
                      } else {
                          if ( key_DOWN || key_RMINUS )   {
                              if (fullX<Img.width){
                                  if ((dx-st)<=fullX) dx=fullX; 
                                  else dx -= st;
                                  if (dx>fullX) { x+=st; y+=st;} 
                              }
                          }
                          if ( key_UP || key_RPLUS ) {
                              if (dy!=Img.height){
                                  if (dx<Img.width) { 
                                      if (x>st) x-=st; else x=0;
                                      if (y>st) y-=st; else y=0;
                                  }
                                  if ((x+dx+st)>Img.width)          x -= st;
                                  if (x<st)                         x  = 0;
                                  if ((x+dx+st)<=Img.width)        dx += st;
                                  if ((x==0)&&((Img.width-dx)<st)) dx  = Img.width;
                              }
                          }
                      }
                      if ((key_LEFT )||(key_RMINUS)) {
                          if (fullX<Img.width){
                              if ((dx-st)<=fullX) dx=fullX; 
                              else dx -= st;
                          }
                      }
                      if ((key_RIGHT)||(key_RPLUS)) {
                          if (fullX<Img.width){
                              if ((x+dx+st)>Img.width)              x -= st;
                              if (x<st)                             x  = 0;
                              if ((x+dx+st)<=Img.width)            dx += st;
                              if ((x==0)&&((Img.width-dx)<st))     dx  = Img.width;
                          }
                      }
                  } else {
                      if (key_LEFT)  if (x>=st) x -= st; else   x  = 0;
                      if (key_UP)    if (y>=st) y -= st; else   y  = 0;
                      if (key_RIGHT) if ((x+dx+st)<=Img.width)  x += st; else x  = (int)(Img.width -dx);
                      if (key_DOWN)  if ((y+dy+st)<=Img.height) y += st; else y  = (int)(Img.height-dy);
                  }
      
                  if (auto_aspect) {
                      dy = dx / (256.0/fullY);
                      if ((y+dy)>Img.height)  { y = (int)(Img.height - dy); need_redraw = true;}
                      if (dy>Img.height)      { dy=Img.height; y = 0; dx = dy*(256.0/fullY); need_redraw = true;}
                  }
       
                  if (key_SPACE) {
                      SetCropBorders();
                      key_SPACE    = false;
                  }
      
                  if (key_F2) {
                      if (SpritesEnabled) {
                          ScaleSrc();
                          GetSprites();
                          SaveSprites();
                      } else
                      if (TilesEnabled) {
                          ScaleSrc();
                          GetTiles();
                          SaveTiles();
                      } else
                        if (color_mode_code==3) SaveYJK();
                        else 
                            if (color_mode_code>=4) save_SC57();
                            else {
                                apply_Basic_header = !key_SHIFT;
                                Save_MSX();
                            }
                      key_F2       = false;
                  }
      
                  if (key_F3) {
                      image_sellected = false;
                      selectInput("Select a file to open:", "fileSelected");
                      println("Loaded: "+SourceImage);
                      key_F3       = false;
                  }

                  if (image_sellected) {
                      Open_Image();
                      image_sellected = false;
                      need_redraw     = true;
                  }
      
                  if (key_F5) {
                      auto_aspect ^= true;
                      key_F5       = false;
                  }
          
                  if (key_F6) {
                      filter_mode++;
                      if (filter_mode==6)       filter_mode=2;
                      interpolation(Preview,    filter_mode);
                      interpolation(Interlaced, filter_mode);
                      interpolation(ImgShow,    filter_mode);
                      interpolation(Lens,       filter_mode);
                      key_F6       = false;
                  }
      
                  if (key_F7) {
                      TilesEnabled=false;
                      SpritesEnabled=false;
                      fullX=256;
                      if (key_SHIFT) {
                          color_mode_code--;
                          if ( color_mode_code< 1) color_mode_code=7;
                      } else {
                          color_mode_code++;
                          if ( color_mode_code> 7) color_mode_code=1;
                      }
                      println();
                      println("Mode : "+color_mode_code);
                      if ((color_mode_code==1)||(color_mode_code==5)||(color_mode_code==6)||(color_mode_code==7)) fullY=212;
                      outY=fullY;
                      if ( color_mode_code< 3) coder_mode=color_mode_code-1;
                      if ((color_mode_code==5)||(color_mode_code==7)) {
                            fullX=512;
                            if (dx<512.0) dx=512.0;
                            if (Img.width<512) dx=Img.width;
                            if ((x+dx)>Img.width) x=(int)(Img.width-dx);
                      }
                      if (color_mode_code>5) outY<<=1; 
                      println("Screen: "+fullX+" x "+outY);
                      key_F7       = false;
//                      key_TAB      = false;
                  }
      
                  if (apply_shader==true) {
                      if (key_SHIFT) val=0.025; else val=0.005; 
                      if ((key_RPLUS)&&(!key_CTRL)) {
                          max=filter[shaderNum].val_max;
                          if ((filter[shaderNum].val+val)<max) filter[shaderNum].val+=val;
                          if ((max-filter[shaderNum].val)<val) filter[shaderNum].val=max;
                          filter[shaderNum].shader.set("val",filter[shaderNum].val);
                      }
                      if ((key_RMINUS)&&(!key_CTRL)) {
                          min=filter[shaderNum].val_min;
                          if ((filter[shaderNum].val-val)>min) filter[shaderNum].val-=val;
                          if ((filter[shaderNum].val-val)<min) filter[shaderNum].val=min;
                          filter[shaderNum].shader.set("val",filter[shaderNum].val);
                      }
                      if ((key_RMULT)&&(!key_CTRL)) {
                          filter[shaderNum].val=filter[shaderNum].reset_val;
                          filter[shaderNum].shader.set("val",filter[shaderNum].val);
                          key_RMULT = false;
                      }
                  }

                  if (key_F9 ){
                      if (key_SHIFT) { 
                           Lens.copy(   Img, 0, 0, Img.width, Img.height, 0, 0, lx,        ly);
                           ImgShow.copy(Img, 0, 0, Img.width, Img.height, 0, 0, Img.width, Img.height);
                           ImgShow.filter(filter[shaderNum].shader);
                           Img.copy(ImgShow, 0, 0, Img.width, Img.height, 0, 0, Img.width, Img.height);
                           apply_shader = false; 
                      } else {
                        if (!apply_shader) {
                              apply_shader=true;
                        } else {
                              if (shaderNum>0) shaderNum--;
                              else shaderNum = shaderMax;
                        }
                        filter[shaderNum].shader.set("val", filter[shaderNum].val);
                      }
                      key_F9       = false;
                  }
    
                  if (key_F10 ){
                      apply_shader^= true;
                      if (apply_shader) filter[shaderNum].shader.set("val", filter[shaderNum].val);
                      key_F10      = false;
                  }
    
                  if (key_F11 ){
                      if (key_SHIFT) { 
                           Lens.copy(   Img, 0, 0, Img.width, Img.height, 0, 0, lx,        ly);
                           ImgShow.copy(Img, 0, 0, Img.width, Img.height, 0, 0, Img.width, Img.height);
                           ImgShow.filter(filter[shaderNum].shader);
                           Img.copy(ImgShow, 0, 0, Img.width, Img.height, 0, 0, Img.width, Img.height);
                           apply_shader = false; 
                      } else {
                           if (!apply_shader) {
                                apply_shader=true;
                           } else {
                                shaderNum++;
                                if (shaderNum>shaderMax) { 
                                    shaderNum    = 0; 
                                }
                           }
                           filter[shaderNum].shader.set("val", filter[shaderNum].val);
                      }
                      key_F11       = false;
                  }
                
                  if (key_F12 ){
                      Img=loadImage(SourceImage); 
                      Lens.copy(Img, 0, 0, Img.width, Img.height, 0, 0, lx, ly);
                      need_redraw   = true;
                      key_F12       = false;
                  }
      
                  ScaleSrc();

                  if (TilesEnabled) {
                      GetTiles();
                      ShowGrid(8);
                  }

                  if (SpritesEnabled) {
                      GetSprites();
                      ShowGrid(16);
                  }

                  Render_Info();

              }

              if (key_CTRL){
                if (key_C){
                    for (i=0;i<16;i++) pal_buf[i]=cv[co[i]];
                    key_C=false;
                };
                if ((key_V)&&(customPAL_num>3)){
                    println();
                    print("Paste Palette:  {");
                    
                    for (i=0;i<16;i++){ 
                      customPAL[customPAL_num][i]=pal_buf[i];
                      print("0x"+hex(pal_buf[i],6)); if (i<15) print(",");
                    }
                    println("}");
                    key_V=false;
                };
              } else Render_Info();
              
              
              if ((!key_CTRL)&&(key_RMINUS)){
              }
              if ((!key_CTRL)&&(key_RPLUS)) {
              }
              
              if (key_SHIFT) apply_Basic_header=false; else apply_Basic_header=true;
              
              if (key_TAB) {
                  if (color_mode_code==3) yjk_mode^=8;
                  else {
                    if (!key_SHIFT) {
  //                    if (customPAL_num>0) allow_sorting_PAL^=true;
  //                    allow_sorting_PAL^=true;
                        if (color_mode_code>3) {    // Switch Palette
                            need_redraw = true;
                            if (!CustomPal) CustomPal^=true;
                            else {
                                customPAL_num++;
                                if (customPAL_num>max_customPAL) { customPAL_num=0; CustomPal=false; }
                            }
                        }
                    } else fix_Palette^=true;
                  }
                  need_redraw = true;
                  key_TAB=false;
              }

              outY=848; 
              if (fullY==256) outY=955;
              int frameY=fullY;
              
              if ((color_mode_code>1)&&(color_mode_code<6)&&(color_mode_code!=3)){
              }
              else {
                frameY<<=1;
              }

              ImgPreview.copy(Interlaced, 0, 0, fullX, frameY, 0, 0, fullX, frameY);
              Screen.beginDraw();
              Screen.copy(Lens, 0, 0, Lens.width, Lens.height, 1899-Lens.width, 20, Lens.width, Lens.height);
              Screen.copy(ImgPreview, 0, 0, fullX, frameY, 20, 20, 1024, outY);
               
              Screen.blendMode(BLEND);
              Screen.fill( 0, 0, 0, 50);
/*
              if (mouseOver((x/ldx+1899-lx)*width/1920.0, (20+y/ldy)*width/1920.0, dx/ldx*width/1920.0, dy/ldy*width/1920.0))  {
                  Screen.stroke(255,255,0, 255);
                Screen.rect((x/ldx+1899-lx)*width/1920.0, (20+y/ldy)*width/1920.0, dx/ldx*width/1920.0, dy/ldy*width/1920.0);
                  Screen.stroke(255,0,0, 255);
              } else
*/
              Screen.stroke(255,255,155, 150);
              Screen.rect(x/ldx+1899-lx, 20+y/ldy, dx/ldx, dy/ldy);

              Screen.blendMode(REPLACE );
              if (color_mode_code<3) {
                  Screen.image(P1, 1100, 1080-fullY);
                  Screen.image(P1, 1357, 1080-fullY);
              }

              if (color_mode_code>3) {    // Draw Palette bar
                   Screen.fill( 0, 255, 170, 255);
                   if (CustomPal) { 
                          if (customPAL_num==0) Screen.text("Default MSX1:", 395, outY+42);
                          else if (customPAL_num==1) Screen.text("Default MSX2:", 395, outY+42);
                          else if (customPAL_num==2) Screen.text("SCREEN8 MSX2:", 395, outY+42);
                          else if (customPAL_num==3) Screen.text("Default ZX Spectrum:", 395, outY+42);
                          else  Screen.text("User palette "+(customPAL_num-4)+":", 395, outY+42);
                   } else if (!fix_Palette) Screen.text("Dynamic palette:",395, outY+42);
                          else Screen.text("Fixed palette:",395, outY+42); 
                  Screen.noStroke();
                  for (int t=0; t<16; t++){ 
                   if (CustomPal) 
                        Screen.fill( (customPAL[customPAL_num][co[t]]>>16)&255, (customPAL[customPAL_num][co[t]]>>8)&255, customPAL[customPAL_num][co[t]]&255, 128);
                   else Screen.fill( (cv[co[t]]>>16)&255, (cv[co[t]]>>8)&255, cv[co[t]]&255, 128);
                        Screen.rect(549+t*31, outY+28, 30, 30);
                  }
              }

          }
        
  
          if (flicker) {
              flick^=1;
              Screen.blendMode(REPLACE );
              if (flick==0) Screen.copy(P0, 0, 0, 256, fullY, 20, 20, 1024, outY);
              else          Screen.copy(P1, 0, 0, 256, fullY, 20, 20, 1024, outY);
          } 
          Screen.endDraw();
          if ((flicker)||(need_redraw)) {copy(Screen, 0, 0, 1920,1080, 0,0, width, height); }

          mouse_clr=get(mouseX,mouseY);
          ShowFPS(width-width/8, height-height/48);
}

void ShowFPS(int xpos, int ypos) {
  if ((millis()-tim)>1000) {
    fc+=((frameCount-ofc)/(millis()-tim))*1000; fc/=2;
    if (fc>maxfc) maxfc=fc;
    tim=millis(); ofc=frameCount;
  }
  stroke(0,100,150); fill(20,25,25); rect(xpos,ypos,width-xpos,height-ypos-1);
  textSize(width/120); stroke(1); fill( 255, 255, 0);
  String fps=String.format( "%.2f", fc )+" fps ("+String.format( "%.2f", maxfc )+" max)";
  text( fps, width-fps.length()*(width/180), ypos+width/120+8);
}

void windowResized(){
  need_redraw = true;
}

void keyPressed() {
  if ( keyCode == 97    )    key_F1    = true;
  if ( keyCode == 98    )    key_F2    = true;
  if ( keyCode == 99    )    key_F3    = true;
  if ( keyCode == 100   )    key_F4    = true;
  if ( keyCode == 101   )    key_F5    = true;
  if ( keyCode == 102   )    key_F6    = true;
  if ( keyCode == 103   )    key_F7    = true;
  if ( keyCode == 104   )    key_F8    = true;
  if ( keyCode == 105   )    key_F9    = true;
  if ( keyCode == 106   )    key_F10   = true;
  if ( keyCode == 107   )    key_F11   = true;
  if ( keyCode == 108   )    key_F12   = true;
 
  if ( keyCode == 32    )    key_SPACE = true;
  if ( keyCode == DOWN  )    key_DOWN  = true;
  if ( keyCode == UP    )    key_UP    = true;
  if ( keyCode == RIGHT )    key_RIGHT = true;
  if ( keyCode == LEFT  )    key_LEFT  = true;
  if ( keyCode == 16    )    key_SHIFT = true;
  if ( keyCode == 17    )    key_CTRL  = true;
  if ( keyCode == 45    )    key_MINUS = true;
  if ( keyCode == 61    )    key_PLUS  = true;
  if ( keyCode == 139   )    key_RPLUS = true;
  if ( keyCode == 140   )    key_RMINUS= true;
  if ( keyCode == 141   )    key_RMULT = true;
  if ( keyCode == 147   )    key_DEL   = true;
  if ( keyCode == 11    )    key_PGDOWN= true;
  if ( keyCode == 9     )    key_TAB   = true;
  if ( keyCode == 67    )    key_C     = true;
  if ( keyCode == 86    )    key_V     = true;
//   println(keyCode);
}


void keyReleased() {
  if ( keyCode == 97    )    key_F1    = false;
  if ( keyCode == 98    )    key_F2    = false;
  if ( keyCode == 99    )    key_F3    = false;
  if ( keyCode == 100   )    key_F4    = false;
  if ( keyCode == 101   )    key_F5    = false;
  if ( keyCode == 102   )    key_F6    = false;
  if ( keyCode == 103   )    key_F7    = false;
  if ( keyCode == 104   )    key_F8    = false;
  if ( keyCode == 105   )    key_F9    = false;
  if ( keyCode == 106   )    key_F10   = false;
  if ( keyCode == 107   )    key_F11   = false;
  if ( keyCode == 108   )    key_F12   = false;
  if ( keyCode == 32    )    key_SPACE = false;
  if ( keyCode == DOWN  )    key_DOWN  = false;
  if ( keyCode == UP    )    key_UP    = false;
  if ( keyCode == RIGHT )    key_RIGHT = false;
  if ( keyCode == LEFT  )    key_LEFT  = false;
  if ( keyCode == 16    )    key_SHIFT = false;
  if ( keyCode == 17    )    key_CTRL  = false;
  if ( keyCode == 139   )    key_RPLUS = false;
  if ( keyCode == 140   )    key_RMINUS= false;
  if ( keyCode == 141   )    key_RMULT = false;
  if ( keyCode == 147   )    key_DEL   = false;
  if ( keyCode == 11    )    key_PGDOWN= false;
  if ( keyCode == 9     )    key_TAB   = false;
  if ( keyCode == 67    )    key_C     = false;
  if ( keyCode == 86    )    key_V     = false;
  
}


// Mouse events
void mousePressed() {
    if ( mouseButton == LEFT   ) mouse_LB = true;
    if ( mouseButton == RIGHT  ) mouse_RB = true;
    if ( mouseButton == CENTER ) mouse_MB = true;
}

void mouseReleased() {
    if ( mouseButton == LEFT   ) mouse_LB = false;
    if ( mouseButton == RIGHT  ) mouse_RB = false;
    if ( mouseButton == CENTER ) mouse_MB = false;
}

void mouseWheel( MouseEvent event ) {
  // Resize window if mouse wheel used
  float wheel_dir = event.getCount();
//  if ( osc_Over ) {
    if ( wheel_dir > 0 ) {
    } 
    else {
      }
//  }
}

boolean mouseOver( float x1, float y1, float virt_width1, float virt_height1 )  {
  if (mouseX >= x1 && mouseX <= x1 + virt_width1 && 
      mouseY >= y1 && mouseY <= y1 + virt_height1 ) {
    osc_Over = true;
    return true;
  } else {
    osc_Over = false;
    return false;
  }
}


void mouseDragged() {
  // Drag window if mouse RButton pressed over window
    if ( osc_Over && mouse_RB ) {
//    if ( mouseOver( winX, winY-20, winXW, winYW + 20)  && mouse_RB ) {
    dx = mouseX - x;
    dy = mouseY - y;
    need_redraw=true;
  } 
}
