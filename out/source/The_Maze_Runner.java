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

MazeSquare test;
public void setup() {
    
    test = new MazeSquare(width/2,height/2,30);
}

public void draw() {
    background(100);    
    test.display();
    if(frameCount%60 == 0) test.removeSide(0);
    else if(frameCount%90 == 0) test.addSide(0);
}
public class MazeMaker { // create the maze
    PVector size; 
    public MazeMaker (float mazeWidth, float mazeHeight) {
        size.x = mazeWidth;
        size.y = mazeHeight;
    }

}
PVector[] verticies = {new PVector(0,0), new PVector(1,0),
    new PVector(1,1), new PVector(0,1)}; // starts top-left then go clock-wise

public class MazeSquare {
    PVector loc;
    boolean[] isClosed = {true, true, true, true};

    float size;
    public MazeSquare (float xPos, float yPos, float size) {
        loc = new PVector(xPos, yPos);
        this.size = size;
    }

    public void display(){
        stroke(255);
        pushMatrix();
        translate(loc.x, loc.y);
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

    public void removeSide(int side){
        // 0 - left; 1 - top; 2 - right; 3 - bottom
        isClosed[side] = false;
    }

    public void addSide(int side){
        // 0 - left; 1 - top; 2 - right; 3 - bottom        
        isClosed[side] = true;
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
