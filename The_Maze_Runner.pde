MazeMaker testMaze;
void setup() {
    size(1080, 720);
    testMaze = new MazeMaker(width/2, height-125, 450, 250);
}

void draw() {
    background(100);    
    testMaze.display();
}
