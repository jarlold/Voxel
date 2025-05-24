QueasyCam cam;
World w;
Chunk testChunk;
long t = 0;
int numInitialChunks = 20; // This specifies the border not the total amount
int chunksGenerated = 0;

Gnome g;

void setup() {
  // Setup window and 3D environment
  size(800, 600, P3D);
  ((PGraphicsOpenGL)getGraphics()).textureSampling(2);
  hint(DISABLE_TEXTURE_MIPMAPS);
  frameRate(60);
  fill(255, 255);
  stroke(0);
  lights();
  
  // Setup the camera
  cam = new QueasyCam(this, 0.1, 500*10);
  cam.speed = 4;              // default is 3
  cam.sensitivity = 0.5;      // default is 2
  
  // Then create the world object
  w = new World(42, "atlas.png", cam);
  
  g = new Gnome(w, new PVector(1, 1, 1));
}

void draw() {
  background(170, 210, 255);
  
  if (chunksGenerated < numInitialChunks*numInitialChunks) {
    int i = chunksGenerated / numInitialChunks;
    int j = chunksGenerated % numInitialChunks;
    w.generateChunk(new PVector(i, 0, j));
    //for (int k = 0; k < chunksGenerated; k++) {
    //  i = k / numInitialChunks;
    //  j = k % numInitialChunks;
    //  rect(i * (width/numInitialChunks), j * (height/numInitialChunks), width/numInitialChunks, height/numInitialChunks);
    //}
    chunksGenerated++;
  }
  
  w.drawChunks();
  w.drawCamera();
  g.drawImage();
}
