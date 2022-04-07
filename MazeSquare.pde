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
    color wallColor = color(255);

    float size;
    boolean alreadyVisited = false; // status of the square
    boolean isCorrect = false; // also status of the square
    public MazeSquare (float xPos, float yPos, float size, int[] idx) {
        loc = new PVector(xPos, yPos);
        this.size = size;
        this.idx = idx;
    }

    void display(){
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

    PVector getLocation(){
        return loc.copy();
    }

    float[] getBoundary(){ // return the boundaries of the box
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

    PVector[] getBoundaryVerticies(){  // return the verticies of the boundary in actual units (instead of just the signs)
       PVector[] boundary = new PVector[4];
       
       for(int x = 0; x < 4; x++){
           boundary[x] = new PVector(loc.x + verticies[x].x*size, loc.y + verticies[x].y*size);
        }
        return boundary;
    }

    int[] getIdx(){
        return idx.clone(); // clone just to be safe
    }
    
    void removeSide(MazeSquare neighbor){
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

    void removeSide(int side){ // remove a specific side
        isClosed[side] = false;
    }

    void addSide(int side){
        // 3 - left; 0 - top; 1 - right; 2 - bottom        
        isClosed[side] = true;
    }

    void visit(){ // mark this square as visited
        alreadyVisited = true;
    }

    boolean hasVisited(){ // return the availaibility of this square
        return alreadyVisited;
    }
}
