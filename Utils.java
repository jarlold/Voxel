import processing.core.*;
class Utils {
  // Should be static and in utils
  static long vectorHash(PVector p) {
    // We should be able to fit 3 shorts (2 bytes) in 1 long (8 bytes)
    // with a little room to spare
    long x = (short) (p.x);
    long y = (short) (p.y);
    long z = (short) (p.z);
    long hash = (x | y << 16) | z << 32;
    return hash;
  }

  // Should be static and in utils
  static float distSquared(PVector v1, PVector v2) {
    return (v1.x-v2.x)*(v1.x-v2.x) + (v1.y-v2.y)*(v1.y-v2.y) + (v1.z-v2.z)*(v1.z-v2.z);
  }
  
}
