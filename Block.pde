class Block {
  int blockType;
  PVector pos; // Contains position in unit of blocks in WORLD SPACE (not relative to the chunk)
  float size = World.cubeSize;
  boolean[] sideCovered = new boolean[6];
  PImage atlas;
  PVector[] sides = {new PVector(size, 0, 0), new PVector(-size, 0, 0), new PVector(0, 0, size), new PVector(0, 0, -size), new PVector(0, size, 0), new PVector(0, -size, 0)};
  Chunk parentChunk;

  public Block( PVector v) {
    this(v, 0, null);
  }

  public String toString() {
    return "<Block at " + (int)pos.x + "," + (int)pos.y + "," + (int)pos.z + " of type " + blockType + ">";
  }

  public Block(PVector pos, int blockType, Chunk parentChunk) {
    this.pos = pos;
    this.blockType = blockType;
    this.parentChunk = parentChunk;
  }

  public Block(float x, float y, float z, int block, Chunk parentChunk) {
    this(new PVector(x, y, z), block, parentChunk);
  }

  boolean canSee(int side) {
    PVector canvasSpacePos = PVector.mult(pos, World.cubeSize);
    PVector sidePos = PVector.add(sides[side], canvasSpacePos);
    PVector cameraPosCanvasSpace = PVector.mult(parentChunk.world.cameraPos, World.cubeSize);
    
    float a = Utils.distSquared(sidePos, cameraPosCanvasSpace);
    float b = Utils.distSquared(canvasSpacePos, cameraPosCanvasSpace);
    return a < b;
  }

  void draw() {
    pushMatrix();
    translate(pos.x*World.cubeSize, pos.y*World.cubeSize, pos.z*World.cubeSize);
    for (int i = 0; i < 6; i++) drawSide(i);
    popMatrix();
  }

  void drawSide(int side) {
    PImage atlas = parentChunk.world.atlas;
    if (sideCovered[side]) return;
    if (!canSee(side)) return;

    pushMatrix();
    // Move to the position of the block
    translate(sides[side].x/2, sides[side].y/2, sides[side].z/2);

    // Rotate the side to face accordingly
    if (side < 4)
      rotateZ(PI);
    if (side == 0 || side == 1)
      rotateY(PI/2);
    if (side == 4 || side == 5)
      rotateX(PI/2);

    // Then find where in the texture atlas we need to put our
    // texture will be
    int u = blockType*16;
    int v;
    if (side < 4) v = 16;
    else if (side == 4) v = 0;
    else v = 32;

    // Draw a picture there
    if (side < 4) // The side-sides, like the horizontal ones
      image(atlas, -size/2, -size/2, size, size, u, v, u+16, v+16);
    if (side == 4) // The top (or was it bottom)
      image(atlas, -size/2, -size/2, size, size, u, v, u+16, v+16);
    if (side == 5) // The bottom unless 4 was the bottom then this is the top
      image(atlas, -size/2, -size/2, size, size, u, v, u+16, v+16);

    popMatrix();
  }

  void updateCover() {
    // Go through all the sides
    for (int i = 0; i < 6; i++) {
      // Get the appropriate offset for each side (+y in y for the top, +x for the right, etc)
      PVector toCheck = new PVector(0, 0, 0);
      toCheck.add(sides[i]);
      toCheck.div(size);
      toCheck.add(pos);

      // We'll use the world getBlock so we can check for
      // blocks in neighboring chunks
      Block covering = parentChunk.world.getBlock(toCheck);

      // If there isn't one then the side isn't covered
      if (covering == null) {
        sideCovered[i] = false;
        continue;
      }

      // Otherwise we'll say the side is covered
      sideCovered[i] = true;
    }
  }

  boolean equals(Block other) {
    return other.pos.x == pos.x && other.pos.y == pos.y && other.pos.z == pos.z;
  }

  void updateNeighbors() {}
}
