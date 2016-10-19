import java.awt.Image;
import java.awt.image.*;
import java.net.URL;
import java.awt.Toolkit;
import java.lang.reflect.Method;
import javax.imageio.*;
import java.util.*;
ArrayList<UserItem> userItems = new ArrayList();
HashSet<String> users;
UserItem focus = null;
PVector world = new PVector(0, 0), vel = new PVector();
float textSize;
float scale = 1;
JSONObject data;
ArrayList<String> keys;
void setup() {
  size(640, 480);
  textAlign(CENTER);
  userItems.add(new UserItem("Blarg", 50, 50, 14));
  textSize = textAscent() + textDescent();
  data = loadJSONObject("output.json"); // JSON file from Flickr API
  keys = new ArrayList(data.keys()); 
  users = new HashSet();
  for (int i = 0; i < data.size(); i++) {
    users.add(data.getJSONObject(keys.get(i)).getString("user"));
  }
  for (String s : users) {
    println(s);
  }
}
void draw() {
  if (mousePressed) {
    vel = new PVector(mouseX - pmouseX, mouseY - pmouseY);
  } else {
    vel.setMag(vel.mag() / 1.1);
  }
  if (focus != null) {
    scale = lerp(scale, 4, 0.1);
    world.lerp(focus.pos, 0.1);
  } else {
    scale = lerp(scale, 1, 0.1);
  }
  world.add(vel);
  background(255);
  translate(world.x, world.y);
  scale(scale);
  for (UserItem uI : userItems) {
    uI.draw();
  }
}
void mousePressed() {
  for (UserItem uI : userItems) {
    if (uI.hover) {
      if (focus == uI) {
        uI.zoomed = false;
        focus = null;
      } else {
        uI.zoomed = true;
        focus = uI;
      }
      break;
    }
  }
}
public UserItem generateItem(String user) {
  UserItem out;
  HashMap<String, Integer> images = new HashMap();
  int earliest = -1;
  int latest = 1000;
  for (String k : keys) {
    if(data.getJSONObject(k).getString("user").equals(user)) {
      images.put(k, avgColor(loadImage(k + ".png").pixels));
      int date = data.getJSONObject(k).getJSONArray("time")
      if () earliest = ;
      if () latest = ;
    }
  }
  int days = 0;
  out = new UserItem(user, random(0, width) + world.x, random(0, height) + world.y, days);
  return out;
}
/**
 * This is a bit of a hack and might change depending on which jdk you use!
 */
public BufferedImage loadImageCrazyFast( URL src ){
    try{
        Image im = Toolkit.getDefaultToolkit().createImage( src );
        Method method = im.getClass().getMethod( "getBufferedImage" );
        BufferedImage bim = null;
        int counter = 0;
        // load 30seconds maximum!
        while( bim == null && counter < 3000 ){
            im.getWidth( null );
            bim = (BufferedImage) method.invoke( im );
            try{ Thread.sleep( 10 ); }
            catch( InterruptedException e ){ }
            counter ++;
        }
       
        if( bim != null ){
            return bim;
        }
    }
    catch( Exception e ){
        System.err.println( "Fast loading of " + src.toString() + " failed. You might want to correct this in loadImageCrazyFast( URL )" );
        System.err.println( "Falling back to ImageIO, which is... slow!" );
    }
    try{
        return ImageIO.read( src );
    }
    catch( IOException ioe ){
        return null;
    }
}

/**
 * This is another bit of a hack and might also change
 */
public int[] loadPixelsCrazyFast( BufferedImage img ){
    return ((DataBufferInt) img.getRaster().getDataBuffer()).getData();
}
public static enum Day {
  SUNDAY, MONDAY, TUESDAY, WEDNESDAY,
  THURSDAY, FRIDAY, SATURDAY;
  private static Day[] vals = values();
  public Day next() {
      return vals[(this.ordinal() + 1) % vals.length];
  }
  public Day previous() {
      return vals[((this.ordinal() - 1) % vals.length + vals.length ) % vals.length];
  }
}