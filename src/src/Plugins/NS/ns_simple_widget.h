
/******************************************************************************
* MODULE     : ns_simple_widget.hpp
* DESCRIPTION: Aqua simple widget class
* COPYRIGHT  : (C) 2007  Massimiliano Gubinelli
*******************************************************************************
* This software falls under the GNU general public license version 3 or later.
* It comes WITHOUT ANY WARRANTY WHATSOEVER. For details, see the file LICENSE
* in the root directory or <http://www.gnu.org/licenses/gpl-3.0.html>.
******************************************************************************/

#ifndef NS_SIMPLE_WIDGET_H
#define NS_SIMPLE_WIDGET_H

#include "widget.hpp"

class simple_widget_rep: public widget_rep {
  
  widget impl;
  
public:
  simple_widget_rep ();
	
  virtual void handle_get_size_hint (SI& w, SI& h);
  virtual void handle_notify_resize (SI w, SI h);
  virtual void handle_keypress (string key, time_t t);
  virtual void handle_keyboard_focus (bool has_focus, time_t t);
  virtual void handle_mouse (string kind, SI x, SI y, int mods, time_t t);
  virtual void handle_set_zoom_factor (double zoom);
  virtual void handle_clear (renderer ren, SI x1, SI y1, SI x2, SI y2);
  virtual void handle_repaint (renderer ren, SI x1, SI y1, SI x2, SI y2);

	virtual void send (slot s, blackbox val);
	// send a message val to the slot s
  virtual blackbox query (slot s, int type_id);
	// obtain information of a given type from the slot s
  virtual widget read (slot s, blackbox index);
	// abstract read access (of type s) of a subwidget at position index
  virtual void write (slot s, blackbox index, widget w);
	// abstract write access (of type s) of a subwidget at position index
  virtual void notify (slot s, blackbox new_val);
  
  widget get_impl (); //{ return impl; }
 // void set_impl (widget _impl) { impl = _impl; }
};

#endif // defined NS_SIMPLE_WIDGET_H
