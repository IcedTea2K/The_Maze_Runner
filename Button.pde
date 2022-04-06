public class Button {
    final String message;
    private float buttonHeight;
    private float buttonWidth;
    private color buttonColor;
    private color txtColor;
    private float widthScalar = 2;
    private float heightScalar = 2;
    boolean isActive = false; // depends one which scene, a button can be either activated or deactivated
    PVector pos;
    float fontSize;
    
    public Button (String message, PVector pos, float fontSize, boolean isActive, color buttonColor, color txtColor) {
        this.message = message;
        this.pos = pos;
        this.fontSize = fontSize;
        this.buttonColor = buttonColor;
        this.txtColor = txtColor;
        this.isActive = isActive;
    }

    void calculateTextBox(){
        textSize(fontSize);
        buttonHeight = textAscent() * heightScalar;
        buttonWidth = textWidth(message) * widthScalar;
    }

    boolean overBox(){ // detect if the mouse is hovering over the box
        return(mouseX > pos.x - buttonWidth/2 && mouseX < pos.x + buttonWidth/2)
            && mouseY > (pos.y - buttonHeight/2)
                && mouseY < (pos.y + buttonHeight/2);
    }

    void display(){
        calculateTextBox();
        rectMode(CENTER);

        noStroke();
        fill(buttonColor); // draw plain button
        rect(pos.x, pos.y, buttonWidth, buttonHeight);
        
        textAlign(CENTER);
        fill(txtColor); // write the text onto the button
        text(message, pos.x, pos.y + buttonHeight/(heightScalar * 2)); // padding (or scale) * 2 will make the text appear in the middle
    }

    void activate(){
        isActive = true;
    }

    void deactivate(){
        isActive = false;
    }
}
