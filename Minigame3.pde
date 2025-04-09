class CrankGenerator {
  float lightLevel;
  float decreaseRate;
  float crankAngle;
  float lastCrankAngle;
  boolean isDragging;
  boolean quotePrimed;
  
  float crankX;
  float crankY;
  float crankRadius;
  float handleRadius;
  float handleX;
  float handleY;
  float handleDistance;
  
  color lightColor;
  
  CrankGenerator() {
    lightLevel = 100;
    decreaseRate = 0.4;
    crankAngle = 0;
    lastCrankAngle = 0;
    isDragging = false;
    quotePrimed = false;
    
    crankX = width/2;
    crankY = height/2;
    crankRadius = 100;
    handleRadius = 20;
    handleDistance = crankRadius;
    updateHandlePosition();
    
    lightColor = color(255, 255, 200);
  }
  
  void updateHandlePosition() {
    handleX = crankX + cos(crankAngle) * handleDistance;
    handleY = crankY + sin(crankAngle) * handleDistance;
  }
  
  boolean isOverHandle() {
    return dist(mouseX, mouseY, handleX, handleY) < handleRadius;
  }
  
  void handleMousePressed() {
    if (isOverHandle()) {
      isDragging = true;
    }
  }
  
  void handleMouseDragged() {
    if (isDragging) {
      float newAngle = atan2(mouseY - crankY, mouseX - crankX);
      float angleDiff = newAngle - lastCrankAngle;
      
      if (angleDiff > PI) angleDiff -= TWO_PI;
      if (angleDiff < -PI) angleDiff += TWO_PI;
      
      crankAngle = newAngle;
      lightLevel += abs(angleDiff) * 25;
      if (lightLevel > 100) {
        lightLevel = 100;
      }
      
      updateHandlePosition();
      lastCrankAngle = newAngle;
    }
  }
  
  void handleMouseReleased() {
    isDragging = false;
  }
  
  int tick() {
    boolean startedHigh = (lightLevel >= 25);
    
    lightLevel -= decreaseRate;
    
    if (startedHigh && lightLevel < 25) {
      quotePrimed = true;
    }
    
    if (lightLevel <= 0) {
      lightLevel = 60;
      return -1;
    }
    
    return 0;
  }
  
  void display() {
    background(0, 0, 0, map(100 - lightLevel, 0, 100, 0, 200));
    
    float lightRadius = map(lightLevel, 0, 100, 50, 300);
    
    noStroke();
    for (int i = 5; i > 0; i--) {
      float alpha = map(i, 0, 5, 10, 70);
      fill(255, 255, 200, alpha * (lightLevel/100));
      ellipse(width/2, height/3, lightRadius * (1 + i * 0.2), lightRadius * (1 + i * 0.2));
    }
    
    fill(255, 255, 200, map(lightLevel, 0, 100, 50, 255));
    ellipse(width/2, height/3, lightRadius, lightRadius);
    
    stroke(100);
    strokeWeight(3);
    line(width/2, height/3 - 40, width/2, height/3 - 80);
    
    noStroke();
    fill(200, 200, 200, 150);
    ellipse(width/2, height/3, 60, 70);
    
    fill(80);
    rectMode(CENTER);
    rect(crankX, crankY + 20, 180, 40, 10);
    
    stroke(0);
    strokeWeight(1);
    fill(120);
    ellipse(crankX, crankY, 50, 50);
    
    stroke(80);
    strokeWeight(6);
    line(crankX, crankY, handleX, handleY);
    
    stroke(0);
    strokeWeight(1);
    fill(isOverHandle() || isDragging ? color(200, 50, 50) : color(180));
    ellipse(handleX, handleY, handleRadius * 2, handleRadius * 2);
    
    fill(255);
    textAlign(CENTER);
    textSize(20);
    text("Crank the handle to keep the light on!", width/2, height - 50);
    
    rectMode(CORNER);
    fill(50);
    rect(width/2 - 100, height - 100, 200, 20, 5);
    
    fill(map(lightLevel, 0, 100, 255, 0), map(lightLevel, 0, 100, 0, 255), 0);
    rect(width/2 - 100, height - 100, map(lightLevel, 0, 100, 0, 200), 20, 5);
  }
  
  color getColor() {
    if (lightLevel >= 66) {
      return color(0, 255, 0);
    } else if (lightLevel >= 33) {
      return color(255, 255, 0);
    } else {
      return color(255, 0, 0);
    }
  }
}