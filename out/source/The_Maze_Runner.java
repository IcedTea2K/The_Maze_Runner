import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.*; 
import java.text.DecimalFormat; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class The_Maze_Runner extends PApplet {

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

public void setup() {
    
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

public void draw() {
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
public void startMenuScene(){ // nothing but a plain black canvas
  rectMode(CORNER);
  fill(0, 255);
  rect(0,0,width, height);
}

public void instructionScene(){
  startMenuScene(); // borrow the black background in the start menu
  imageMode(CENTER);
  
  pushMatrix();
  translate(width/2, height/3 + 50);
  for(int x = 0; x <= 270; x+=90){ // just a smart way to cycle through the different directions and offset them
    float xOffSet = sin(radians(x)) * 150; // since the drawing offset only y or x and they do that alternately
    float yOffSet = cos(radians(x)) * -150;  // sin() cos() would be able to replicate this alternating pattern
    int c = 255;
    if(direction[(x/90 + 1)%4]) // change color based on input
      c = 0xff00FFFF;
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

public void drawMainScene(){ 
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
    fill(0xff039be5);
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
        else fill(0xffC07F80, brightness);
        rect(x*sliceWidth - mainSceneW/2 + sliceWidth/2, 0, sliceWidth, sliceHeight);
    }
    popMatrix();
}

public void endScene(){
  startMenuScene(); // borrow the background of start menu
  textSize(20);
  
  if(completions > 0){ // only congratulate them if they've completed the maze at least once
    fill(random(0,255), random(0,255), random(0,255));
    text("Congratulations Player, You Are the First Ever MAZE RUNNER!!", width/2, height*1/2 - 80);
  }
  else{
    fill(0xffcc0000);
    text("Sorry! You did not make it out." , width/2, height*1/2 - 80);
  }
  fill(213, 133, 132);
  text("Completions: " + completions, width/2, height*1/2);
  
  text("Best Time: " + clock.getBestTimeStr(), width/2, height*1/2 + 50);
}

public void displayButtons(){ // show all the active buttons
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
public void startGame(){
  gameStatus = 2;

  allButtons.get(0).deactivate();
  allButtons.get(1).deactivate();
  allButtons.get(6).deactivate();
  allButtons.get(3).activate();
  allButtons.get(4).activate();
  allButtons.get(5).activate();
}

public void howToPlay(){
  allButtons.get(0).deactivate();
  allButtons.get(1).deactivate();
  allButtons.get(2).activate();
  
  gameStatus = 1;
}

public void returnToIntro(){
  allButtons.get(2).deactivate();
  allButtons.get(0).activate();
  allButtons.get(1).activate();  

  gameStatus = 0;
}

public void endGame(){
  clock.stop();
  for(int x = 0; x < allButtons.size()-1;x++){
    allButtons.get(x).deactivate();
  }
  allButtons.get(6).activate();
  gameStatus = 3;
}

public void buttonEvent(int idx){ // turn on specific functions based on inputs (or clicks)
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

public boolean setDirection (int k, boolean isOn) { // record pressed keys (direction)
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

public void mouseClicked(){
  for(int x = 0; x < allButtons.size(); x++){
    if(allButtons.get(x).isActive && allButtons.get(x).overBox()){ // detect the clicks are elligible
      buttonEvent(x);
      break;
    }
  }
}

public void keyPressed() {
  if (key == CODED) 
    isMoving = setDirection(keyCode, true) && gameStatus == 2; // only considered as moving when the game has started and there's input
}

public void keyReleased() {
  if(key==CODED) setDirection(keyCode, false);
}
/************************ Button ************************/
/*
* This is only a class for buttons. For the main program
* please view The_Maze_Runner.pde
*/
public class Button {
    final String message;
    private float buttonHeight;
    private float buttonWidth;
    private int buttonColor;
    private int txtColor;
    private float widthScalar = 2;
    private float heightScalar = 2;
    boolean isActive = false; // depends one which scene, a button can be either activated or deactivated
    PVector pos;
    float fontSize;
    
    public Button (String message, PVector pos, float fontSize, boolean isActive, int buttonColor, int txtColor) {
        this.message = message; // declare all the properties of this buttons
        this.pos = pos;
        this.fontSize = fontSize;
        this.buttonColor = buttonColor;
        this.txtColor = txtColor;
        this.isActive = isActive;
    }

    public void calculateTextBox(){  // width and height are scaled by arbitary amount to make it look less cramped within the box
        textSize(fontSize);
        buttonHeight = textAscent() * heightScalar; // textAscent return the highest baseline of that font
        buttonWidth = textWidth(message) * widthScalar; // the width of the message
    }

    public boolean overBox(){ // detect if the mouse is hovering over the box
        return(mouseX > pos.x - buttonWidth/2 && mouseX < pos.x + buttonWidth/2)
            && mouseY > (pos.y - buttonHeight/2)
                && mouseY < (pos.y + buttonHeight/2);
    }

    public void display(){
        calculateTextBox();
        rectMode(CENTER);

        noStroke();
        fill(buttonColor); // draw plain button
        rect(pos.x, pos.y, buttonWidth, buttonHeight);
        
        textAlign(CENTER);
        fill(txtColor); // write the text onto the button
        text(message, pos.x, pos.y + buttonHeight/(heightScalar * 2)); // padding (or scale) * 2 will make the text appear in the middle
    }

    public void activate(){
        isActive = true;
    }

    public void deactivate(){
        isActive = false;
    }
}
/************************ Maze Maker ************************/
/*
* This is only a class for maze generator. For the main program
* please view The_Maze_Runner.pde
*/
public class MazeMaker { // create the maze
    PVector size; 
    final PVector loc;    
    int rows;
    int columns;

    int squareSize = 15;
    ArrayList<ArrayList<MazeSquare>> allSquares = new ArrayList<ArrayList<MazeSquare>>(); // 2D array to replicate the grid
    ArrayList<MazeSquare> solution = new ArrayList<MazeSquare>(); // solution for the maze
    Stack<MazeSquare> visitedSquareStack = new Stack<MazeSquare>();

    final float mazeWidth;
    final float mazeHeight;
    public MazeMaker (float xPos, float yPos, float mazeWidth, float mazeHeight) {
        loc = new PVector(xPos, yPos);
        size = new PVector(mazeWidth, mazeHeight);
        rows = PApplet.parseInt(mazeHeight/squareSize); // calculate properties of maze based on square size
        columns = PApplet.parseInt(mazeWidth/squareSize);
        this.mazeWidth = mazeWidth;
        this.mazeHeight = mazeHeight;
        createGrid();
        makeMaze();
    }

    public void createGrid(){ // simple function to instantiate sufficient number of square and put it into the 2D array
        for(int y = 0; y < rows; y++){            
            allSquares.add(new ArrayList<MazeSquare>());
            for(int x = 0; x < columns; x++){    
                allSquares.get(y).add(new MazeSquare(x*squareSize, y*squareSize, squareSize, new int[] {x,y}));
            }
        }
    }

    public void makeMaze(){
        visitedSquareStack.push(allSquares.get(0).get(0)); // inital cell is always the first square on top left
        allSquares.get(0).get(0).visit(); // mark this square as visited
        allSquares.get(0).get(0).removeSide(0); // the top side of this square is always removed

        ArrayList<MazeSquare> availableNeighbor = new ArrayList<MazeSquare>();
        MazeSquare lastRightSquare = allSquares.get(0).get(0);
        boolean reached = false;
        while(!visitedSquareStack.empty()){
            MazeSquare currSquare = visitedSquareStack.pop(); // examining the square ontop of the stack
            int[] neighborIdx = checkNeighbor(currSquare); // check for all possible neighbors -- most will have 4; the least is 2
            
            for(int x = 0; x < 4; x++){ // check if the neighbors are vistited, if they are not, they are considered available to visit
                if(neighborIdx[x] == -1) continue; 
                    
                if(x%2 == 0 && !allSquares.get(currSquare.getIdx()[1]).get(neighborIdx[x]).hasVisited())
                    availableNeighbor.add(allSquares.get(currSquare.getIdx()[1]).get(neighborIdx[x]));
                else if(x%2 != 0 && !allSquares.get(neighborIdx[x]).get(currSquare.getIdx()[0]).hasVisited())   
                    availableNeighbor.add(allSquares.get(neighborIdx[x]).get(currSquare.getIdx()[0]));
            }

            if(reached) // has returned to the main path (solution)
                solution.add(currSquare);
            
            if(availableNeighbor.size() == 0) { // all the neighbor of this square has beeen checked --> this square is good to go
                if(currSquare.getIdx()[0] == columns-1 && currSquare.getIdx()[1] == rows-1 || currSquare == lastRightSquare)
                    reached = true;
                continue;
            }else if(availableNeighbor.size() != 0 && reached){
                lastRightSquare = currSquare; // there are neighbors to check out --> must mark this square as belonging to the main path
                reached = false; // before branching out and check other neighbors
            }

            visitedSquareStack.push(currSquare); // push this one ontop of the stack

            int tempRandomNeighborIdx = PApplet.parseInt(round(random(0, availableNeighbor.size()-1))); // randomly select the neighbors
            currSquare.removeSide(availableNeighbor.get(tempRandomNeighborIdx)); // remove adjacent sides for both squares
            availableNeighbor.get(tempRandomNeighborIdx).removeSide(currSquare);

            availableNeighbor.get(tempRandomNeighborIdx).visit(); // mark the chosen neighbor visited
            visitedSquareStack.push(availableNeighbor.get(tempRandomNeighborIdx)); // push it ontop of the stack    
            availableNeighbor.clear(); // reset the array of available neighbors
        }

        allSquares.get(rows-1).get(columns-1).removeSide(2); // the last square always gets its bottom removed
        allSquares.get(rows-1).get(columns-1).isCorrect = true; // and always belongs to the solution
    }

    public void revealSolution(boolean isRevealing){ // display the solution in the 2D map
        for(int x = 0; x < solution.size(); x++){
            solution.get(x).isCorrect = isRevealing;   
        }
    }

    public void reset(){ // delete all the squares + create a new maze
        solution.clear();
        allSquares.clear();
        createGrid();
        makeMaze();
    }

    public int[] checkNeighbor(MazeSquare square){ // check how many neighbor there are + return their idices 
        int[] possibleNeighbors = new int[4];
        for(int x = 0; x<4;x++) possibleNeighbors[x] = -1;
        if(square.getIdx()[0] - 1 >= 0){
            possibleNeighbors[0] = square.getIdx()[0] - 1;
        }
        if(square.getIdx()[1] - 1 >= 0){
            possibleNeighbors[1] = square.getIdx()[1] - 1;
        }
        if(square.getIdx()[0] + 1  < columns){
           possibleNeighbors[2] = square.getIdx()[0] + 1; 
        }            
        if(square.getIdx()[1] + 1 < rows){
           possibleNeighbors[3] = square.getIdx()[1] + 1;
        }        
        return possibleNeighbors;
    }

    public void drawGrid(){
        pushMatrix();
        translate(loc.x, loc.y); // reset the grid to make it easer to draw the squares
        for(int y = 0; y < rows; y++){
            for(int x = 0; x<columns; x++){
                allSquares.get(y).get(x).display();
            }
        }
        popMatrix();
    }

    public void drawBackground(){
        fill(0);
        rectMode(CORNER);
        noStroke();
        rect(loc.x, loc.y, size.x, size.y);        
    }

    public void display(boolean isHardCore){
        drawBackground();
        if(!isHardCore) drawGrid(); // the 2D map is invisible in hardocre mode (except for visited ones)
    }

    public MazeSquare getSquare(int rowIdx, int colIdx){ // return the specified square
        if(rowIdx <= -1)
            return allSquares.get(rows-1).get(columns-1);
        else if(rowIdx >= rows)
            return allSquares.get(0).get(0); 
        return allSquares.get(rowIdx).get(colIdx);
    }

    public PVector getLoc(){
        return loc.copy(); // a copy just to be safe (since it's a pointer) 
    }
}
/************************ Maze Square ************************/
/*
* This is only a class for the squares of the maze/grid. 
* For the main program please view The_Maze_Runner.pde
*/
PVector[] verticies = {new PVector(0,0), new PVector(1,0),
    new PVector(1,1), new PVector(0,1)}; // starts top-left then go clock-wise

public class MazeSquare{
    final PVector loc; // prevent these from being changed later on
    final int[] idx;
    boolean[] isClosed = {true, true, true, true}; // which side is closed or open; 0 - top, 1 - right; 2 - bot; 3 - left
    int wallColor = color(255);

    float size;
    boolean alreadyVisited = false; // status of the square
    boolean isCorrect = false; // also status of the square
    public MazeSquare (float xPos, float yPos, float size, int[] idx) {
        loc = new PVector(xPos, yPos);
        this.size = size;
        this.idx = idx;
    }

    public void display(){
        pushMatrix();
        translate(loc.x, loc.y); // move to desired location
        if(isCorrect){ // if part of the solution, color the square instead of drawing the outline
            fill(255,0,0);
            noStroke();
            rectMode(CORNER);
            rect(0, 0, size, size);
        }

        stroke(wallColor);
        for(int x = 0; x < 4; x++){
            if(isClosed[x]){ // only drawn if they are indicated as closed
                if(x != 3)  
                    line(verticies[x].x*size, verticies[x].y*size, verticies[x+1].x*size, verticies[x+1].y*size);
                else // first and last vertices are connected for the last side
                    line(verticies[x].x*size, verticies[x].y*size, verticies[0].x*size, verticies[0].y*size);  
            }
        }
        popMatrix();
    }

    public PVector getLocation(){
        return loc.copy();
    }

    public float[] getBoundary(){ // return the boundaries of the box
        float[] boundary = new float[4];
        for(int x = 0; x < 4; x++){
            if(x%2 == 0){ // top and bottom
                    boundary[x] = loc.y + verticies[x].y*size;
                }else{
                    boundary[x] = loc.x + verticies[x].x*size;
                }
        }
        return boundary;
    }

    public PVector[] getBoundaryVerticies(){  // return the verticies of the boundary in actual units (instead of just the signs)
       PVector[] boundary = new PVector[4];
       
       for(int x = 0; x < 4; x++){
           boundary[x] = new PVector(loc.x + verticies[x].x*size, loc.y + verticies[x].y*size);
        }
        return boundary;
    }

    public int[] getIdx(){
        return idx.clone(); // clone just to be safe
    }
    
    public void removeSide(MazeSquare neighbor){
        // 0 - left; 1 - top; 2 - right; 3 - bottom
        int tempColumnIdxDiff = neighbor.getIdx()[0] - idx[0]; 
        int tempRowIdxDiff = neighbor.getIdx()[1] - idx[1];

        if(tempColumnIdxDiff < 0) // remove the side based on its targeted neighbor
            isClosed[3] = false;
        else if(tempRowIdxDiff < 0)
            isClosed[0] = false;
        else if(tempColumnIdxDiff > 0)
            isClosed[1] = false;
        else if(tempRowIdxDiff > 0)
            isClosed[2] = false;
    }

    public void removeSide(int side){ // remove a specific side
        isClosed[side] = false;
    }

    public void addSide(int side){
        // 3 - left; 0 - top; 1 - right; 2 - bottom        
        isClosed[side] = true;
    }

    public void visit(){ // mark this square as visited
        alreadyVisited = true;
    }

    public boolean hasVisited(){ // return the availaibility of this square
        return alreadyVisited;
    }
}
/************************ Player ************************/
/*
* This is only a class for player. For the main program
* please view The_Maze_Runner.pde
*/
public class Player {
    PVector loc = new PVector(0,0);
    float speed = 0.5f;
    int size = 6;
    float heading = 0; // where it is going toward
    boolean isDone = false;

    MazeSquare currSquare;
    int[] currSquareIdx;
    MazeMaker maze;
    boolean[] bufferZones = {false, false, false, false}; // the zone between actual boundary and collision boundary
                                                            // top - right - bottom - left
    HashSet<MazeSquare> track = new HashSet<MazeSquare>(); // the squares the player has gone through
    ArrayList<Ray> playerVisibility = new ArrayList<Ray>(); // container for all the rays
    public Player (MazeMaker maze) {
        this.maze = maze;
        this.reset();
    }

    public void move(boolean[] input){ // movement + boundary detection
        if(gameStatus != 2) return;
        currSquare = maze.getSquare(currSquareIdx[1], currSquareIdx[0]);

        PVector direction;
        if(input[0]) // rotate based on left and right arrow
            heading += -2;
        else if(input[2])
            heading += 2;
        direction = PVector.fromAngle(radians(heading));
        
        if(input[1]) // move
            direction.setMag(speed);
        else if(input[3])
            direction.setMag(-speed);
        else {
            direction.setMag(0);
        }

        PVector futureLoc = PVector.add(direction, loc); // predict the future location
        float[] boundary = currSquare.getBoundary(); 
        
        //********************************* Collision checking *********************************//
        if(futureLoc.x <= boundary[3] + size/2){ // collision boundary = offeset a bit from the actual boundary
            if(currSquare.isClosed[3]) // no moving if the side is closed
                direction.setMag(0);
            else if(futureLoc.x < boundary[3]) currSquareIdx[0]--; // if passed the actual boundary --> reaches new square
        }else if(futureLoc.x >= boundary[1] - size/2){ // collision boundary
            if(currSquare.isClosed[1])
                direction.setMag(0);
            else if(futureLoc.x > boundary[1]) currSquareIdx[0]++; // actual boundary
        }
        if(futureLoc.y <= boundary[0] + size/2){ // collision boundary
            if(currSquare.isClosed[0])
                direction.setMag(0);
            else if(futureLoc.y < boundary[0]) currSquareIdx[1]--; // actual boundary
        }else if(futureLoc.y >= boundary[2] - size/2){ // collision boundary
            if(currSquare.isClosed[2])
                direction.setMag(0);
            else if(futureLoc.y > boundary[2]) currSquareIdx[1]++; // actual boundary    
        }
        
        loc.add(direction); // actually move after all the checks
        if(currSquareIdx[1] == maze.rows) { // reset when the end is reached
                track.clear();
                maze.reset(); 
        }else track.add(currSquare); // record the path
        
        
        bufferZones[0] = (boundary[0] - size/2.f <= loc.y && loc.y < boundary[0] + size/2.f); // buffer zone  
        bufferZones[1] = (boundary[1] - size/2.f < loc.x && loc.x <= boundary[1] + size/2.f); // buffer zone
        bufferZones[2] = (boundary[2] - size/2.f < loc.y && loc.y <= boundary[2] + size/2.f); // buffer zone  
        bufferZones[3] = (boundary[3] - size/2.f <= loc.x && loc.x < boundary[3] + size/2.f); // buffer zone 
    }

    public int checkBuffer(){
        for(int x = 0; x < 4; x++){ // return the index of the activated buffer zone
            if(bufferZones[x]) return x;
        }  
        return -1;
    }
    // utilize passing pointer as parameter --> doesn't have to return that point; instead can return another information 
    // --> essentially returning two things with one function
    public boolean castRay(Ray targetRay, MazeSquare targetSquare, int entrySide){ 
       int intersectedSide = -1;       
       PVector[] squareBoundary = targetSquare.getBoundaryVerticies(); // get the boundary

       for(int z = 0; z < 4; z++){
            if(entrySide == z) continue; // no point of checking the square the ray comes from --> prevent infinite recursion
            if(z != 3){ // check if it hits any of the sides 
                intersectedSide = (targetRay.intersect(squareBoundary[z], squareBoundary[z+1])) ? z : intersectedSide;
            }else{
                intersectedSide = (targetRay.intersect(squareBoundary[0], squareBoundary[3])) ? 3 : intersectedSide;
            }
        } 
        if(intersectedSide == -1) return false; // precaution against when the ray doesn't intersect any of the 4 sides for some reason

        int[] squareIdx = targetSquare.getIdx();
        
        if((Arrays.equals(squareIdx, new int[]{0,0}) && intersectedSide == 0) || 
            (Arrays.equals(squareIdx, new int[]{maze.columns-1,maze.rows-1}) && intersectedSide == 2)){
            return true; // prevent from checking the open-on-default sides of the first and last square
        }
        if(!targetSquare.isClosed[intersectedSide]){ // check if the intersected side is open
            if(intersectedSide == 0) // if open go to the next square
                squareIdx[1]--; // go up one row
            else if(intersectedSide == 1)
                squareIdx[0]++; // go right one column
            else if(intersectedSide == 2)
                squareIdx[1]++; // go down one row
            else if(intersectedSide == 3)
                squareIdx[0]--; // go left one column
            intersectedSide += (intersectedSide <= 1) ? 2 : -2; // top of one square is bot of the other; same for left and right
            return castRay(targetRay, maze.getSquare(squareIdx[1], squareIdx[0]), intersectedSide);
        }
        return true; 
    }

    public void detectWalls(){ // gives the player's visibility
        playerVisibility.clear(); // reset everytime

        for(float theta = -30+ heading; theta<=30+heading; theta+=0.5f){ // -30 to +30 is player's field of vision (FOV)
            Ray temp = new Ray(this.loc.copy(), theta);
            if(!castRay(temp, currSquare, -1) && checkBuffer() != -1){ // if in buffer zone, must check the next square as well
                if(checkBuffer() == 0)
                    castRay(temp, maze.getSquare(currSquare.getIdx()[1]-1, currSquare.getIdx()[0]), -1);
                else if(checkBuffer() == 1)
                    castRay(temp, maze.getSquare(currSquare.getIdx()[1], currSquare.getIdx()[0] + 1), -1);
                else if(checkBuffer() == 2)
                    castRay(temp, maze.getSquare(currSquare.getIdx()[1]+1, currSquare.getIdx()[0]), -1);
                else if(checkBuffer() == 3)
                    castRay(temp, maze.getSquare(currSquare.getIdx()[1], currSquare.getIdx()[0]-1), -1);
                
            }
            if(temp.intersection != null) playerVisibility.add(temp); // only add the ray if it actually hit any wall
        }
        
        for(Ray r: playerVisibility)
            r.connectIntersect(); // display the rays
    }

    public void display(){
        pushMatrix();
        translate(maze.getLoc().x, maze.getLoc().y);
        Iterator<MazeSquare> x = track.iterator(); // keep track of player's path
        while(x.hasNext()){
            x.next().display(); // only displays squares that player's have been through
        }
        
        ellipseMode(CENTER);
        noStroke();
        fill(0,255,0);
        if(currSquareIdx[1] < 0){ 
            // uncomment the following 3-lines to for cheat code --> go back into the entrace will get you to the exit //
            // loc.y = maze.getSquare(maze.rows - 1, maze.columns - 1).getLocation().y + maze.squareSize;
            // loc.x += maze.getSquare(maze.rows - 1, maze.columns - 1).getLocation().x; 
            // currSquareIdx = maze.getSquare(maze.rows - 1, maze.columns - 1).getIdx(); 
            
            this.reset(); // ***** then comment this for the cheat code to actually work ****** //
        }else if(currSquareIdx[1] >= maze.allSquares.size()){
            maze.makeMaze(); // restart the maze
            this.reset();
            isDone = true; 
        }
        detectWalls();
        circle(loc.x, loc.y, size);
        popMatrix();        
    }

    public void reset(){ // reset the player to the first square
        currSquare = maze.getSquare(0,0);
        currSquareIdx = currSquare.getIdx();
        loc.x = currSquare.getLocation().x + maze.squareSize/2;
        loc.y = currSquare.getLocation().y + maze.squareSize/2; 
    }

    public void action(boolean[] input){
        move(input);
        display();
    }
}
/************************ Ray ************************/
/*
* This is only an object for the implementation of rays of
* visibility. For the main program please view The_Maze_Runner.pde
*/
public class Ray{
    PVector pos;
    PVector direction = new PVector(0,0);
    PVector intersection = null; // the point of intersection with the targeted boundary
    float heading; // used to created the vector direction

    boolean facingEntry = false;
    boolean facingExit = false;
    public Ray (PVector pos, float angle) {
        this.pos = pos;
        direction.x = cos(radians(angle));
        direction.y = sin(radians(angle));
        this.heading = angle;
    }

    public boolean intersect(PVector start, PVector end){ 
        // L1 = boundary; L2 = ray
        // L1: (x1, y1) = start; (x2, y2) = end
        // L2: (x3, y3) = pos; (x4, y4) = pos + direction
        // https://en.wikipedia.org/wiki/Line%E2%80%93line_intersection

        float x1 = start.x; // boundary
        float y1 = start.y;
        float x2 = end.x;
        float y2 = end.y;

        float x3 = pos.x; // ray
        float y3 = pos.y;
        float x4 = direction.x + pos.x;
        float y4 = direction.y + pos.y;

        float denominator = (x1-x2)*(y3-y4)-(y1-y2)*(x3-x4); // pure math to detect the intersection between two segments
        float t = ((x1-x3)*(y3-y4)-(y1-y3)*(x3-x4))/denominator;
        float u = ((x1-x3)*(y1-y2)-(y1-y3)*(x1-x2))/denominator; 

        if((0 < t && t < 1) && u > 0){
            PVector temp = new PVector(
                (x1 + t*(x2-x1)), (y1 + t*(y2-y1))
            );
            intersection = temp;
            if(intersection.x >= 0 && intersection.x<=15
                && intersection.y == 0) // check facing the entry
                facingEntry = true;
            else if(intersection.x >= 435 && intersection.x <= 450
                && intersection.y == 240)
                facingExit = true; // checking facing the exit
            return true;
        }
        return false;
    }

    public float distanceToIntersection(){ // calculate the distance of player to intersection (Duhhh!!!)
        return dist(pos.x, pos.y, intersection.x, intersection.y);
    }

    public void connectIntersect(){ // draw the ray 
        stroke(255);  
        line(pos.x, pos.y, intersection.x , intersection.y);
    }
}
/************************ Stop Watch ************************/
/*
* This is only an object for stopwatch. For the main program
* please view The_Maze_Runner.pde
*/
public class StopWatch {
    float startTime = 0;
    float endTime = 0;
    boolean running = false; // is the clock still running?
    float bestTime = Float.POSITIVE_INFINITY;  // the best/fastest time of completion

    public void start(){
        if(running) return;
        startTime = millis();
        running = true;
    }

    public void stop(){
        if(!running) return;
        endTime = millis();
        running = false;
    }

    public float getEllapsedTime(){
        if(running) return millis()-startTime;
        return endTime - startTime;
    }

    
    public float millisecond(float t){
        return t % 100; // round to 2 decimals
    }
    
    public float second(float t){ // calculate any given value in ms
        return round(t/1000) % 60;
    }

    public float minute(float t){ // calculate any given value in ms
        return round(t/(1000*60)) % 60;
    }

    public String timeInText(Float t){
        int s;
        int m;
        int ms;
        if(t.isNaN()){ // not calculating specified time -- just the current ellapsed time in general
            s = PApplet.parseInt(this.second(this.getEllapsedTime()));
            m = PApplet.parseInt(this.minute(this.getEllapsedTime()));
            ms = PApplet.parseInt(this.millisecond(this.getEllapsedTime()));
        }else{
            ms = PApplet.parseInt(this.millisecond(t));
            s = PApplet.parseInt(this.second(t));
            m = PApplet.parseInt(this.minute(t));
        }
        

        DecimalFormat df = new DecimalFormat("00");
        
        return df.format(m) + ":" + df.format(s) + "." + df.format(ms);
    }

    public void evaluate(){ // was that the fastest run or no?
        bestTime = (clock.getEllapsedTime() < bestTime) ? clock.getEllapsedTime() : bestTime;
    }

    public String getBestTimeStr(){ // best time but in a proper format instead of ms
        return (Float.isInfinite(bestTime)) ? this.timeInText(0.f) : this.timeInText(bestTime);
    }

    public void display(){
        String currTimeStr = this.timeInText(Float.NaN);
        String bestTimeStr = getBestTimeStr();
        textFont(font, 20);
        
        fill(0,255,0);
        text("Current Time", 106, 570); // label
        text(currTimeStr, 106, 590);
        text("Best Time", 106, 630); // label
        text(bestTimeStr, 106, 650); 
    }

    public void reset(){
        startTime = 0;
        endTime = 0;
    }
}
  public void settings() {  size(1080, 720); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "The_Maze_Runner" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
