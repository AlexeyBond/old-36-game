
Grid grid = null;

String location = "/home/a_bond/p3sb/z99_main/data/";
int currentLevel = -1;
boolean playerReady = true;
boolean anyLevelDone = false;
boolean shouldStartNextLevel = false;

void startLevel() {
  if (++currentLevel >= levels.length) {
    grid = null;
    return;
  }

  grid = initLevel(levels[currentLevel]);
  expectationDone = false;
}

void levelDone() {
  playerReady = false;
  anyLevelDone = true;
  //startLevel();
}

void setup() {
  //size(1366, 768, P2D);
  fullScreen(P2D);
  
  setupSound();
  loadSprites();
  
  RR.pg = createGraphics(RR.TX, RR.TY, P2D);
  
  startLevel();
}

int x, y, cs;

void draw() {
  background(0);
  fill(0,0,0,0);
  stroke(255);
  
  if (grid != null) {
    {
      float wcss = grid.szx + 2;
      float hcss = grid.szy + 2;
      
      float wscr = width;
      float hscr = height;
      
      if ((wcss/hcss) < (wscr/hscr)) {
        cs = (int)(hscr/hcss);
      } else {
        cs = (int)(wscr/wcss);
      }
      
      x = cs + (int)(0.5 * (wscr - wcss * (float)cs));
      y = cs + (int)(0.5 * (hscr - hcss * (float)cs));
    }
    
    grid.update();
    grid.draw(x, y, cs);
    if (shouldStartNextLevel) {
      startLevel();
      shouldStartNextLevel = false;
    }
    
    if (grid != null) {
      String msg = String.format(" Level %s", currentLevel);
      
      textSize((.8 * (float)cs));
      fill(255);
      text(msg, 0, (.9 * (float)cs));
      
      if ((messages[currentLevel] != null && !expectationDone) || (successMessages[currentLevel] != null && expectationDone)) {
        textSize((.4 * (float)cs));
        text(expectationDone?successMessages[currentLevel]:messages[currentLevel], 0, height - (.5 * (float)cs));
      }
    }
  } else {
    float ts = .02 * (float)width;
    fill(255);
    textSize(3*ts);
    textAlign(CENTER);
    text("You win", ts, 2*ts, width - 2.*ts, height-2.*ts);
    fill(64);
    textSize(ts);
    textAlign(CENTER);
    text("I have no artist to draw a beutyful background for this screen :(", ts, 6*ts, width - 2.*ts, height-2.*ts);
    fill(128);
    textSize(ts);
    textAlign(CENTER);
    text("Thanks for playing. Now press [ESC].", ts, 8*ts, width - 2.*ts, height-2.*ts);
    fill(200);
    textSize(2*ts);
    textAlign(RIGHT);
    text("AB", ts, 12*ts, width - 2.*ts, height-2.*ts);
  }
}

void mouseClicked() {
  if (grid != null) {
    grid.turnCell(x, y, cs);
  }
}