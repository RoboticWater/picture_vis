public class ImageValue implements Comparable {
  color val;
  int time, day;
  String img;
  public ImageValue(color val, int time, String img, int day) {
    this.val = val;
    this.time = time;
    this.img = img;
    this.day = day;
  }
  public int compareTo(Object o) {
    int t = ((ImageValue) o).time;
    return time - t;
  }
}