import peasy.*;
import peasy.org.apache.commons.math.geometry.Rotation;
import peasy.org.apache.commons.math.geometry.Vector3D;

Selection_in_P3D_OPENGL_A3D select;
PeasyCam cam;

PeasyDragHandler panHandler;
PeasyDragHandler rotateHandler;
PeasyDragHandler zoomHandler;
PeasyWheelHandler wheelHandler; 

CameraState topView;

// 
void InitCamera() {
  cam = new PeasyCam(this, 500);
  cam.setResetOnDoubleClick(false);
  cam.setMinimumDistance(0.5);
  // middle of the bed for look at
  float x =  0.5 * b2w(bed_size);
  float y = -0.5 * b2w(bed_size); //(flip-y manually)
  float z = 0; 
  cam.lookAt(x, y, z);
  
  // save default handlers
  panHandler = cam.getPanDragHandler();
  rotateHandler = cam.getRotateDragHandler();
  zoomHandler = cam.getZoomDragHandler();
  wheelHandler = cam.getZoomWheelHandler();
  
  // save top view as camera state
  topView = new CameraState(new Rotation(new Vector3D(0,0,10),new Vector3D(0,0,PI)), 
                            new Vector3D(x,y,z), 
                            cam.getDistance());

  // 3d-selection 
  select = new Selection_in_P3D_OPENGL_A3D();
}

//
void TopView() {
  cam.setState(topView, 500);
}

//
PVector CameraPosition() {
  float[] arr = cam.getPosition();
  return new PVector(arr[0], arr[1], arr[2]);
}

//
float CameraDistanceScaleDown() {
  return stepMap((float)cam.getDistance(), 0, 500, 0.5, smooth_stroke);
}
