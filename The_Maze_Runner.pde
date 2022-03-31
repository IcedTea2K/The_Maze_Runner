import java.util.*;

MazeMaker mainMaze;
void setup() {
    size(1080, 720);
    mainMaze = new MazeMaker(width/2-225, height-250, 450, 240);
}

void draw() {
    background(100);    
    mainMaze.display();
}
