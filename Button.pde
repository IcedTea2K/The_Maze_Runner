public class Button {
    final String message;
    private float buttonHeight;
    private float buttonWidth;
    private color buttonColor;
    private color txtColor;
    private float widthScalar = 1.5;
    private float heightScalar = 3;
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

    void display(){
        calculateTextBox();
        rectMode(CORNER);

        noStroke();
        fill(buttonColor); // drarw plain button
        rect(pos.x - buttonWidth*(widthScalar-1)/2, pos.y - buttonHeight*(heightScalar-2)/2, buttonWidth * widthScalar, buttonHeight * heightScalar);

        fill(txtColor); // write the text onto the button
        text(message, pos.x, pos.y);
    }
}
