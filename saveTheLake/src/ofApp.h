#pragma once

#include "ofxiOS.h"
#include "ofxiOSCoreMotion.h"
#include "Map.h"
#include "Photo.h"

#define NUM_MAPS 8
#define NUM_PHOTOS 15

class ofApp : public ofxiOSApp {
	
    public:
        void setup();
        void update();
        void draw();
        void exit();
	
        void touchDown(ofTouchEventArgs & touch);
        void touchMoved(ofTouchEventArgs & touch);
        void touchUp(ofTouchEventArgs & touch);
        void touchDoubleTap(ofTouchEventArgs & touch);
        void touchCancelled(ofTouchEventArgs & touch);

        void lostFocus();
        void gotFocus();
        void gotMemoryWarning();
        void deviceOrientationChanged(int newOrientation);

    Map maps[NUM_MAPS];
    Map map0;
    Photo photos[NUM_PHOTOS];
    int currentIndex;
    
    ofColor colWater;
    ofColor colLand1;
    ofColor colLand2;
    
    ofVec2f lastTouch;
    float radius;
    
    ofxiOSCoreMotion myCoreMotion;
    
    float myAngleX;
    float myAngleY;
    float myAngleZ;
    
    ofShader shader;
    ofShader noise;
    ofFbo fbo;
    
    ofTrueTypeFont myPrettyFont;
    
    ofVec2f finger[2];
    bool touched[2];
    
    ofVec2f finger_p[2];
    bool touched_p[2];
    
    bool displayPhoto;
    int displayPhotoIndex;
    float displayPhotoWidth;
    float displayPhotoHeight;
    float displayPhotoX;
    float displayPhotoY;
    ofVec2f shift;
    
    float easing;
    float freeze;
    
    bool bleeding;
};


