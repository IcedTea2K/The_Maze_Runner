public class StopWatch {
    float startTime = 0;
    float endTime = 0;
    boolean running = false;

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

    void display(){
        String time = this.timeInText(Float.NaN);
        textFont(font, 20);
        noStroke();
        rectMode(CENTER);
        fill(0);
        rect(106, 585, 65, textAscent());
        
        fill(0,255,0);
        text(time, 106, 585 + textAscent()/4);   
    }

    void reset(){
        startTime = 0;
        endTime = 0;
    }
}
