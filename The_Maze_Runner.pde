import java.util.*;
MazeMaker mainMaze;
Player mainPlayer;
boolean[] direction = new boolean[4];
void setup() {
    size(1080, 720);
    mainMaze = new MazeMaker(width/2-225, height-250, 450, 240);
    mainPlayer = new Player(mainMaze, mainMaze.getSquare(0,0));
}

void draw() {
    background(100);    
    mainMaze.display();
    mainPlayer.action(direction);
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
