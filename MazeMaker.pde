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
        rows = int(mazeHeight/squareSize); // 10 = square's size
        columns = int(mazeWidth/squareSize);
        createGrid();
    }

    void createGrid(){
                
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

    void drawGrid(){
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

    void drawBackground(){
        fill(0);
        rectMode(CORNER);
        noStroke();
        rect(loc.x, loc.y, size.x, size.y);        
    }

    void display(){
        drawBackground();
        drawGrid();
    }
}
