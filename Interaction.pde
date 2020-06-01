// MOUSE CONTROLS
// 
void mousePressed() { 
  if(mouseButton == LEFT && __isDrawMode) {
    p.StartStroke();
  }
  //if(mouseButton == RIGHT && __isDrawMode) {
    //PVector wc = p.MousePointInWorldCoordinates();
    
    // intervenes with stroke prints
    // needs an isPrinting check with acknowledgements
    //SendMessage("/move", w2b(wc.x), w2b(wc.y), p.current_height);
  //}
}
void mouseDragged() {
  if(mouseButton == LEFT && __isDrawMode) {
    p.CollectStroke();
  }
}
void mouseReleased() {
  if(mouseButton == LEFT && __isDrawMode) {
    p.EndStroke();
  }
}

// KEYBOARD CONTROLS
//
boolean __isDrawMode = false;
boolean __isAltDown = false;
void keyReleased(KeyEvent e) {
  // update Alt key (left and right alt keys are 18 and 19)
  if(e.getKeyCode() == 18 || e.getKeyCode() == 19) __isAltDown = false;
}
// 
void keyPressed(KeyEvent e) {
  // update Alt key
  if(e.isAltDown()) __isAltDown = true;
  
  if(key == ' ') {
    __isDrawMode = !__isDrawMode;
    if(__isDrawMode) {
      cam.setLeftDragHandler(null);
      cam.setRightDragHandler(null);
    }
    else {
      cam.setLeftDragHandler(rotateHandler);
      cam.setRightDragHandler(zoomHandler);
    }
    PrintManager("Draw Mode="+__isDrawMode, __isDrawMode? 3:2);
  }
  if(key == 't' || key == 'T') {
    TopView();
  }
}
////////////////////////////////



/////////////////////////////////
/////////////////////////////////

// http://andrewmarsh.com/blog/2011/12/04/gluunproject-p3d-and-opengl-sketches/
public class Selection_in_P3D_OPENGL_A3D
{

  // True if near and far points calculated.
  public boolean isValid() { 
    return m_bValid;
  }
  private boolean m_bValid = false;

  // Maintain own projection matrix.
  public PMatrix3D getMatrix() { 
    return m_pMatrix;
  }
  private PMatrix3D m_pMatrix = new PMatrix3D();

  // Maintain own viewport data.
  public int[] getViewport() { 
    return m_aiViewport;
  }
  private int[] m_aiViewport = new int[4];

  // Store the near and far ray positions.
  public PVector ptStartPos = new PVector();
  public PVector ptEndPos = new PVector();

  // -------------------------

  public void captureViewMatrix(PGraphics3D g3d)
  { // Call this to capture the selection matrix after
    // you have called perspective() or ortho() and applied your
    // pan, zoom and camera angles - but before you start drawing
    // or playing with the matrices any further.

    if (g3d == null)
    { // Use main canvas if it is P3D, OPENGL or A3D.
      g3d = (PGraphics3D)g;
    }

    if (g3d != null)
    { // Check for a valid 3D canvas.

      // Capture current projection matrix.
      m_pMatrix.set(g3d.projection);

      // Multiply by current modelview matrix.
      m_pMatrix.apply(g3d.modelview);

      // Invert the resultant matrix.
      m_pMatrix.invert();

      // Store the viewport.
      m_aiViewport[0] = 0;
      m_aiViewport[1] = 0;
      m_aiViewport[2] = g3d.width;
      m_aiViewport[3] = g3d.height;
    }
  }

  // -------------------------

  public boolean gluUnProject(float winx, float winy, float winz, PVector result)
  {

    float[] in = new float[4];
    float[] out = new float[4];

    // Transform to normalized screen coordinates (-1 to 1).
    in[0] = ((winx - (float)m_aiViewport[0]) / (float)m_aiViewport[2]) * 2.0f - 1.0f;
    in[1] = ((winy - (float)m_aiViewport[1]) / (float)m_aiViewport[3]) * 2.0f - 1.0f;
    in[2] = constrain(winz, 0f, 1f) * 2.0f - 1.0f;
    in[3] = 1.0f;

    // Calculate homogeneous coordinates.
    out[0] = m_pMatrix.m00 * in[0]
      + m_pMatrix.m01 * in[1]
      + m_pMatrix.m02 * in[2]
      + m_pMatrix.m03 * in[3];
    out[1] = m_pMatrix.m10 * in[0]
      + m_pMatrix.m11 * in[1]
      + m_pMatrix.m12 * in[2]
      + m_pMatrix.m13 * in[3];
    out[2] = m_pMatrix.m20 * in[0]
      + m_pMatrix.m21 * in[1]
      + m_pMatrix.m22 * in[2]
      + m_pMatrix.m23 * in[3];
    out[3] = m_pMatrix.m30 * in[0]
      + m_pMatrix.m31 * in[1]
      + m_pMatrix.m32 * in[2]
      + m_pMatrix.m33 * in[3];

    if (out[3] == 0.0f)
    { // Check for an invalid result.
      result.x = 0.0f;
      result.y = 0.0f;
      result.z = 0.0f;
      return false;
    }

    // Scale to world coordinates.
    out[3] = 1.0f / out[3];
    result.x = out[0] * out[3];
    result.y = out[1] * out[3];
    result.z = out[2] * out[3];
    return true;
  }

  public boolean calculatePickPoints(int x, int y)
  { // Calculate positions on the near and far 3D frustum planes.
    m_bValid = true; // Have to do both in order to reset PVector on error.
    if (!gluUnProject((float)x, (float)y, 0.0f, ptStartPos)) m_bValid = false;
    if (!gluUnProject((float)x, (float)y, 1.0f, ptEndPos)) m_bValid = false;
    return m_bValid;
  }
}
