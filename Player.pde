public class Player {
    PVector loc = new PVector(0,0);
    PVector velocity = new PVector(0,0);
    float speed = 1;
    int size = 6;

    MazeSquare currSquare;
    int[] currSquareIdx;
    MazeMaker maze;

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

        float[] boundary = currSquare.getBoundary();
        
        if(input[0]){
            velocity.x = -speed;
            if(loc.x + velocity.x < boundary[3] + size/2){
                if(currSquare.isClosed[3])
                    velocity.x = 0;
                else currSquareIdx[0]--;
            }
        }            
        else if(input[2]){
            velocity.x = speed;
            if(loc.x + velocity.x > boundary[1] - size/2){
                if(currSquare.isClosed[1])
                    velocity.x = 0;
                else currSquareIdx[0]++;
            }
        }
        if(input[1]){
            velocity.y = -speed;
            if(loc.y + velocity.y < boundary[0] + size/2){
                if(currSquare.isClosed[0])
                    velocity.y = 0;
                else currSquareIdx[1]--;
            }
        }
        else if(input[3]){
            velocity.y = speed;
            if(loc.y + velocity.y > boundary[2] - size/2){
                if(currSquare.isClosed[2])
                    velocity.y = 0;
                else currSquareIdx[1]++;
            }
        }
        loc.add(velocity);
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
        circle(loc.x, loc.y, size);
        popMatrix();
    }

    void action(boolean[] input){
        move(input);
        display();
    }
}
