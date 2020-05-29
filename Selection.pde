
////////////////////////////////
class BBox
{
  public PVector B1; //min vertex
  public PVector B2; //max vertex
  public PVector C;  //center vertex
  
  BBox()  {}
  BBox(PVector min, PVector max){
    this.B1 = min;
    this.B2 = max;
    this.C = new PVector((max.x-min.x)/2, (max.y-min.y)/2, (max.z-min.z)/2);
  }
  BBox(PVector min, PVector max, PVector cen){
    this.B1 = min;
    this.B2 = max;
    this.C = cen;
  }
  
  // Update max
  public void UpdateMax(float x, float y, float z) {
    this.B2.x = x;
    this.B2.y = y;
    this.B2.z = z;
     
    this.B1.x = 0;
    this.B1.y = 0;
    this.B1.z = z-10;
    
    this.C.x = (B2.x-B1.x)/2;
    this.C.y = (B2.y-B1.y)/2;
    this.C.z = (B2.z-B1.z)/2;
  }
  
  // returns true if line (L1, L2) intersects with the box (B1, B2)
  // returns intersection point in Hit
  public boolean CheckLineBox( PVector L1, PVector L2, PVector Hit)
  {
    if (L2.x < B1.x && L1.x < B1.x) return false; //<>// //<>//
    if (L2.x > B2.x && L1.x > B2.x) return false;
    if (L2.y < B1.y && L1.y < B1.y) return false;
    if (L2.y > B2.y && L1.y > B2.y) return false;
    if (L2.z < B1.z && L1.z < B1.z) return false;
    if (L2.z > B2.z && L1.z > B2.z) return false;
    if (L1.x > B1.x && L1.x < B2.x && L1.y > B1.y && L1.y < B2.y && L1.z > B1.z && L1.z < B2.z){
      Hit = L1;  
      return true;
    }
    
    if ( (GetIntersection( L1.x-B2.x, L2.x-B2.x, L1, L2, Hit) && InBox( Hit, 1 )) 
      || (GetIntersection( L1.y-B2.y, L2.y-B2.y, L1, L2, Hit) && InBox( Hit, 2 )) 
      || (GetIntersection( L1.z-B2.z, L2.z-B2.z, L1, L2, Hit) && InBox( Hit, 3 ))
      || (GetIntersection( L1.x-B1.x, L2.x-B1.x, L1, L2, Hit) && InBox( Hit, 1 ))
      || (GetIntersection( L1.y-B1.y, L2.y-B1.y, L1, L2, Hit) && InBox( Hit, 2 )) 
      || (GetIntersection( L1.z-B1.z, L2.z-B1.z, L1, L2, Hit) && InBox( Hit, 3 ))) 
        return true;
    
    return false;
  }
  private boolean GetIntersection( float fDst1, float fDst2, PVector P1, PVector P2, PVector Hit) {
    if ( (fDst1 * fDst2) >= 0.0f) return false;
    if ( fDst1 == fDst2) return false; 
    PVector p = PVector.add(P1, PVector.mult(PVector.sub(P2, P1), -fDst1/(fDst2-fDst1)));
    Hit.x = p.x;
    Hit.y = p.y;
    Hit.z = p.z;
    
    return true;
  }
    
  private boolean InBox( PVector Hit, int Axis) {
    if ( Axis==1 && Hit.z > B1.z && Hit.z < B2.z && Hit.y > B1.y && Hit.y < B2.y) return true;
    if ( Axis==2 && Hit.z > B1.z && Hit.z < B2.z && Hit.x > B1.x && Hit.x < B2.x) return true;
    if ( Axis==3 && Hit.x > B1.x && Hit.x < B2.x && Hit.y > B1.y && Hit.y < B2.y) return true;
    return false;
  }
  
}
/////////////////////////////////







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
