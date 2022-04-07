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
        rows = int(mazeHeight/squareSize); // calculate properties of maze based on square size
        columns = int(mazeWidth/squareSize);
        this.mazeWidth = mazeWidth;
        this.mazeHeight = mazeHeight;
        createGrid();
        makeMaze();
    }

    void createGrid(){ // simple function to instantiate sufficient number of square and put it into the 2D array
        for(int y = 0; y < rows; y++){            
            allSquares.add(new ArrayList<MazeSquare>());
            for(int x = 0; x < columns; x++){    
                allSquares.get(y).add(new MazeSquare(x*squareSize, y*squareSize, squareSize, new int[] {x,y}));
            }
        }
    }

    void makeMaze(){
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

            int tempRandomNeighborIdx = int(round(random(0, availableNeighbor.size()-1))); // randomly select the neighbors
            currSquare.removeSide(availableNeighbor.get(tempRandomNeighborIdx)); // remove adjacent sides for both squares
            availableNeighbor.get(tempRandomNeighborIdx).removeSide(currSquare);

            availableNeighbor.get(tempRandomNeighborIdx).visit(); // mark the chosen neighbor visited
            visitedSquareStack.push(availableNeighbor.get(tempRandomNeighborIdx)); // push it ontop of the stack    
            availableNeighbor.clear(); // reset the array of available neighbors
        }

        allSquares.get(rows-1).get(columns-1).removeSide(2); // the last square always gets its bottom removed
        allSquares.get(rows-1).get(columns-1).isCorrect = true; // and always belongs to the solution
    }

    void revealSolution(boolean isRevealing){ // display the solution in the 2D map
        for(int x = 0; x < solution.size(); x++){
            solution.get(x).isCorrect = isRevealing;   
        }
    }

    void reset(){ // delete all the squares + create a new maze
        solution.clear();
        allSquares.clear();
        createGrid();
        makeMaze();
    }

    int[] checkNeighbor(MazeSquare square){ // check how many neighbor there are + return their idices 
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

    void drawGrid(){
        pushMatrix();
        translate(loc.x, loc.y); // reset the grid to make it easer to draw the squares
        for(int y = 0; y < rows; y++){
            for(int x = 0; x<columns; x++){
                allSquares.get(y).get(x).display();
            }
        }
        popMatrix();
    }

    void drawBackground(){
        fill(0);
        rectMode(CORNER);
        noStroke();
        rect(loc.x, loc.y, size.x, size.y);        
    }

    void display(boolean isHardCore){
        drawBackground();
        if(!isHardCore) drawGrid(); // the 2D map is invisible in hardocre mode (except for visited ones)
    }

    MazeSquare getSquare(int rowIdx, int colIdx){ // return the specified square
        if(rowIdx <= -1)
            return allSquares.get(rows-1).get(columns-1);
        else if(rowIdx >= rows)
            return allSquares.get(0).get(0); 
        return allSquares.get(rowIdx).get(colIdx);
    }

    PVector getLoc(){
        return loc.copy(); // a copy just to be safe (since it's a pointer) 
    }
}
