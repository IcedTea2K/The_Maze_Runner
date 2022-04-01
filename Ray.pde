public class Ray{
    PVector pos;
    PVector direction = new PVector(0,0);
    PVector intersection = null;
    public Ray (PVector pos, float angle) {
        this.pos = pos;
        direction.x = cos(radians(angle));
        direction.y = sin(radians(angle));
    }

    void setDirection(PVector dirPos){
        direction = dirPos.copy().sub(pos);
        direction.normalize();
    }

    void display(){
        pushMatrix();
        fill(255);
        ellipseMode(CENTER);
        circle(pos.x, pos.y, 15);

        stroke(255);
        translate(pos.x, pos.y);
        line(0,0, direction.x*20, direction.y*20);
        popMatrix();
        
    }

    boolean intersect(PVector start, PVector end){
        // L1 = boundary; L2 = ray
        // L1: (x1, y1) = start; (x2, y2) = end
        // L2: (x3, y3) = pos; (x4, y4) = pos + direction
        // https://en.wikipedia.org/wiki/Line%E2%80%93line_intersection

        float x1 = start.x; // boundary
        float y1 = start.y;
        float x2 = end.x;
        float y2 = end.y;

        float x3 = pos.x; // ray
        float y3 = pos.y;
        float x4 = direction.x + pos.x;
        float y4 = direction.y + pos.y;

        float denominator = (x1-x2)*(y3-y4)-(y1-y2)*(x3-x4);
        float t = ((x1-x3)*(y3-y4)-(y1-y3)*(x3-x4))/denominator;
        float u = ((x1-x3)*(y1-y2)-(y1-y3)*(x1-x2))/denominator; 

        if((0 < t && t < 1) && u > 0){
            PVector temp = new PVector(
                (x1 + t*(x2-x1)), (y1 + t*(y2-y1))
            );
            if(intersection == null ||  
                (dist(pos.x, pos.y, intersection.x, intersection.y) > 
                dist(pos.x, pos.y, temp.x, temp.y))){
                    intersection = temp;
            } // calculate the shortest wall
            if((intersection.x == start.x && intersection.y == start.y)
                || (intersection.x == end.x && intersection.x == end.y))
                println("Heck Yeah");
            return true;
        }
        return false;
    }

    void connectIntersect(){        
        line(pos.x, pos.y, intersection.x , intersection.y);
    }
}
