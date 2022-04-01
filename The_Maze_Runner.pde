import java.util.*;
MazeMaker mainMaze;
Player mainPlayer;

Ray test;
ArrayList<Ray> allRays = new ArrayList<Ray>();
PVector[] boundary = new PVector[2];

boolean[] direction = new boolean[4];
void setup() {
    size(1080, 720);
    mainMaze = new MazeMaker(width/2-225, height-250, 450, 240);
    mainPlayer = new Player(mainMaze, mainMaze.getSquare(0,0));
    
    boundary[0] = new PVector(width*3/4, height/4);
    boundary[1] = new PVector(width*3/4, height*3/4);

    
}

void draw() {
    background(100);    
    mainMaze.display();
    mainPlayer.action(direction);
    

    allRays.clear();
    for(float theta = 0; theta <= 360; theta += 0.5){
        Ray temp = new Ray(new PVector(mouseX, mouseY), theta);
        if(temp.intersect(boundary[0], boundary[1])){
            allRays.add(temp);
        }
    }

    stroke(255);
    line(boundary[0].x, boundary[0].y, boundary[1].x, boundary[1].y);
    for(Ray a: allRays){
        a.display();
        a.connectIntersect();
    }
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
