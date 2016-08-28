

class Ray {
  final int r, g, b;
  
  Ray(int r_, int g_, int b_) {
    r = r_; g = g_; b = b_;
  }
  
  int fade_(int x) {
    if (x == 0) return x;
    return x - 1;
  }
  
  Ray fade() {return new Ray(fade_(r), fade_(g), fade_(b));}
}

final Ray DARK = new Ray(0,0,0);
final Ray LIGHT = new Ray(16,16,16);

class Dir_ {
  int
  UP_LEFT = 7,    UP = 0,     UP_RIGHT = 1,
  LEFT = 6,                   RIGHT = 2,
  DN_LEFT = 5,    DN = 4,     DN_RIGHT = 3;
  
  int CNT = 8;
  
  int[] h = new int[CNT];
  int[] v = new int[CNT];
  
  {
    h[UP] = 0;
    h[UP_RIGHT] = 1;
    h[RIGHT] = 1;
    h[DN_RIGHT] = 1;
    h[DN] = 0;
    h[DN_LEFT] = -1;
    h[LEFT] = -1;
    h[UP_LEFT] = -1;
    
    v[UP] = -1;
    v[UP_RIGHT] = -1;
    v[RIGHT] = 0;
    v[DN_RIGHT] = 1;
    v[DN] = 1;
    v[DN_LEFT] = 1;
    v[LEFT] = 0;
    v[UP_LEFT] = -1;
  }
  
  int next(int dir, int cnt) {return (dir + cnt) % CNT;}
  
  int reverse(int dir) {return next(dir, 4);}
  
  int next(int dir) {return next(dir, 1);}
  int prev(int dir) {return next(dir, CNT - 1);}
  int perpendicular(int dir) {return next(dir, 2);}
  
  float angle(int dir) {
    return PI * 0.25 * (float) dir;
  }
}

final Dir_ DIR = new Dir_();

abstract class ICell {
  abstract Ray getEmit(int dir);
  
  abstract Ray getReceive(int dir);
  
  abstract void setEmit(int dir, Ray ray);
  
  abstract int getDir();
}

abstract class IGrid {
  abstract ICell getCell(int x, int y);
  
  ICell getCell(int x, int y, int dir) {
    return getCell(x + DIR.h[dir], y + DIR.v[dir]);
  }
}

abstract class ICellObject {
  abstract void update(ICell cell);
  
  abstract void drawBg(int x, int y, int h, int w, int dir);
  abstract void drawFg(int x, int y, int h, int w, int dir);
  
  boolean isTurnable = false;
  boolean isWithFlare = false;
}

class EmptyCell extends ICellObject {
  void update(ICell cell) {
    for (int i = 0; i < DIR.CNT; ++i) {
      cell.setEmit(i,
        cell.getReceive(DIR.reverse(i))
          .fade());
    }
  };
  
  void drawBg(int x, int y, int h, int w, int dir) {};
  void drawFg(int x, int y, int h, int w, int dir) {};
}

EmptyCell EMPTYCELL = new EmptyCell();

class Cell extends ICell {
  Ray[][] emit = new Ray[][]{new Ray[DIR.CNT], new Ray[DIR.CNT]};
  
  int ectr = 0;
  int dir = DIR.UP;
  
  int getDir() {
    return dir;
  };

  IGrid grid;
  ICellObject obj = EMPTYCELL;
  int x, y;
  
  Cell(int x_, int y_, IGrid grid_) {
    x = x_; y = y_;
    grid = grid_;
    
    clearEmit();
    swapEmit();
    clearEmit();
  }
  
  void swapEmit() {
    ectr = 1&(ectr+1);
  }
  
  Ray getEmit(int dir) {
    return emit[ectr][dir];
  }
  
  Ray getReceive(int dir) {
    return grid.getCell(x, y, dir).getEmit(DIR.reverse(dir));
  }
  
  void setEmit(int dir, Ray ray) {
    emit[(ectr+1)&1][dir] = ray;
  }
  
  void clearEmit() {
    for (int i = 0; i < DIR.CNT; ++i) {
      setEmit(i, DARK);
    }
  }
  
  void update() {
    if (obj != null) obj.update(this);
  };
}

class NoCell extends ICell {
  Ray getEmit(int dir) {return DARK;}
  Ray getReceive(int dir) {return DARK;}
  void setEmit(int dir, Ray ray) {}
  int getDir() {return 0;};
}

final NoCell NOCELL = new NoCell();

class Grid extends IGrid {
  int szx, szy;
  Cell[][] cells;
  boolean flares[];
  
  PImage bgImg = loadImage(location + "bg-com-0.png");
  PImage flareImg = loadImage(location + "flare.png");
  PImage highlightImg = loadImage(location + "turn-cursor.png");
  
  Grid(int szx_, int szy_) {
    szx = szx_; szy = szy_;
    
    cells = new Cell[szx][];
    
    for (int i = 0; i < szx; ++i) {
      cells[i] = new Cell[szy];
      
      for (int j = 0; j < szy; ++j) {
        cells[i][j] = new Cell(i, j, this);
        cells[i][j].clearEmit();
      }
    }
    
    flares = new boolean[szx*szy];
  }
  
  ICell getCell(int x, int y) {
    if (x < 0 || x >= szx || y < 0 || y >= szy)
      return NOCELL;
      
    return cells[x][y];
  }
  
  void update() {
    for (int i = 0; i < szx; ++i)
      for (int j = 0; j < szy; ++j) {
        cells[i][j].clearEmit();
        cells[i][j].update();
      }

    for (int i = 0; i < szx; ++i)
      for (int j = 0; j < szy; ++j) {
        cells[i][j].swapEmit();
      }
  }
  
  void drawRays(int x, int y, int cellsize) {
    int hcsz = cellsize >> 1;
    
    RR.prepare();
    
    blendMode(ADD);
    
    for (int i = 0; i < szx*szy; ++i) flares[i] = false;

    for (int i = 0; i < szx; ++i) {
      int cellcx = x + cellsize * i + hcsz;
      
      for (int j = 0; j < szy; ++j) {
        int cellcy = y + cellsize * j + hcsz;
        ICell c = getCell(i, j);
        boolean flare = false;
        
        for (int dir = 0; dir < DIR.CNT; ++dir) {
          int endx = cellcx + DIR.h[dir] * cellsize;
          int endy = cellcy + DIR.v[dir] * cellsize;
          int pdir = DIR.perpendicular(dir);
          Ray e = c.getEmit(dir);
          
          if (e.r == 0 && e.g == 0 && e.b == 0) continue;
          
          //stroke(e.r*16, e.g*16, e.b*16);
          
          //line(cellcx, cellcy, endx, endy);
          
          RR.drawRay(e, cellcx, cellcy, endx, endy, DIR.h[pdir], DIR.v[pdir]);
          flares[i + j * szx] = true;
        }
      }
    }

    noTint();
    
    for (int i = 0; i < szx; ++i) {
      int cellcx = x + cellsize * i + hcsz;
      
      for (int j = 0; j < szy; ++j) {
        int cellcy = y + cellsize * j + hcsz;
        ICell c = getCell(i, j);
        
        if(flares[i + szx*j] && cells[i][j].obj.isWithFlare) {
          image(flareImg, cellcx - hcsz, cellcy - hcsz, cellsize, cellsize);
        }
      }
    }
    
    blendMode(BLEND);
  }
  
  int getMouseCellX(int x, int y, int cs) {
    if (mouseX < x || mouseX >= x + cs * szx)
      return -1;

    return (mouseX - x) / cs;
  }
  
  int getMouseCellY(int x, int y, int cs) {
    if (mouseY < y || mouseY >= y + cs * szy)
      return -1;

    return (mouseY - y) / cs;
  }
  
  void turnCell(int x, int y, int cs) {    
    int xx = getMouseCellX(x,y,cs);
    int yy = getMouseCellY(x,y,cs);
    
    if (xx < 0 || yy < 0) return;
    
    if (!cells[xx][yy].obj.isTurnable) return;
    
    cells[xx][yy].dir = DIR.next(cells[xx][yy].dir, 1);
  }
  
  void drawHighlight(int x, int y, int cs) {      
    int xx = getMouseCellX(x,y,cs);
    int yy = getMouseCellY(x,y,cs);
    
    if (xx < 0 || yy < 0) return;
    
    if (!cells[xx][yy].obj.isTurnable) return;
    
    //stroke(255, 128, 128);
    //rect(x+xx*cs, y+yy*cs, cs, cs);
    
    int hcs = cs >> 1;
    int cx = x+xx*cs+hcs;
    int cy = y+yy*cs+hcs;
    
    pushMatrix();
    translate(cx, cy);
    rotate(0.002 * (float)millis());
    scale(1. + .05 * sin(0.001 * (float)millis()));
    translate(-cs, -cs);
    image(highlightImg, 0,0, 2*cs, 2*cs);
    popMatrix();
  }
  
  void draw(int x, int y, int cellsize) {
    for (int i = 0; i < szx; ++i) {
      int cellx = x + cellsize * i;
      
      for (int j = 0; j < szy; ++j) {
        int celly = y + cellsize * j;
        
        image(bgImg, cellx, celly, cellsize, cellsize);
        
        cells[i][j].obj.drawBg(cellx, celly, cellsize, cellsize, cells[i][j].dir);
      }
    }
    
    drawRays(x, y, cellsize);

    for (int i = 0; i < szx; ++i) {
      int cellx = x + cellsize * i;
      
      for (int j = 0; j < szy; ++j) {
        int celly = y + cellsize * j;
        
        cells[i][j].obj.drawFg(cellx, celly, cellsize, cellsize, cells[i][j].dir);
      }
    }
    
    drawHighlight(x, y, cellsize);
  }
}