public class UserItem {
  private ArrayList<ImageValue> images;
  private ArrayList<ImageValue>[] imgDist;
  private String user;
  private PVector pos, vel;
  private float size, curSize = 0;
  private float lineSize, curLineSize;
  private float textAlpha = 0;
  private color backgroundCol, cBGC, tBGC;
  private color textCol, cTC;
  private int state = 0;
  private int days;
  private int timer = 0;
  private int curColor = 1;
  private int num;
  public  boolean hover = false;
  public  boolean zoomed = false;
  public  boolean outline = false;
  public UserItem(String user, float x, float y, int days, ArrayList<ImageValue>[] imgDist, ArrayList<ImageValue> images) {
    this(user, x, y, textWidth(user) + 20, textWidth(user) + 20, days, imgDist, images);
  }
  public UserItem(String user, float x, float y, float size, float lineSize, int days, ArrayList<ImageValue>[] imgDist, ArrayList<ImageValue> images) {
    this.user = user;
    this.pos = new PVector(x, y);
    this.size = size;
    this.lineSize = lineSize;
    this.curLineSize = size / 2;
    this.days = days;
    this.imgDist = imgDist;
    this.backgroundCol = images.get(0).val;
    this.tBGC = backgroundCol;
    this.outline = brightness(backgroundCol) - saturation(backgroundCol) > 200;
    this.textCol = outline ? #000000 : #ffffff;
    this.images = images;
    this.vel = PVector.fromAngle(random(0, TWO_PI));
    this.num = glNum++;
  }
  public void draw() {
    update();
    pushMatrix();
    translate(pos.x, pos.y);
    if (frameCount % 15 == 0 && curColor < images.size()) {
      tBGC = avgColor(images, ++curColor);
      outline = brightness(tBGC) - saturation(tBGC) > 200;
    }
    backgroundCol = lerpColor(backgroundCol, tBGC, 0.1);
    if (state > 2 || state == -1) {
      strokeWeight(0.5);
      pushMatrix();
      for (int i = 0; i < days; i++) {
        stroke(0);
        line(0, 0, 0, -curLineSize);
        noStroke();
        fill(0);
        if (i == 0) {
          rect(0, 10-curLineSize, 5, 5);
        }
        text(str(i + 1), 0, -10 - curLineSize);
        float rot = -PI / 160;
        float off = 0;
        for (int j = 0; j < imgDist[i].size(); j++) {
          fill(imgDist[i].get(j).val);
          pushMatrix();
          if (rot / (TWO_PI / days - PI / 23) > 1) {
            rot = -PI / 160;
            off++;
          }
          rot += PI / (35 - 2 * off);
          //if (rot / (TWO_PI / days - PI / 23) > 1) {
          //  rot = -PI / 160;
          //  off++;
          //}
          //rot += PI / (40 - 2 * off);
          rotate(rot);//(j % days + 0.5) * TWO_PI / (days * 7));
          translate(0, 6.8 * off - curLineSize);//5 * (int(j / days) + 0.2) - curLineSize);
          
          ellipse(0, 0, 10, 10);
          popMatrix();
        }
        rotate(TWO_PI / days);
      }
      popMatrix();
    }
    fill(cBGC);
    if(outline) {
      stroke(textCol);
      strokeWeight(1);
    } else {
      noStroke();
    }
    ellipse(0, 0, curSize, curSize);
    fill(cTC, textAlpha);
    text(user, 0, 0 + textSize / 4);
    popMatrix();
  }
  private void update() {
    hover = dist(width / 2 + (pos.x + world.x) * scale, height / 2 + (pos.y + world.y) * scale, mouseX, mouseY) < scale * size / 2;
    if (hover) {
      cTC = lerpColor(cTC, backgroundCol, 0.2);
      cBGC = lerpColor(cBGC, textCol, 0.2);
    } else {
      cTC = lerpColor(cTC, textCol, 0.2);
      cBGC = lerpColor(cBGC, backgroundCol, 0.2);
    }
    if(!hover && !zoomed) {
      if (move) pos.add(vel);
      else pos.lerp(new PVector((num % 10 - 5) * 2 * size, -int(num / 10) * 2 * size), 0.1);
      if (dist(pos.x, pos.y, 0, 0) > 2500) vel.mult(-1);
    }
    if (state == 0) {
      curSize = lerp(curSize, size, 0.1);
      textAlpha = lerp(textAlpha, 255, 0.07);
      if (size - curSize < 0.05) state++;
    } else if (state == 1) {
      if (zoomed) {
        state++;
        timer = millis() + 100;
      }
    } else if (state == 2) {
      fullFocus = true;
      if(millis() > timer) state++;
    } else if (state == 3) {
      curLineSize = lerp(curLineSize, lineSize, 0.1);
      if (lineSize - curLineSize < 0.01) state++;
    } else if (state == 4) {
       if (!zoomed) {
         state++;
         timer = millis() + 200;
       }
    } else if (state == 5) {
      if(millis() > timer) state++;
    } else if (state == 6) {
      curLineSize = lerp(curLineSize, -0.1, 0.1);
      if (curLineSize < -0.05) state = 1;
    }
  }
}