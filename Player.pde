public class Player {
    PVector loc = new PVector(0,0);
    PVector velocity = new PVector(0,0);
    PVector mazeLoc;
    float speed = 0.5;
    int size = 7;
    public Player (PVector mazeLoc, MazeSquare firstSquare) {
        this.mazeLoc = mazeLoc;
        loc.x = firstSquare.getLocation().x + firstSquare.size/2;
        loc.y = firstSquare.getLocation().y + firstSquare.size/2;
    }

    void move(boolean[] input){
        velocity.x = 0; // reset velocity before taking in inputs
        velocity.y = 0;
        if(input[0])
            velocity.x = -speed;
        else if(input[2])
            velocity.x = speed;
        if(input[1])
            velocity.y = -speed;
        else if(input[3])
            velocity.y = speed;
        loc.add(velocity);
    }

    void display(){
        pushMatrix();
        translate(mazeLoc.x, mazeLoc.y);

        ellipseMode(CENTER);
        fill(0,255,0);
        circle(loc.x, loc.y, size);
        popMatrix();
    }

    void action(boolean[] input){
        move(input);
        display();
    }
}
