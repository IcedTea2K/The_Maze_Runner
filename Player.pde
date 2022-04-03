public class Player {
    PVector loc = new PVector(0,0);
    PVector velocity = new PVector(0,0);
    float speed = 1;
    int size = 6;

    MazeSquare currSquare;
    int[] currSquareIdx;
    MazeMaker maze;
    boolean[] bufferZones = {false, false, false, false}; // the zone between actual boundary and collision boundary
                                                            // top - right - bottom - left

    ArrayList<Ray> playerVisibility = new ArrayList<Ray>();
    public Player (MazeMaker maze, MazeSquare firstSquare) {
        this.maze = maze;
        currSquare = firstSquare;
        currSquareIdx = currSquare.getIdx();
        loc.x = firstSquare.getLocation().x + firstSquare.size/2;
        loc.y = firstSquare.getLocation().y + firstSquare.size/2;
    }

    void move(boolean[] input){
        velocity.x = 0; // reset velocity before taking in inputs
        velocity.y = 0;
        currSquare = maze.getSquare(currSquareIdx[1], currSquareIdx[0]);

        float[] boundary = currSquare.getBoundary(); // actual boundary
        
        if(input[0]){
            velocity.x = -speed;
            if(loc.x + velocity.x < boundary[3] + size/2){ // collision boundary
                if(currSquare.isClosed[3])
                    velocity.x = 0;
                else if(!checkBuffer()) currSquareIdx[0]--;
            }
        }            
        else if(input[2]){
            velocity.x = speed;
            if(loc.x + velocity.x > boundary[1] - size/2){ // collision boundary
                if(currSquare.isClosed[1])
                    velocity.x = 0;
                else if(!checkBuffer()) currSquareIdx[0]++;
            }
        }
        if(input[1]){
            velocity.y = -speed;
            if(loc.y + velocity.y < boundary[0] + size/2){ // collision boundary
                if(currSquare.isClosed[0])
                    velocity.y = 0;
                else if(!checkBuffer()) currSquareIdx[1]--;
            }
        }
        else if(input[3]){
            velocity.y = speed;
            if(loc.y + velocity.y > boundary[2] - size/2){ // collision boundary
                if(currSquare.isClosed[2])
                    velocity.y = 0;
                else if(!checkBuffer()) currSquareIdx[1]++;
            }
        }
        loc.add(velocity); 
        bufferZones[0] = (boundary[0] < loc.y && loc.y< boundary[0] + size/2); // buffer zone  
        bufferZones[1] = (boundary[1] - size/2. < loc.x && loc.x < boundary[1]); // buffer zone
        bufferZones[2] = (boundary[2] - size/2. < loc.y && loc.y < boundary[2]); // buffer zone  
        bufferZones[3] = (boundary[3] < loc.x && loc.x < boundary[3] + size/2); // buffer zone
        println("bufferZones: "+Arrays.toString(bufferZones));
        println("Loc: " + loc + " square's loc: " + currSquare.getLocation() + " # of rays: " + playerVisibility.size());
    }

    boolean checkBuffer(){
        for(int x = 0; x < 4; x++){
            if(bufferZones[x]) return true;
        }  
        return false;
    }

    boolean castRay(Ray targetRay, MazeSquare targetSquare, int entrySide){
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

    void detectWalls(){
        playerVisibility.clear(); // reset everytime

        for(float theta = 0; theta<=360; theta+=0.5){
            Ray temp = new Ray(this.loc.copy(), theta);
            if(castRay(temp, currSquare, -1)) // make use of passing pointers --> doesn't have to return ray
                playerVisibility.add(temp);
        }
        
        for(Ray r: playerVisibility)
            r.connectIntersect(); // display the rays
    }

    void display(){
        pushMatrix();
        translate(maze.getLoc().x, maze.getLoc().y);

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

    void action(boolean[] input){
        move(input);
        display();
    }
}
