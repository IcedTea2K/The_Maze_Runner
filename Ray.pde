public class Ray{
    PVector pos;
    PVector direction = new PVector(0,0);
    PVector intersection = null; // the point of intersection with the targeted boundary
    float heading; // used to created the vector direction

    boolean facingEntry = false;
    boolean facingExit = false;
    public Ray (PVector pos, float angle) {
        this.pos = pos;
        direction.x = cos(radians(angle));
        direction.y = sin(radians(angle));
        this.heading = angle;
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

        float denominator = (x1-x2)*(y3-y4)-(y1-y2)*(x3-x4); // pure math to detect the intersection between two segments
        float t = ((x1-x3)*(y3-y4)-(y1-y3)*(x3-x4))/denominator;
        float u = ((x1-x3)*(y1-y2)-(y1-y3)*(x1-x2))/denominator; 

        if((0 < t && t < 1) && u > 0){
            PVector temp = new PVector(
                (x1 + t*(x2-x1)), (y1 + t*(y2-y1))
            );
            intersection = temp;
            if(intersection.x >= 0 && intersection.x<=15
                && intersection.y == 0) // check facing the entry
                facingEntry = true;
            else if(intersection.x >= 435 && intersection.x <= 450
                && intersection.y == 240)
                facingExit = true; // checking facing the exit
            return true;
        }
        return false;
    }

    float distanceToIntersection(){ // calculate the distance of player to intersection (Duhhh!!!)
        return dist(pos.x, pos.y, intersection.x, intersection.y);
    }

    void connectIntersect(){ // draw the ray 
        stroke(255);  
        line(pos.x, pos.y, intersection.x , intersection.y);
    }
}
