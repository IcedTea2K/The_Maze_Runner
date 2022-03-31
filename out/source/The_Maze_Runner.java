import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class The_Maze_Runner extends PApplet {

MazeMaker testMaze;
public void setup() {
    
    testMaze = new MazeMaker(width/2-225, height-250, 450, 240);
}

public void draw() {
    background(100);    
    testMaze.display();
}
public class MazeMaker { // create the maze
    PVector size; 
    PVector loc;    
    int rows;
    int columns;

    int squareSize = 15;
    ArrayList<ArrayList<MazeSquare>> allSquares = new ArrayList<ArrayList<MazeSquare>>(); // 2D array to replicate the grid

    public MazeMaker (float xPos, float yPos, float mazeWidth, float mazeHeight) {
        loc = new PVector(xPos, yPos);
        size = new PVector(mazeWidth, mazeHeight);
        rows = PApplet.parseInt(mazeHeight/squareSize); // 10 = square's size
        columns = PApplet.parseInt(mazeWidth/squareSize);
        createGrid();
    }

    public void createGrid(){
                
        for(int y = 0; y < rows; y++){            
            allSquares.add(new ArrayList<MazeSquare>());
            for(int x = 0; x < columns; x++){    
                allSquares.get(y).add(new MazeSquare(x*squareSize, y*squareSize, squareSize));
                       
            }
        }
       for(int y = 0; y < rows; y++){
            for(int x = 0; x<columns; x++){
                println(allSquares.get(y).get(x).info().x + " " + allSquares.get(y).get(x).info().y);
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
        drawGrid();
    }
}
PVector[] verticies = {new PVector(0,0), new PVector(1,0),
    new PVector(1,1), new PVector(0,1)}; // starts top-left then go clock-wise

public class MazeSquare {
    PVector loc;
    boolean[] isClosed = {true, true, true, true};

    float size;
    boolean alreadyVisited = false;
    public MazeSquare (float xPos, float yPos, float size) {
        loc = new PVector(xPos, yPos);
        this.size = size;
    }

    public void display(){
        stroke(255);
        pushMatrix();
        translate(loc.x, loc.y); // move to desired location
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

    public PVector info(){
        return loc;
    }
    
    public void removeSide(int side){
        // 0 - left; 1 - top; 2 - right; 3 - bottom
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
