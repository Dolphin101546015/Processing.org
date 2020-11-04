boolean   key_LEFT    =  false, key_RIGHT   =  false, key_UP      =  false, key_DOWN    =  false,
          key_F1      =  false, key_F2      =  false, key_F3      =  false, key_F4      =  false,
          key_F5      =  false, key_F6      =  false, key_F7      =  false, key_F8      =  false,
          key_F9      =  false, key_F10     =  false, key_F11     =  false, key_F12     =  false,
          key_SPACE   =  false, key_SHIFT   =  false, key_CTRL    =  false,
          key_PLUS    =  false, key_MINUS   =  false, key_ESC     =  false, key_DEL     =  false,
          key_1       =  false, key_2       =  false, key_3       =  false, key_4       =  false;

boolean   mouse_LB = false, 
          mouse_MB = false, 
          mouse_RB = false,
          Select_Palette = false,
          Enable_emboss  = true,
          Data_Saved     = true,
          Quit_Select    = false,
          Edit_Mode      = false,
          Window_Drag    = false;

PShader   sprites;
PShader   lens;
PShader   emboss;

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
int         clr_l;
int         clr_r;
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
      SAT[i*4+2]=i*4;
      SAT[i*4+3]=0;
      dx[i]=random(2)-1.0;
      dy[i]=random(2)-1.0;
    }
  
    if (Edit_Mode) 
       for (i=0; i<64; i+=2) {
          SAT[ i   *4+1]=int(((i>>1)&3)*16+10);
          SAT[(i+1)*4+1]=((i>>1)&3)*16+10;
       } else for (i=0; i<64; i++) SAT[i*4+1]=(i&7)*16+10;
  
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

    lscale   = scaller;          // Lens Scale Factor

    lx       = lens_x;           // Lens X
    ly       = lens_y;           // Lens Y

    lens.set("clr_l", clr_l);
    lens.set("clr_r", clr_r);
    lens.set("lx",lens_x);
    lens.set("ly",lens_y);
    lens.set("scale", lscale);
    lens.set("PAT", LPAT);
    lens.set("SCT", LSCT);
}

void Proceed_Lens() {
  float fx=(mouseX-lx)/lscale;
  float fy=(mouseY-ly)/lscale;
  int mx=int(fx);
  int my=int(fy);
  overLens=false;

  //  Drag Pattern with Mouse

    if ((key_SHIFT)&&(mouse_MB)) {
      int dmx=int(mouseX-lx-xmofs);
      int dmy=int(mouseY-ly-ymofs);
      int sct_shft=0;
      int spr_ind=0;
      int dx=int(dmx/lscale)&15;
      int dy=int(dmy/lscale)&15;
      int ddat=0;

      for (i=0; i<16; i++){
              if ((sellector&1)>0) {
                  sct_shft=(spr_num&1)<<4;
                  spr_ind=((spr_num&62)<<3);
                  ddat=(PAT[spr_ind+((i-dy)&15)]>>sct_shft)&0xFFFF;
                  LPAT[i]=((ddat>>dx)|(ddat<<(16-dx)))&0xFFFF;
              }
              if ((sellector&2)>0) {
                  sct_shft=((spr_num+1)&1)<<4;
                  spr_ind=(((spr_num+1)&62)<<3);
                  ddat=(PAT[spr_ind+((i-dy)&15)]>>sct_shft)&0xFFFF;
                  LPAT[i+16]=((ddat>>dx)|(ddat<<(16-dx)))&0xFFFF;
              }
      }
      
       lens.set("PAT", LPAT);
       filter(lens);
       return;
    }

  // Patterns Roll with keys 
  if (key_RIGHT) {
       int sct_shft=0;
       int spr_ind=0;
       for (i=0; i<16; i++){
              if ((sellector&1)>0) {
                  sct_shft=(spr_num&1)<<4;
                  spr_ind=((spr_num&62)<<3)+i;
                  LPAT[i]=((LPAT[i]>>1)|((LPAT[i]&1)<<15))&0xFFFF;
                  PAT[spr_ind]&=~(0xFFFF<<sct_shft);
                  PAT[spr_ind]|=(LPAT[i]<<sct_shft);
              }
              if ((sellector&2)>0) {
                  sct_shft=((spr_num+1)&1)<<4;
                  spr_ind=(((spr_num+1)&62)<<3)+i;
                  LPAT[i+16]=((LPAT[i+16]>>1)|((LPAT[i+16]&1)<<15))&0xFFFF;
                  PAT[spr_ind]&=~(0xFFFF<<sct_shft);
                  PAT[spr_ind]|=(LPAT[i+16]<<sct_shft);
              }
           }
       sprites.set("PAT", PAT);
       lens.set("PAT", LPAT);
       key_RIGHT=false;
  }

  if (key_LEFT) {
       int sct_shft=0;
       int spr_ind=0;
       for (i=0; i<16; i++){
              if ((sellector&1)>0) {
                  sct_shft=(spr_num&1)<<4;
                  spr_ind=((spr_num&62)<<3)+i;
                  LPAT[i]=((LPAT[i]<<1)|((LPAT[i]&0x8000)>>15))&0xFFFF;
                  PAT[spr_ind]&=~(0xFFFF<<sct_shft);
                  PAT[spr_ind]|=(LPAT[i]<<sct_shft);
              }
              if ((sellector&2)>0) {
                  sct_shft=((spr_num+1)&1)<<4;
                  spr_ind=(((spr_num+1)&62)<<3)+i;
                  LPAT[i+16]=((LPAT[i+16]<<1)|((LPAT[i+16]&0x8000)>>15))&0xFFFF;
                  PAT[spr_ind]&=~(0xFFFF<<sct_shft);
                  PAT[spr_ind]|=(LPAT[i+16]<<sct_shft);
              }
           }
       sprites.set("PAT", PAT);
       lens.set("PAT", LPAT);
       key_LEFT=false;
  }
  if (key_UP) {
       int sct_shft=0;
       int spr_ind=0;
       int tmp1=LPAT[0];
       int tmp2=LPAT[16];
       for (i=0; i<15; i++){
              if ((sellector&1)>0) {
                  sct_shft=(spr_num&1)<<4;
                  spr_ind=((spr_num&62)<<3)+i;
                  LPAT[i]=LPAT[i+1];
                  LSCT[i]=LSCT[i+1];
                  PAT[spr_ind]&=~(0xFFFF<<sct_shft);
                  PAT[spr_ind]|=(LPAT[i]<<sct_shft);
              }
              if ((sellector&2)>0) {
                  sct_shft=((spr_num+1)&1)<<4;
                  spr_ind=(((spr_num+1)&62)<<3)+i;
                  LPAT[i+16]=LPAT[i+17];
                  LSCT[i+16]=LSCT[i+17];
                  PAT[spr_ind]&=~(0xFFFF<<sct_shft);
                  PAT[spr_ind]|=(LPAT[i+16]<<sct_shft);
              }
           }

     if ((sellector&1)>0) {
       sct_shft=(spr_num&1)<<4;
       spr_ind=((spr_num&62)<<3)+15;
       LPAT[15]=tmp1;
       PAT[spr_ind]&=~(0xFFFF<<sct_shft);
       PAT[spr_ind]|=(tmp1<<sct_shft);
     }
     if ((sellector&2)>0) {
       sct_shft=((spr_num+1)&1)<<4;
       spr_ind=(((spr_num+1)&62)<<3)+15;
       LPAT[31]=tmp2;
       PAT[spr_ind]&=~(0xFFFF<<sct_shft);
       PAT[spr_ind]|=(tmp2<<sct_shft);
     }

       sprites.set("PAT", PAT);
       lens.set("PAT", LPAT);
       key_UP=false;
  }
  
  if (key_DOWN) {
       int sct_shft=0;
       int spr_ind=0;
       int tmp1=LPAT[15];
       int tmp2=LPAT[31];
       for (i=15; i>0; i--){
              if ((sellector&1)>0) {
                  sct_shft=(spr_num&1)<<4;
                  spr_ind=((spr_num&62)<<3)+i;
                  LPAT[i]=LPAT[i-1];
                  PAT[spr_ind]&=~(0xFFFF<<sct_shft);
                  PAT[spr_ind]|=(LPAT[i]<<sct_shft);
              }
              if ((sellector&2)>0) {
                  sct_shft=((spr_num+1)&1)<<4;
                  spr_ind=(((spr_num+1)&62)<<3)+i;
                  LPAT[i+16]=LPAT[i+15];
                  PAT[spr_ind]&=~(0xFFFF<<sct_shft);
                  PAT[spr_ind]|=(LPAT[i+16]<<sct_shft);
              }
           }

     if ((sellector&1)>0) {
       sct_shft=(spr_num&1)<<4;
       spr_ind=((spr_num&62)<<3);
       LPAT[0]=tmp1;
       PAT[spr_ind]&=~(0xFFFF<<sct_shft);
       PAT[spr_ind]|=(tmp1<<sct_shft);
     }
     if ((sellector&2)>0) {
       sct_shft=((spr_num+1)&1)<<4;
       spr_ind=(((spr_num+1)&62)<<3);
       LPAT[16]=tmp2;
       PAT[spr_ind]&=~(0xFFFF<<sct_shft);
       PAT[spr_ind]|=(tmp2<<sct_shft);
     }
       sprites.set("PAT", PAT);
       lens.set("PAT", LPAT);
       key_DOWN=false;
  }
  

  
  if ((fx>-2)&&(fx<18)&&(fy>-1)&&(fy<18)) overLens=true; else Select_Palette=false;

  // Select color
  if ((fx>0)&&(fx<16)&&(fy>17)&&(fy<18)) {
    if (mouse_LB) {
      if ((sellector&1)>0) {
          clr_l=mx;
          lens.set("clr_l", clr_l);
      }
      if ((sellector&2)>0) {
          clr_r=mx;
          lens.set("clr_r", clr_r);
      }
      Select_Palette=false;
    }
    
  // Select Color Palette
    if (mouse_RB) {
      if ((sellector&1)>0) {
          clr_l=mx;
          lens.set("clr_l", clr_l);
      }
      if ((sellector&2)>0) {
          clr_r=mx;
          lens.set("clr_r", clr_r);
      }
      Select_Palette=true;
    }
  }

  // Palette Selector Handler 
    if (Select_Palette){
        lens.set("PAL", Palette);
        sprites.set("PAL", Palette);
        filter(lens);
        strokeWeight(3);
        int clr=0;
        if ((sellector&1)>0) clr=clr_l;
        if ((sellector&2)>0) clr=clr_r;
        
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
      // Draw Pal Selector Control
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

    if ((mouse_MB)&&((fx<16)&&(fy<16)&&(fx>0)&&(fy>-1))) {
      Window_Drag    = true;
      lx=mouseX-xmofs;
      ly=mouseY-ymofs;
      lens.set("lx", lx);
      lens.set("ly", ly);
  }

  // Set color line
  if ((fx>-2)&&(fx<-1)&&(fy>0)&&(fy<16)) {
    if (mouse_LB) {
      Data_Saved = false;
      if ((sellector&1)>0) {
          LSCT[my]=(LSCT[my]&240)|clr_l;
          int sct_shft=(spr_num&3)<<3;
          int sct_mask=~(int(0x0F<<sct_shft));
          int spr_ind=((spr_num&28)<<2)+my;
          SCT[spr_ind]&=sct_mask;
          SCT[spr_ind]|=LSCT[my]<<sct_shft;
      }
      if ((spr_num<63)&&((sellector&2)>0)) {
          LSCT[my+16]=(LSCT[my+16]&240)|clr_r;
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
  int  chk_x=0;
  
  if (Edit_Mode) chk_x=4; else chk_x=8;
    if ((!overLens)&&(mouse_LB)&&((fx>=0)&&(fx<(chk_x*16))&&(fy>0)&&(fy<(8*16)))) {
      tmp_num=int(int(fy/16)*chk_x+fx/16);
      if (Edit_Mode) tmp_num<<=1;
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
    rect((10+(bx & 7)*(chk_x<<1))*scale,(30+(bx / 8)*16)*scale,16*scale,16*scale);
  }
  if ((sellector&2)>0) {
    if (!Edit_Mode) bx=(spr_num+1)&63;
    rect((10+(bx & 7)*(chk_x<<1))*scale,(30+(bx / 8)*16)*scale,16*scale,16*scale);
  }
  
}

void setup() {
  frameRate( 960 );
  fullScreen( P3D);
  background(0);

  sprites  = loadShader("Sprites.glsl");
  lens     = loadShader("Lens.glsl");
  emboss   = loadShader("embos3.glsl");

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

  clr_l     = 3;                // Current color
  clr_r     = 3;                // Current color
  sellector = 3;                // Sprite Edit Mode (S1 OR S2)     
  lens.set("sellect", sellector);
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
  textSize(18);
  fill(   255, 255, 0);
  text( String.format( "%.2f", fc )+" fps ("+String.format( "%.2f", maxfc )+" max)", 40, 30);
}

void Quit(){
    SaveSprites();
    exit();  
}

void DrawText() {
  fill(   250, 250, 200,255);
  text( "[F1]",      1000, 290);
  text( "[F2]",      1000, 330);
  text( "[F3]",      1000, 370);
  text( "[F4]",      1000, 410);
  text( "[F5]",      1000, 450);
  text( "[H]",       1000, 490);
  text( "[V]",       1000, 530);
  text( "[DEL]",     1000, 570);
  text( "[UP]",      1000, 610);
  text( "[RIGHT]",   1000, 650);
  text( "[DOWN]",    1000, 690);
  text( "[LEFT]",    1000, 730);
  text( "[Mouse LB]",1000, 770);
  text( "[Mouse RB]",1000, 810);
  text( "[Mouse MB]",1000, 850);

  text( "[F10]",1000, 890);
  text( "[ESC]",1350, 890);
  fill(   150, 150, 100,200);
  text( "- Edit left",       1150, 290);
  text( "- Edit right & OR", 1150, 330);
  text( "- Mode switch",     1150, 370);
  text( "- Emboss",          1150, 410);
  text( "- Scale",           1150, 450);
  text( "- Flip Horizontal", 1150, 490);
  text( "- Flip Vertical",   1150, 530);
  text( "- Clear Pattern",   1150, 570);
  text( "- Roll Pattern UP", 1150, 610);
  text( "- ... RIGHT",       1150, 650);
  text( "- ... DOWN",        1150, 690);
  text( "- ... LEFT",        1150, 730);
  text( "- Draw / Select",   1150, 770);
  text( "- Erase / Edit Palette",1150, 810);
  text( "- Drag window / + [SHIFT] - ... Pattern",1150, 850);
  text( "- Exit w/o saving", 1150, 890);
  text( "- Exit & save",     1450, 890);

}

void draw() {
  background(25,25,25);
  textSize(36);
  stroke(   255, 255, 255);
  fill(   50, 250, 170,150);
  text( "MSX2 SM2 Sprite Editor v2.0 (final)", 650, 70);
  fill(   100, 100, 100,50);
  textSize(22);
  text( "(C) Dolphin_Soft #101546015", 1600, 1070);
  if (Window_Drag) DrawText();

  if (Quit_Select) Quit();
  Sprite_Sellector();

  filter(sprites);
  Proceed_Lens();
  
  if (Enable_emboss) filter(emboss);
  Show_fps();
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
    if ( mouseButton == CENTER ) {
      mouse_MB = false;
      if (key_SHIFT){
              int sct_shft=0;
              int spr_ind=0;
              for (i=0; i<16; i++){
                      if ((sellector&1)>0) {
                          sct_shft=(spr_num&1)<<4;
                          spr_ind=((spr_num&62)<<3);
                          PAT[spr_ind+i]&=~(0xFFFF<<sct_shft);
                          PAT[spr_ind+i]|=LPAT[i]<<sct_shft;
                      }
                      if ((sellector&2)>0) {
                          sct_shft=((spr_num+1)&1)<<4;
                          spr_ind=(((spr_num+1)&62)<<3);
                          PAT[spr_ind+i]&=~(0xFFFF<<sct_shft);
                          PAT[spr_ind+i]|=LPAT[i+16]<<sct_shft;
                      }
               }
               sprites.set("PAT", PAT);
      }

  }
}

void keyPressed() {
  if ( keyCode == 97    ) {
    key_F1    = true;
    sellector^=2;
  }
  if ( keyCode == 98    ) {
    key_F2    = true;
    sellector^=1;
  }
  if ( keyCode == 99    )    {
    key_F3    = true;
    Edit_Mode=!Edit_Mode;
    if (Edit_Mode) 
       for (i=0; i<64; i+=2) {
          SAT[ i   *4+1]=int(((i>>1)&3)*16+10);
          SAT[(i+1)*4+1]=((i>>1)&3)*16+10;
       } else for (i=0; i<64; i++) SAT[i*4+1]=(i&7)*16+10;
    sprites.set("SAT",SAT);
  }

  if ( keyCode == 100   )    {
    key_F4    = true;
    Enable_emboss=!Enable_emboss;
  }

  if ( keyCode == 101   )    {
    key_F5    = true;
    scale^=2;
    sprites.set("scale",scale);
  }

  // Flip Horisontal [H]
  if ( keyCode ==  72   )   {
       int bt=0;
       for (k=0; k<16; k++){
           for (i=0; i<16; i++){
              if ((sellector&1)>0) {
                  int sct_shft=(spr_num&1)<<4;
                  int spr_ind=((spr_num&62)<<3)+k;
                  bt=(LPAT[k]>>(i^15))&1;
                  PAT[spr_ind]&=~((1<<i)<<sct_shft);
                  PAT[spr_ind]|=((bt<<i)<<sct_shft);
              }
              if ((sellector&2)>0) {
                  int sct_shft=((spr_num+1)&1)<<4;
                  int spr_ind=(((spr_num+1)&62)<<3)+k;
                  bt=(LPAT[k+16]>>(i^15))&1;
                  PAT[spr_ind]&=~((1<<i)<<sct_shft);
                  PAT[spr_ind]|=((bt<<i)<<sct_shft);
              }
           }
       }
       sprites.set("PAT", PAT);
       Fill_Lens(lx,ly,lscale);
  }
 // Flip Vertical [V]
  if ( keyCode ==  86   )   {
           for (i=0; i<16; i++) {
              if ((sellector&1)>0) {
                  int sct_shft=(spr_num&1)<<4;
                  int spr_ind=((spr_num&62)<<3)+i;
                  PAT[spr_ind]&=~(0xFFFF<<sct_shft);
                  PAT[spr_ind]|=LPAT[i^15]<<sct_shft;
              }
              if ((sellector&2)>0) {
                  int sct_shft=((spr_num+1)&1)<<4;
                  int spr_ind=(((spr_num+1)&62)<<3)+i;
                  PAT[spr_ind]&=~(0xFFFF<<sct_shft);
                  PAT[spr_ind]|=LPAT[(i^15)+16]<<sct_shft;
              }
       }
       sprites.set("PAT", PAT);
       Fill_Lens(lx,ly,lscale);
  }

  if ( keyCode == 102   )    key_F6    = true;
  if ( keyCode == 103   )    key_F7    = true;
  if ( keyCode == 104   )    key_F8    = true;
  if ( keyCode == 105   )    key_F9    = true;
  if ( keyCode == 106   )    key_F10   = true;
  if ( keyCode == 107   )    key_F11   = true;
  if ( keyCode == 108   )    key_F12   = true;
  if ( keyCode ==  32   )    key_SPACE = true;
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
  if ( keyCode == 147   )    {
    key_DEL   = true;
              int sct_shft=0;
              int spr_ind=0;
              for (i=0; i<16; i++){
                      if ((sellector&1)>0) {
                          sct_shft=(spr_num&1)<<4;
                          spr_ind=((spr_num&62)<<3);
                          PAT[spr_ind+i]&=~(0xFFFF<<sct_shft);
                          LPAT[i]=0;
                      }
                      if ((sellector&2)>0) {
                          sct_shft=((spr_num+1)&1)<<4;
                          spr_ind=(((spr_num+1)&62)<<3);
                          PAT[spr_ind+i]&=~(0xFFFF<<sct_shft);
                          LPAT[i+16]=0;
                      }
               }
               sprites.set("PAT", PAT);
               lens.set("PAT", LPAT);
  }
// println(keyCode);
}


void keyReleased() {
  if ( keyCode == 97    ) {
    key_F1    = false;
    sellector^=2;
  }
  if ( keyCode == 98    ) {
    key_F2    = false;
    sellector^=1;
  }
  if ( keyCode == 99    )    key_F3    = false;
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
  if ( keyCode == 147   )    key_DEL   = false;
}
