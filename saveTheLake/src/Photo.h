#pragma once

#include "ofxiOS.h"

class Photo{
    
    public:
    void setup(int i){
        index = i;
        name = "photo" + to_string(i);
        
        img.load("Photos/" + to_string(i) + ".jpg");
        
        w = ofGetWidth();
        h =  img.getHeight() * w / img.getWidth();
        offset = (ofGetHeight() - h) / 2;
    };
    
    void update() {

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
};
