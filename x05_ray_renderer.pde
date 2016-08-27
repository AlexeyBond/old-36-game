class RayRenderer {
  final int TX = 128;
  final int HTX = TX >> 1;
  final int TY = 64;
  final int HTY = TY >> 1;
  PGraphics pg = null;
  float[] f = new float[HTX];
  float[] an = new float[HTX];

  void prepare() {
    float hty = TY >> 1;
    pg.beginDraw();
    pg.background(0,0,0,0);
    
    float kt = sin(.005 * (float)millis());
    
    getAudioNoise(an);
    
    for (int i = 0; i < HTX; ++i) {
      float n = sin(((float)i) - (float)millis() * .01) * .5 + an[i] * 2.;
      float k_ = 1. - (((float)min(i, HTX-i)) / (float)HTX);
      float k = 1. - k_ * k_;
      f[i] = kt * k * n * 3.;
    }
    
    pg.noFill();
    pg.strokeWeight(5);
    pg.stroke(255,255,255,128);
    pg.beginShape();
    
    for (int i = 0; i < HTX; ++i) {
      pg.vertex(i*2, f[i]+hty);
    }
    
    pg.endShape();

    pg.strokeWeight(2);
    pg.stroke(255,255,255,255);
    pg.beginShape();
    
    for (int i = 0; i < HTX; ++i) {
      pg.vertex(i*2, f[i]+hty);
    }
    
    pg.endShape();
    pg.endDraw();
  }
  
  void drawRay(Ray ray, int x1, int y1, int x2, int y2, int tx, int ty) {
    float dx = tx * HTY;
    float dy = ty * HTY;
    
    beginShape();
    noStroke();
    texture(pg);
    textureMode(NORMAL);
    tint(ray.r * 16, ray.g * 16, ray.b * 16);
    vertex((float)x1 + dx-ty, (float)y1 + dy+tx*2, 0, 1.);
    vertex((float)x1 - dx-ty, (float)y1 - dy+tx*2, 0, 0);
    vertex((float)x2 - dx, (float)y2 - dy, 1., 0);
    vertex((float)x2 + dx, (float)y2 + dy, 1., 1.);
    endShape(CLOSE);
  }
}

final RayRenderer RR = new RayRenderer();