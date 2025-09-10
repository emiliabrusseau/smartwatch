class ButtonKey
{  
  float cx, cy, w, h;
  String label = "";
  
  ButtonKey(float cx, float cy, float w, float h, String label) {
    this.cx = cx;
    this.cy = cy;
    this.w = w;
    this.h = h;
    this.label = label;
  }
  
  void drawKey() {
    rectMode(CENTER);
    fill(255);
    rect(cx, cy, w, h);
    
    textAlign(CENTER, CENTER);
    textSize(10);
    fill(0);
    text(label, cx, cy);
  }
  
  boolean clickedIn() {
    return clickedInRect(cx, cy, w, h);
  }
  
  String getLabel() {
    return label;
  }
}

//********************************************************
class Pair implements Comparable<Pair> {
  String label;
  float value;

  Pair(String label, float value) {
    this.label = label;
    this.value = value;
  }

  public int compareTo(Pair other) {
    return Float.compare(other.value, this.value); // Descending
  }
  
  public String toString() {
    return "(" + label + ", " + value + ")";
  }
  
  @Override
  public boolean equals(Object obj) {
    if (obj instanceof Pair) {
      Pair other = (Pair) obj;
      return this.label.equals(other.label);
    }
    return false;
  }
}

//********************************************************
class Pdist {
  HashMap<String, Long> counts = new HashMap<>();
  long total;
  
  Pdist(String filePath) {
    String[] lines = loadStrings(filePath);
    
    for (String line : lines) {
      String[] parts = line.split("\t");
      String ngram = parts[0];
      long count = Long.parseLong(parts[1]);
      counts.put(ngram, count);
      total += count;
    }
  }
  
  float getProb(String key) {
    if (counts.containsKey(key))
      return (float)counts.get(key) / total;
    return 0;
  }
  
  HashMap<String, Long> getCounts() {
    return counts;
  }
}
