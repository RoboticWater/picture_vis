public class UserItem {
  private HashMap<String, Integer> images;
  private int[] numPics;
  private Day startDay;
  private String user;
  private PVector pos;
  private float size, curSize = 0;
  private float lineSize, curLineSize;
  private float textAlpha = 0;
  private color backgroundCol, cBGC;
  private color textCol, cTC;
  private int state = 0;
  private int days;
  private int timer = 0;
  public  boolean hover = false;
  public  boolean zoomed = false;
  public UserItem(String user, float x, float y, int days) {
    this(user, x, y, textWidth(user) + 20, textWidth(user) + 20, days);
  }
  public UserItem(String user, float x, float y, float size, float lineSize, int days) {
    this.user = user;
    this.pos = new PVector(x, y);
    this.size = size;
    this.lineSize = lineSize;
    this.curLineSize = size / 2;
    this.days = days;
    this.numPics = new int[days];
    for (int i = 0; i < days; i++) {
      numPics[i] = 20;
    }
    this.backgroundCol = #000000;
    this.textCol = #ffffff;
    this.startDay = Day.MONDAY;
  }
  public void draw() {
    update();
    if (state > 2) {
      strokeWeight(0.5);
      pushMatrix();
      translate(pos.x, pos.y);
      for (int i = 0; i < days; i++) {
        rotate(TWO_PI / days);
        stroke(0);
        line(0, 0, 0, -curLineSize);
        noStroke();
        fill(0);
        float rot = -PI / 160;
        float off = 0;
        for (int j = 0; j < numPics[i]; j++) {
          pushMatrix();
          if (rot / (TWO_PI / days - PI / 23) > 1) {
            rot = -PI / 160;
            off++;
          }
          rot += PI / (40 - 2 * off);
          rotate(rot);//(j % days + 0.5) * TWO_PI / (days * 7));
          translate(0, 3.8 * off - curLineSize);//5 * (int(j / days) + 0.2) - curLineSize);
          ellipse(0, 0, 3, 3);
          popMatrix();
        }
      }
      popMatrix();
    }
    noStroke();
    fill(cBGC);
    ellipse(pos.x, pos.y, curSize, curSize);
    fill(cTC, textAlpha);
    text(user, pos.x, pos.y + textSize / 4);
  }
  private void update() {
    hover = dist((pos.x * scale + world.x), (pos.y * scale + world.y), mouseX, mouseY) < scale * size / 2;
    if (hover) {
      cTC = lerpColor(cTC, backgroundCol, 0.2);
      cBGC = lerpColor(cBGC, textCol, 0.2);
    } else {
      cTC = lerpColor(cTC, textCol, 0.2);
      cBGC = lerpColor(cBGC, backgroundCol, 0.2);
    }
    if (state == 0) {
      curSize = lerp(curSize, size, 0.1);
      textAlpha = lerp(textAlpha, 255, 0.07);
      if (size - curSize < 0.01) state++;
    } else if (state == 1) {
      if (zoomed) {
        state++;
        timer = millis() + 700;
      }
    } else if (state == 2) {
      if(millis() > timer) state++;
    } else if (state == 3) {
      curLineSize = lerp(curLineSize, lineSize, 0.1);
      if (lineSize - curLineSize < 0.01) state++;
    }
  }
  public String dayString(Day d, boolean full) {
    if (full) {
      switch (d) {
        case SUNDAY:
          return "Sunday";
        case MONDAY:
          return "Monday";
        case TUESDAY:
          return "Tuesday";
        case WEDNESDAY:
          return "Wednesday";
        case THURSDAY:
          return "Thursday";
        case FRIDAY:
          return "Friday";
        case SATURDAY:
          return "Saturday";
        default:
          return "";
      }
    } else {
      switch (d) {
        case SUNDAY:
          return "Sun.";
        case MONDAY:
          return "Mon.";
        case TUESDAY:
          return "Tues.";
        case WEDNESDAY:
          return "Wed.";
        case THURSDAY:
          return "Thur.";
        case FRIDAY:
          return "Fri.";
        case SATURDAY:
          return "Sat.";
        default:
          return "";
      }
    }
  }
}