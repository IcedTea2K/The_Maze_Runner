import java.util.*;
MazeMaker mainMaze;
Player mainPlayer;

Ray test;
ArrayList<Ray> allRays = new ArrayList<Ray>();

float mainSceneW = 810; // 3D scene's width
float mainSceneH = 420; // 3D scene's height

boolean[] direction = new boolean[4]; // users' input

void setup() {
    size(1080, 720);
    mainMaze = new MazeMaker(width/2-225, height-250, 450, 240);
    mainPlayer = new Player(mainMaze, mainMaze.getSquare(0,0));
}

void draw() {
    background(100);    
    mainMaze.display();
    mainPlayer.action(direction);

    drawMainScene();
}

void drawMainScene(){
    rectMode(CENTER);
    noStroke();

    pushMatrix();
    translate(width/2, 231);
    fill(0);
    rect(0, 0, mainSceneW, mainSceneH); // draw the background
    
    float sliceWidth = mainSceneW/mainPlayer.playerVisibility.size();
    for(int x = 0; x < mainPlayer.playerVisibility.size();x++){
        float dist = mainPlayer.playerVisibility.get(x).distanceToIntersection();
        
        dist *= cos(radians(mainPlayer.playerVisibility.get(x).heading - mainPlayer.heading)); // fix the fish eye effects
        float brightness = map(dist, 0, 100, 255, 0);
        float sliceHeight = map(dist, 0, 100, mainSceneH, 0);

        noStroke();
        rectMode(CENTER);
        fill(brightness);
        rect(x*sliceWidth - mainSceneW/2, 0, sliceWidth, sliceHeight);
    }
    popMatrix();
    
}

void setDirection (int k, boolean isOn) { // record pressed keys (direction)
  switch(k) {
  case LEFT:
    direction[0] = isOn;    
    break;
  case UP:
    direction[1] = isOn;
    break;
  case RIGHT:
    direction[2] = isOn;
    break;
  case DOWN:
    direction[3] = isOn;
    break;
  }
}


void keyPressed() {
  if (key == CODED) setDirection(keyCode, true);
}

void keyReleased() {
  if(key==CODED) setDirection(keyCode, false);
}
