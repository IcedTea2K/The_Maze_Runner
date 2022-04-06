public class StopWatch {
    float startTime = 0;
    float endTime = 0;
    boolean running = false;
    float bestTime = Float.POSITIVE_INFINITY;  // the best/fastest time of completion

    void start(){
        if(running) return;
        startTime = millis();
        running = true;
    }

    void stop(){
        if(!running) return;
        endTime = millis();
        running = false;
    }

    float getEllapsedTime(){
        if(running) return millis()-startTime;
        return endTime - startTime;
    }

    
    float millisecond(float t){
        return t % 100; // round to 2 decimals
    }
    
    float second(float t){ // calculate any given value in ms
        return round(t/1000) % 60;
    }

    float minute(float t){
        return round(t/(1000*60)) % 60;
    }

    String timeInText(Float t){
        int s;
        int m;
        int ms;
        if(t.isNaN()){ // not calculating specified time -- just the current ellapsed time in general
            s = int(this.second(this.getEllapsedTime()));
            m = int(this.minute(this.getEllapsedTime()));
            ms = int(this.millisecond(this.getEllapsedTime()));
        }else{
            ms = int(this.millisecond(t));
            s = int(this.second(t));
            m = int(this.minute(t));
        }
        

        DecimalFormat df = new DecimalFormat("00");
        
        return df.format(m) + ":" + df.format(s) + "." + df.format(ms);
    }

    void evaluate(){
        bestTime = (clock.getEllapsedTime() < bestTime) ? clock.getEllapsedTime() : bestTime;
    }

    void display(){
        String currTimeStr = this.timeInText(Float.NaN);
        String bestTimeStr = (Float.isInfinite(bestTime)) ? this.timeInText(0.) : this.timeInText(bestTime);
        textFont(font, 20);
        
        fill(0,255,0);
        text("Current Time", 106, 570);
        text(currTimeStr, 106, 590);
        text("Best Time", 106, 630);
        text(bestTimeStr, 106, 650); 
    }

    void reset(){
        startTime = 0;
        endTime = 0;
    }
}
