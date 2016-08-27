
Grid grid = null;

String location = "/home/a_bond/p3sb/z99_main/data/";
int currentLevel = 0;
boolean playerReady = false;
boolean anyLevelDone = false;

void startLevel() {
  if (currentLevel == levels.length) {
    currentLevel = 0;
  }
  grid = initLevel(levels[currentLevel]);
}

void levelDone() {
  currentLevel++;
  playerReady = false;
  anyLevelDone = true;
  startLevel();
}

void setup() {
  size(1366, 768, P2D);
  
  setupSound();
  loadSprites();
  
  RR.pg = createGraphics(RR.TX, RR.TY, P2D);
  
  //grid = new Grid(10, 10);
  //grid.cells[5][5].obj = EMITTERCELL;
  //grid.cells[5][3].obj = PRISMCELL;
  //grid.cells[3][3].obj = MIRRORCELL;
  
  startLevel();
}

void draw() {
  background(128);
  fill(0,0,0,0);
  stroke(255);
  
  if (playerReady) {
    grid.update();
    grid.draw(50, 50, 64);
    if (expectationDone) {
      levelDone();
      expectationDone = false;
    }
  } else {
    
  }
}

void mouseClicked() {
  if (playerReady) {
    grid.turnCell(50, 50, 64);
  } else {
    playerReady = true;
  }
}