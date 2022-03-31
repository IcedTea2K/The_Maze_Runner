public class Player {
    PVector loc = new PVector(0,0);
    PVector velocity = new PVector(0,0);
    PVector mazeLoc;
    float speed = 0.5;
    int size = 3;
    public Player (PVector mazeLoc) {
        this.mazeLoc = mazeLoc;
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
        translate(mazeLoc.x + size/2, mazeLoc.y + size/2);

        ellipseMode(CENTER);
        fill(0,255,0);
        circle(loc.x, loc.y, size);
        popMatrix();
    }
}
