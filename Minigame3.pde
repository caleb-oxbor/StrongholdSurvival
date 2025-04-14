// crank generator minigame - keep the light on!

class CrankGenerator {
  float lightLevel; // how bright the light is (0-100)
  float decreaseRate; // how quickly light dims
  float crankAngle;
  float lastCrankAngle;
  boolean isDragging; // tracks if player is dragging the handle
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
    decreaseRate = 0.25;
    crankAngle = 0;
    lastCrankAngle = 0;
    isDragging = false;
    quotePrimed = false;
    
    crankX = width/2;
    crankY = height/2;
    crankRadius = 100;
    handleRadius = 25;
    handleDistance = crankRadius;
    updateHandlePosition();
    
    lightColor = color(255, 255, 200); // warm light color
  }
  
  void updateHandlePosition() {
    // calculate position based on angle and distance
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
      // calculate new angle based on mouse position
      float newAngle = atan2(mouseY - crankY, mouseX - crankX);
      float angleDiff = newAngle - lastCrankAngle;

      // wrap angle if we pass 2pi
      if (angleDiff > PI) angleDiff -= TWO_PI;
      if (angleDiff < -PI) angleDiff += TWO_PI;
      
      crankAngle = newAngle;
      // increase light level based on how much you cranked
      lightLevel += abs(angleDiff) * 3;
      if (lightLevel > 100) {
        lightLevel = 100; // cap at 100%
      }
      
      updateHandlePosition();
      lastCrankAngle = newAngle;
    }
  }
  
  void handleMouseReleased() {
    isDragging = false;
  }
  
  int tick() {
    boolean startedHigh = (lightLevel >= 30);
    
    lightLevel -= decreaseRate;
    
    // trigger audio quote when light gets low
    if (startedHigh && lightLevel < 30) {
      quotePrimed = true;
    }
    
    // if light completely dies, lose a life
    if (lightLevel <= 0) {
      lightLevel = 60; // reset to medium level
      return -1;
    }
    
    return 0;
  }
  
  void display() {
    // for when light is dimmer
    background(0, 0, 0, map(100 - lightLevel, 0, 100, 0, 200));
    
    float lightRadius = map(lightLevel, 0, 100, 50, 300);
    
    // draw light glow layers
    noStroke();
    for (int i = 5; i > 0; i--) {
      float alpha = map(i, 0, 5, 10, 70);
      fill(255, 255, 200, alpha * (lightLevel/100));
      ellipse(width/2, height/3, lightRadius * (1 + i * 0.2), lightRadius * (1 + i * 0.2));
    }
    
    // main light
    fill(255, 255, 200, map(lightLevel, 0, 100, 50, 255));
    ellipse(width/2, height/3, lightRadius, lightRadius);
    
    // light fixture cord
    stroke(100);
    strokeWeight(3);
    line(width/2, height/3 - 40, width/2, height/3 - 80);
    
    // bulb base
    noStroke();
    fill(200, 200, 200, 150);
    ellipse(width/2, height/3, 60, 70);
    
    // generator base
    fill(80);
    rectMode(CENTER);
    rect(crankX, crankY + 20, 180, 40, 10);
    
    // crank center
    stroke(0);
    strokeWeight(1);
    fill(120);
    ellipse(crankX, crankY, 50, 50);
    
    // crank arm
    stroke(80);
    strokeWeight(6);
    line(crankX, crankY, handleX, handleY);
    
    // crank handle - red when mouse is over it
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
    
    // light level indicator (green when full, red when empty)
    fill(map(lightLevel, 0, 100, 255, 0), map(lightLevel, 0, 100, 0, 255), 0);
    rect(width/2 - 100, height - 100, map(lightLevel, 0, 100, 0, 200), 20, 5);
  }
  
  color getColor() {
    if (lightLevel >= 66) {
      return color(0, 255, 0); // green when high
    } else if (lightLevel >= 33) {
      return color(255, 255, 0); // yellow when medium
    } else {
      return color(255, 0, 0); // red when low
    }
  }
}
