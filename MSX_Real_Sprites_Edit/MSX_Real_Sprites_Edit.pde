boolean   key_LEFT    =  false, key_RIGHT   =  false, key_UP      =  false, key_DOWN    =  false,
          key_F1      =  false, key_F2      =  false, key_F3      =  false, key_F4      =  false,
          key_F5      =  false, key_F6      =  false, key_F7      =  false, key_F8      =  false,
          key_F9      =  false, key_F10     =  false, key_F11     =  false, key_F12     =  false,
          key_SPACE   =  false, key_SHIFT   =  false, key_CTRL    =  false,
          key_PLUS    =  false, key_MINUS   =  false, key_ESC     =  false,
          key_1       =  false, key_2       =  false, key_3       =  false, key_4       =  false;

boolean   mouse_LB = false, 
          mouse_MB = false, 
          mouse_RB = false,
          Select_Palette = false,
          Enable_embos = true,
          Data_Saved   = true,
          Quit_Select  = false;

PImage    BackImg;

PShader   sprites;
PShader   lens;
PShader   embos;
PShader   back;

// Sprites Data
byte[]      SpritesPAT;
byte[]      SpritesSCT;
byte[]      SpritesPAL;
int[]       Palette;
int[]       PAT;
int[]       SCT;
float[]     SAT;
int         scale;
int         prefix;
int         spr_num;

float[]     dx;
float[]     dy;

// Lens Data
int[]       LPAT;
int[]       LSCT;
float       lx;
float       ly;
int         lscale;
int         sellector;
int         clr;
boolean     overLens;

// FPS Counter Data
int         tim   = 0;
float       fc    = 0;
float       maxfc = 0;
float       ofc   = 0;
PFont       font;

// Other data
int         i     = 0;
int         j     = 0;
int         d     = 0;
byte        k     = 0;
float       xmofs = 0;
float       ymofs = 0;

String      PATFile="spr0pat.bin";
String      SCTFile="spr0sat.bin";
String      PALFile="spr0pal.bin";

String      BackupPAT="spr0pat.old";
String      BackupSCT="spr0sat.old";
String      BackupPAL="spr0pal.old";

void SaveSprites(){
    for (i=0; i<16; i++){
      SpritesPAL[i*2]=byte(((Palette[i]>>17)&112)|((Palette[i]>>5)&7));
      SpritesPAL[i*2+1]=byte((Palette[i]>>13)&7);
    }
    saveBytes(PALFile, SpritesPAL);

  for (i=0; i<8; i++)
    for (k=0; k<4; k++)
      for (j=0; j<16; j++) {
      SpritesSCT[prefix+i*64+k*16+j]=byte((SCT[j+i*16]>>(k<<3))&255);
  }

  saveBytes(SCTFile, SpritesSCT);

  for (i=0; i<32; i++)
    for (j=0; j<16; j++) {
      SpritesPAT[i*64+j+   prefix]=byte((PAT[j+i*16]>> 8)&255);
      SpritesPAT[i*64+j+16+prefix]=byte((PAT[j+i*16]    )&255);
      SpritesPAT[i*64+j+32+prefix]=byte((PAT[j+i*16]>>24)&255);
      SpritesPAT[i*64+j+48+prefix]=byte((PAT[j+i*16]>>16)&255);
  }
    saveBytes(PATFile, SpritesPAT);

    println("Changes saved:");
    println(PATFile);
    println(SCTFile);
    println(PALFile);
    println(" ");
}

void LoadSprites() {
    SpritesPAT  = loadBytes(PATFile);
    SpritesSCT  = loadBytes(SCTFile);
    SpritesPAL  = loadBytes(PALFile);
    saveBytes(BackupPAT, SpritesPAT);
    saveBytes(BackupSCT, SpritesSCT);
    saveBytes(BackupPAL, SpritesPAL);
    println("Original files saved:");
    println(BackupPAT);
    println(BackupSCT);
    println(BackupPAL);
    println(" ");
    prefix=SpritesPAT.length%2048;            // If Basic BSAVEd file, keep header
  
    scale=6;
  
    for (i=0; i<32; i++)
      for (j=0; j<16; j++) {
        PAT[j+i*16]  = (SpritesPAT[i*64+j+   prefix]&255)<<8;
        PAT[j+i*16] |= (SpritesPAT[i*64+j+16+prefix]&255);
        PAT[j+i*16] |= (SpritesPAT[i*64+j+32+prefix]&255)<<24;
        PAT[j+i*16] |= (SpritesPAT[i*64+j+48+prefix]&255)<<16;
    }

    for (i=0; i<8; i++)
      for (k=0; k<4; k++)
        for (j=0; j<16; j++) {
        int dat=(SpritesSCT[i*64+k*16+j+prefix]&255);
        SCT[j+i*16]|=dat<<(k<<3);
    }
  
    for (i=0; i<64; i++) {
      SAT[i*4+0]=i/8*16+30;
      SAT[i*4+1]=(i&7)*16+10;
      SAT[i*4+2]=i*4;
      SAT[i*4+3]=0;
      dx[i]=random(2)-1.0;
      dy[i]=random(2)-1.0;
    }
  
  
    for (i=0; i<16; i++) {
      Palette[i] =((SpritesPAL[i*2  ]&240)*36)<<12;  // R
      Palette[i]|= (SpritesPAL[i*2  ]&  7)*36;       // B
      Palette[i]|=((SpritesPAL[i*2+1]&  7)*36)<<8;   // G
    }
  
    sprites.set("SAT", SAT);
    sprites.set("SCT", SCT);
    sprites.set("PAT", PAT);
    sprites.set("PAL", Palette);
    sprites.set("scale", scale);
    lens.set("PAL", Palette);
    spr_num=0;
}

void Fill_Lens(float lens_x, float lens_y, int scaller) {
int pat1_shft=(spr_num&1)*16;
int pat2_shft=pat1_shft^16;
int sct1_shft=(spr_num&3)*8;
int sct2_shft=((spr_num+1)&3)*8;

  for (i=0; i<16; i++){
    LPAT[i]    = (PAT[ (spr_num    >>1)*16+i]>>pat1_shft)&0xFFFF;
    LSCT[i]    = (SCT[((spr_num&31)>>2)*16+i]>>sct1_shft)&255;
    LPAT[i+16] = (PAT[(((spr_num+1)&63)>>1)*16+i]>>pat2_shft)&0xFFFF;
    LSCT[i+16] = (SCT[(((spr_num+1)&31)>>2)*16+i]>>sct2_shft)&255;
  }

    sellector= 3;                // Sprite Edit Mode (S1 OR S2)     
    lscale   = scaller;          // Lens Scale Factor

    lx       = lens_x;           // Lens X
    ly       = lens_y;           // Lens Y

    lens.set("clr", lx);
    lens.set("lx",lens_x);
    lens.set("ly",lens_y);
    lens.set("scale", lscale);
    lens.set("sellect", sellector);
    lens.set("PAT", LPAT);
    lens.set("SCT", LSCT);
}

void Proceed_Lens() {
  float fx=(mouseX-lx)/lscale;
  float fy=(mouseY-ly)/lscale;
  int mx=int(fx);
  int my=int(fy);
  overLens=false;
  
  if ((fx>-2)&&(fx<18)&&(fy>-1)&&(fy<18)) overLens=true; else Select_Palette=false;

  // Select color
  if ((fx>0)&&(fx<16)&&(fy>17)&&(fy<18)) {
    if (mouse_LB) {
      clr=mx;
      lens.set("clr", clr);
      Select_Palette=false;
    }
    
  // Select Color Palette
    if (mouse_RB) {
      clr=mx;
      lens.set("clr", clr);
      Select_Palette=true;
    }
  }

  // Palette Selector Handler 
    if (Select_Palette){
        lens.set("PAL", Palette);
        sprites.set("PAL", Palette);
        filter(lens);
        strokeWeight(3);
        int p_r=((Palette[clr]>>16)&255)/8;
        int p_g=((Palette[clr]>> 8)&255)/8;
        int p_b=((Palette[clr]    )&255)/8;
        int px=int(lx+(clr-1.0)*lscale);
        int py=int(ly+13*lscale);
        int x=mouseX;
        int y=mouseY;
        int t_rgb=int((7-(y-py)/20)*4.5);
        if (mouse_LB){
            if ((y>py)&&(y<(py+4*lscale))){
              if ((x> px             )&&(x<(px+1.15*lscale)))  p_r=t_rgb;
              if ((x>(px+0.85*lscale))&&(x<(px+2.15*lscale)))  p_g=t_rgb;
              if ((x>(px+1.85*lscale))&&(x<(px+3.00*lscale)))  p_b=t_rgb;
              Palette[clr] =p_r<<19;
              Palette[clr]|=p_g<<11;
              Palette[clr]|=p_b<<3;
            }
        }

        fill(96,96,96);
        rect(px, py-5, 3*lscale, 4*lscale+9, 10);
        stroke(p_r*3,0,0);
        fill(p_r*6,0,0);
        rect(lx+(clr-0.8)*lscale, ly+13*lscale+3, 0.5*lscale, 4*lscale-6, 10);
        stroke(0,p_g*3,0);
        fill(0,p_g*6,0);
        rect(lx+(clr+0.3)*lscale, ly+13*lscale+3, 0.5*lscale, 4*lscale-6, 10);
        stroke(0,0,p_b*3);
        fill(0,0,p_b*6);
        rect(lx+(clr+1.3)*lscale, ly+13*lscale+3, 0.5*lscale, 4*lscale-6, 10);

        stroke(48,48,48);  fill(96,96,96);
        circle(lx+(clr-0.55)*lscale, ly+16*lscale+((7-p_r)*lscale/9.4)-3, 18);
        stroke(48,48,48);  fill(96,96,96);
        circle(lx+(clr+0.55)*lscale, ly+16*lscale+((7-p_g)*lscale/9.4)-3, 18);
        stroke(48,48,48);  fill(96,96,96);
        circle(lx+(clr+1.55)*lscale, ly+16*lscale+((7-p_b)*lscale/9.4)-3, 18);
        strokeWeight(1);
        Data_Saved = false;
        return; 
    }

  //  Drag Lens Window
/*
    if ((mouse_MB)&&((fx<16)&&(fy<16)&&(fx>0)&&(fy>-1))) {
      lx=mouseX-xmofs;
      ly=mouseY-ymofs;
      lens.set("lx", lx);
      lens.set("ly", ly);
  }
*/
  // Set color line
  if ((fx>-2)&&(fx<-1)&&(fy>0)&&(fy<16)) {
    if (mouse_LB) {
      Data_Saved = false;
      if ((sellector&1)>0) {
          LSCT[my]=(LSCT[my]&240)|clr;
          int sct_shft=(spr_num&3)<<3;
          int sct_mask=~(int(0x0F<<sct_shft));
          int spr_ind=((spr_num&28)<<2)+my;
          SCT[spr_ind]&=sct_mask;
          SCT[spr_ind]|=LSCT[my]<<sct_shft;
      }
      if ((spr_num<63)&&((sellector&2)>0)) {
          LSCT[my+16]=(LSCT[my+16]&240)|clr;
          int sct_shft=((spr_num+1)&3)<<3;
          int sct_mask=~(int(0x0F<<sct_shft));
          int spr_ind=(((spr_num+1)&28)<<2)+my;
          SCT[spr_ind]&=sct_mask;
          SCT[spr_ind]|=LSCT[my+16]<<sct_shft;
      }

      lens.set("SCT", LSCT);
      sprites.set("SCT", SCT);
    }
  }

  // Set OR Attribyte
  if ((fx>17)&&(fx<18)&&(fy>0)&&(fy<16)) {
    if (mouse_LB) {
      if ((spr_num<63)&&((sellector&2)>0)) {             // Set OR
          int sct_shft=int(((spr_num+1)&3)<<3);
          int spr_ind=int((((spr_num+1)&28)<<2)+my);
          LSCT[my+16]=LSCT[my+16]|64;
          SCT[spr_ind]|=int(64<<sct_shft);
          Data_Saved = false;
      }

      lens.set("SCT", LSCT);
      sprites.set("SCT", SCT);
    }

    if (mouse_RB) {
      if ((sellector&2)>0) {                             // Clear OR
          int sct_shft=((spr_num+1)&3)<<3;
          int sct_mask=~(int(64<<sct_shft));
          int spr_ind=(((spr_num+1)&28)<<2)+my;
          LSCT[my+16]=LSCT[my+16]&(~0x00000040);
          SCT[spr_ind]&=sct_mask;
          Data_Saved = false;
      }

      lens.set("SCT", LSCT);
      sprites.set("SCT", SCT);
    }
  }


  // Draw Point
  if ((fx>0)&&(fx<16)&&(fy>0)&&(fy<16)) {
    if (mouse_LB) {
        Data_Saved = false;
        if ((sellector&1)>0) {
            int sct_shft=(spr_num&1)<<4;
            int spr_ind=((spr_num&62)<<3)+my;
            LPAT[my]|=(1<<(mx^15));
            PAT[spr_ind]|=(1<<(mx^15))<<sct_shft;
          }

        if ((sellector&2)>0) {
            int sct_shft=((spr_num+1)&1)<<4;
            int spr_ind=(((spr_num+1)&62)<<3)+my;
            LPAT[my+16]|=(1<<(mx^15));
            PAT[spr_ind]|=(1<<(mx^15))<<sct_shft;
        }
    lens.set("PAT", LPAT);
    sprites.set("PAT", PAT);
  }

    // Clear Point
    if (mouse_RB) {
        Data_Saved = false;
        if ((sellector&1)>0) {
            int sct_shft=(spr_num&1)<<4;
            int spr_ind=((spr_num&62)<<3)+my;
            LPAT[my]&=~(1<<(mx^15));
            PAT[spr_ind]&=~int((1<<(mx^15))<<sct_shft);
        }
        if ((sellector&2)>0) {
            int sct_shft=((spr_num+1)&1)<<4;
            int spr_ind=(((spr_num+1)&62)<<3)+my;
            LPAT[my+16]&=~(1<<(mx^15));
            PAT[spr_ind]&=~int((1<<(mx^15))<<sct_shft);
        }
    lens.set("PAT", LPAT);
    sprites.set("PAT", PAT);
    }
  }
  lens.set("sellect", sellector);
  filter(lens);
}

void Sprite_Sellector() {
  float fx=(mouseX)/scale-10;
  float fy=(mouseY)/scale-30;
  int  tmp_num=spr_num;
  
    if ((!overLens)&&(mouse_LB)&&((fx>=0)&&(fx<(8*16))&&(fy>0)&&(fy<(8*16)))) {
      tmp_num=int(int(fy/16)*8+fx/16);
    }

  if (tmp_num!=spr_num) {
      spr_num=tmp_num;   
      Fill_Lens(lx,ly,lscale);
  }

  if (sellector==3) fill(22,22,22);
  else fill(32,32,32);
  stroke(64);
  int bx=spr_num;
  if ((sellector&1)>0) {
    rect((10+(bx & 7)*16)*scale,(30+(bx / 8)*16)*scale,16*scale,16*scale);
  }
  if ((sellector&2)>0) {
    bx=(spr_num+1)&63;
    rect((10+(bx & 7)*16)*scale,(30+(bx / 8)*16)*scale,16*scale,16*scale);
  }
  
}

void setup() {
  frameRate( 960 );
  fullScreen( P3D);
  background(0);

  sprites  = loadShader("Sprites.glsl");
  lens     = loadShader("Lens.glsl");
  embos    = loadShader("embos3.glsl");
  back     = loadShader("back.glsl");

  SpritesPAL = new byte[32];
  PAT = new int[512];
  SCT = new int[128];
  SAT = new float[256];
  dx  = new float[64];
  dy  = new float[64];
  
  Palette=new int[16];
  Palette[ 0]=0x000000; Palette[ 1]=0x000000; Palette[ 2]=0x20D020; Palette[ 3]=0x60FF60;
  Palette[ 4]=0x2020FF; Palette[ 5]=0x4060FF; Palette[ 6]=0xD02020; Palette[ 7]=0x40D0FF;
  Palette[ 8]=0xFF2020; Palette[ 9]=0xFF6060; Palette[10]=0xD0D020; Palette[11]=0xD0D080;
  Palette[12]=0x208020; Palette[13]=0xD040B0; Palette[14]=0xB0B0B0; Palette[15]=0xFFFFFF;
  
  LPAT = new int[32];
  LSCT = new int[32];

  LoadSprites();

  clr      = 3;                // Current color
  Fill_Lens(1000, 270, 40);

  tim = millis();
  stroke(255,0,0);
  fill(   255, 0, 0, 155 );
  font = createFont( "Arial", 200, true );
  textFont( font );
  textAlign( LEFT );

}

void Show_fps() {
  if ((millis()-tim)>1000) {
    fc+=((frameCount-ofc)/(millis()-tim))*1000;
    fc/=2;
    if (fc>maxfc) maxfc=fc;
    tim=millis();
    ofc=frameCount;
  }
  textSize(22);
  fill(   255, 255, 0);
  text( String.format( "%.2f", fc )+" fps ("+String.format( "%.2f", maxfc )+" max)", 40, 1070);
}

void Quit(){
    SaveSprites();
    exit();  
}

void draw() {
  background(15,15,15);
  textSize(36);
  stroke(   255, 255, 255);
  fill(   150, 150, 150,150);
  text( "MSX2 SM2 Sprite Editor v1.0 (alpha)", 600, 70);
  textSize(22);
  fill(   150, 150, 100,200);
  text( "[F1] Edit only left sprite   [F2] Edit only right sprite & OR bit  [F3] Preview sprites sum [F4] Emboss ON/OFF  [F10] Exit", 350, 1070);
  fill(   100, 100, 100,50);
  text( "(C) Dolphin_Soft #101546015", 1600, 1070);

  if (Quit_Select) Quit();
  Sprite_Sellector();

  filter(sprites);
  Proceed_Lens();
  
  if (Enable_embos) filter(embos);
  Show_fps();
/*
  if ((!Data_Saved)&&(key_F2)){
    Data_Saved = true;
    SaveSprites();
  }
*/
}

void mousePressed() {
    if ( mouseButton == LEFT   ) mouse_LB = true;
    if ( mouseButton == RIGHT  ) mouse_RB = true;
    if ( mouseButton == CENTER ) {
      mouse_MB = true;
      float fx=(mouseX-lx)/lscale;
      float fy=(mouseY-ly)/lscale;
      if (((fx<16)&&(fy<16)&&(fx>0)&&(fy>-1))) {
          xmofs=mouseX-lx;
          ymofs=mouseY-ly;
      } else {
      mouse_MB = false;
      }
    }
}

void mouseReleased() {
    if ( mouseButton == LEFT   ) mouse_LB = false;
    if ( mouseButton == RIGHT  ) mouse_RB = false; 
    if ( mouseButton == CENTER ) mouse_MB = false;
}

void keyPressed() {
  if ( keyCode == 97    )    key_F1    = true;
  if ( keyCode == 98    )    key_F2    = true;
  if ( keyCode == 99    )    {
    key_F3    = true;
    for (i=0; i<64; i+=2) {
      SAT[ i   *4+1]=int(((i>>1)&3)*16+10);
      SAT[(i+1)*4+1]=((i>>1)&3)*16+10;
    }
    sprites.set("SAT",SAT);
  }

  if ( keyCode == 100   )    {
    key_F4    = true;
    Enable_embos=!Enable_embos;
  }
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
  if ( keyCode == 27    )   {key_ESC   = true; key=0;}
  if ( keyCode == 49    )    key_1     = true;
  if ( keyCode == 50    )    key_2     = true;
  if ( keyCode == 51    )    key_3     = true;
  if ( keyCode == 52    )    key_4     = true;
// println(keyCode);
  if (key_F1) sellector=1; 
  if (key_F2) sellector=2;
}


void keyReleased() {

  sellector=3;

  if ( keyCode == 97    )    key_F1    = false;
  if ( keyCode == 98    )    key_F2    = false;
  if ( keyCode == 99    )    {
    key_F3    = false;
    for (i=0; i<64; i++) {
      SAT[i*4+1]=(i&7)*16+10;
    }
    sprites.set("SAT",SAT);
  }
  if ( keyCode == 100   )    key_F4    = false;
  if ( keyCode == 101   )    key_F5    = false;
  if ( keyCode == 102   )    key_F6    = false;
  if ( keyCode == 103   )    key_F7    = false;
  if ( keyCode == 104   )    key_F8    = false;
  if ( keyCode == 105   )    key_F9    = false;
  if ( keyCode == 106   )   {key_F10   = false; exit(); }
  if ( keyCode == 107   )    key_F11   = false;
  if ( keyCode == 108   )    key_F12   = false;
  if ( keyCode == 32    )    key_SPACE = false;
  if ( keyCode == DOWN  )    key_DOWN  = false;
  if ( keyCode == UP    )    key_UP    = false;
  if ( keyCode == RIGHT )    key_RIGHT = false;
  if ( keyCode == LEFT  )    key_LEFT  = false;
  if ( keyCode == 16    )    key_SHIFT = false;
  if ( keyCode == 17    )    key_CTRL  = false;
  if ( keyCode == 45    )    key_MINUS = false;
  if ( keyCode == 61    )    key_PLUS  = false;
  if ( keyCode == 27    )   {key_ESC   = false; key=0; Quit_Select=true;}
  if ( keyCode == 49    )    key_1     = false;
  if ( keyCode == 50    )    key_2     = false;
  if ( keyCode == 51    )    key_3     = false;
  if ( keyCode == 52    )    key_4     = false;
}
