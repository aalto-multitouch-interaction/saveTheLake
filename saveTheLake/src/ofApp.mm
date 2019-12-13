#include "ofApp.h"

//--------------------------------------------------------------
void ofApp::setup(){
    ofBackground(8., 87., 195., 255.);
    ofSetVerticalSync(false);
    ofEnableAlphaBlending();
    ofSetLogLevel(OF_LOG_VERBOSE);
    
    for(int i=0; i<NUM_MAPS; i++){
        Map map;
        map.setup(i);
        maps[i] = map;
    }
    
    for(int i=0; i<NUM_PHOTOS; i++){
        Photo photo;
        photo.setup(i);
        photos[i] = photo;
    }
    
    currentIndex = 0;
    
    colWater = ofColor(203, 227, 245, 255);
    colLand1 = ofColor(255, 253, 238, 255);
    colLand2 = ofColor(252, 242, 215, 255);
    
    lastTouch.set(0,0);
    radius = 0;
    
    myAngleX = 0;
    myAngleY = 0;
    myAngleZ = 0;
    
    myCoreMotion.setupAccelerometer();
    
    shader.load("shader");
    noise.load("noise");
    
    fbo.allocate(maps[0].img.getWidth(), maps[0].img.getHeight());
    fbo.begin();
    ofClear(0, 0, 0, 255);
    fbo.end();
    
    myPrettyFont.load("Bitter-Regular.ttf", 72);
    for(int i=0; i<2; i++){
        finger[i] = ofVec2f(0,0);
        touched[i] = false;
        touched_p[i] = false;
        finger_p[i] = ofVec2f(0,0);
    }
    
    displayPhoto = false;
    displayPhotoIndex = 0;
    displayPhotoWidth = 0;
    displayPhotoHeight = 0;
    displayPhotoX = 0;
    displayPhotoY = 0;
    shift = ofVec2f(0,0);
    
    easing = 0;
    freeze = 0;
    bleeding = false;
    
    map0.setup(0);
}

//--------------------------------------------------------------
void ofApp::update(){
    if(freeze > 0) freeze -= 1;
    if(displayPhoto == false) {
        if(currentIndex == NUM_MAPS-1) {
            if(lastTouch != ofVec2f(0,0)) {
                float x = lastTouch.x + myAngleX;
                float y = lastTouch.y - myAngleY;
                
                if((x >= ofGetWidth()-10) or (y >= ofGetHeight()-10) or (x <= 10) or (y <= 10)){
                    lastTouch = ofVec2f(0,0);
                    radius = 0;
                    myAngleX = 0;
                    myAngleY = 0;
                    myAngleZ = 0;
                } else {
                    ofColor underColor = maps[0].pix.getColor(x,y);
                    if(underColor == colWater) {
                        for(int i=-radius;i<radius+1;i++){
                            for(int j=-radius;j<radius+1;j++){
                                ofColor underColor = maps[0].pix.getColor(x+i,y+j);
                                if(underColor == colWater) {
                                    maps[currentIndex].pix.setColor(x+i,y+j,colWater);
                                }
                            }
                        }
                        maps[currentIndex].update();
                    }
                    
                    myCoreMotion.update();
                    ofVec3f accelData = myCoreMotion.getAccelerometerData();
                    myAngleX += accelData.x;
                    myAngleY += accelData.y;
                    myAngleZ += accelData.z;
                    
                    //if((radius>0) && (int(ofGetElapsedTimef()) % 10 == 0)) radius -= 1;
                }
            }
        } else {
            if(radius > 350){
                radius = 0;
                lastTouch = ofVec2f(0,0);
                currentIndex += 1;
                bleeding = false;
                if(currentIndex >= NUM_MAPS-1) {
                    currentIndex = NUM_MAPS - 1;
                    if(maps[0].reset_c == false) {
                        maps[0] = map0;
                        maps[0].reset_c = true;
                    }
                }
            }
            
            if(lastTouch != ofVec2f(0,0)) {
            
                float x = lastTouch.x;
                float y = lastTouch.y;
                
                for(int i=-radius;i<radius+1;i++){
                    for(int j=-radius;j<radius+1;j++){
                        ofVec2f searchPoint = ofVec2f(x+i,y+j);
                        ofColor currentColor = maps[currentIndex].pix.getColor(x+i,y+j);
                        if((lastTouch.distance(searchPoint) >= radius) and (lastTouch.distance(searchPoint) < radius + 1)) {
                            ofColor underColor = maps[currentIndex+1].pix.getColor(x+i,y+j);
                            
                            if(currentColor == colWater and underColor == colLand2) {
                                maps[currentIndex].pix.setColor(x+i,y+j,ofColor::red);
                            }
                        }
                    }
                }
                
                maps[currentIndex].update();
                
                radius += 1;
            }
        }
    }
}

//--------------------------------------------------------------
void ofApp::draw(){
    fbo.begin();
    ofClear(0, 0, 0, 255);
    noise.begin();
    noise.setUniform1f("iTime", ofGetElapsedTimef());
    noise.setUniform2f("iResolution", fbo.getWidth(), fbo.getHeight());
    maps[currentIndex].img.draw(0,0);
    noise.end();
    fbo.end();
    
    shader.begin();
    shader.setUniform1f("iTime", ofGetElapsedTimef());
    shader.setUniform2f("iResolution", ofGetWidth(), ofGetHeight());
    shader.setUniform2f("iChannelResolution", maps[currentIndex].img.getWidth(), maps[currentIndex].img.getHeight());
    float offset = maps[currentIndex].offset;
    float w = maps[currentIndex].w;
    float h = maps[currentIndex].h;
    fbo.draw(0, offset, w, h);
    shader.end();
    
    ofSetColor(254.,245.,200.,255.);
    float halfString = myPrettyFont.stringWidth("Save the Lake!")/2.;
    myPrettyFont.drawString("Save the Lake!", ofGetWidth()/2.-halfString, 92);
    halfString = myPrettyFont.stringWidth("|||||||||||||||||||||||||||||")/2.;
    myPrettyFont.drawString("|||||||||||||||||||||||||||||", ofGetWidth()/2.-halfString, ofGetHeight()-30);
    
    if(displayPhoto) {
        if(shift == ofVec2f(0,0)) {
            float px = min(finger[0].x, finger[1].x);
            // float pw = max(finger[0].x, finger[1].x) - px;
            float py = min(finger[0].y, finger[1].y);
            float ph = max(finger[0].y, finger[1].y) - py;
            
            float iw = photos[displayPhotoIndex].img.getWidth();
            float ih = photos[displayPhotoIndex].img.getHeight();
            
            float pw = ph * iw / ih;
            
            displayPhotoWidth = pw;
            displayPhotoHeight = ph;
            displayPhotoX = px;
            displayPhotoY = py;
            photos[displayPhotoIndex].img.draw(px, py, pw, ph);
        } else {
            float cx = (displayPhotoX+displayPhotoWidth)/2.;
            float cy = (displayPhotoY+displayPhotoHeight)/2.;
            float ix = displayPhotoX/2. + easing*(shift.x - cx);
            float iy = displayPhotoY/2. + easing*(shift.y - cy);
            photos[displayPhotoIndex].img.draw(ix, iy, displayPhotoWidth, displayPhotoHeight);
            if(easing < 1) easing += 0.01;
            displayPhotoX = ix;
            displayPhotoY = iy;
        }
    }
}

//--------------------------------------------------------------
void ofApp::exit(){

}

//--------------------------------------------------------------
bool isZoom(bool touched[], bool touched_p[], ofVec2f finger[], ofVec2f finger_p[]) {
    if(touched[0] && touched[1] && touched_p[0] && touched_p[1]) {
        ofVec2f center = (finger_p[0] + finger_p[1]) / 2.;
        if((center.distance(finger_p[0]) < center.distance(finger[0])) && (center.distance(finger_p[1]) < center.distance(finger[1]))) {
            return true;
        }
    }
    return false;
}

//--------------------------------------------------------------
void ofApp::touchDown(ofTouchEventArgs & touch){
    touched_p[touch.id] = touched[touch.id];
    finger_p[touch.id] = finger[touch.id];
    
    touched[touch.id] = true;
    finger[touch.id] = touch;
    
    if((displayPhoto == false) && (bleeding == false) && (freeze == 0)) {
        float offset = maps[currentIndex].offset;
        float imgWidth = maps[currentIndex].img.getWidth();
        float imgHeight = maps[currentIndex].img.getHeight();
        float w = maps[currentIndex].w;
        float h = maps[currentIndex].h;
        
        float x = touch.x * (imgWidth / w);
        float y = (touch.y - offset) * (imgHeight / h);
        
        ofColor currentColor = maps[currentIndex].pix.getColor(x, y);
        
        if(currentIndex < NUM_MAPS-1){
            ofColor underColor = maps[currentIndex+1].pix.getColor(x, y);
            
            if(currentColor == colWater and underColor == colLand2) {
                lastTouch.set(x,y);
                radius = 0;
                bleeding = true;
            } else {
                lastTouch.set(0,0);
            }
        } else {
            if(currentColor == colWater) {
                lastTouch.set(x,y);
                radius = 30;
                myAngleX = 0;
                myAngleY = 0;
                myAngleZ = 0;
            }
        }
    }
    
    if(displayPhoto){
        if((touched[0] == true) && (touched[1] == false)) {
            shift = ofVec2f(touch.x, touch.y);
        } else {
            shift = ofVec2f(0, 0);
        }
    }
}

//--------------------------------------------------------------
void ofApp::touchMoved(ofTouchEventArgs & touch){
    touched_p[touch.id] = touched[touch.id];
    finger_p[touch.id] = finger[touch.id];
    
    touched[touch.id] = true;
    finger[touch.id] = touch;
    
    if(isZoom(touched, touched_p, finger, finger_p)) {
        if(!displayPhoto) displayPhotoIndex = (int)ofRandom(NUM_PHOTOS);
        displayPhoto = true;
    }
    
    if(displayPhoto){
        if((touched[0] == true) && (touched[1] == false)) {
            shift = ofVec2f(touch.x, touch.y);
        } else {
            shift = ofVec2f(0, 0);
        }
    }
}

//--------------------------------------------------------------
void ofApp::touchUp(ofTouchEventArgs & touch){
    touched_p[touch.id] = touched[touch.id];
    finger_p[touch.id] = finger[touch.id];
    
    touched[touch.id] = false;
    finger[touch.id] = touch;
}

//--------------------------------------------------------------
void ofApp::touchDoubleTap(ofTouchEventArgs & touch){
    if(displayPhoto) {
        displayPhoto = false;
        displayPhotoWidth = 0;
        displayPhotoHeight = 0;
        displayPhotoX = 0;
        displayPhotoY = 0;
        shift = ofVec2f(0,0);
        freeze = 20;
    } else if((touch.x > ofGetWidth() * 0.65) and (touch.y > ofGetHeight() * 0.55)) {
        currentIndex += 1;
        bleeding = false;
        if(currentIndex >= NUM_MAPS-1) {
            currentIndex = NUM_MAPS - 1;
            if(maps[0].reset_c == false) {
                maps[0] = map0;
                maps[0].reset_c = true;
            }
        }
    }
}

//--------------------------------------------------------------
void ofApp::touchCancelled(ofTouchEventArgs & touch){
    
}

//--------------------------------------------------------------
void ofApp::lostFocus(){

}

//--------------------------------------------------------------
void ofApp::gotFocus(){

}

//--------------------------------------------------------------
void ofApp::gotMemoryWarning(){

}

//--------------------------------------------------------------
void ofApp::deviceOrientationChanged(int newOrientation){

}
