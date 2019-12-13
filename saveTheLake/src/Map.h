#pragma once

#include "ofxiOS.h"

class Map{
    
    public:
    void setup(int i){
        index = i;
        name = "map" + to_string(i);
        
        img.load("Aral_Sea/" + to_string(i) + ".png");
        
        w = ofGetWidth();
        h =  img.getHeight() * w / img.getWidth();
        offset = (ofGetHeight() - h) / 2;
        
        pix = img.getPixels();
        reset_c = false;
    };
    
    void update() {
        img.setFromPixels(pix);
    };
    
    void reset() {
        img.load("Aral_Sea/" + to_string(index) + ".png");
        pix = img.getPixels();
        reset_c = true;
    };
    
    void draw(){
        img.draw(0, offset, w, h);
    };
    
    ofImage img;
    int index;
    string name;
    float w;
    float h;
    float offset;
    
    ofPixels pix;
    bool reset_c;
};
