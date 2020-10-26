boolean   key_LEFT    =  false, key_RIGHT   =  false, key_UP      =  false, key_DOWN    =  false,
          key_F1      =  false, key_F2      =  false, key_F3      =  false, key_F4      =  false,
          key_F5      =  false, key_F6      =  false, key_F7      =  false, key_F8      =  false,
          key_F9      =  false, key_F10     =  false, key_F11     =  false, key_F12     =  false,
          key_SPACE   =  false, key_SHIFT   =  false, key_CTRL    =  false,
          key_PLUS    =  false, key_MINUS   =  false;

boolean   mouse_LB, mouse_MB, mouse_RB;

PShader   sprites;
PShader   embos;

// Sprites Data
byte[]      SpritesPAT;
byte[]      SpritesSAT;
int[]       Palette;
int[]       PAT;
int[]       SCT;
float[]     SAT;
int         scale;
int         prefix;

float[]     dx;
float[]     dy;

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


void LoadSprites(String PATFile, String SCTFile, int scalling) {
  SpritesPAT  = loadBytes(PATFile);
  SpritesSAT  = loadBytes(SCTFile);
  prefix=SpritesPAT.length%2048;            // Test file offset (for Basic BSAVE files)

  scale=scalling;

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
        int dat=(SpritesSAT[i*64+k*16+j+prefix]&255);
        SCT[j+i*16]|=dat<<(k<<3);
  }

  for (i=0; i<64; i++) {
    SAT[i*4+0]=i/8*17;
    SAT[i*4+1]=(i&7)*17+60;
    SAT[i*4+2]=i*4;
    SAT[i*4+3]=0;
    dx[i]=random(2)-1.0;
    dy[i]=random(2)-1.0;
  }

  sprites.set("SAT", SAT);
  sprites.set("SCT", SCT);
  sprites.set("PAT", PAT);
  sprites.set("scale", scale);
}

void setup() {
  frameRate( 60 );
  fullScreen( P3D);
  background(0);

  sprites  = loadShader("Sprites.glsl");
  embos    = loadShader("embos3.glsl");

  PAT = new int[512];
  SCT = new int[128];
  SAT = new float[256];
  dx  = new float[64];
  dy  = new float[64];

  LoadSprites("spr1pat.bin", "spr1sat.bin", 6);

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
  textSize(38);
  fill(   255, 255, 0);
  text( String.format( "%.2f", fc )+" fps ("+String.format( "%.2f", maxfc )+" max)", 40, 80);
}

void draw() {
  background(0);

  for (i=0; i<64; i++) {
    float t=0;
    t=SAT[i*4+0]+dy[i];
    if ((t>0)&&(t<(1080/scale-16))) SAT[i*4+0]+=dy[i];
    else dy[i]=-dy[i];
    t=SAT[i*4+1]+dx[i];
    if ((t>0)&&(t<(1920/scale-16))) SAT[i*4+1]+=dx[i];
    else dx[i]=-dx[i];
    dy[i]+=0.02;
  }

  sprites.set("SAT", SAT);
  filter(sprites);
  filter(embos);
  Show_fps();
}

void mousePressed() {
    if ( mouseButton == LEFT   ) mouse_LB = true;
    if ( mouseButton == RIGHT  ) {mouse_RB = true; redraw();} 
    if ( mouseButton == CENTER ) mouse_MB = true;
  loop();
}

void mouseReleased() {
    if ( mouseButton == LEFT   ) mouse_LB = false;
    if ( mouseButton == RIGHT  ) mouse_RB = false; 
    if ( mouseButton == CENTER ) mouse_MB = false;
  noLoop();
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
// println(keyCode);
  if (key_F3) loop();
  if (key_F1) noLoop();
}


void keyReleased() {
  if (key_F1) loop();
  if (key_F2) {noLoop();redraw();}
  if (key_F3) noLoop();

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
  if ( keyCode == 45    )    key_MINUS = false;
  if ( keyCode == 61    )    key_PLUS  = false;
}
