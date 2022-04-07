/************************ Player ************************/
/*
* This is only a class for player. For the main program
* please view The_Maze_Runner.pde
*/
public class Player {
    PVector loc = new PVector(0,0);
    float speed = 0.5;
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

    void move(boolean[] input){ // movement + boundary detection
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
        
        
        bufferZones[0] = (boundary[0] - size/2. <= loc.y && loc.y < boundary[0] + size/2.); // buffer zone  
        bufferZones[1] = (boundary[1] - size/2. < loc.x && loc.x <= boundary[1] + size/2.); // buffer zone
        bufferZones[2] = (boundary[2] - size/2. < loc.y && loc.y <= boundary[2] + size/2.); // buffer zone  
        bufferZones[3] = (boundary[3] - size/2. <= loc.x && loc.x < boundary[3] + size/2.); // buffer zone 
    }

    int checkBuffer(){
        for(int x = 0; x < 4; x++){ // return the index of the activated buffer zone
            if(bufferZones[x]) return x;
        }  
        return -1;
    }
    // utilize passing pointer as parameter --> doesn't have to return that point; instead can return another information 
    // --> essentially returning two things with one function
    boolean castRay(Ray targetRay, MazeSquare targetSquare, int entrySide){ 
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

    void detectWalls(){ // gives the player's visibility
        playerVisibility.clear(); // reset everytime

        for(float theta = -30+ heading; theta<=30+heading; theta+=0.5){ // -30 to +30 is player's field of vision (FOV)
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

    void display(){
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

    void reset(){ // reset the player to the first square
        currSquare = maze.getSquare(0,0);
        currSquareIdx = currSquare.getIdx();
        loc.x = currSquare.getLocation().x + maze.squareSize/2;
        loc.y = currSquare.getLocation().y + maze.squareSize/2; 
    }

    void action(boolean[] input){
        move(input);
        display();
    }
}
