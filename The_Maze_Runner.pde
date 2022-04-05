import java.util.*;
import java.text.DecimalFormat;
MazeMaker mainMaze;
Player mainPlayer;

ArrayList<Ray> allRays = new ArrayList<Ray>();

float mainSceneW = 810; // 3D scene's width
float mainSceneH = 420; // 3D scene's height

boolean[] direction = new boolean[4]; // users' input

PFont font;
StopWatch clock;
Button test;
void setup() {
    size(1080, 720);
    mainMaze = new MazeMaker(width/2-225, height-250, 450, 240);
    mainPlayer = new Player(mainMaze, mainMaze.getSquare(0,0));

    clock = new StopWatch();
    clock.start();

    font = createFont("MunaBold", 16, true);
    textFont(font);
    
}

void draw() {
    background(100);    
    mainMaze.display();
    mainPlayer.action(direction);

    clock.display();

    drawMainScene();
    test = new Button("Test", new PVector(97, 636), 30, color(0,0,0), color(255,255,255));
    test.display();
    println("mouseX: "+mouseX + " mouseY: " + mouseY);
}

void drawMainScene(){ // draw the 3D scene
    rectMode(CENTER);
    noStroke();
    
    pushMatrix();
    translate(width/2, 231);
    fill(#039be5);
    rect(0, 0, mainSceneW, mainSceneH); // draw the background
    
    // rectMode(CORNER);
    float sliceWidth = mainSceneW/mainPlayer.playerVisibility.size(); 
    float max = 100;
    for(int x = 0; x < mainPlayer.playerVisibility.size();x++){ // each slice corresponds to one ray
        float dist = mainPlayer.playerVisibility.get(x).distanceToIntersection();

        // projection of ray onto the camera --> fix the fish eye effects    
        dist *= cos(radians(mainPlayer.playerVisibility.get(x).heading - mainPlayer.heading)); 
        if(dist>max) max = dist; // change the maximum distance to avoid random rendering bug
        float brightness = map(dist - mainPlayer.size/2, 0, max, 255, 0);
        float sliceHeight = map(dist - mainPlayer.size/2, 0, max, mainSceneH, 0);
        if(mainPlayer.playerVisibility.get(x).facingEntry)
          fill(0,255,0,brightness);
        else if(mainPlayer.playerVisibility.get(x).facingExit)
          fill(0,0,255,brightness); 
        else fill(#C07F80, brightness);
        rect(x*sliceWidth - mainSceneW/2 + sliceWidth/2, 0, sliceWidth, sliceHeight);
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
