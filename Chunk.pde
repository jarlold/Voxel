class Chunk {
  PVector pos;
  ArrayList<Block> blocks = new ArrayList();
  ArrayList<Entity> entities = new ArrayList();
  HashMap<Long, Block> blockMap = new HashMap();
  World world;
  
  public Chunk(PVector pos, World world) {
    this.pos = pos;
    this.world = world;
    for (int x=0; x < World.chunkSize; x++)
      for (int y=0; y < World.chunkSize; y++)
        for (int z=0; z < World.chunkSize; z++) {
          if (z % 16 == 0 || x % 16 == 0) addBlockRelative(new PVector(x, y, z), 1);
          else addBlockRelative(new PVector(x, y, z), 2 + ( (x + z + y)  % 2));
        }
  }
  
  public String toString() {
    return "<Chunk at " + (int)pos.x + "," + (int)pos.y + "," + (int)pos.z + " containing " + blocks.size() + " blocks>";
  }
  
  void update() {
    for (int i =0; i < blocks.size(); ++i)
      blocks.get(i).updateCover();
  }
  
  Block getBlockRelative(PVector relativePos) {
   // Gets a block in this chunk BASED ON ITS RELATIVE CHUNK POSITION
   // NOT ITS WORLD POSITION
   long hash = Utils.vectorHash(relativePos);
   if(blockMap.containsKey(hash)) return blockMap.get(hash);
   return null;
  }
  
  void addBlockRelative(PVector relativePos, int blockType){
    // Add a block BASED ON ITS RELATIVE CHUNK POSITION
    
    // We'll calculate the world space position of the block
    // because blocks store their position in world space 
    // NOT CHUNK SPACE
    PVector worldPos = new PVector(0, 0, 0);
    worldPos.add(pos);
    worldPos.mult(World.chunkSize);
    worldPos.add(relativePos);
   
    // Then we can make the block
    Block b = new Block(worldPos, blockType, this);
    
    // But then we'll store it using the relative CHUNK SPACE
    // so that blocks in different chunks don't need unique hashes
    long hash = Utils.vectorHash(relativePos);
    
    // If the block is already here, don't add shit
    if(blockMap.containsKey(hash)) return;
    
    // Otherwise add it to the list of blocks and the blockMap
    blocks.add(b);
    blockMap.put(hash, b);
    
    // Then send an update so we know to rebuild the mesh
    b.updateNeighbors();
  }
  
  void removeBlockRelative(PVector relativePos) {
    Block toRemove = blockMap.get(Utils.vectorHash(relativePos)); 
    blocks.remove(toRemove);
    blockMap.remove(Utils.vectorHash(relativePos));
    //toRemove.updateNeighbors();
  }
  
  void draw() {
    // Go through all the blocks and if 
    // they're within render distance draw them
    for (int i = 0 ; i < blocks.size(); i++) {
      PVector middle = PVector.mult(pos, World.chunkSize);
      middle.add(new PVector( World.chunkSize/2, World.chunkSize/2, World.chunkSize/2));
      
     // PVector b = PVector.mult(pos, World.chunkSize);
      float d = world.distSquaredToCamera(middle);
      if (d < World.renderDist*World.renderDist) {
        blocks.get(i).draw();
      }
    }
  }
}
