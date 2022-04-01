import java.util.*;
MazeMaker mainMaze;
Player mainPlayer;

Ray test;
ArrayList<Ray> allRays = new ArrayList<Ray>();
PVector[][] boundary = new PVector[10][2];
PVector[] outerBoundary = new PVector[4];

boolean[] direction = new boolean[4];
void setup() {
    size(1080, 720);
    mainMaze = new MazeMaker(width/2-225, height-250, 450, 240);
    mainPlayer = new Player(mainMaze, mainMaze.getSquare(0,0));

    outerBoundary[0] = new PVector(0,0);
    outerBoundary[1] = new PVector(width,0);
    outerBoundary[2] = new PVector(width,height);
    outerBoundary[3] = new PVector(0,height); 

    for(int x = 0; x < 10; x++){
        boundary[x][0] = new PVector(random(0, width), random(0, height));
        boundary[x][1] = new PVector(random(0, width), random(0, height));
    }    
}

void draw() {
    background(100);    
    mainMaze.display();
    mainPlayer.action(direction);

    allRays.clear();
    for(float theta = 0; theta <= 360; theta += 0.5){
        Ray temp = new Ray(new PVector(mouseX, mouseY), theta);
        for(int x = 0; x < boundary.length; x++){
            temp.intersect(boundary[x][0], boundary[x][1]);
        }
        if(temp.intersection == null){
            for(int i = 0; i < 3; i++){
                temp.intersect(outerBoundary[i], outerBoundary[i+1])
                if(i == 2)
                   temp.intersect(outerBoundary[0], outerBoundary[i+1]); 
                
            }
            
        } 
        if(temp.intersection != null) allRays.add(temp);
    }

    stroke(255);
    for(int x = 0; x < boundary.length; x++){
        line(boundary[x][0].x, boundary[x][0].y, boundary[x][1].x, boundary[x][1].y);
    }
    for(Ray a: allRays){
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
