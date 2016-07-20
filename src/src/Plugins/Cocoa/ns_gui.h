
/******************************************************************************
* MODULE     : ns_gui.hpp
* DESCRIPTION: Aqua GUI class
* COPYRIGHT  : (C) 2006 Massimiliano Gubinelli
*******************************************************************************
* This software falls under the GNU general public license version 3 or later.
* It comes WITHOUT ANY WARRANTY WHATSOEVER. For details, see the file LICENSE
* in the root directory or <http://www.gnu.org/licenses/gpl-3.0.html>.
******************************************************************************/

#ifndef NS_GUI_H
#define NS_GUI_H
#include "mac_cocoa.h"
#include "timer.hpp"
#include "gui.hpp"
#include "font.hpp"
#include "widget.hpp" 
#include "array.hpp"
#include "hashmap.hpp"

#include "ns_widget.h"




/******************************************************************************
 * Event queue
 ******************************************************************************/

class qp_type {
public:
  enum id_t {
    QP_NULL,    QP_KEYPRESS,     QP_KEYBOARD_FOCUS,
    QP_MOUSE,   QP_RESIZE,       QP_SOCKET_NOTIFICATION,
    QP_COMMAND, QP_COMMAND_ARGS, QP_DELAYED_COMMANDS };
  id_t sid;
  inline qp_type (id_t sid2 = QP_NULL): sid (sid2) {}
  inline qp_type (const qp_type& s): sid (s.sid) {}
  inline qp_type& operator = (qp_type s) { sid = s.sid; return *this; }
  inline operator id_t () const { return sid; }
  inline bool operator == (id_t sid2) { return sid == sid2; }
  inline bool operator != (id_t sid2) { return sid != sid2; }
  inline bool operator == (qp_type s) { return sid == s.sid; }
  inline bool operator != (qp_type s) { return sid != s.sid; }
  inline friend tm_ostream& operator << (tm_ostream& out, qp_type s)
  { return out << s.sid; }
};

class queued_event : public pair<qp_type, blackbox>
{
public:
  queued_event (qp_type _type = qp_type(), blackbox _bb = blackbox())
  : pair<qp_type, blackbox>(_type, _bb) { }
};

/*!
 */
class event_queue {
  list<queued_event> q;
  event_queue (const event_queue& q2);  // = delete;
  event_queue& operator= (const event_queue& q2); // = delete;
  
  unsigned int n;  // ugly internal counter to avoid traversal of list in N(q)
public:
  event_queue();
  
  void append (const queued_event& ev);
  queued_event next ();
  bool is_empty() const;
  int size() const;
};



/******************************************************************************
* The ns_gui class
******************************************************************************/

typedef class ns_gui_rep* ns_gui;
extern ns_gui the_gui;

@class TMHelper;

class ns_gui_rep {
public:
  bool interrupted;
  time_t interrupt_time;
  time_t time_credit;        // interval to interrupt long redrawings
  time_t timeout_time;       // new redraw interruption

  
  // marshalling flags between update, needs_update and check_event.
  bool do_check_events;
  bool        updating;
  bool  needing_update;

  event_queue     waiting_events;

  
  TMHelper* helper;
  NSTimer* updatetimer;
  
  char*                        selection;
  hashmap<string,tree>         selection_t;
  hashmap<string,string>       selection_s;

public:
  ns_gui_rep(int& argc, char **argv);
  virtual ~ns_gui_rep();
  
  
  /********************* extents, grabbing, selections ***********************/
  void   get_extents (SI& width, SI& height);
  void   get_max_size (SI& width, SI& height);
 // void   set_button_state (unsigned int state);

  /* important routines */
   void event_loop ();
  
  /* interclient communication */
  virtual bool get_selection (string key, tree& t, string& s);
  virtual bool set_selection (string key, tree t, string s);
  virtual void clear_selection (string key);
  
  /* miscellaneous */
  void set_mouse_pointer (string name);
  void set_mouse_pointer (string curs_name, string mask_name);
  void show_wait_indicator (widget w, string message, string arg);
  
  /* event handling */
  void add_event (const queued_event& ev);
  bool check_event (int type);
  void set_check_events (bool enable_check);

  void update();
  void force_update();
  void need_update();
  void refresh_language();
  
  /* queued processing */
  void process_keypress (ns_simple_widget_rep *wid, string key, time_t t);
  void process_keyboard_focus (ns_simple_widget_rep *wid, bool has_focus,
                               time_t t);
  void process_mouse (ns_simple_widget_rep *wid, string kind, SI x, SI y,
                      int mods, time_t t);
  void process_resize (ns_simple_widget_rep *wid, SI x, SI y);
  void process_command (command _cmd);
  void process_command (command _cmd, object _args);
  void process_delayed_commands ();
  void process_queued_events (int max = -1);

  friend void needs_update ();
};

#endif // defined NS_GUI_H
