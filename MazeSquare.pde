PVector[] verticies = {new PVector(0,0), new PVector(1,0),
    new PVector(1,1), new PVector(0,1)}; // starts top-left then go clock-wise

public class MazeSquare {
    final PVector loc; // prevent these from being changed later on
    final int[] idx;
    boolean[] isClosed = {true, true, true, true};
    color wallColor = color(255);

    float size;
    boolean alreadyVisited = false;
    boolean isCorrect = false;
    public MazeSquare (float xPos, float yPos, float size, int[] idx) {
        loc = new PVector(xPos, yPos);
        this.size = size;
        this.idx = idx;
    }

    void display(){
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

    void changeColor(color wallColor){
        this.wallColor = wallColor;
    }

    PVector getLocation(){
        return loc;
    }

    int[] getIdx(){
        return idx;
    }
    
    void removeSide(MazeSquare neighbor){
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

    void removeSide(int side){
        isClosed[side] = false;
    }

    void addSide(int side){
        // 0 - left; 1 - top; 2 - right; 3 - bottom        
        isClosed[side] = true;
    }

    void visit(){
        alreadyVisited = true;
    }

    boolean hasVisited(){
        return alreadyVisited;
    }
}
