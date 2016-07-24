
/******************************************************************************
* MODULE     : simple_wk_widget.cpp
* DESCRIPTION: Simple wk_widgets for customization later on
* COPYRIGHT  : (C) 2007  Joris van der Hoeven
*******************************************************************************
* This software falls under the GNU general public license version 3 or later.
* It comes WITHOUT ANY WARRANTY WHATSOEVER. For details, see the file LICENSE
* in the root directory or <http://www.gnu.org/licenses/gpl-3.0.html>.
******************************************************************************/

#include "Widkit/simple_wk_widget.hpp"
#include "gui.hpp"
#include "message.hpp"

/******************************************************************************
* Constructor
******************************************************************************/

simple_widget_rep::simple_widget_rep (widget_delegate_rep *del2):
  attribute_widget_rep (), del (del2) {}

widget proxy_widget (widget_delegate_rep *del) {
  wk_widget wid =  tm_new<simple_widget_rep> (del);
  return abstract (wid);
}


simple_widget_rep::operator tree () {
  return tree (TUPLE, "simple");
}

/******************************************************************************
* Empty handlers for redefinition later on
******************************************************************************/

bool
simple_widget_rep::is_editor_widget () {
  return del ? del->is_editor_widget() : false;
}

void
simple_widget_rep::handle_get_size_hint (SI& w, SI& h) {
  if (del) del->handle_get_size_hint(w,h);
  else gui_root_extents (w, h);
}

void
simple_widget_rep::handle_notify_resize (SI w, SI h) {
  if (del) del->handle_notify_resize (w, h);
}

void
simple_widget_rep::handle_keypress (string key, time_t t) {
  if (del) {
    // keep delegate alive
    INC_COUNT (del);
    del->handle_keypress (key, t);
    DEC_COUNT (del);
  }
}

void
simple_widget_rep::handle_keyboard_focus (bool has_focus, time_t t) {
  if (del) del->handle_keyboard_focus (has_focus, t);
}

void
simple_widget_rep::handle_mouse (string kind, SI x, SI y, int mods, time_t t) {
  if (del) {
    // keep delegate alive
    INC_COUNT (del);
    del->handle_mouse (kind, x, y, mods, t);
    DEC_COUNT (del);
  }
}

void
simple_widget_rep::handle_set_zoom_factor (double zoom) {
  if (del) del->handle_set_zoom_factor (zoom);
}

void
simple_widget_rep::handle_clear (renderer win, SI x1, SI y1, SI x2, SI y2) {
  if (del) del->handle_clear (win, x1, y1, x2, y2);
}

void
simple_widget_rep::handle_repaint (renderer win, SI x1, SI y1, SI x2, SI y2) {
  if (del) del->handle_repaint (win, x1, y1, x2, y2);
}


template<class T> void
check_type (blackbox bb, string s) {
  if (type_box (bb) != type_helper<T>::id) {
    failed_error << "slot type= " << s << "\n";
    FAILED ("type mismatch");
  }
}

void
simple_widget_rep::send (slot s, blackbox val) {
  switch (s) {
    case SLOT_DELEGATE:
    {
      check_type<pointer> (val, "SLOT_DELEGATE");
      pointer p = open_box<pointer> (val);
      del = (widget_delegate_rep*)p;
    }
      break;
      
    default:
      attribute_widget_rep::send (s, val);
      break;
  }
}

/******************************************************************************
* Calling the handlers from the usual widkit handlers
******************************************************************************/

void
simple_widget_rep::handle_get_size (get_size_event ev) {
  handle_get_size_hint (ev->w, ev->h);
}

void
simple_widget_rep::handle_attach_window (attach_window_event ev) {
  basic_widget_rep::handle_attach_window (ev);
}

void
simple_widget_rep::handle_resize (resize_event ev) { (void) ev;
  handle_notify_resize (0, 0); // FIXME
}

void
simple_widget_rep::handle_keypress (keypress_event ev) {
  handle_keypress (ev->key, ev->t);
}

void
simple_widget_rep::handle_keyboard_focus (keyboard_focus_event ev) {
  handle_keyboard_focus (ev->flag, ev->t);
}

void
simple_widget_rep::handle_mouse (mouse_event ev) {
  handle_mouse (ev->type, ev->x, ev->y, ev->mods, ev->t);
}

void
simple_widget_rep::handle_set_integer (set_integer_event ev) {
  (void) ev;
}

void
simple_widget_rep::handle_set_double (set_double_event ev) {
  if (ev->which == "zoom factor")
    handle_set_zoom_factor (ev->x);
}

void
simple_widget_rep::handle_clear (clear_event ev) {
  handle_clear (ev->win, ev->x1, ev->y1, ev->x2, ev->y2);
}

void
simple_widget_rep::handle_repaint (repaint_event ev) {
  handle_repaint (ev->win, ev->x1, ev->y1, ev->x2, ev->y2);
}

void
simple_widget_rep::handle_set_coord2 (set_coord2_event ev) {
  if (ev->which == "extra width" && ev->c1 == 0 && ev->c2 == 0) return;
  else WK_FAILED ("could not set coord2 attribute " * ev->which);
}

void
simple_widget_rep::handle_get_coord2 (get_coord2_event ev) {
  if (ev->which == "extra width") { ev->c1= ev->c2= 0; return; }
  else WK_FAILED ("could not get coord2 attribute " * ev->which);
}
