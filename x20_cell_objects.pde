
void loadSprites() {
  MIRRORCELL.img = loadImage(location+"mirror.png");
  MIRRORCELL.bgimg = loadImage(location+"mirror_bg.png");
  PRISMCELL.img = loadImage(location+"prism.png");
  PRISMCELL.bgimg = loadImage(location+"mirror_bg.png");
  ANYEXPECTORCELL.bgimg = loadImage(location+"mirror_bg.png");
  ANYEXPECTORCELL.img = loadImage(location+"expector.png");
  ANYEXPECTORCELL.arrowImg = loadImage(location+"arrow-target.png");
  ANYEXPECTORCELL.gearImg = loadImage(location+"expector-gear.png");
  ANYEXPECTORCELL.successImg = loadImage(location+"expector-success.png");
  ANYEXPECTORCELL.failImg = loadImage(location+"expector-fail.png");
  WALLCELL.bgimg = loadImage(location+"wall-v2-bg.png");
  WALLCELL.img = loadImage(location+"wall-v2-fg.png");
  EMITTERCELL.bgimg = loadImage(location+"mirror_bg.png");
  EMITTERCELL.img = loadImage(location+"emitter.png");
}

abstract class SpriteCell extends ICellObject {
  PImage img;
  PImage bgimg;

  void drawFg(int x, int y, int h, int w, int dir) {
    if (img != null)
      drawImg(img, x, y, h, w, DIR.angle(dir));
  };

  void drawBg(int x, int y, int h, int w, int dir) {
    if (bgimg != null)
      drawImg(bgimg, x, y, h, w, 0);
  };
  
  void drawImg(PImage im, int x, int y, int h, int w, float a) {
    float hh = .5 * (float)h;
    float hw = .5 * (float)w;
    
    pushMatrix();
    translate(hw + (float)x, hh + (float)y);
    rotate(a);
    translate(-hw, -hh);
    image(im, 0, 0, h, w);
    popMatrix();
  }
}

class EmitterCell extends SpriteCell {
  {isTurnable = true;}
  
  void update(ICell cell) {
    cell.setEmit(cell.getDir(), LIGHT);
  };
}

EmitterCell EMITTERCELL = new EmitterCell();

class WallCell extends SpriteCell {
  void update(ICell cell) {
  };
  void drawFg(int x, int y, int h, int w, int dir) {
    if (img != null)
      drawImg(img, x, y, h, w, 0);
  };
}

WallCell WALLCELL = new WallCell();

class MirrorCell extends SpriteCell {
  {isTurnable = true;}
  {isWithFlare = true;}
  
  void update(ICell cell) {
    reflect(cell, cell.getDir());
    reflect(cell, DIR.reverse(cell.getDir()));
  };
  
  void drawBg(int x, int y, int h, int w) {};
  
  void reflect(ICell cell, int nDir) {
    int d1 = DIR.next(nDir);
    int d2 = DIR.prev(nDir);

    cell.setEmit(d1, cell.getReceive(d2).fade());
    cell.setEmit(d2, cell.getReceive(d1).fade());
  }
}

MirrorCell MIRRORCELL = new MirrorCell();

class PrismCell extends SpriteCell {
  {isTurnable = true;}
  {isWithFlare = true;}
  
  void update(ICell cell) {
    int cd = cell.getDir();
    Ray src = cell.getReceive(DIR.reverse(cd)).fade();
    
    Ray R = new Ray(src.r, 0, 0);
    Ray G = new Ray(0, src.g, 0);
    Ray B = new Ray(0, 0, src.b);
    
    cell.setEmit(cd, G);
    cell.setEmit(DIR.next(cd), R);
    cell.setEmit(DIR.prev(cd), B);
  };
}

PrismCell PRISMCELL = new PrismCell();

boolean expectationDone;

class ExpectorCell extends SpriteCell {
  int r, g, b;
  PImage arrowImg;
  PImage gearImg;
  PImage failImg, successImg;
  
  int doneDir;
  
  ExpectorCell(int r_, int g_, int b_) {
    r= r_; g = g_; b = b_;
  }
  
  void drawFg(int x, int y, int h, int w, int dir) {
    //super.drawFg(x,y,h,w,dir);
    
    drawImg(img, x,y,h,w,0);
    drawImg(gearImg, x,y,h,w, (expectationDone?1.:-1.)*.001*(float)millis());
    drawImg(expectationDone?successImg:failImg, x,y,h,w,0);
    
    if (arrowImg != null && (currentLevel <= 2 || expectationDone)) {
      float aof = 30. * (1. + sin(.005 * (float)millis()));
      
      image(arrowImg, x, y-h-aof, w, h);
    }
  }
  
  int match(int e, int r) {
    return e * ((r>0)?1:0);
  }
  
  void update(ICell cell) {
    if (expectationDone && (doneDir != cell.getDir())) {
      shouldStartNextLevel = true;
      return;
    }
    
    for (int i = 0; i < DIR.CNT; ++i) {
      Ray rc = cell.getReceive(i);
      
      int x = match(r, rc.r) + match(g, rc.g) + match(b, rc.b);
      
      if (x > 0) {
        expectationDone = true;
        isTurnable = true;
        doneDir = cell.getDir();
        return;
      }
    }

    expectationDone = false;
    isTurnable = false;
  }
}

ExpectorCell ANYEXPECTORCELL = new ExpectorCell(1, 1, 1);