public class Button {
    final String message;
    private float buttonHeight;
    private float buttonWidth;
    private color buttonColor;
    private color txtColor;
    private float widthScalar = 1.5;
    private float heightScalar = 3;
    boolean isActive = false;
    PVector pos;
    float fontSize;
    
    public Button (String message, PVector pos, float fontSize, color buttonColor, color txtColor) {
        this.message = message;
        this.pos = pos;
        this.fontSize = fontSize;
        this.buttonColor = buttonColor;
        this.txtColor = txtColor;
    }

    void calculateTextBox(){
        textSize(fontSize);
        buttonHeight = (textDescent() - textAscent());
        println(buttonHeight);
        buttonWidth = textWidth(message);
    }

    boolean overBox(){ // detect if the mouse is hovering over the box
        return(mouseX > (pos.x - buttonWidth*(widthScalar-1)/2) && mouseX < pos.x - buttonWidth*(widthScalar-1)/2 + buttonWidth*widthScalar
            && mouseY < pos.y - buttonHeight*(heightScalar-2)/2 && mouseY > pos.y - buttonHeight*(heightScalar-2)/2 + buttonHeight * heightScalar);
    }

    void display(){
        calculateTextBox();
        rectMode(CORNER);

        noStroke();
        fill(buttonColor); // drarw plain button
        // some offset to write the text in the middle of the button
        rect(pos.x - buttonWidth*(widthScalar-1)/2, pos.y - buttonHeight*(heightScalar-2)/2, buttonWidth * widthScalar, buttonHeight * heightScalar);

        fill(txtColor); // write the text onto the button
        text(message, pos.x, pos.y);
        println(overBox());
    }

    void activate(){
        isActive = true;
    }

    void deactivate(){
        isActive = false;
    }
}
