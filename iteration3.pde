import java.util.Arrays;
import java.util.Collections;
import java.util.Random;
import java.util.ArrayList;
import java.util.HashSet;

//**********************************************************************************************************//
//************************************************* Setup **************************************************//
//**********************************************************************************************************//

// Set the DPI to make your smartwatch 1 inch square. Measure it on the screen
final int DPIofYourDeviceScreen = 127; //you will need to look up the DPI or PPI of your device to make sure you get the right scale!!
//http://en.wikipedia.org/wiki/List_of_displays_by_pixel_density

//Do not change the following variables
String[] phrases; //contains all of the phrases
String[] suggestions; //contains all of the phrases
int totalTrialNum = 3 + (int)random(3); //the total number of phrases to be tested - set this low for testing. Might be ~10 for the real bakeoff!
int currTrialNum = 0; // the current trial number (indexes into trials array above)
float startTime = 0; // time starts when the first letter is entered
float finishTime = 0; // records the time of when the final trial ends
float lastTime = 0; //the timestamp of when the last trial was completed
float lettersEnteredTotal = 0; //a running total of the number of letters the user has entered (need this for final WPM computation)
float lettersExpectedTotal = 0; //a running total of the number of letters expected (correct phrases)
float errorsTotal = 0; //a running total of the number of errors (when hitting next)
String currentPhrase = ""; //the current target phrase
String currentTyped = ""; //what the user has typed so far
final float sizeOfInputArea = DPIofYourDeviceScreen*1; //aka, 1.0 inches square!
PImage watch;
PImage mouseCursor;
float cursorHeight;
float cursorWidth;

//Variables for implementation:
ButtonKey spaceKey;
ButtonKey deleteKey1;
ButtonKey deleteKey2;
ArrayList<ButtonKey> allKeys = new ArrayList<>();
ArrayList<HashSet<String>> disallowedKeys = new ArrayList<HashSet<String>>();
String currWord = "";
Pdist P2l;
Pdist P3l;

//You can modify anything in here. This is just a basic implementation.
void setup()
{
  watch = loadImage("watchhand3smaller.png");
  phrases = loadStrings("phrases2.txt"); //load the phrase set into memory 
  Collections.shuffle(Arrays.asList(phrases), new Random()); //randomize the order of the phrases with no seed
  //Collections.shuffle(Arrays.asList(phrases), new Random(100)); //randomize the order of the phrases with seed 100; same order every time, useful for testing
 
  orientation(LANDSCAPE); //can also be PORTRAIT - sets orientation on android device
  size(800, 800); //Sets the size of the app. You should modify this to your device's native size. Many phones today are 1080 wide by 1920 tall.
  textFont(createFont("Arial", 24)); //set the font to arial 24. Creating fonts is expensive, so make difference sizes once in setup, not draw
  noStroke(); //my code doesn't use any strokes
  rectMode(CENTER);
  
  //set finger as cursor. do not change the sizing.
  noCursor();
  mouseCursor = loadImage("finger.png"); //load finger image to use as cursor
  cursorHeight = DPIofYourDeviceScreen * (400.0/250.0); //scale finger cursor proportionally with DPI
  cursorWidth = cursorHeight * 0.6;
  
  // Setup for my design
  setupKeys();
  P2l = new Pdist(sketchPath("ngrams/count_2l.txt"));
  P3l = new Pdist(sketchPath("ngrams/count_3l.txt"));
}

void setupKeys() {
  // Space and Delete
  spaceKey = new ButtonKey(width/2 - 0.1625*sizeOfInputArea, height/2+.4*sizeOfInputArea, 0.6*sizeOfInputArea, 0.18*sizeOfInputArea, " ");
  deleteKey1 = new ButtonKey(width/2+.335*sizeOfInputArea, height/2+.415*sizeOfInputArea, 0.325*sizeOfInputArea, 0.15*sizeOfInputArea, "del");
  deleteKey2 = new ButtonKey(width/2+.335*sizeOfInputArea, height/2-.42*sizeOfInputArea, 0.325*sizeOfInputArea, 0.15*sizeOfInputArea, "del");
  
  float keyWidth = 0.085 * sizeOfInputArea;
  float keyHeight = 0.175 * sizeOfInputArea;
  
  // First row of keys
  String[] letters1 = {"q", "w", "e", "r", "t", "y", "u", "i", "o", "p"};
  float dx = -0.455 * sizeOfInputArea;
  float y = height/2 - 0.20 * sizeOfInputArea;
  for (int i = 0; i < 10; i++) {
    allKeys.add(new ButtonKey(width/2 + dx, y, keyWidth, keyHeight, letters1[i]));
    dx += 0.1 * sizeOfInputArea;
  }
  
  // Second row of keys
  String[] letters2 = {"a", "s", "d", "f", "g", "h", "j", "k", "l"};
  dx = -0.405 * sizeOfInputArea;
  y = height/2 - 0 * sizeOfInputArea;
  for (int i = 0; i < 9; i++) {
    allKeys.add(new ButtonKey(width/2 + dx, y, keyWidth, keyHeight, letters2[i]));
    dx += 0.1 * sizeOfInputArea;
  }
  
  // Third row of keys
  String[] letters3 = {"z", "x", "c", "v", "b", "n", "m"};
  dx = -0.305 * sizeOfInputArea;
  y = height/2 + 0.2 * sizeOfInputArea;
  for (int i = 0; i < 7; i++) {
    allKeys.add(new ButtonKey(width/2 + dx, y, keyWidth, keyHeight, letters3[i]));
    dx += 0.1 * sizeOfInputArea;
  }
}
