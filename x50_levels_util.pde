
class LevelObject {
  int x, y;
  ICellObject obj;
  
  LevelObject(int x_, int y_, ICellObject obj_) {
    x = x_; y = y_; obj = obj_; 
  }
}

class LevelDesc {
  int xsz, ysz;
  LevelObject[] objs;
  
  LevelDesc(int xs, int ys, LevelObject[] o) {
    xsz = xs; ysz = ys; objs = o;
  }
}

LevelObject O(int x, int y, ICellObject o) {
  return new LevelObject(x, y, o);
}

LevelDesc L(int xsz_, int ysz_, LevelObject... objs_) {
  return new LevelDesc(xsz_, ysz_, objs_);
}

Grid initLevel(LevelDesc ld) {
  Grid g = new Grid(ld.xsz, ld.ysz);
  
  for (LevelObject lo : ld.objs) {
    g.cells[lo.x][lo.y].obj = lo.obj;
  }
  
  return g;
}