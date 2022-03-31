MazeSquare test;
void setup() {
    size(1080, 720);
    test = new MazeSquare(width/2,height/2,30);
}

void draw() {
    background(100);    
    test.display();
}
