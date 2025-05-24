interface Entity {
  public void setPosition(PVector newPos);
  public void drawImage();
}

class Gnome implements Entity {
  final PImage card;
  World world;
  PVector pos;
  Chunk chunk;
  
  public Gnome(World world, PVector pos) {
    card = loadImage("Gnome.png");
    this.world = world;
    this.pos = pos;
    setChunk();
  }
  
  public void setChunk() {
    //// Round our current position to the nearest 16th
    //// or whatever size chunks are these days
    //int x = floor(pos.x/World.chunkSize);
    //int y = floor(pos.y/World.chunkSize);
    //int z = floor(pos.z/World.chunkSize);
    
    //// THERE HE IS! THERE'S MY FAVORITE WHITE BOY!
    //Chunk c = world.getChunk(new PVector(x, y, z));
    
    //if (c == null) print("BALLS!");
    
    //// We will remove the gnome from the previous favorite white boy
    //if (chunk != null) this.chunk.entities.remove(this);
    
    //// Then swap favored white boys
    //this.chunk = c;
    //this.chunk.entities.add(this);
  }
  
  public void setPosition(PVector newPos) {
    this.pos = newPos;
    setChunk();
  }
  
  public void drawImage() {
    pushMatrix();
    translate(pos.x, pos.y - World.cubeSize*2, pos.z);
    image(card, 0, 0, World.cubeSize, World.cubeSize*2);
    popMatrix();
  }
  
}
