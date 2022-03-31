public class MazeMaker { // create the maze
    PVector size; 
    PVector loc;
    public MazeMaker (float xPos, float yPos, float mazeWidth, float mazeHeight) {
        loc = new PVector(xPos, yPos);
        size = new PVector(mazeWidth, mazeHeight);
    }

    void grid(){

    }

    void gridBg(){
        fill(0);
        rectMode(CENTER);
        noStroke();
        rect(loc.x, loc.y, size.x, size.y);        
    }

    void display(){
        gridBg();
        grid();
    }
}
