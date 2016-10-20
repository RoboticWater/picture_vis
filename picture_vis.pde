import java.util.*;
import java.util.Collections;


JSONObject data;
ArrayList<UserItem> userItems;
ArrayList<String> users;
ArrayList<String> keys;
UserItem onDeck;
UserItem focus;
PVector world; 
PVector vel;
float textSize;
float scale;
float uScale;
int glNum;
boolean fullFocus;
boolean linkHover;
boolean move;


void setup() {
  size(640, 480);
  textAlign(CENTER);
  rectMode(CENTER);
  data = loadJSONObject("output.json");
  userItems = new ArrayList();
  users = new ArrayList();
  keys = new ArrayList(data.keys());
  for (int i = 0; i < data.size(); i++) {
    String s = data.getJSONObject(keys.get(i)).getString("user");
    if(!users.contains(s))
    users.add(s);
  }
  onDeck = null;
  focus = null;
  world = new PVector();
  vel = new PVector();
  textSize = textAscent() + textDescent();
  scale = 1;
  uScale = 0.25;
  glNum = 0;
  fullFocus = false;
  linkHover = false;
  move = true;
  thread("addUser");
}
void draw() {
  if (users.size() > 0 && frameCount % 100 == 0) {
    thread("addUser");
  }
  if (mousePressed) {
    vel = new PVector((mouseX - pmouseX) / scale, (mouseY - pmouseY) / scale);
  } else {
    vel.setMag(vel.mag() / 1.1);
  }
  if (focus != null && mouseX < 120 && mouseY < 17) {
    cursor(HAND);
    linkHover = true;
  } else {
    cursor(ARROW);
    linkHover = false;
  }
  world.add(vel);
  background(255);
  if(focus!=null) {
    fill(0);
    text("view pictures on web", 65, 10);
  }
  translate(width / 2, height / 2);
  scale(scale);
  translate(world.x, world.y);
  if (onDeck != null) {
    userItems.add(onDeck);
    onDeck = null;
  }
  if (fullFocus) {
    focus.draw();
  } else {
    for (UserItem uI : userItems) {
      uI.draw();
    }
  }
  if (focus != null) {
    scale = lerp(scale, 200/focus.lineSize, 0.08);
    PVector v = focus.pos.get();
    v.mult(-1);
    world.lerp(v, 0.1);
  } else {
    scale = lerp(scale, uScale, 0.1);
  }
}
void addUser() {
  String user = users.get(int(random(users.size())));
  users.remove(user);
  onDeck = generateItem(user);
}
void keyPressed() {
  if (key == ' ' && users.size() > 0) thread("addUser");
  else if (key == 'm') move = !move;
  if (key == 'A' && users.size() > 0) {
    addAllUser();
  }
  else if (key == 'R') {
    setup();
  } else if (keyCode == UP) {
    uScale *= 2;
  } else if (keyCode == DOWN) {
    uScale /= 2;
  }
}
void mousePressed() {
  if (linkHover) {
    link("https://www.flickr.com/photos/" + focus.user);
  }
  for (UserItem uI : userItems) {
    if (uI.hover) {
      if (focus == uI) {
        uI.zoomed = false;
        focus = null;
        fullFocus = false;
      } else if (focus == null) {
        uI.zoomed = true;
        focus = uI;
      }
      break;
    }
  }
}
void mouseWheel(MouseEvent event) {
  int e = int(event.getCount());
  uScale = uScale * pow(2, -e);
}
public UserItem generateItem(String user) {
  UserItem out;
  ArrayList<ImageValue> images = new ArrayList();
  for (String k : keys) {
    JSONObject jObj = data.getJSONObject(k);
    if(jObj.getString("user").equals(user)) {
      JSONArray time = jObj.getJSONArray("time");
      int d = time.getInt(2);
      int date = d > 10 ? d - 30 : d;
      int t = 24 * date + 60 * time.getInt(3) + 60 * time.getInt(4) + time.getInt(5);
      color c = avgColor(loadImage(k + ".jpg").pixels);
      images.add(new ImageValue(c, t, k, date));
    }
  }
  Collections.sort(images);
  int earliest = 100;
  int latest = -100;
  for (ImageValue im : images) {
    int d = im.day; 
    if (d > latest) latest = d;
    if(d < earliest) earliest = d;
  }
  int days = 1 + latest - earliest;
  ArrayList<ImageValue>[] imgDist = new ArrayList[days];

  for (int i = 0; i < days; i++) imgDist[i] = new ArrayList();
  List ordered = new ArrayList(images);
  Collections.sort(ordered);
  for (ImageValue im : images) {
    imgDist[im.day - earliest].add(im);
  }
  out = new UserItem(user, random(-width, width), random(-height, height), days, imgDist, images);
  return out;
}
public color avgColor(color[] cols) {
  if (cols.length == 0) return 0;
  float r = red(cols[0]);
  float g = green(cols[0]);
  float b = blue(cols[0]);
  for (int i = 1; i < cols.length; i++) {
    r += red(cols[i]);
    g += green(cols[i]);
    b += blue(cols[i]);
  }
  r /= cols.length;
  g /= cols.length;
  b /= cols.length;
  return color(r, g, b);
}
public color avgColor(color a, color b) {
  float r = (red(a) + red(b)) / 2;
  float g = (green(a) + green(b))/2;
  float bl = (blue(a) + blue(b))/2;
  return color(r, g, b);
}
public color avgColor(ArrayList<ImageValue> ims, int stop) {
  float r = red(ims.get(0).val);
  float g = green(ims.get(0).val);
  float b = blue(ims.get(0).val);
  for (int i = 1; i < stop; i++) {
    r += red(ims.get(i).val);
    g += green(ims.get(i).val);
    b += blue(ims.get(i).val);
  }
  r /= stop;
  g /= stop;
  b /= stop;
  return color(r, g, b);
}