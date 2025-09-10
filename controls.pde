void mousePressed()
{ 
  //You are allowed to have a next button outside the 1" area
  if (mouseX > 600 && mouseX<600+200 && mouseY>600 && mouseY<600+200) //check if click is in next button
  {
    nextTrial(); //if so, advance to next trial
    return;
  }
  else if (currentPhrase.length() == 0 || !clickedInsideWatch())
    return;
  
  if (deleteKey1.clickedIn() || deleteKey2.clickedIn())
    handleDelete();
  else if (spaceKey.clickedIn()) {
    currWord = "";
    currentTyped += " ";
  }
  else {
    ArrayList<Pair> pribs = getOverallLetterProbs();
    Pair closestKey = pribs.get(0);
    String keyClickedIn = closestKey.label;
    currWord += keyClickedIn;
    currentTyped += keyClickedIn;
  }
  
  if (currentTyped.length() > disallowedKeys.size())
    disallowedKeys.add(new HashSet<String>());
  assert abs(disallowedKeys.size() - currentTyped.length()) <= 1 : "Incorrect disallowedKeys size (28)";
}

void handleDelete() {
  if (currWord.length() > 0)
    currWord = currWord.substring(0, currWord.length()-1);
   
  if (currentTyped.length() > 0) {
    assert abs(disallowedKeys.size() - currentTyped.length()) <= 1: "Incorrect disallowedKeys size (37)";
    
    String deletedChar = currentTyped.substring(currentTyped.length()-1, currentTyped.length());
    HashSet<String> currDisallowedKeys = disallowedKeys.get(currentTyped.length() - 1);
    currDisallowedKeys.add(deletedChar);
    
    currentTyped = currentTyped.substring(0, currentTyped.length()-1);
  }
  
  if (disallowedKeys.size() - currentTyped.length() > 1)
    disallowedKeys.remove(disallowedKeys.size() - 1);
}
