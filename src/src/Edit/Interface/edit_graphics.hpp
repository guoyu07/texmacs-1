
/******************************************************************************
* MODULE     : edit_graphics.hpp
* DESCRIPTION: the interface for TeXmacs
* COPYRIGHT  : (C) 1999  Joris van der Hoeven
*******************************************************************************
* This software falls under the GNU general public license and comes WITHOUT
* ANY WARRANTY WHATSOEVER. See the file $TEXMACS_PATH/LICENSE for more details.
* If you don't have this file, write to the Free Software Foundation, Inc.,
* 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
******************************************************************************/

#ifndef EDIT_GRAPHICS_H
#define EDIT_GRAPHICS_H
#include "editor.hpp"
#include "timer.hpp"

class edit_graphics_rep: virtual public editor_rep {
private:
  box go_box;           // The graphical object typesetted as a box
  double gr_x, gr_y;    // Last (x, y) position of the mouse
  gr_selections gs;     // Last graphical_select (x, y)
  array<point> pts;     // Last control points
  array<point> ci, cgi; // Last Curves & Grid/curves intersections (x, y)
  grid gr0;             // Last grid

protected:
  point cur_pos;
  tree graphical_object;

public:
  edit_graphics_rep ();
  ~edit_graphics_rep ();

  bool   inside_graphics (bool b);
  bool   inside_active_graphics (bool b);
  bool   over_graphics (SI x, SI y);
  tree   get_graphics ();
  double get_x ();
  double get_y ();
  frame  find_frame (bool last= false);
  grid   find_grid ();
  void   find_limits (point& lim1, point& lim2);
  bool   find_graphical_region (SI& x1, SI& y1, SI& x2, SI& y2);
  point  adjust (point p);
  tree   find_point (point p);
  tree   graphical_select (double x, double y);
  tree   graphical_select (double x1, double y1, double x2, double y2);
  tree   get_graphical_object ();
  void   set_graphical_object (tree t);
  void   invalidate_graphical_object ();
  void   draw_graphical_object (renderer ren);
  bool   mouse_graphics (string s, SI x, SI y, time_t t);
};

#endif // defined EDIT_GRAPHICS_H
