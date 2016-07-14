//
//  ns_simple_widget.mm
//  TeXmacs
//
//  Created by Massimiliano Gubinelli on 14/07/16.
//  Copyright © 2016 TeXmacs.org. All rights reserved.
//

#include "message.hpp"

#include "ns_simple_widget.h"
#include "ns_gui.h"
#include "ns_widget.h"



simple_widget_rep::simple_widget_rep ()
: widget_rep () {  }

void
simple_widget_rep::handle_get_size_hint (SI& w, SI& h) {
  gui_root_extents (w, h);
}

void
simple_widget_rep::handle_notify_resize (SI w, SI h) {
  (void) w; (void) h;
}

void
simple_widget_rep::handle_keypress (string key, time_t t) {
  (void) key; (void) t;
}

void
simple_widget_rep::handle_keyboard_focus (bool has_focus, time_t t) {
  (void) has_focus; (void) t;
}

void
simple_widget_rep::handle_mouse (string kind, SI x, SI y, int mods, time_t t) {
  (void) kind; (void) x; (void) y; (void) mods; (void) t;
}

void
simple_widget_rep::handle_set_zoom_factor (double zoom) {
  (void) zoom;
}

void
simple_widget_rep::handle_clear (renderer ren, SI x1, SI y1, SI x2, SI y2) {
  (void) ren; (void) x1; (void) y1; (void) x2; (void) y2;
}

void
simple_widget_rep::handle_repaint (renderer ren, SI x1, SI y1, SI x2, SI y2) {
  (void) ren; (void) x1; (void) y1; (void) x2; (void) y2;
}

void
simple_widget_rep::send (slot s, blackbox val) {
  get_impl()->send (s, val);
}

blackbox
simple_widget_rep::query (slot s, int type_id) {
  get_impl()->query (s, type_id);
}

void
simple_widget_rep::notify (slot s, blackbox new_val) {
  get_impl()->notify (s, new_val);
}

widget
simple_widget_rep::read (slot s, blackbox index) {
  return get_impl()->read(s,index);
}

void
simple_widget_rep::write (slot s, blackbox index, widget w) {
  get_impl()->write(s,index,w);
}

widget
simple_widget_rep::get_impl () {
  if (is_nil(impl)) {
    ns_simple_widget_rep *p = tm_new<ns_simple_widget_rep>();
    p->setCounterpart(this);
    impl = p;
  }
  return impl;
}

