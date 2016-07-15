
/******************************************************************************
* MODULE     : ns_widget.h
* DESCRIPTION: Aqua widget class
* COPYRIGHT  : (C) 2007  Massimiliano Gubinelli
*******************************************************************************
* This software falls under the GNU general public license version 3 or later.
* It comes WITHOUT ANY WARRANTY WHATSOEVER. For details, see the file LICENSE
* in the root directory or <http://www.gnu.org/licenses/gpl-3.0.html>.
******************************************************************************/

#ifndef NS_WIDGET_H
#define NS_WIDGET_H

#include "widget.hpp"
#include "ns_simple_widget.h"
#include "TMView.h"

@class TMMenuItem;
@class TMView;



class ns_widget_rep : public widget_rep {
public:
	ns_widget_rep() : widget_rep () { };
	
	virtual widget plain_window_widget (string s); 
	virtual widget make_popup_widget (); 
	virtual widget popup_window_widget (string s); 
 
  virtual TMMenuItem *as_menuitem();
  
};


class ns_widget {
public:
  ABSTRACT_NULL(ns_widget);
  inline bool operator == (ns_widget w) { return rep == w.rep; }
  inline bool operator != (ns_widget w) { return rep != w.rep; }
};
ABSTRACT_NULL_CODE(ns_widget);

inline widget abstract (ns_widget w) { return widget (w.rep); }
inline ns_widget concrete (widget w) { return ns_widget ((ns_widget_rep*) w.rep); }


class ns_view_widget_rep: public ns_widget_rep {
public:
  NSView *view;
  
public:
  ns_view_widget_rep (NSView *v);
  ~ns_view_widget_rep ();
  
  virtual void send (slot s, blackbox val);
  // send a message val to the slot s
  virtual blackbox query (slot s, int type_id);
  // obtain information of a given type from the slot s
  virtual widget read (slot s, blackbox index);
  // abstract read access (of type s) of a subwidget at position index
  virtual void write (slot s, blackbox index, widget w);
  // abstract write access (of type s) of a subwidget at position index
  virtual void notify (slot s, blackbox new_val);
  // notification of a change on a slot s which contains a state variable
  //  virtual void connect (slot s, widget w2, slot s2);
  // connect a state slot s to another slot s2 of another widget w2
  //  virtual void deconnect (slot s, widget w2, slot s2);
  // deconnect a state slot s from another slot s2 of another widget w2
  
  virtual widget plain_window_widget (string s);
  
};


class ns_simple_widget_rep: public ns_view_widget_rep {
  
  widget p_counterpart;
  
  simple_widget_rep *counterpart ()  { return dynamic_cast<simple_widget_rep*>(p_counterpart.rep); }
  void setCounterpart (simple_widget_rep *w)  { p_counterpart = w; }

public:
  ns_simple_widget_rep (simple_widget_rep *w);
  
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
  
  TMView*         canvas () { return (TMView*)(view); }
  
  NSRect    p_extents;   // The size of the virtual area where things are drawn.
  NSPoint    p_origin;   // The offset into that area
  
  NSPoint       backing_pos;

  
  void scrollContentsBy ( int dx, int dy );
  void updateScrollBars (void);
  void setExtents ( NSRect newExtents );
  
  virtual TMMenuItem *as_menuitem();
};



extern widget the_keyboard_focus;


#endif // defined NS_WIDGET_H
