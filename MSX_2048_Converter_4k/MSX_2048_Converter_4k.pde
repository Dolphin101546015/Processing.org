////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                                                                //
//  MSX2 Images Converter v3.00 (by Dolphin_Soft #101546015)                                                                      //
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
//  [F2 ] : Save current mode image in MSX2/2+ Basic format with headers ( [SHIFT]+[F2] in Plain Format without headers)          //
//  [F3 ] : Open File Dialog                                                                                                      //
//  [F4 ] : Toogle Height of Output Images (256(*)/212) (Basic able to load images with 212 raws, even files stored with 256)     //
//          Also in Tile Generator switch height 24(*)/32 tile raws                                                               //
//                                                                                                                                //
//  [F5 ] : Toogle Auto Aspect Rate ( On(*) / Off )                                                                               //
//  [F6 ] : Select Interpolation Filter (Point, Linear(*), Bilinear, Trilinear)                                                   //
//  [F8 ] : Preview mode with fast flicker for 256/2048(*) Output Images (3)                                                      //
//  [F7 ] : Switch color mode (256/2048(*)/16M colors/Palette 16c ( 256x212 / 512x212 / 256x424 / 512x424 )) in cycle (1)         //
//          With [SHIFT] - switch backward                                                                                        //
//                                                                                                                                //
//  [F9 ] : Switch backward Shader Filter(2), 1-pass on output surfaces (With SHIFT - apply to Source Image)                      //
//  [F10] : Toogle Shader Filter (Enable/Disable(*))                                                                              //
//  [F11] : Switch forward  Shader Filter(2), 1-pass on output surfaces (With SHIFT - apply to Source Image)                      //
//  [F12] : Reload source image (without reseting sellected options)                                                              //
//                                                                                                                                //
//  [TAB]   : Switch Palette (Dynamic(*) / Custom Fixed)                                                                          //
//  [SHIFT] + [TAB]    : Switch Custom User Palette Sorting (Deny(*) / Allow)                                                     //
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


//                          Custom Palette (16 colors 0xRRGGBB)
static int customPAL[][]={{0x000000,0x000000,0x20C020,0x60E060,0x2020E0,0x4060E0,0xA02020,0x40C0E0,    //  Custom MSX Palette
                           0xE02020,0xE06060,0xC0C020,0xC0C080,0x208020,0xC040A0,0xA0A0A0,0xE0E0E0},
                          {0x000000,0x002020,0x008000,0x20E020,0x0000C0,0x2080E0,0x800000,0x60E0E0,    //  Custom User MSX Palette
                           0xE02020,0xE06040,0xE0A000,0xE0E000,0x006000,0x606060,0xA0A0A0,0xE0E0E0},
                          {0x000000,0x606060,0xA0A0A0,0xE0E0E0,0x600080,0x200040,0x0000A0,0x0000E0,    //  Custom User Palette 2
                           0x008060,0x004020,0x00A000,0x00E000,0x806000,0x402000,0xA00000,0xE00000}};
int         customPAL_num      = 0;                           
int         max_customPAL      = 2;                           
boolean     allow_sorting_PAL  = false;                           

PShader     cut_colors;
PShader     repaint;

int[] cv    = new int[512];
int[] ci    = new int[512];
int[] co    = {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15};
byte[] tnt  = new byte[32*32];
byte[] tct  = new byte[32*32*8];
byte[] tpt  = new byte[32*32*8];
int         ps;
int         num=0; 
int         tmp=0;


float       ScaleY = 0.9;
String      coder;
String      color_mode;
int         filter_mode;
int         coder_mode;
int         flick;
int         color_mode_code;
int         odd, cnt;
int         j, i, c;
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
int         st;
PGraphics   ImgShow;
PGraphics   Screen;
PGraphics   Preview;
PGraphics   Interlaced;
PImage      ImgPreview;
PImage      Img;
PImage      P0;
PImage      P1;
PImage      Lens;
PFont       font;
color       mouse_clr;

boolean     new_image            = true;  
boolean     auto_aspect          = true;  
boolean     need_redraw          = true;
boolean     apply_Basic_header   = true; 
boolean     apply_shader         = false; 
boolean     image_sellected      = false; 
boolean     flicker              = false; 
boolean     doNotRescale         = false; 
boolean     GridEnabled          = false; 
boolean     TilesReady           = false; 
boolean     CustomPal            = false; 
            
boolean     key_LEFT  = false, key_RIGHT = false, key_UP      = false, key_DOWN   = false;
boolean     key_F1    = false, key_F2    = false, key_F3      = false, key_F4     = false;
boolean     key_F5    = false, key_F6    = false, key_F7      = false, key_F8     = false;
boolean     key_F9    = false, key_F10   = false, key_F11     = false, key_F12    = false;
boolean     key_SPACE = false, key_SHIFT = false, key_CTRL    = false, key_RMULT  = false;
boolean     key_PLUS  = false, key_MINUS = false, key_RPLUS   = false, key_RMINUS = false; 
boolean     key_DEL   = false, key_PGDOWN= false, key_TAB     = false;

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
        if (ps<16) {
          for (t=ps; t<16; t++) cv[t]=0;
          ps=16;
        }

        for (t=15; t>0; t--)
           for (i=t-1; i>=0; i--) 
               if (cv[t]<cv[i]) { tmp=cv[t]; cv[t]=cv[i]; cv[i]=tmp;}
               
}

void convertSC57(){
     if (CustomPal){ 
        for (int t=0; t<16; t++) {cv[t]=customPAL[customPAL_num][t]; co[t]=t;}
        for (int t=15; t>0; t--)
           for (i=t-1; i>=0; i--) 
               if (cv[t]<cv[i]) { 
                 tmp=cv[t]; cv[t]=cv[i]; cv[i]=tmp;
                 if ((CustomPal)&&(allow_sorting_PAL)) {
                     tmp=co[t]; co[t]=co[i]; co[i]=tmp;
                 }
               }
     } else buildRange();
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
        if (key_SHIFT) {
            OutFile=ImgOut+".pal";
            OutputStream outp = createOutput(OutFile);
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

void ShowGrid(){
        Interlaced.loadPixels();
        for (j=0; j < 256; j+=8)
          for (i=0; i < 256; i++) {
            Interlaced.pixels[i+j*512]^=0x060606;
            Interlaced.pixels[j+i*512]^=0x060606;
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
                code+=":COLOR=RESTORE;40 BLOAD"+(char)34+"img.s4c"+(char)34+",S,&H2000;50 IF NOTSTRIG(0)GOTO50;60 RUN"+(char)34+"img.bas"+(char)34;
                String[] list = split(code, ';');
                saveStrings(ImgOut+".bas",list);
            }
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
}

void Open_Image() {
        if (Img!=null) g.removeCache(Img);
        if (ImgShow!=null) g.removeCache(ImgShow);
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
        if (Lens!=null) g.removeCache(Lens);
        Lens=createImage(lx, ly, RGB);
        Lens.copy(Img, 0, 0, Img.width, Img.height, 0, 0, lx, ly);
        ScaleSrc();
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

//      frameRate(175);
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
        color_mode_code = 2;
      
        fullX = 256;
        fullY = 212;
        Open_Image();

//      NEAR=2, LINEAR=3, BILINEAR=4, and TRILINEAR=5
        filter_mode = 3;
        interpolation(Screen,  2);
        interpolation(Interlaced,  filter_mode);
        interpolation(ImgShow,     filter_mode);
        interpolation(Preview,     filter_mode);
        ScaleSrc();
}

void ScaleSrc() {
        if ((color_mode_code>5)||(color_mode_code==3)) outY=fullY*2; else outY=fullY;
        Interlaced.beginDraw();
        Interlaced.blendMode(REPLACE );
        Interlaced.copy(Img, x, y, (int)(dx), (int)(dy), 0, 0, fullX, outY);
        if ((dy>outY)&&((y+dy+1)<Img.height)) Interlaced.blend(Img, x, y+1, (int)(dx), (int)(dy), 0, 0, fullX, outY, BLEND );
        Interlaced.endDraw();

        if (apply_shader) Interlaced.filter(filter[shaderNum].shader);
        if (color_mode_code>3) convertSC57();
        if (color_mode_code<3) coder();
        else flicker = false;
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
                  b2&= 0xE0;
                  if (color_mode_code==2) Interlaced.pixels[offs] =(r2<<16)|(g2<<8)|b2;
                  r1 = (r2<<1) & 32; r2 &= 0xE0; r1 += r2; if (r1>255) r1=0xE0;
                  g1 = (g2<<1) & 32; g2 &= 0xE0; g1 += g2; if (g1>255) g1=0xE0;
                  b1 = (b2<<1) & 64; b2 &= 0xC0; b1 += b2; if (b1>255) b1=0xC0;
                  int c1=(r1<<16)|(g1<<8)|b1;
                  int c2=(r2<<16)|(g2<<8)|b2;
                  offs=(j<<8)+i;
                  if (color_mode_code==1) {
                        P0.pixels[offs] = c2;//color(r2,g2,b2);
                        P1.pixels[offs] = c1;//color(r1,g1,b1);
                        int k=(j<<1);
                        Interlaced.pixels[( k   <<9)+i] = c2;//color(r2,g2,b2);
                        Interlaced.pixels[((k+1)<<9)+i] = c1;//color(r1,g1,b1);
                  } else {
                        odd^=1;
                        if (odd==0){
                              P0.pixels[offs] = c2;//color(r2,g2,b2);
                              P1.pixels[offs] = c1;//color(r1,g1,b1);
                        } else {
                              P0.pixels[offs] = c1;//color(r1,g1,b1);
                              P1.pixels[offs] = c2;//color(r2,g2,b2);
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
                    rgb |= (P0.pixels[i] >> 6) & 0x3;
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
                  rgb |= (P1.pixels[i] >> 6) & 0x3;
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
            code+=";20 BLOAD"+(char)34+"img.s80"+(char)34+",s:SET PAGE1,1;30 BLOAD"+(char)34+"img.s81"+(char)34+",s:COLOR=RESTORE;40 IFNOTSTRIG(0)GOTO40;50 RUN"+(char)34+"img.bas"+(char)34+";";
            String[] list = split(code, ';');
            saveStrings(ImgOut+".bas",list);
          }
}

void SaveYJK(){
        OutputStream outp = createOutput(ImgOut+".sC0");
        println("Saving: "+ImgOut+".sC0");
        int y1,y2,y3,y4;
        int r3,g3,b3;
        int r4,g4,b4;
        int j1,k1,j2,k2;
        int offs;
        try {
              if (apply_Basic_header){
                    outp.write(0xFE); 
                    outp.write(0x00); outp.write(0x00); 
                    outp.write(0x00); outp.write(0xD4); 
                    outp.write(0x00); outp.write(0x00);
              }
              Interlaced.loadPixels();
              for (j=0; j<fullY;j++) 
                  for (i=0; i<64;i++) {
                        offs=j*1024+i*4;
                        b1 = Interlaced.pixels[offs];
                        r1 = (b1>>16)&255; g1 = (b1>> 8)&255; b1&= 255;
                        y1 = (((b1<<2)+(r1<<1)+g1)>>3);  //  Laurens Holst's corrected formula
                        b2 = Interlaced.pixels[offs+1];
                        r2 = (b2>>16)&255; g2 = (b2>> 8)&255; b2&= 255;
                        y2 = (((b2<<2)+(r2<<1)+g2)>>3);
                        b3 = Interlaced.pixels[offs+2];
                        r3 = (b3>>16)&255; g3 = (b3>> 8)&255; b3&= 255;
                        y3 = (((b3<<2)+(r3<<1)+g3)>>3);
                        b4 = Interlaced.pixels[offs+3];
                        r4 = (b4>>16)&255; g4 = (b4>> 8)&255; b4&= 255;
                        y4 = (((b4<<2)+(r4<<1)+g4)>>3);

                        r1+=r2+r3+r4; r1>>=2;
                        g1+=g2+g3+g4; g1>>=2;
                        b1+=b2+b3+b4; b1>>=2;
                        j2=((y1+y2+y3+y4)>>2);
                        j1 = (r1-j2); k1 = (g1-j2);

                        y1&=248; y2&=248; y3&=248; y4&=248;

                        j1>>=3; k1>>=3;
                        y1|=k1&7; y2|=(k1>>3)&7;
                        y3|=j1&7; y4|=(j1>>3)&7;

                        outp.write(y1); outp.write(y2); outp.write(y3); outp.write(y4);
                  }
              outp.flush();
              outp.close();
        }
        catch(Exception e) {
              println("Message: " + e);
        }
      
        outp = createOutput(ImgOut+".sC1");
        println("Saving: "+ImgOut+".sC1");
        try {
              if (apply_Basic_header){
                  outp.write(0xFE); 
                  outp.write(0x00); outp.write(0x00); 
                  outp.write(0x00); outp.write(0xD4); 
                  outp.write(0x00); outp.write(0x00);
              }
              for (j=0; j<fullY;j++) 
                  for (i=0; i<64;i++) {
                        offs=j*1024+i*4+512;
                        b1 = Interlaced.pixels[offs];
                        r1 = (b1>>16)&255; g1 = (b1>> 8)&255; b1&= 255;
                        y1 = (((b1<<2)+(r1<<1)+g1)>>3);   //  Laurens Holst's corrected formula
                        b2 = Interlaced.pixels[offs+1];
                        r2 = (b2>>16)&255; g2 = (b2>> 8)&255; b2&= 255;
                        y2 = (((b2<<2)+(r2<<1)+g2)>>3); 
                        b3 = Interlaced.pixels[offs+2];
                        r3 = (b3>>16)&255; g3 = (b3>> 8)&255; b3&= 255;
                        y3 = (((b3<<2)+(r3<<1)+g3)>>3);
                        b4 = Interlaced.pixels[offs+3];
                        r4 = (b4>>16)&255; g4 = (b4>> 8)&255; b4&= 255;
                        y4 = (((b4<<2)+(r4<<1)+g4)>>3);

                        r1+=r2+r3+r4; r1>>=2;
                        g1+=g2+g3+g4; g1>>=2;
                        b1+=b2+b3+b4; b1>>=2;
                        j2=((y1+y2+y3+y4)>>2);
                        j1 = (r1-j2); k1 = (g1-j2);
  
                        if ((y1&7)>0) y1+=8;
                        if ((y2&7)>0) y2+=8;
                        if ((y3&7)>0) y3+=8;
                        if ((y4&7)>0) y4+=8;
                        y1&=248; y2&=248; y3&=248; y4&=248;

                        k2=j1&7; 
                        if (k2>0) 
                          if (j1<0) j1-=3; else j1+=3; 
                        k2=k1&7; 
                        if (k2>0) 
                          if (k1<0) k1-=3; else k1+=3;
                        
                        k1>>=3; j1>>=3;
                        y1|=k1&7; y2|=(k1>>3)&7;
                        y3|=j1&7; y4|=(j1>>3)&7;

                        outp.write(y1); outp.write(y2); outp.write(y3); outp.write(y4);
                  }
              outp.flush();
              outp.close();
          }
          catch(Exception e) {
              println("Message: " + e);
          }
          if (apply_Basic_header){
            String code = "10 SCREEN 12,,,,,2;20 BLOAD"+(char)34+"img.sC0"+(char)34+",s:SET PAGE1,1:CLS;";
            code+="30 BLOAD"+(char)34+"img.sC1"+(char)34+",s;40 IFNOTSTRIG(0)GOTO40;50 RUN"+(char)34+"img.bas"+(char)34+";";
            String[] list = split(code, ';');
            saveStrings(ImgOut+".bas",list);
          }
}

void Render_Info(){
          Screen.beginDraw();
          Screen.blendMode(REPLACE );
          Screen.background(20,25,25);

//          Screen.textFont(font);
          Screen.textSize(15);
          if (color_mode_code==1) color_mode="332 bits (256x212 + 256x424 Screen 8)";
          if (color_mode_code==2) color_mode="443 bits (MSX2 2048 colors)";
          if (color_mode_code==3) color_mode="16M preview (MSX2+ YJK Output)";
          if (color_mode_code==4) 
              if (!GridEnabled) color_mode="16 Colors (256x"+fullY+" Screen 5)";
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
                      GridEnabled   ^= true; 
                      color_mode_code=4; 
//                      TilesReady     = false; 
                      need_redraw = true;
                      fullX=256;
                      fullY=212;
                      key_F1         = false;
              }

              if ((key_F8)&&(color_mode_code<3)) {
                  if (color_mode_code<4) flicker     ^= true;
                  key_F8       = false;
              }
          
                  if (key_PGDOWN) {
                    key_PGDOWN=false;
                  }

              if (!flicker) {
                  need_redraw = false;
    
                  if (keyPressed) {
                    need_redraw = true;
                  }

    
                  if (key_F4) {
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
                  else             st = 1;
      
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
                            if ((dy-st)<fullY) dy=fullY; 
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
                      if (GridEnabled) {
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
                      key_F6       = false;
                  }
      
                  if (key_F7) {
                      GridEnabled=false;
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
                            if ((x+dx)>Img.width) x=(int)(Img.width-dx);
                      }
                      if (color_mode_code>5) outY<<=1; 
                      println("Screen: "+fullX+" x "+outY);
                      key_F7       = false;
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

                  if (GridEnabled) {
                      GetTiles();
                      ShowGrid();
                  }

                  Render_Info();

              }
              if (key_SHIFT) apply_Basic_header=false; else apply_Basic_header=true;
              
              if (key_TAB) {
                  if (key_SHIFT) {
                    if (customPAL_num>0) allow_sorting_PAL^=true;
                  } else
                      if (color_mode_code>3) {    // Switch Palette
                          need_redraw = true;
                          if (!CustomPal) CustomPal^=true;
                          else {
                              customPAL_num++;
                              if (customPAL_num>max_customPAL) { customPAL_num=0; CustomPal=false; }
                          }
                      }
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
              Screen.fill( 0, 0, 0, 128);
              Screen.stroke(255,155,155, 100);
              Screen.rect(x/ldx+1899-lx, 20+y/ldy, dx/ldx, dy/ldy);
              Screen.blendMode(REPLACE );
              if (color_mode_code<3) {
                  Screen.image(P1, 1100, 1080-fullY);
                  Screen.image(P1, 1357, 1080-fullY);
              }

              if (color_mode_code>3) {    // Draw Palette bar
                   Screen.fill( 0, 255, 170, 255);
                  //Screen.stroke(255,215,255, 0);
                   if (CustomPal) { 
                          if (customPAL_num==0) Screen.text("Custom palette MSX:", 395, outY+42);
                          else  Screen.text("Custom palette User "+(customPAL_num-1)+":", 395, outY+42);
                   } else Screen.text("Dynamic palette:",395, outY+42);
                  Screen.noStroke();
                  for (int t=0; t<16; t++){ 
                   if (CustomPal) Screen.fill( (customPAL[customPAL_num][co[t]]>>16)&255, (customPAL[customPAL_num][co[t]]>>8)&255, customPAL[customPAL_num][co[t]]&255, 128);
                   else Screen.fill( (cv[t]>>16)&255, (cv[t]>>8)&255, cv[t]&255, 128);
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
 //  println(keyCode);
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
  
}
