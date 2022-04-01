public class Ray{
    PVector pos;
    PVector direction = new PVector(0,0);
    public Ray (PVector pos, float angle) {
        this.pos = pos;
        direction.x = cos(radians(angle));
        direction.y = sin(radians(angle));
    }

    // PVector intersection(PVector target){
        
    // }

    void display(){
        pushMatrix();
        translate(mainMaze.getLoc().x, mainMaze.getLoc().y);
        line(pos.x, pos.y, direction.x*20, direction.y*20);
        popMatrix();
        
    }
}
