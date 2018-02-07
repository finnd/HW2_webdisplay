//@author Finn
//@contact dmfinn@wustl.edu
//@INFO: Animated bar-line graph transition for wustl cse 557a, SP 2018
//@DESC: Reads in 2 column CSV data and generates a bar graph that can transition to a line graph.

hybridGraph graph;

enum status {barGraph, animating, lineGraph};

class hybridGraph {
  String title;
  String x_axis;
  String y_axis;
  float x_size = 100;
  float y_size = 100;
  float pencil_width = 500;
  float pencil_height = 500;
  float rect_width = 0.14 * x_size;
  Table data; 
  String data_source;
  int num_rows;
  float buffer_space = 10;
  float point_radius = 10;
  float animate_speed = 10;
  int stat = 1;
  int cur_display_mode = 1;
  float frames_made = 0;
  boolean respondingToClick = false;
  String hoverText = "";
  

  hybridGraph(String data_source, String title) {
    this.data_source = data_source;
    this.title = title;
  }

  hybridGraph(String data_source) {
    this.data_source = data_source;
  }


  boolean buildTable() {
    Table temp = loadTable(this.data_source);
    if (temp != null) {
      this.data = temp;
      this.num_rows = this.data.getRowCount();
      this.x_axis = this.data.getRow(0).getString(0);
      this.y_axis = this.data.getRow(0).getString(1);
      println(this.x_axis);
      println(this.y_axis);
      return true;
    }

    return false;
  }

  float maxY() {
    float max = Float.MIN_VALUE;
    for (TableRow r : this.data.rows()) {

      try {
        float val = r.getFloat(1);
        if (val > max) {
          max = val;
        }
      } 
      catch(Throwable e) {
        // pass
      }
    }

    return max;
  }

  float raw_x_length() {
    return this.x_size + this.buffer_space;
  }

  float x_length() {
    return this.x_size + this.pencil_width - this.buffer_space;
  }

  float raw_y_length() {
    return this.y_size;
  }

  float y_length() {
    return this.y_size + this.pencil_height - this.buffer_space;
  }

  float vertical_bins() {
    float delta = y_length() - raw_y_length();
    float tickDistance = delta / 12;
    return tickDistance;
  }

  float horizontal_bins() {
    float delta = x_length() - raw_x_length();
    float numTicks = this.data.getRowCount();
    return delta / numTicks;
  }

  void drawYAxis() {
    fill(0, 0, 0);
    line(raw_x_length(), raw_y_length(), raw_x_length(), y_length());

    float bins = vertical_bins();

    for (int i = 0; i < 12; ++i) {
      line(raw_x_length() - 10, raw_y_length() + bins*(i+1), raw_x_length(), raw_y_length() + bins*(i+1));
    }

    float deltaY = maxY() / 10.0;

    for (int i = 0; i < 12; i++) {
      float x_pos = raw_x_length() - 40;
      float y_pos = y_length() - bins*(i);
      String tick_val = (Float.toString(Math.round(deltaY * i * 10) / 10));
      text(tick_val, x_pos, y_pos);
    }

    float label_x = raw_x_length() - this.buffer_space;
    float label_y = raw_y_length() - this.buffer_space;
    text(this.data.getRow(0).getString(1), label_x, label_y);
  }

  void drawXAxis() {
    fill(0, 0, 0);
    line(raw_x_length(), y_length(), x_length(), y_length());

    float bins = horizontal_bins();

    for (int i = 0; i < this.data.getRowCount(); i++) {
      line(raw_x_length() + bins*(i+1), y_length(), raw_x_length() + bins*(i+1), y_length() + 10);
    }

    textMode(CENTER);
    for (int i = 1; i < this.data.getRowCount(); i++) {
      String val = this.data.getRow(i).getString(0);
      text(val, raw_x_length() + bins*(i) - 10, y_length() + 25);
    }
    
    float label_x = x_length() / 2.0 + 20;
    float label_y = y_length() + 50;
    text(this.data.getRow(0).getString(0), label_x, label_y);
  }

  void drawBarGraph() {

    float max = maxY();
    float x_bins = horizontal_bins();
    float y_bins = vertical_bins();
    float bin_length = max / 10.0;

    rectMode(CORNERS);
    for (int i = 1; i < this.data.getRowCount(); i++) {
      TableRow r = this.data.getRow(i);
      float val = r.getFloat(1);
      float x_upper_left = raw_x_length() + x_bins*(i) - this.rect_width / 2.0;
      float x_lower_right = raw_x_length() + x_bins*(i) + this.rect_width / 2.0;
      float numBins = val / bin_length;
      float y_upper_left = y_length() - numBins*y_bins;
      float y_lower_right = y_length();
      if (stat == 2){
        float deltaHeight = (y_upper_left - y_lower_right) / 10;
        float temp_y_lower_right = y_lower_right + deltaHeight*(frames_made);
        if (temp_y_lower_right <= y_upper_left){
          y_lower_right = y_upper_left;
        } else {
          y_lower_right = temp_y_lower_right;
        }
      }
      fill(125, 149, 49);
      rect(x_upper_left, y_upper_left, x_lower_right, y_lower_right);
      if (rectIsHovered(mouseX, mouseY, x_upper_left, y_upper_left, x_lower_right, y_lower_right)) {
        String name = r.getString(0);
        this.hoverText = name + ":" + val;
      }
    }
    if (stat == 2){
      if (frames_made == 10.0 || frames_made == 0.0){
        if (frames_made == 10.0){
          stat = 3;
          this.cur_display_mode = 2;
        }
        if (frames_made == 0.0){
          stat = 1;
          this.cur_display_mode = 1;
        }
        
      }
        if(this.cur_display_mode == 1){
          frames_made++;
        }
        if (this.cur_display_mode == 2){
          frames_made--;
        }
        
   
      delay(80);
    }
  }
  
  void startAnimating(){
    this.stat = 2;
    println("Beginning Animation");
  }

  boolean rectIsHovered(float mouse_x, float mouse_y, float rect_x1, float rect_y1, float rect_x2, float rect_y2) {
    boolean xBounds = (mouse_x >= rect_x1 && mouse_x <= rect_x2);
    boolean yBounds = (mouse_y >= rect_y1 && mouse_y <= rect_y2);
    return xBounds && yBounds;
  }

  boolean ellipseIsHovered(float mouse_x, float mouse_y, float el_x1, float el_y1) {
    boolean xBounds = (mouse_x >= el_x1 - this.point_radius && mouse_x <= el_x1 + this.point_radius);
    boolean yBounds = (mouse_y >= el_y1 - this.point_radius && mouse_y <= el_y1 + this.point_radius);
    return xBounds && yBounds;
  }

  void drawLineGraph() {
    float max = maxY();
    float x_bins = horizontal_bins();
    float y_bins = vertical_bins();
    float bin_length = max / 10.0;

    ellipseMode(RADIUS);

    for (int i = 1; i < this.data.getRowCount(); i++) {
      TableRow r = this.data.getRow(i);
      float val = r.getFloat(1);
      float numBins = val / bin_length;
      float x_center = raw_x_length() + x_bins*(i);
      float y_center = y_length() - numBins*y_bins;
      fill(124, 149, 49);
      ellipse(x_center, y_center, this.point_radius, this.point_radius);
      if (i > 1){
        float prev_x_center = raw_x_length() + x_bins*(i-1);
        TableRow prev_row = this.data.getRow(i-1);
        float prev_val = prev_row.getFloat(1);
        float prev_y_center = y_length() - (prev_val/bin_length)*y_bins;
        line(x_center, y_center, prev_x_center, prev_y_center);
      }
      if (ellipseIsHovered(mouseX, mouseY, x_center, y_center)) {
        String name = r.getString(0);
        this.hoverText = name + ":" + val;
      }
    }
  }

  void drawTitle() {

    String words;
    if (this.title == null) {
      String dep = this.data.getRow(0).getString(1);
      String indp = this.data.getRow(0).getString(0);
      words = dep + " v.s. " + indp;
    } else {
      words = this.title;
    }
    fill(0, 0, 0);
    text(words, (x_length() - raw_x_length()) / 2.0, raw_y_length() - 10);
  }

  void drawButton(){
    String words = "";
    if(stat == 1){
      words = "Line Graph";
    }
    
    if (stat == 2) {
      words = "Animating";
    }
    
    if (stat == 3) {
      words = "Bar Graph";
    }
    fill(200,200,200);
    rectMode(CENTER);
    rect(x_length() - 10, raw_y_length(), words.length() * 10 + this.buffer_space, 20);
    fill(0,0,0);
    text(words, x_length() - (words.length() * 10 / 2), raw_y_length() + 5);
    if (this.respondingToClick){
      boolean xBounds = (mouseX >= (x_length() - 10) - ((words.length() * 10 + this.buffer_space)/2.0) && (mouseX <= (x_length() - 10) + ((words.length() * 10 + this.buffer_space)/2.0)));
      boolean yBounds = (mouseY >= raw_y_length() - 10 && mouseY <= raw_y_length() + 10);
      if (xBounds && yBounds && this.stat != 2){
        this.startAnimating();
      }
      this.respondingToClick = false;        
    }
  
  }
  void drawGraph() {
    this.drawYAxis();
    this.drawXAxis();
    this.drawTitle();
    this.drawButton();
    if (stat == 1){
      this.drawBarGraph();
      println("Drawing Bar Graph");
    }
    
    if (stat == 2){
      this.drawBarGraph();
    }
    
    if (stat == 3) {
      this.drawLineGraph();
    }

    if (this.hoverText != "") {
      fill(200, 200, 200);
      rectMode(CENTER);
      rect(mouseX, mouseY - 15, this.hoverText.length()*10, 20);
      fill(0, 0, 0);
      text(this.hoverText, mouseX - 30, mouseY - 10);
    }

    this.hoverText = "";
  }
  
  void resize(float x, float y, float w, float h) {
      this.x_size = x;
      this.y_size = y;
      this.pencil_height = h;
      this.pencil_height = w;
  }
}

void setup() {
  size(700, 700);
  background(255, 255, 255);
  surface.setResizable(true);
  String data_source = "avocado_data.csv";
  graph = new hybridGraph(data_source, "Avocado Pricing By Month (2017)");
  if (! graph.buildTable()) {
    println("Error - you have specified an invalid data path!");
    System.exit(1);
  }
  graph.resize(100,100,500,500);
}

void draw() {
  clear();
  background(255, 255, 255);
  graph.resize(0.1*width, 0.1*height, 0.8*width, 0.8*height);
  graph.drawGraph();
}

void mouseClicked(){
  graph.respondingToClick = true;
}