import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class The_Maze_Runner extends PApplet {


MazeMaker mainMaze;
Player mainPlayer;

Ray test;
ArrayList<Ray> allRays = new ArrayList<Ray>();
PVector[][] boundary = new PVector[10][2];
PVector[] outerBoundary = new PVector[4];

boolean[] direction = new boolean[4];

public void setup() {
    
    mainMaze = new MazeMaker(width/2-225, height-250, 450, 240);
    mainPlayer = new Player(mainMaze, mainMaze.getSquare(0,0));
}

public void draw() {
    background(100);    
    mainMaze.display();
    mainPlayer.action(direction);
}

public void setDirection (int k, boolean isOn) { // record pressed keys (direction)
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


public void keyPressed() {
  if (key == CODED) setDirection(keyCode, true);
}

public void keyReleased() {
  if(key==CODED) setDirection(keyCode, false);
}
public class MazeMaker { // create the maze
    PVector size; 
    final PVector loc;    
    int rows;
    int columns;

    int squareSize = 15;
    ArrayList<ArrayList<MazeSquare>> allSquares = new ArrayList<ArrayList<MazeSquare>>(); // 2D array to replicate the grid
    ArrayList<MazeSquare> solution = new ArrayList<MazeSquare>();
    Stack<MazeSquare> visitedSquareStack = new Stack<MazeSquare>();

    public MazeMaker (float xPos, float yPos, float mazeWidth, float mazeHeight) {
        loc = new PVector(xPos, yPos);
        size = new PVector(mazeWidth, mazeHeight);
        rows = PApplet.parseInt(mazeHeight/squareSize); // 10 = square's size
        columns = PApplet.parseInt(mazeWidth/squareSize);
        createGrid();
        makeMaze();
    }

    public void makeMaze(){
        visitedSquareStack.push(allSquares.get(0).get(0)); // inital cell is always the first square on top left
        allSquares.get(0).get(0).visit();
        allSquares.get(0).get(0).removeSide(0);

        ArrayList<MazeSquare> availableNeighbor = new ArrayList<MazeSquare>();
        MazeSquare lastRightSquare = allSquares.get(0).get(0);
        boolean reached = false;
        while(!visitedSquareStack.empty()){
            MazeSquare currSquare = visitedSquareStack.pop();

            int[] neighborIdx = checkNeighbor(currSquare);
            
            for(int x = 0; x < 4; x++){
                if(neighborIdx[x] == -1) continue;
                    
                if(x%2 == 0 && !allSquares.get(currSquare.getIdx()[1]).get(neighborIdx[x]).hasVisited())
                    availableNeighbor.add(allSquares.get(currSquare.getIdx()[1]).get(neighborIdx[x]));
                else if(x%2 != 0 && !allSquares.get(neighborIdx[x]).get(currSquare.getIdx()[0]).hasVisited())   
                    availableNeighbor.add(allSquares.get(neighborIdx[x]).get(currSquare.getIdx()[0]));
            }

            if(reached) {
                currSquare.isCorrect = true;
                solution.add(currSquare);
            }
            
            if(availableNeighbor.size() == 0) {
                if(currSquare.getIdx()[0] == columns-1 && currSquare.getIdx()[1] == rows-1 || currSquare == lastRightSquare){
                    
                    reached = true;
                }
                continue;
            }else if(availableNeighbor.size() != 0 && reached){
                lastRightSquare = currSquare;
                reached = false;
            }

            visitedSquareStack.push(currSquare);

            int tempRandomNeighborIdx = PApplet.parseInt(round(random(0, availableNeighbor.size()-1)));
            currSquare.removeSide(availableNeighbor.get(tempRandomNeighborIdx)); // remove adjacent sides
            availableNeighbor.get(tempRandomNeighborIdx).removeSide(currSquare);


            availableNeighbor.get(tempRandomNeighborIdx).visit(); // mark the chosen neighbor visited
            visitedSquareStack.push(availableNeighbor.get(tempRandomNeighborIdx));      
            availableNeighbor.clear(); // reset
        }
        println(solution.size());
        allSquares.get(rows-1).get(columns-1).removeSide(2);
        allSquares.get(rows-1).get(columns-1).isCorrect = true;
    }

    public int[] checkNeighbor(MazeSquare square){
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

    public void createGrid(){
        for(int y = 0; y < rows; y++){            
            allSquares.add(new ArrayList<MazeSquare>());
            for(int x = 0; x < columns; x++){    
                allSquares.get(y).add(new MazeSquare(x*squareSize, y*squareSize, squareSize, new int[] {x,y}));
                       
            }
        }
    }

    public void drawGrid(){
        pushMatrix();
        translate(loc.x, loc.y); // reset the grid to make it easer to draw the squares
        for(int y = 0; y < rows; y++){
            for(int x = 0; x<columns; x++){
                allSquares.get(y).get(x).display();
                // println(allSquares.get(y).get(x).info().x + " " + allSquares.get(y).get(x).info().y);
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

    public void display(){
        drawBackground();
        // drawGrid();
    }

    public MazeSquare getSquare(int rowIdx, int colIdx){ // return the specified square
        if(rowIdx <= -1)
            return allSquares.get(rows-1).get(columns-1);
        else if(rowIdx >= rows)
            return allSquares.get(0).get(0); 
        return allSquares.get(rowIdx).get(colIdx);
    }

    public PVector getLoc(){
        return loc; 
    }
}
PVector[] verticies = {new PVector(0,0), new PVector(1,0),
    new PVector(1,1), new PVector(0,1)}; // starts top-left then go clock-wise

public class MazeSquare implements Comparable<MazeSquare>{
    final PVector loc; // prevent these from being changed later on
    final int[] idx;
    boolean[] isClosed = {true, true, true, true};
    int wallColor = color(255);

    float size;
    boolean alreadyVisited = false;
    boolean isCorrect = false;
    public MazeSquare (float xPos, float yPos, float size, int[] idx) {
        loc = new PVector(xPos, yPos);
        this.size = size;
        this.idx = idx;
    }

    public int compareTo(MazeSquare s){
        return PApplet.parseInt(PVector.sub(this.loc, new PVector(0,0)).magSq());
    }

    public void display(){
        pushMatrix();
        translate(loc.x, loc.y); // move to desired location
        if(isCorrect){
            fill(255,0,0);
            noStroke();
            rectMode(CORNER);
            rect(0, 0, size, size);
        }

        stroke(wallColor);
        for(int x = 0; x < 4; x++){
            if(isClosed[x]){
                if(x != 3)
                    line(verticies[x].x*size, verticies[x].y*size, verticies[x+1].x*size, verticies[x+1].y*size);
                else
                    line(verticies[x].x*size, verticies[x].y*size, verticies[0].x*size, verticies[0].y*size);  
            }
        }
        
        popMatrix();
        
    }

    public void changeColor(int wallColor){
        this.wallColor = wallColor;
    }

    public PVector getLocation(){
        return loc.copy();
    }

    public float[] getBoundary(){
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

    public PVector[] getBoundaryVerticies(){ 
       PVector[] boundary = new PVector[4];
       
       boundary[0] = new PVector(loc.x,loc.y);
       boundary[1] = new PVector(width,0);
       boundary[2] = new PVector(width,height);
       boundary[3] = new PVector(0,height);
       for(int x = 0; x < 4; x++){
           boundary[x] = new PVector(loc.x + verticies[x].x*size, loc.y + verticies[x].y*size);
        }
        return boundary;
    }

    public int[] getIdx(){
        return idx.clone();
    }
    
    public void removeSide(MazeSquare neighbor){
        // 0 - left; 1 - top; 2 - right; 3 - bottom
        int tempColumnIdxDiff = neighbor.getIdx()[0] - idx[0]; 
        int tempRowIdxDiff = neighbor.getIdx()[1] - idx[1];

        if(tempColumnIdxDiff < 0)
            isClosed[3] = false;
        else if(tempRowIdxDiff < 0)
            isClosed[0] = false;
        else if(tempColumnIdxDiff > 0)
            isClosed[1] = false;
        else if(tempRowIdxDiff > 0)
            isClosed[2] = false;
    }

    public void removeSide(int side){
        isClosed[side] = false;
    }

    public void addSide(int side){
        // 0 - left; 1 - top; 2 - right; 3 - bottom        
        isClosed[side] = true;
    }

    public void visit(){
        alreadyVisited = true;
    }

    public boolean hasVisited(){
        return alreadyVisited;
    }
}
public class Player {
    PVector loc = new PVector(0,0);
    PVector velocity = new PVector(0,0);
    float speed = 1.5f;
    int size = 6;

    MazeSquare currSquare;
    int[] currSquareIdx;
    MazeMaker maze;
    boolean[] bufferZones = {false, false, false, false}; // the zone between actual boundary and collision boundary
                                                            // top - right - bottom - left
    SortedSet<MazeSquare> track = new TreeSet<MazeSquare>();
    ArrayList<Ray> playerVisibility = new ArrayList<Ray>();
    public Player (MazeMaker maze, MazeSquare firstSquare) {
        this.maze = maze;
        currSquare = firstSquare;
        currSquareIdx = currSquare.getIdx();
        loc.x = firstSquare.getLocation().x + firstSquare.size/2;
        loc.y = firstSquare.getLocation().y + firstSquare.size/2;
    }

    public void move(boolean[] input){
        velocity.x = 0; // reset velocity before taking in inputs
        velocity.y = 0;
        currSquare = maze.getSquare(currSquareIdx[1], currSquareIdx[0]);

        float[] boundary = currSquare.getBoundary(); // actual boundary
        
        if(input[0]){
            velocity.x = -speed;
            if(loc.x + velocity.x < boundary[3] + size/2){ // collision boundary
                if(currSquare.isClosed[3])
                    velocity.x = 0;
                else if(loc.x + velocity.x < boundary[1]) currSquareIdx[0]--;
            }
        }            
        else if(input[2]){
            velocity.x = speed;
            if(loc.x + velocity.x > boundary[1] - size/2){ // collision boundary
                if(currSquare.isClosed[1])
                    velocity.x = 0;
                else if(loc.x + velocity.x > boundary[3]) currSquareIdx[0]++;
            }
        }
        if(input[1]){
            velocity.y = -speed;
            if(loc.y + velocity.y < boundary[0] + size/2){ // collision boundary
                if(currSquare.isClosed[0])
                    velocity.y = 0;
                else if(loc.y + velocity.y < boundary[2]) currSquareIdx[1]--;
            }
        }
        else if(input[3]){
            velocity.y = speed;
            if(loc.y + velocity.y > boundary[2] - size/2){ // collision boundary
                if(currSquare.isClosed[2])
                    velocity.y = 0;
                else if(loc.y + velocity.y > boundary[0]) currSquareIdx[1]++;
            }
        }
        loc.add(velocity);
        track.add(currSquare);

        bufferZones[0] = (boundary[0] <= loc.y && loc.y < boundary[0] + size/2); // buffer zone  
        bufferZones[1] = (boundary[1] - size/2.f < loc.x && loc.x <= boundary[1]); // buffer zone
        bufferZones[2] = (boundary[2] - size/2.f < loc.y && loc.y <= boundary[2]); // buffer zone  
        bufferZones[3] = (boundary[3] <= loc.x && loc.x < boundary[3] + size/2); // buffer zone 
        println("bufferZones: "+Arrays.toString(bufferZones));
        println("Loc: " + loc + " square's loc: " + currSquare.getLocation() + " # of rays: " + playerVisibility.size());
    }

    public int checkBuffer(){
        for(int x = 0; x < 4; x++){
            if(bufferZones[x]) return x;
        }  
        return -1;
    }

    public boolean castRay(Ray targetRay, MazeSquare targetSquare, int entrySide){
       int intersectedSide = -1;       
       PVector[] squareBoundary = targetSquare.getBoundaryVerticies(); // get the boundary

       for(int z = 0; z < 4; z++){
            if(entrySide == z) continue; // prevent infinite recursion
            if(z != 3){
                intersectedSide = (targetRay.intersect(squareBoundary[z], squareBoundary[z+1])) ? z : intersectedSide;
            }else{
                intersectedSide = (targetRay.intersect(squareBoundary[0], squareBoundary[3])) ? 3 : intersectedSide;
            }
        } 
        if(intersectedSide == -1) return false; // precaution against when the ray doesn't intersect any of the 4 sides for some reason

        int[] squareIdx = targetSquare.getIdx();
        
        if((Arrays.equals(squareIdx, new int[]{0,0}) && intersectedSide == 0) || 
            (Arrays.equals(squareIdx, new int[]{maze.columns-1,maze.rows-1}) && intersectedSide == 2)){
            return true;
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

    public void detectWalls(){
        playerVisibility.clear(); // reset everytime

        for(float theta = 0; theta<=360; theta+=0.5f){
            Ray temp = new Ray(this.loc.copy(), theta);
            if(castRay(temp, currSquare, -1)) // make use of passing pointers --> doesn't have to return ray
                playerVisibility.add(temp);
            else if(checkBuffer() != -1){
                if(checkBuffer() == 0)
                    castRay(temp, maze.getSquare(currSquare.getIdx()[1]-1, currSquare.getIdx()[0]), -1);
                else if(checkBuffer() == 1)
                    castRay(temp, maze.getSquare(currSquare.getIdx()[1], currSquare.getIdx()[0] + 1), -1);
                else if(checkBuffer() == 2)
                    castRay(temp, maze.getSquare(currSquare.getIdx()[1]+1, currSquare.getIdx()[0]), -1);
                else if(checkBuffer() == 3)
                    castRay(temp, maze.getSquare(currSquare.getIdx()[1], currSquare.getIdx()[0]-1), -1);
                if(temp.intersection != null) playerVisibility.add(temp);
            }
        }
        if(playerVisibility.size() == 0) println("Heck Yeah");
        for(Ray r: playerVisibility)
            r.connectIntersect(); // display the rays
    }

    public void display(){
        pushMatrix();
        translate(maze.getLoc().x, maze.getLoc().y);
        Iterator<MazeSquare> x = track.iterator();
        while(x.hasNext()){
            x.next().display();
        }
        println(track.size());
        ellipseMode(CENTER);
        noStroke();
        fill(0,255,0);
        if(currSquareIdx[1] < 0){
            loc.y = maze.getSquare(maze.rows - 1, maze.columns - 1).getLocation().y + maze.squareSize;
            loc.x += maze.getSquare(maze.rows - 1, maze.columns - 1).getLocation().x; 

            currSquareIdx = maze.getSquare(maze.rows - 1, maze.columns - 1).getIdx(); 
        }else if(currSquareIdx[1] >= maze.allSquares.size()){
            loc.y = maze.getSquare(0,0).getLocation().y;
            loc.x -= currSquare.getLocation().x;

            currSquareIdx = maze.getSquare(0,0).getIdx();
        }
        detectWalls();
        circle(loc.x, loc.y, size);
        popMatrix();        
    }

    public void action(boolean[] input){
        move(input);
        display();
    }
}
public class Ray{
    PVector pos;
    PVector direction = new PVector(0,0);
    PVector intersection = null;
    public Ray (PVector pos, float angle) {
        this.pos = pos;
        direction.x = cos(radians(angle));
        direction.y = sin(radians(angle));
    }

    public void setDirection(PVector dirPos){
        direction = dirPos.copy().sub(pos);
        direction.normalize();
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

        float denominator = (x1-x2)*(y3-y4)-(y1-y2)*(x3-x4);
        float t = ((x1-x3)*(y3-y4)-(y1-y3)*(x3-x4))/denominator;
        float u = ((x1-x3)*(y1-y2)-(y1-y3)*(x1-x2))/denominator; 

        if((0 < t && t < 1) && u > 0){
            PVector temp = new PVector(
                (x1 + t*(x2-x1)), (y1 + t*(y2-y1))
            );
            intersection = temp;
            return true;
        }
        return false;
    }

    public void connectIntersect(){
        stroke(255);  
        line(pos.x, pos.y, intersection.x , intersection.y);
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
