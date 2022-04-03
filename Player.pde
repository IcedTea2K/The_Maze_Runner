public class Player {
    PVector loc = new PVector(0,0);
    PVector velocity = new PVector(0,0);
    float speed = 1.5;
    int size = 6;
    float heading = 0;

    MazeSquare currSquare;
    int[] currSquareIdx;
    MazeMaker maze;
    boolean[] bufferZones = {false, false, false, false}; // the zone between actual boundary and collision boundary
                                                            // top - right - bottom - left
    HashSet<MazeSquare> track = new HashSet<MazeSquare>();
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

        PVector direction;
        if(input[0]) // rotate
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
            return;
        }

        float[] boundary = currSquare.getBoundary(); // actual boundary
        PVector futureLoc = PVector.add(direction, loc);
        
        if(futureLoc.x <= boundary[3] + size/2){ // collision boundary
            if(currSquare.isClosed[3])
                direction.setMag(0);
            else if(futureLoc.x < boundary[3]) currSquareIdx[0]--;
        }else if(futureLoc.x >= boundary[1] - size/2){ // collision boundary
            if(currSquare.isClosed[1])
                direction.setMag(0);
            else if(futureLoc.x > boundary[1]) currSquareIdx[0]++;
        }
        if(futureLoc.y <= boundary[0] + size/2){ // collision boundary
            if(currSquare.isClosed[0])
                direction.setMag(0);
            else if(futureLoc.y < boundary[0]) currSquareIdx[1]--;
        }else if(futureLoc.y >= boundary[2] - size/2){ // collision boundary
            if(currSquare.isClosed[2])
                direction.setMag(0);
            else if(futureLoc.y > boundary[2]) currSquareIdx[1]++;
        }
        println("futureLoc: "+futureLoc);
        println("boundary: "+Arrays.toString(boundary)); 
        println(Arrays.toString(currSquareIdx));
        loc.add(direction);
        track.add(currSquare);

        bufferZones[0] = (boundary[0] <= loc.y && loc.y < boundary[0] + size/2); // buffer zone  
        bufferZones[1] = (boundary[1] - size/2. < loc.x && loc.x <= boundary[1]); // buffer zone
        bufferZones[2] = (boundary[2] - size/2. < loc.y && loc.y <= boundary[2]); // buffer zone  
        bufferZones[3] = (boundary[3] <= loc.x && loc.x < boundary[3] + size/2); // buffer zone 
    }

    int checkBuffer(){
        for(int x = 0; x < 4; x++){
            if(bufferZones[x]) return x;
        }  
        return -1;
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

    void detectWalls(){ // gives the player's visibility
        playerVisibility.clear(); // reset everytime

        for(float theta = -45 + heading; theta<=45+heading; theta+=0.5){
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
