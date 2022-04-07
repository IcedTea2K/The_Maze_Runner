/************************ Main Program ************************/
/*
* Minh Au
* Comp Sci 30
* The Maze Runner!!!
* Descriptions: Welcome to the maze where not everyone can escape. Solve the 3D (and 2D) maze
* in the shortest time possible. The program uses depth-first search algorithm to generate the maze randomly.
* So knock yourself out with unlimited number of mazes. Ray casting algorithm is also used to 
* establish the player's Field of View (FOV) in both the 2D map and 3D view. 
* The 3D view is not exactly 3D. It is divided into many small sections that represent a ray. Then the brightness
* and height of section are manipulated to create a sense of distance. NOTE, it is by no means a perfect 3D view
* so when it feels like you're stuck and can't move despite the clear area ahead, you are actually colliding
* with a wall. SO use the 2D map to get yourself out of that situation. 
* 
* There are 4 main scenes:
* + Start menu - have the option to start the game or to view the instructions
* + How to play - instructions on how to play the game. Press any of the arrows for cool interactions
* + Game Play (or Main Scene) - display 3D view and 2D map. Player has the option to view solution,
* enter hardcore mode (TRY IT OUT!!) or quit the game
* + End Scene - shows the stats of the player (best time + number of completions)
* User will be interacting with buttons which are self-explanatory. To view the key bindings of movement,
* refer to the How to play scene.
*
* ##### I understand that the maze takes really long (~3mins) to finish so I put in some cheat code in the 
* ##### file Player.pde on line 158. It just basically allows you to teleport to the end of the maze by passing
* ##### through the green gate.
*/

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
ArrayList<Button> allButtons = new ArrayList<Button>();

int gameStatus = 0; // 0 - intro; 1 - instructions; 2 - in game; 3 - game over
boolean hardCoreMode = false;
PImage[] arrowsImg = new PImage[4];
boolean isMoving = false;
boolean isResolved = false;

int completions = 0; // number of times the players has gone through the maze

void setup() {
    size(1080, 720);
    mainMaze = new MazeMaker(width/2-225, height-250, 450, 240);
    mainPlayer = new Player(mainMaze);

    clock = new StopWatch();

    // Instantiate buttons
    allButtons.add(new Button("Start", new PVector(width/2, height/2), 30, true, color(0,123,255), color(255,255,255)));
    allButtons.add(new Button("How to Play", new PVector(width/2, height*7/10), 30, true, color(0,123,255), color(255,255,255))); 
    allButtons.add(new Button("Back", new PVector(width/2, height*8/10 + 50), 30, false, color(0,123,255), color(255,255,255))); 
    allButtons.add(new Button("Solution", new PVector(949, 529), 20, false, color(0,123,255), color(0)));
    allButtons.add(new Button("HardCore", new PVector(949, 599), 20, false, color(0,123,255), color(0)));
    allButtons.add(new Button("Quit", new PVector(949, 669), 20, false, color(0,123,255), color(0)));
    allButtons.add(new Button("Try Again", new PVector(width/2, height*3/4), 20, false, color(0,123,255), color(0))); 

    // load the arrows drawing for the instruction scene
    arrowsImg[0] = loadImage("up_arrow.png");
    arrowsImg[1] = loadImage("right_arrow.png");
    arrowsImg[2] = loadImage("down_arrow.png");
    arrowsImg[3] = loadImage("left_arrow.png");
    font = createFont("MunaBold", 16, true);
    textFont(font);   
}

void draw() {
    background(100);    
    if(gameStatus == 0)
      startMenuScene();
    else if(gameStatus == 1)
      instructionScene();
    else if(gameStatus == 2)
      drawMainScene();
    else if(gameStatus == 3)
      endScene();
    
    displayButtons();
}

/****************************** ALL THE SCENES IN GAME ******************************/
void startMenuScene(){ // nothing but a plain black canvas
  rectMode(CORNER);
  fill(0, 255);
  rect(0,0,width, height);
}

void instructionScene(){
  startMenuScene(); // borrow the black background in the start menu
  imageMode(CENTER);
  
  pushMatrix();
  translate(width/2, height/3 + 50);
  for(int x = 0; x <= 270; x+=90){ // just a smart way to cycle through the different directions and offset them
    float xOffSet = sin(radians(x)) * 150; // since the drawing offset only y or x and they do that alternately
    float yOffSet = cos(radians(x)) * -150;  // sin() cos() would be able to replicate this alternating pattern
    color c = 255;
    if(direction[(x/90 + 1)%4]) // change color based on input
      c = #00FFFF;
    tint(c);
    arrowsImg[x/90].resize(150, 0);
    image(arrowsImg[x/90], xOffSet, yOffSet);
    
    fill(c);
    if(x == 0){ // label the arrows
      text("Forward", xOffSet, yOffSet - 80);
    }else if(x/90 % 2 != 0){
      pushMatrix(); // make them appear vertically
      translate(xOffSet + sin(radians(x))*80, yOffSet + cos(radians(x))*-80);
      rotate(radians(x)); 
      text("Rotate", 0, 0);
      popMatrix();
    }else{
      text("Backward", xOffSet, yOffSet + 100);
    }
  }
  popMatrix();
}

void drawMainScene(){ 
    if(isMoving == true && !clock.running) // preliminary check
      clock.start(); // only start when the player has started moving && the clock is not already running
    if(mainPlayer.isDone){ // if the player has reached the end
      clock.stop();
      clock.evaluate(); // evaluate the best time
      clock.reset();

      completions++;
      mainPlayer.isDone = false;
      isMoving = false;
    }
      
    mainMaze.display(hardCoreMode); // draw the 2D Map
    mainPlayer.action(direction); // draw the player on 2D map
    clock.display();
    
    // draw the 3D scene //
    rectMode(CENTER); 
    noStroke();
    
    pushMatrix();
    translate(width/2, 231);
    fill(#039be5);
    rect(0, 0, mainSceneW, mainSceneH); // draw the background
    
    float sliceWidth = mainSceneW/mainPlayer.playerVisibility.size(); // divide the screne into the number of rays
    float max = 100;
    for(int x = 0; x < mainPlayer.playerVisibility.size();x++){ // each slice corresponds to one ray
        float dist = mainPlayer.playerVisibility.get(x).distanceToIntersection();

        // projection of ray onto the camera --> fix the fish eye effects    
        dist *= cos(radians(mainPlayer.playerVisibility.get(x).heading - mainPlayer.heading)); 
        if(dist>max) max = dist; // change the maximum distance to avoid random rendering bug due to map()
        // modify the brightness as well as the wall height accordingly (to create an illusion of distance)
        float brightness = map(dist - mainPlayer.size/2, 0, max, 255, 0);
        float sliceHeight = map(dist - mainPlayer.size/2, 0, max, mainSceneH, 0);
        if(mainPlayer.playerVisibility.get(x).facingEntry) // draw the entry green (behind the player)
          fill(0,255,0,brightness);
        else if(mainPlayer.playerVisibility.get(x).facingExit) // draw the exit red (at the end)
          fill(0,0,255,brightness); 
        else fill(#C07F80, brightness);
        rect(x*sliceWidth - mainSceneW/2 + sliceWidth/2, 0, sliceWidth, sliceHeight);
    }
    popMatrix();
}

void endScene(){
  startMenuScene(); // borrow the background of start menu
  textSize(20);
  
  if(completions > 0){ // only congratulate them if they've completed the maze at least once
    fill(random(0,255), random(0,255), random(0,255));
    text("Congratulations Player, You Are the First Ever MAZE RUNNER!!", width/2, height*1/2 - 80);
  }
  else{
    fill(#cc0000);
    text("Sorry! You did not make it out." , width/2, height*1/2 - 80);
  }
  fill(213, 133, 132);
  text("Completions: " + completions, width/2, height*1/2);
  
  text("Best Time: " + clock.getBestTimeStr(), width/2, height*1/2 + 50);
}

void displayButtons(){ // show all the active buttons
  for(int x = 0; x < allButtons.size(); x++){
    if(allButtons.get(x).isActive)
      allButtons.get(x).display();
  }
}

/****************************** BUTTONS' FUNCTIONS ******************************/
//** mostly control the state of the game, rather changing component directly **//
// Disclaimed: the reason loops (or functions) are not used to make the code   //
// more readable and efficient is because some buttons require a specific     //
// order of activating and deactivating,in order to not affect other buttons //
void startGame(){
  gameStatus = 2;

  allButtons.get(0).deactivate();
  allButtons.get(1).deactivate();
  allButtons.get(6).deactivate();
  allButtons.get(3).activate();
  allButtons.get(4).activate();
  allButtons.get(5).activate();
}

void howToPlay(){
  allButtons.get(0).deactivate();
  allButtons.get(1).deactivate();
  allButtons.get(2).activate();
  
  gameStatus = 1;
}

void returnToIntro(){
  allButtons.get(2).deactivate();
  allButtons.get(0).activate();
  allButtons.get(1).activate();  

  gameStatus = 0;
}

void endGame(){
  clock.stop();
  for(int x = 0; x < allButtons.size()-1;x++){
    allButtons.get(x).deactivate();
  }
  allButtons.get(6).activate();
  gameStatus = 3;
}

void buttonEvent(int idx){ // turn on specific functions based on inputs (or clicks)
  switch(idx){
    case 0:
      startGame();
      break;
    case 1:
      howToPlay();
      break;
    case 2:
      returnToIntro();
      break;
    case 3:
      isResolved = !isResolved; // able to toggle the visibility of the solution
      mainMaze.revealSolution(isResolved);
      break;
    case 4:
      hardCoreMode = !hardCoreMode; // able to toggle the mode
      break;
    case 5:
      endGame();
      break;
    case 6:
      clock.stop(); // restart the game + reset all the stats
      clock.reset();
      clock.bestTime = Float.POSITIVE_INFINITY;
      isMoving = false;
      completions = 0;
      mainPlayer.reset();
      startGame();
      break;
  }
}

boolean setDirection (int k, boolean isOn) { // record pressed keys (direction)
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
  default:
    return false; // no arrows have been pressed
  }
  return true;
}

void mouseClicked(){
  for(int x = 0; x < allButtons.size(); x++){
    if(allButtons.get(x).isActive && allButtons.get(x).overBox()){ // detect the clicks are elligible
      buttonEvent(x);
      break;
    }
  }
}

void keyPressed() {
  if (key == CODED) 
    isMoving = setDirection(keyCode, true) && gameStatus == 2; // only considered as moving when the game has started and there's input
}

void keyReleased() {
  if(key==CODED) setDirection(keyCode, false);
}
