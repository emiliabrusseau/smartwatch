int mod(int n, int d) {
  return ((n % d) + d) % d;
}

float distance(float x1, float y1, float x2, float y2) {
  return sqrt(pow(x1 - x2, 2) + pow(y1 - y2, 2));
}

boolean clickedInRect(float cx, float cy, float rectWidth, float rectHeight) {
  return (cx - rectWidth/2  <= mouseX && mouseX <= cx + rectWidth/2 &&
          cy - rectHeight/2 <= mouseY && mouseY <= cy + rectHeight/2);
}

boolean clickedInsideWatch() {
  return clickedInRect(width/2, height/2, sizeOfInputArea, sizeOfInputArea);
}

String getKeyClickedIn() {
  for (ButtonKey k : allKeys) {
    if (k.clickedIn())
      return k.getLabel();
  }
  return "";
}

// Uses the 3 letter probability if at least 3 letters are in word,
// 2 if two letters exist, and just returns the constant 1 otherwise
float getNgramProb(String word) {
  if (word.length() < 2)
      return 1;
  else if (word.length() == 2)
      return P2l.getProb(word);
  String letter3 = word.substring(word.length() - 3);
  return P3l.getProb(letter3);
}

void normalizePairList(ArrayList<Pair> L) {
  float minVal = Float.MAX_VALUE;
  float maxVal = Float.MIN_VALUE;
  
  for (Pair p : L) {
    if (p.value < minVal) {
      minVal = p.value;
    }
    if (p.value > maxVal) {
      maxVal = p.value;
    }
  }

  if (minVal == maxVal)
    return;

  for (Pair p : L) {
    p.value = (p.value - minVal) / (maxVal - minVal);
  }
}

ArrayList<Pair> getNormalizedKetDistances() {
  ArrayList<Pair> dists = new ArrayList<Pair>();
  for (ButtonKey k : allKeys) {
    dists.add(new Pair(k.getLabel(), distance(mouseX, mouseY, k.cx, k.cy)));
  }
  
  normalizePairList(dists);
  return dists;
}

ArrayList<Pair> getNormalizedNgramProbs(String prevLetters) {
  ArrayList<Pair> probs = new ArrayList<Pair>();
  for (ButtonKey k : allKeys) {
    float ngramProb = getNgramProb(prevLetters + k.label);
    probs.add(new Pair(k.getLabel(), ngramProb));
  }
  normalizePairList(probs);
  return probs;
}

ArrayList<Pair> getOverallLetterProbs() {
  ArrayList<Pair> dists = getNormalizedKetDistances();
  ArrayList<Pair> probs = getNormalizedNgramProbs(currWord);
  
  ArrayList<Pair> res = new ArrayList<>();
  for (int i = 0; i < dists.size(); i++) {
    Pair d = dists.get(i);
    Pair p = probs.get(i);
    assert d.label == p.label : "Mismatch probabilities";
    
    float weight = 0.9;
    HashSet<String> currDisallowedKeys = currentTyped.length() >= disallowedKeys.size() ? new HashSet<>() : disallowedKeys.get(currentTyped.length());
    if (currDisallowedKeys.contains(d.label))
      res.add(new Pair(d.label, 0));
    else
      res.add(new Pair(d.label, (1-d.value)*weight + p.value*(1-weight))); // 1 - d.value so that closer keys have a larger probability
  }
  
  Collections.sort(res);
  return res;
}

void nextTrial()
{
  if (currTrialNum >= totalTrialNum) //check to see if experiment is done
    return; //if so, just return

  if (startTime!=0 && finishTime==0) //in the middle of trials
  {
    System.out.println("==================");
    System.out.println("Phrase " + (currTrialNum+1) + " of " + totalTrialNum); //output
    System.out.println("Target phrase: " + currentPhrase); //output
    System.out.println("Phrase length: " + currentPhrase.length()); //output
    System.out.println("User typed: " + currentTyped); //output
    System.out.println("User typed length: " + currentTyped.length()); //output
    System.out.println("Number of errors: " + computeLevenshteinDistance(currentTyped.trim(), currentPhrase.trim())); //trim whitespace and compute errors
    System.out.println("Time taken on this trial: " + (millis()-lastTime)); //output
    System.out.println("Time taken since beginning: " + (millis()-startTime)); //output
    System.out.println("==================");
    lettersExpectedTotal+=currentPhrase.trim().length();
    lettersEnteredTotal+=currentTyped.trim().length();
    errorsTotal+=computeLevenshteinDistance(currentTyped.trim(), currentPhrase.trim());
  }

  //probably shouldn't need to modify any of this output / penalty code.
  if (currTrialNum == totalTrialNum-1) //check to see if experiment just finished
  {
    finishTime = millis();
    System.out.println("==================");
    System.out.println("Trials complete!"); //output
    System.out.println("Total time taken: " + (finishTime - startTime)); //output
    System.out.println("Total letters entered: " + lettersEnteredTotal); //output
    System.out.println("Total letters expected: " + lettersExpectedTotal); //output
    System.out.println("Total errors entered: " + errorsTotal); //output

    float wpm = (lettersEnteredTotal/5.0f)/((finishTime - startTime)/60000f); //FYI - 60K is number of milliseconds in minute
    float freebieErrors = lettersExpectedTotal*.05; //no penalty if errors are under 5% of chars
    float penalty = max(errorsTotal-freebieErrors, 0) * .5f;
    
    System.out.println("Raw WPM: " + wpm); //output
    System.out.println("Freebie errors: " + freebieErrors); //output
    System.out.println("Penalty: " + penalty);
    System.out.println("WPM w/ penalty: " + (wpm-penalty)); //yes, minus, becuase higher WPM is better
    System.out.println("==================");

    currTrialNum++; //increment by one so this mesage only appears once when all trials are done
    return;
  }

  if (startTime==0) //first trial starting now
  {
    System.out.println("Trials beginning! Starting timer..."); //output we're done
    startTime = millis(); //start the timer!
  } 
  else
    currTrialNum++; //increment trial number

  lastTime = millis(); //record the time of when this trial ended
  currentTyped = ""; //clear what is currently typed preparing for next trial
  currWord = "";
  disallowedKeys = new ArrayList<HashSet<String>>();
  currentPhrase = phrases[currTrialNum]; // load the next phrase!
  //currentPhrase = "abc"; // uncomment this to override the test phrase (useful for debugging)
}

//=========SHOULD NOT NEED TO TOUCH THIS METHOD AT ALL!==============
int computeLevenshteinDistance(String phrase1, String phrase2) //this computers error between two strings
{
  int[][] distance1 = new int[phrase1.length() + 1][phrase2.length() + 1];

  for (int i = 0; i <= phrase1.length(); i++)
    distance1[i][0] = i;
  for (int j = 1; j <= phrase2.length(); j++)
    distance1[0][j] = j;

  for (int i = 1; i <= phrase1.length(); i++)
    for (int j = 1; j <= phrase2.length(); j++)
      distance1[i][j] = min(min(distance1[i - 1][j] + 1, distance1[i][j - 1] + 1), distance1[i - 1][j - 1] + ((phrase1.charAt(i - 1) == phrase2.charAt(j - 1)) ? 0 : 1));

  return distance1[phrase1.length()][phrase2.length()];
}
