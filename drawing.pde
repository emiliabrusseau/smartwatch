void draw()
{
  background(255); //clear background
  noStroke();
  drawWatch(); //draw watch background
  fill(100);
  textSize(24);
  rect(width/2, height/2, sizeOfInputArea, sizeOfInputArea); //input area should be 1" by 1

  // Draw finished screen
  if (finishTime!=0) {
    fill(128);
    textAlign(CENTER);
    text("Finished", 280, 150);
    cursor(ARROW);
    return;
  }

  // Draw starting screen
  if (startTime==0 & !mousePressed) {
    fill(128);
    textAlign(CENTER);
    text("Click to start time!", 280, 150); //display this messsage until the user clicks!
  }

  if (startTime==0 & mousePressed) {
    nextTrial(); //start the trials!
  }

  // Draw typing screen
  if (startTime!=0)
  {
    drawSummaryAndNext();
    drawAllKeys();
    
    // Draw small display of most recent letters typed
    textAlign(LEFT, CENTER);
    textSize(15);
    fill(255);
    String displayText = currentTyped.substring(currentTyped.length() - min(9, currentTyped.length())) + "|";
    text(displayText, width/2-sizeOfInputArea/2, height/2-.42*sizeOfInputArea);
  }
  
  //draw cursor with middle of the finger nail being the cursor point. do not change this.
  image(mouseCursor, mouseX+cursorWidth/2-cursorWidth/3, mouseY+cursorHeight/2-cursorHeight/5, cursorWidth, cursorHeight); //draw user cursor   
}

void drawWatch()
{
  float watchscale = DPIofYourDeviceScreen/144.0;
  pushMatrix();
  translate(width/2, height/2);
  scale(watchscale);
  imageMode(CENTER);
  image(watch, 0, 0);
  popMatrix();
}

void drawSummaryAndNext() {
  //feel free to change the size and position of the target/entered phrases and next button 
  textAlign(LEFT); //align the text left
  fill(128);
  text("Phrase " + (currTrialNum+1) + " of " + totalTrialNum, 70, 50); //draw the trial count
  fill(128);
  text("Target:   " + currentPhrase, 70, 100); //draw the target string
  text("Entered:  " + currentTyped +"|", 70, 140); //draw what the user has entered thus far 

  //draw very basic next button
  fill(255, 0, 0);
  rect(700, 700, 200, 200); //draw next button
  fill(255);
  text("NEXT > ", 650, 650); //draw next label
}

void drawAllKeys() {
  spaceKey.drawKey();
  deleteKey1.drawKey();
  deleteKey2.drawKey();
  for (ButtonKey k : allKeys) {
    k.drawKey();
  }
}
