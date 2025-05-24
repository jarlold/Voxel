class World {
  static final int renderDist = 64;
  public static final int cubeSize = 16;
  static final int chunkSize = 16;
  static final int worldBottom = -2*cubeSize;
  static final int chunkWidth = chunkSize * cubeSize;
  int seed;
  
  // Should be static
  final PImage atlas;
  QueasyCam camera;
  ArrayList<Chunk> chunks = new ArrayList();
  HashMap<Long, Chunk> chunkMap = new HashMap(); 
  PVector cameraPos = new PVector(2.5 * chunkSize, -0.5 * chunkSize, 2.5 * chunkSize);

  public World(int seed, String texture_atlas, QueasyCam camera) {
    this.atlas = loadImage(texture_atlas);
    this.seed = seed;
    this.camera = camera;
  }

  void drawAxes() {
    stroke(255, 0, 0);
    line(0, 0, 0, 10000, 0, 0); // X-axis
    line(0, 0, 0, 0, 10000, 0); // Y-axis
    line(0, 0, 0, 0, 0, -10000); // Z-axis
    stroke(0);
  }
  
  
  void drawCamera() {
    //pushMatrix();
    //translate(cameraPos.x * cubeSize, cameraPos.y  * cubeSize - 4, cameraPos.z  * cubeSize);
    //box(2);
    //popMatrix();
    cameraPos = PVector.div(camera.position, cubeSize);
  }
  
  float distSquaredToCamera(PVector v1) {
    return Utils.distSquared(v1, new PVector(cameraPos.x, cameraPos.y, cameraPos.z)); 
  }

  public Chunk generateChunk(PVector pos) {
    Chunk c = new Chunk(pos, this);
    this.chunks.add(c);
    this.chunkMap.put(Utils.vectorHash(pos), c);
    c.update();
    
    // Update neighbors
    PVector[] neighbors = {
      new PVector(-1, 0, 0),
      new PVector(1, 0, 0),
      new PVector(0, -1, 0),
      new PVector(0, 1, 0),
      new PVector(0, 0, -1),
      new PVector(0, 0, 1),
    };
    
    Chunk balls;
    for (PVector neighbor : neighbors) {
      PVector n = PVector.add(pos, neighbor);
      balls = getChunk(n);
      if (balls != null) {
        balls.update();
      }
    }
    
    // Debug
    print("Generated " + c.toString() + "\n");
    return c;
  }

  public Chunk getChunk(PVector v){
    if(!chunkMap.containsKey(Utils.vectorHash(v))) return null;
    return chunkMap.get(Utils.vectorHash(v));
  }
  
  public void addBlock(PVector blockWorldPos, int blockType) {
    // Calculate which chunk its in
    PVector chunkPos = new PVector(
      floor(blockWorldPos.x / chunkSize),
      floor(blockWorldPos.y / chunkSize),
      floor(blockWorldPos.z / chunkSize)
    );
        
    // Calculate its offset inside the chunk
    PVector off = new PVector(
      blockWorldPos.x - (chunkPos.x * World.chunkSize),
      blockWorldPos.y - (chunkPos.y * World.chunkSize),
      blockWorldPos.z - (chunkPos.z * World.chunkSize)
    );
    
    // Look for that in the chunkMap
    Chunk chunk = getChunk(chunkPos);
    
    // If the chunk isn't generated yet, we'll have to generate it
    if (chunk == null) { 
      generateChunk(chunkPos);
      chunk = getChunk(chunkPos);
    }
    
    // Add the block to it using its relative coordinates
    chunk.addBlockRelative(off, blockType);
    
    // Then update the chunk so it knows to rebuld its mesh
    chunk.update();
  }
  
  public void removeBlock(PVector blockWorldPos) {
    // Calculate which chunk its in
    PVector chunkPos = new PVector(
      floor(blockWorldPos.x / chunkSize),
      floor(blockWorldPos.y / chunkSize),
      floor(blockWorldPos.z / chunkSize)
    );
        
    // Calculate its offset inside the chunk
    PVector off = new PVector(
      blockWorldPos.x - (chunkPos.x * World.chunkSize),
      blockWorldPos.y - (chunkPos.y * World.chunkSize),
      blockWorldPos.z - (chunkPos.z * World.chunkSize)
    );
    
    // Look for that in the chunkMap
    Chunk chunk = getChunk(chunkPos);
    
    // If the chunk isn't generated yet, we'll have to generate it
    if (chunk == null) { 
      generateChunk(chunkPos);
      chunk = getChunk(chunkPos);
    }
    
    // Delete the block using its relative coordinates
    chunk.removeBlockRelative(off);
    
    // Then update the chunk so it knows to rebuld its mesh
    chunk.update();
    
    // And update his neighbors
    // Update neighbors
    PVector[] neighbors = {
      new PVector(-1, 0, 0),
      new PVector(1, 0, 0),
      new PVector(0, -1, 0),
      new PVector(0, 1, 0),
      new PVector(0, 0, -1),
      new PVector(0, 0, 1),
    };
    
    Chunk balls;
    for (PVector neighbor : neighbors) {
      PVector n = PVector.add(chunkPos, neighbor);
      balls = getChunk(n);
      if (balls != null) {
        balls.update();
      }
    }
  }
  
  Block getBlock(PVector blockWorldPos){
    // First we need to decide what chunk that blocks is in. We should be able to do
    // this just by rounding down the block position to the nearest 16th (or whatever chunk
    // sizes are).
    PVector chunkPos = new PVector(
      floor(blockWorldPos.x / chunkSize),
      floor(blockWorldPos.y / chunkSize),
      floor(blockWorldPos.z / chunkSize)
    );
    
    // Look for that in the chunkMap
    Chunk chunk = getChunk(chunkPos);
    
    // If there's no chunk there's no block
    if (chunk == null) return null;
    
    // Then we'll calculate the offset in chunk space
    PVector off = new PVector(
      blockWorldPos.x - (chunk.pos.x * World.chunkSize),
      blockWorldPos.y - (chunk.pos.y * World.chunkSize),
      blockWorldPos.z - (chunk.pos.z * World.chunkSize)
    );
    
    // Then using the offset in chunk space we'll get the block from the
    // chunk
    return chunk.getBlockRelative(off);
  }
  
  public void drawChunks() {
    for (int i =0; i < chunks.size(); i++) chunks.get(i).draw(); 
  }
  
}
