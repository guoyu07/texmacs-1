
/******************************************************************************
* MODULE     : ns_ui_element.h
* DESCRIPTION: NS UI element class
* COPYRIGHT  : (C) 2016  Massimiliano Gubinelli
*******************************************************************************
* This software falls under the GNU general public license version 3 or later.
* It comes WITHOUT ANY WARRANTY WHATSOEVER. For details, see the file LICENSE
* in the root directory or <http://www.gnu.org/licenses/gpl-3.0.html>.
******************************************************************************/

#ifndef NS_UI_ELEMENT_H
#define NS_UI_ELEMENT_H

#include "ns_widget.h"
//#include "ns_menu.h"

@class TMMenuItem;

class ns_ui_element_rep: public ns_widget_rep {

public:
  
  enum types {
    none = 0,
    input_widget,    file_chooser,       window_widget,      view_widget,
    horizontal_menu, vertical_menu,      horizontal_list,    vertical_list,
    tile_menu,       minibar_menu,       menu_separator,     menu_group,
    pulldown_button, pullright_button,   menu_button,        balloon_widget,
    text_widget,     xpm_widget,         toggle_widget,      enum_widget,
    choice_widget,   scrollable_widget,  hsplit_widget,      vsplit_widget,
    aligned_widget,  tabs_widget,        icon_tabs_widget,   wrapped_widget,
    refresh_widget,  refreshable_widget, glue_widget,        resize_widget,
    texmacs_widget,  simple_widget,      embedded_tm_widget, popup_widget,
    field_widget,    filtered_choice_widget, tree_view_widget
  } ;
  
private:
  
  types     type;
  blackbox  load;
  
public:

  ns_ui_element_rep (types _type, blackbox _load);
  virtual ~ns_ui_element_rep();
  
  virtual widget make_popup_widget ();
  
  virtual TMMenuItem* as_menuitem ();
  virtual NSView* as_view ();
  
  operator tree ();
  
  template<class X1> static ns_widget create (types _type, X1 x1) {
    return tm_new <ns_ui_element_rep> (_type, close_box<X1>(x1));
  }
  
  template <class X1, class X2>
  static ns_widget create (types _type, X1 x1, X2 x2) {
    typedef pair<X1,X2> T;
    return tm_new <ns_ui_element_rep> (_type, close_box<T> (T (x1,x2)));
  }
  
  template <class X1, class X2, class X3>
  static ns_widget create (types _type, X1 x1, X2 x2, X3 x3) {
    typedef triple<X1,X2,X3> T;
    return tm_new <ns_ui_element_rep> (_type, close_box<T> (T (x1,x2,x3)));
  }
  
  template <class X1, class X2, class X3, class X4>
  static ns_widget create (types _type, X1 x1, X2 x2, X3 x3, X4 x4) {
    typedef quartet<X1,X2,X3,X4> T;
    return tm_new <ns_ui_element_rep> (_type, close_box<T> (T (x1,x2,x3,x4)));
  }
  
  template <class X1, class X2, class X3, class X4, class X5>
  static ns_widget create (types _type, X1 x1, X2 x2, X3 x3, X4 x4, X5 x5) {
    typedef quintuple<X1,X2,X3,X4,X5> T;
    return tm_new <ns_ui_element_rep> (_type, close_box<T> (T (x1,x2,x3,x4,x5)));
  }
  
protected:
//  static blackbox get_payload (ns_widget qtw, types check_type = none);
};


#endif /* NS_UI_ELEMENT_H */
