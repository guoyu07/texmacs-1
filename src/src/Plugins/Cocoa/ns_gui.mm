
/******************************************************************************
* MODULE     : ns_gui.mm
* DESCRIPTION: Cocoa display class
* COPYRIGHT  : (C) 2006 Massimiliano Gubinelli
*******************************************************************************
* This software falls under the GNU general public license version 3 or later.
* It comes WITHOUT ANY WARRANTY WHATSOEVER. For details, see the file LICENSE
* in the root directory or <http://www.gnu.org/licenses/gpl-3.0.html>.
******************************************************************************/


#include "iterator.hpp"
#include "dictionary.hpp"
#include "ns_gui.h"
#include "analyze.hpp"
#include <locale.h>
#include "language.hpp"
#include "message.hpp"
#include "command.hpp"
#include "scheme.hpp"

#include "ns_renderer.h" // for the_ns_renderer

//extern hashmap<id, pointer> NSWindow_to_window;
//extern window (*get_current_window) (void);

ns_gui_rep* the_gui= NULL;

int nr_windows = 0; // FIXME: fake variable, referenced in tm_server

bool ns_update_flag= false;

int time_credit;
int timeout_time;



/******************************************************************************
 * Queued events
 ******************************************************************************/

#pragma mark Queued events

event_queue::event_queue() : n(0) { }

void
event_queue::append (const queued_event& ev) {
  q << ev;
  ++n;
}

queued_event
event_queue::next () {
  if (is_nil(q))
    return queued_event();
  queued_event ev = q->item;
  q = q->next;
  --n;
  return ev;
}

bool
event_queue::is_empty() const {
  ASSERT (!(n!=0 && is_nil(q)), "WTF?");
  return n == 0;
}

int
event_queue::size() const {
  return n;
}


/******************************************************************************
 * Delayed commands
 ******************************************************************************/

#pragma mark Delayed commands

command_queue::command_queue() : lapse (0), wait (true) { }
command_queue::~command_queue() { clear_pending(); /* implicit */ }

void
command_queue::exec (object cmd) {
  q << cmd;
  start_times << (((time_t) texmacs_time ()) - 1000000000);
  lapse = texmacs_time();
  the_gui->need_update();
  wait= true;
}

void
command_queue::exec_pause (object cmd) {
  q << cmd;
  start_times << ((time_t) texmacs_time ());
  lapse = texmacs_time();
  the_gui->need_update();
  wait= true;
}

void
command_queue::exec_pending () {
  array<object> a = q;
  array<time_t> b = start_times;
  q = array<object> (0);
  start_times = array<time_t> (0);
  int i, n = N(a);
  for (i = 0; i<n; i++) {
    time_t now =  texmacs_time ();
    if ((now - b[i]) >= 0) {
      object obj = call (a[i]);
      if (is_int (obj) && (now - b[i] < 1000000000)) {
        time_t pause = as_int (obj);
        //cout << "pause = " << obj << "\n";
        q << a[i];
        start_times << (now + pause);
      }
    }
    else {
      q << a[i];
      start_times << b[i];
    }
  }
  if (N(q) > 0) {
    wait = true;  // wait_for_delayed_commands
    lapse = start_times[0];
    int n = N(start_times);
    for (i = 1; i<n; i++) {
      if (lapse > start_times[i]) lapse = start_times[i];
    }
  } else
    wait = false;
}

void
command_queue::clear_pending () {
  q = array<object> (0);
  start_times = array<time_t> (0);
  wait = false;
}

bool
command_queue::must_wait (time_t now) const {
  return wait && (lapse <= now);
}



/******************************************************************************
 * TMHelper
 ******************************************************************************/

#pragma mark TMHelper

@interface TMHelper : NSObject
{
}
@end

@implementation TMHelper
- init
{
  if (self = [super init])
  {
    //[[NSApplication sharedApplication] setDelegate: self];
  }
  return self;
}

- (void)applicationWillUpdate: (NSNotification *)aNotification
{
  NSBeep();
  the_gui->update ();
}

- (void)dealloc
{
  [NSApp setDelegate:nil];
  [super dealloc];
}

- (void) update
{
  //	NSBeep();
  the_gui->update ();
  //[self performSelector:@selector(waitIdle) withObject:nil afterDelay:0.25 inModes:[NSArray arrayWithObjects:NSDefaultRunLoopMode, nil]];
}

@end


/******************************************************************************
 * Constructor and geometry
 ******************************************************************************/


ns_gui_rep::ns_gui_rep(int& argc, char** argv): 
interrupted(false), time_credit (100), do_check_events (false), updating (false),
needing_update (false), selection(NULL), updatetimer(nil)
{
  (void) argc; (void) argv;
//  argc               = argc2;
//  argv               = argv2;
  interrupted  = false;
  time_credit  = 100;
  timeout_time = texmacs_time () + time_credit;
  
  helper = 	[[TMHelper alloc] init];


  set_output_language (get_locale_language ());
  refresh_language();

}

ns_gui_rep::~ns_gui_rep()
{
  [updatetimer release];
  [helper release];
}



/* important routines */
void
ns_gui_rep::get_extents (SI& width, SI& height) {
  NSRect bounds = [[NSScreen mainScreen] visibleFrame];
  
  width = ((SI) bounds.size.width)  * PIXEL;
  height= ((SI) bounds.size.height) * PIXEL;
}

void
ns_gui_rep::get_max_size (SI& width, SI& height) {
  width = 8000 * PIXEL;
  height= 6000 * PIXEL;
}

/******************************************************************************
 * interclient communication
 ******************************************************************************/

bool
ns_gui_rep::get_selection (string key, tree& t, string& s) {
  t= "none";
  s= "";
  if (selection_t->contains (key)) {
    t= copy (selection_t [key]);
    s= copy (selection_s [key]);
    return true;
  }
  if (key != "primary") return false;
  
	NSPasteboard *pb = [NSPasteboard generalPasteboard];
	NSArray *types = [NSArray arrayWithObject:NSStringPboardType];
	NSString *bestType = [pb availableTypeFromArray:types];

	if (bestType != nil) {
		NSString* data = [pb stringForType:bestType];
		if (data) {
		char *buf = (char*)[data UTF8String];
			unsigned size = strlen(buf);
		s << string(buf, size);
		}
	}

  t= tuple ("extern", s);
  return true;
}

bool
ns_gui_rep::set_selection (string key, tree t, string s) {
  selection_t (key)= copy (t);
  selection_s (key)= copy (s);
  if (key == "primary") {
    //if (is_nil (windows_l)) return false;
    //Window win= windows_l->item;
    if (selection!=NULL) tm_delete_array (selection);
    //XSetSelectionOwner (dpy, XA_PRIMARY, win, CurrentTime);
    //if (XGetSelectionOwner(dpy, XA_PRIMARY)==None) return false;
    selection= as_charp (s);
	
	NSPasteboard *pb = [NSPasteboard generalPasteboard];
	NSArray *types = [NSArray arrayWithObjects:
		NSStringPboardType, nil];
	[pb declareTypes:types owner:nil];
	[pb setString:[NSString stringWithCString: selection] forType: NSStringPboardType];
  }
  return true;
}

void
ns_gui_rep::clear_selection (string key) {
  selection_t->reset (key);
  selection_s->reset (key);
  if ((key == "primary") && (selection != NULL)) {
    tm_delete_array (selection);
	// FIXME: should we do something with the pasteboard?
    selection= NULL;
  }
}


/******************************************************************************
 * Miscellaneous
 ******************************************************************************/

void ns_gui_rep::set_mouse_pointer (string name) { (void) name; }
// FIXME: implement this function
void ns_gui_rep::set_mouse_pointer (string curs_name, string mask_name)  { (void) curs_name; (void) mask_name; } ;

/******************************************************************************
 * OLD Main loop
 ******************************************************************************/

/*
#if 0

static bool check_mask(int mask)
{
  NSEvent * event = [NSApp nextEventMatchingMask:mask
                             untilDate:nil
                                inMode:NSDefaultRunLoopMode 
                               dequeue:NO];
 // if (event != nil) NSLog(@"%@",event);
  return (event != nil);
  
}

#if 0
bool
ns_gui_rep::check_event (int type) {
  switch (type) {
    case INTERRUPT_EVENT:
      if (interrupted) return true;
      else  {
        time_t now= texmacs_time ();
        if (now - interrupt_time < 0) return false;
//        else interrupt_time= now + (100 / (XPending (dpy) + 1));
        else interrupt_time= now + 100;
        interrupted= check_mask(NSKeyDownMask |
                               // NSKeyUpMask |
                                NSLeftMouseDownMask |
                                NSLeftMouseUpMask |
                                NSRightMouseDownMask |
                                NSRightMouseUpMask );
        return interrupted;
      }
      case INTERRUPTED_EVENT:
        return interrupted;
      case ANY_EVENT:
        return check_mask(NSAnyEventMask);
      case MOTION_EVENT:
        return check_mask(NSMouseMovedMask);
      case DRAG_EVENT:
        return check_mask(NSLeftMouseDraggedMask|NSRightMouseDraggedMask);
      case MENU_EVENT:
        return check_mask(NSLeftMouseDownMask |
                          NSLeftMouseUpMask |
                          NSRightMouseDownMask |
                          NSRightMouseUpMask );
  }
  return interrupted;
}
#else
bool
ns_gui_rep::check_event (int type) {
  return false;
}
#endif

 
 
 
 
 void update()
 {
	//NSBeep();
	if (the_interpose_handler) the_interpose_handler();
 ns_update_flag = false;
 
 [[NSNotificationCenter defaultCenter] postNotificationName: @"TeXmacsUpdateWindows" object: nil];
 
 [NSTimer scheduledTimerWithTimeInterval: 10.0 target: the_gui->helper selector: @selector(update) userInfo: nil repeats: NO];
 }
 
 void ns_gui_rep::update ()
 {
 //  NSLog(@"UPDATE----------------------------");
 ::update();
 }
 
 void
 needs_update () {
 ns_update_flag = true;
 [NSTimer scheduledTimerWithTimeInterval: 0.0 target: the_gui->helper selector: @selector(update) userInfo: nil repeats: NO];
 }
 
 
 
 @interface TMInterposer : NSObject
 {
	NSNotification *n;
 }
 - (void)interposeNow;
 -(void)waitIdle;
 @end
 
 @implementation TMInterposer
 - init
 {
 if (self = [super init])
 {
	//	n = [[NSNotification notificationWithName:@"TMInterposeNotification" object:self] retain];
 // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(interposeNow) name:@"TMInterposeNotification" object:nil];
 [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(interposeNow) name:NSApplicationWillUpdateNotification object:nil];
	//	[self waitIdle];
 }
 return self;
 }
 - (void)dealloc
 {
	//[n release];
 [[NSNotificationCenter defaultCenter] removeObserver:self];
 [super dealloc];
 }
 
 - (void)interposeNow
 {
 //	NSBeep();
	update();
	//[self performSelector:@selector(waitIdle) withObject:nil afterDelay:0.25 inModes:[NSArray arrayWithObjects:NSDefaultRunLoopMode, nil]];
 }
 
 -(void)waitIdle
 {
	[[NSNotificationQueue defaultQueue] enqueueNotification:n
 postingStyle:NSPostWhenIdle
 coalesceMask:NSNotificationCoalescingOnName
 forModes:nil];
 }
 
 @end
 
 
 
 //@class FScriptMenuItem;
 
 void ns_gui_rep::event_loop ()
 #if 1
 {
 //	TMInterposer* i = [[TMInterposer alloc ] init];
	//[[NSApp mainMenu] addItem:[[[FScriptMenuItem alloc] init] autorelease]];
 //	update();
 
	[NSApp run];
 //	[i release];
 }
 #else
 {
 //	[[NSApp mainMenu] addItem:[[[FScriptMenuItem alloc] init] autorelease]];
	[NSApp finishLaunching];
	{
	NSEvent *event = nil;
 time_credit= 1000000;
 
 while (1) {
 timeout_time= texmacs_time () + time_credit;
 
 NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
 NSDate *dateSlow = [NSDate dateWithTimeIntervalSinceNow:0.5];
 event= [NSApp nextEventMatchingMask:NSAnyEventMask untilDate: dateSlow //[NSDate distantFuture]
 inMode:NSDefaultRunLoopMode dequeue:YES];
 while (event)
 {
 [NSApp sendEvent:event];
 //	update();
 //NSDate *dateFast = [NSDate dateWithTimeIntervalSinceNow:0.001];
 event= [NSApp nextEventMatchingMask:NSAnyEventMask untilDate:[NSDate distantPast] // dateFast
 inMode:NSDefaultRunLoopMode dequeue:YES];
 }
 interrupted = false;
 if (!event)  {
 update ();
 time_credit= min (1000000, 2 * time_credit);
 ns_update_flag= false;
 }
 [pool release];
 }
	}
 }
 #endif
 
 

#endif // OLD MAIN LOOP
*/

/******************************************************************************
 * Interpose handler interface
 ******************************************************************************/


void (*the_interpose_handler) (void) = NULL;
//void set_interpose_handler (void (*r) (void)) { the_interpose_handler= r; }
void gui_interpose (void (*r) (void)) { the_interpose_handler= r; }


/******************************************************************************
 * Queued processing
 ******************************************************************************/

/*!
 We process a maximum of max events. There are two kind of events: those
 which need a pass on interpose_handler just after and the others. We count
 only the first kind of events. In update() we call this function with
 max = 1 so that only one of these "sensible" events is handled. Otherwise
 updating the internal TeXmacs structure becomes very slow. This can be
 considered a limitation of the current implementation of interpose_handler
 Likewise this function is just a hack to get things working properly.
 */

void
ns_gui_rep::process_queued_events (int max) {
  int count = 0;
  while (max < 0 || count < max)  {
    const queued_event& ev = waiting_events.next();
    if (ev.x1 == qp_type::QP_NULL) break;
#ifdef ns_CPU_FIX
    if (ev.x1 != qp_type::QP_NULL &&
        ev.x1 != qp_type::QP_SOCKET_NOTIFICATION &&
        ev.x1 != qp_type::QP_DELAYED_COMMANDS)
      tm_wake_up ();
#endif
    switch (ev.x1) {
      case qp_type::QP_NULL :
        break;
      case qp_type::QP_KEYPRESS :
      {
        typedef triple<widget, string, time_t > T;
        T x = open_box <T> (ev.x2);
        if (!is_nil (x.x1))
          concrete_simple_widget (x.x1)->handle_keypress (x.x2, x.x3);
      }
        break;
      case qp_type::QP_KEYBOARD_FOCUS :
      {
        typedef triple<widget, bool, time_t > T;
        T x = open_box <T> (ev.x2);
        if (!is_nil (x.x1))
          concrete_simple_widget (x.x1)->handle_keyboard_focus (x.x2, x.x3);
      }
        break;
      case qp_type::QP_MOUSE :
      {
        typedef quintuple<string, SI, SI, int, time_t > T1;
        typedef pair<widget, T1> T;
        T x = open_box <T> (ev.x2);
        if (!is_nil (x.x1))
          concrete_simple_widget (x.x1)->handle_mouse (x.x2.x1, x.x2.x2,
                                                       x.x2.x3, x.x2.x4, x.x2.x5);
      }
        break;
      case qp_type::QP_RESIZE :
      {
        typedef triple<widget, SI, SI > T;
        T x = open_box <T> (ev.x2);
        if (!is_nil (x.x1))
          concrete_simple_widget (x.x1)->handle_notify_resize (x.x2, x.x3) ;
      }
        break;
      case qp_type::QP_COMMAND :
      {
        command cmd = open_box <command> (ev.x2) ;
        cmd->apply();
      }
        break;
      case qp_type::QP_COMMAND_ARGS :
      {
        typedef pair<command, object> T;
        T x = open_box <T> (ev.x2);
        x.x1->apply (x.x2);
      }
        break;
      case qp_type::QP_DELAYED_COMMANDS :
      {
        delayed_commands.exec_pending();
      }
        break;
        
      default:
        FAILED ("Unexpected queued event");
    }
    switch (ev.x1) {
      case qp_type::QP_COMMAND:
      case qp_type::QP_COMMAND_ARGS:
      case qp_type::QP_RESIZE:
      case qp_type::QP_DELAYED_COMMANDS:
        break;
      default:
        count++;
        break;
    }
  }
}

void
ns_gui_rep::process_keypress (ns_simple_widget_rep *wid, string key, time_t t) {
  typedef triple<widget, string, time_t > T;
  add_event (queued_event (qp_type::QP_KEYPRESS,
                           close_box<T> (T (wid, key, t))));
}

void
ns_gui_rep::process_keyboard_focus (ns_simple_widget_rep *wid, bool has_focus,
                                    time_t t ) {
  typedef triple<widget, bool, time_t > T;
  add_event (queued_event (qp_type::QP_KEYBOARD_FOCUS,
                           close_box<T> (T (wid, has_focus, t))));
}

void
ns_gui_rep::process_mouse (ns_simple_widget_rep *wid, string kind, SI x, SI y,
                           int mods, time_t t ) {
  typedef quintuple<string, SI, SI, int, time_t > T1;
  typedef pair<widget, T1> T;
  add_event (queued_event (qp_type::QP_MOUSE,
                           close_box<T> ( T (wid, T1 (kind, x, y, mods, t)))));
}

void
ns_gui_rep::process_resize (ns_simple_widget_rep *wid, SI x, SI y ) {
  typedef triple<widget, SI, SI > T;
  add_event (queued_event (qp_type::QP_RESIZE, close_box<T> (T (wid, x, y))));
}

void
ns_gui_rep::process_command (command _cmd) {
  add_event (queued_event (qp_type::QP_COMMAND, close_box<command> (_cmd)));
}

void
ns_gui_rep::process_command (command _cmd, object _args) {
  typedef pair<command, object > T;
  add_event (queued_event (qp_type::QP_COMMAND_ARGS,
                           close_box<T> (T (_cmd,_args))));
}

void
ns_gui_rep::process_delayed_commands () {
  add_event (queued_event (qp_type::QP_DELAYED_COMMANDS, blackbox()));
}

/*!
 FIXME: add more types and refine, compare with X11 version.
 */
bool
ns_gui_rep::check_event (int type) {
  // do not interrupt if not updating (e.g. while painting the icons in menus)
  if (!updating || !do_check_events) return false;
  
  switch (type) {
    case INTERRUPT_EVENT:
      if (interrupted) return true;
      else {
        time_t now = texmacs_time ();
        if (now - timeout_time < 0) return false;
        timeout_time = now + time_credit;
        interrupted  = !waiting_events.is_empty();
        return interrupted;
      }
    case INTERRUPTED_EVENT:
      return interrupted;
    default:
      return false;
  }
}

void
ns_gui_rep::set_check_events (bool enable_check) {
  do_check_events = enable_check;
}

void
ns_gui_rep::add_event (const queued_event& ev) {
  waiting_events.append (ev);
  if (updating) {
    needing_update = true;
  } else {
    need_update();
    // NOTE: we cannot update now since sometimes this seems to give problems
    // to the update of the window size after a resize. In that situation
    // sometimes when the window receives focus again, update will be called
    // for the focus_in event and interpose_handler is run which sends a
    // slot_extent message to the widget causing a wrong resize of the window.
    // This seems to cure the problem.
  }
}


/*!
 This is called by doUpdate(), which in turn is fired by a timer activated in
 needs_update(), and ensuring that interpose_handler() is run during a pass in
 the event loop after we reactivate the timer with a pause (see FIXME below).
 */

void
ns_gui_rep::update () {
#ifdef ns_CPU_FIX
  int std_delay= 1;
  tm_sleep ();
#else
  int std_delay= 1000 / 6;
#endif
  
  if (updating) {
    cout << "NESTED UPDATING: This should not happen" << LF;
    need_update();
    return;
  }
  
  if (!updatetimer) {
    NSRunLoop *runloop = [NSRunLoop currentRunLoop];
    updatetimer = [NSTimer timerWithTimeInterval:0.1 target: the_gui->helper selector:@selector(update) userInfo:nil repeats:YES];
    [runloop addTimer: updatetimer forMode: NSRunLoopCommonModes];
    [runloop addTimer: updatetimer forMode: NSEventTrackingRunLoopMode];
  }

  updating = true;
  
  static int count_events    = 0;
  static int max_proc_events = 10;
  
  time_t     now = texmacs_time();
  needing_update = false;
  time_credit    = 100 / (waiting_events.size() + 1);

#if 0
  // 1.
  // Check if a wait dialog is active and in that case remove it.
  // If we are here then the long operation has finished.
  
  if (waitDialogs.count()) {
    waitWindow->layout()->removeWidget (waitDialogs.last());
    waitWindow->close();
    while (waitDialogs.count()) {
      waitDialogs.last()->deleteLater();
      waitDialogs.removeLast();
    }
  }
  
  if (popup_wid_time > 0 && now > popup_wid_time) {
    popup_wid_time = 0;
    _popup_wid->send (SLOT_VISIBILITY, close_box<bool> (true));
  }

#endif

  // 2.
  // Manage delayed commands
  
  if (delayed_commands.must_wait (now))
    process_delayed_commands();

  // Debugging code
  // cout << "<" << texmacs_time() << " " << waiting_events.size() << " ";
  // if (waiting_events.size()>0) cout << "(" << waiting_events.q->item.x1 << ")";

  // 3.
  // If there are pending events in the private queue process them until the
  // limit in processed events is reached.
  // If there are no events or the limit is reached then proceed to a redraw.
  
  if (waiting_events.size() == 0) {
    // If there are no waiting events call the interpose handler at least once
    if (the_interpose_handler) the_interpose_handler();
  } else while (waiting_events.size() > 0 && count_events < max_proc_events) {
    process_queued_events (1);
    count_events++;
    if (the_interpose_handler) the_interpose_handler();
  }
  // Repaint invalid regions and redraw
  count_events = 0;
  
  interrupted  = false;
  timeout_time = texmacs_time() + time_credit;
  
  [[NSNotificationCenter defaultCenter] postNotificationName: @"TeXmacsUpdateWindows" object: nil];
  //  ns_simple_widget_rep::repaint_all ();
  
  if (waiting_events.size() > 0) needing_update = true;
  if (interrupted)               needing_update = true;
  if (nr_windows == 0)   {        //qApp->quit();
   // cout << "We must quit!\n";
  }
  
#if 1
  time_t delay = delayed_commands.lapse - texmacs_time();
  if (needing_update) delay = 0;
  else                delay = max (0, min (std_delay, delay));
#else
  time_t delay;
  if (needing_update) delay = 0;
  else                delay = std_delay;
#endif
  
  // cout << "{" << delay << "} ";
  [updatetimer setFireDate: [NSDate dateWithTimeIntervalSinceNow: delay/1000.0]];
  //updatetimer->start (delay);
  updating = false;
  
  // FIXME: we need to ensure that the interpose_handler is run at regular
  //        intervals (1/6th of sec) so that informations on the footbar are
  //        updated. (this should be better handled by promoting code in
  //        tm_editor::apply_changes (which is activated only after idle
  //        periods) at the level of delayed commands in the gui.
  //        The interval cannot be too small to keep CPU usage low in idle state
}

void
ns_gui_rep::force_update() {
  if (updating) needing_update = true;
  else          update();
}

void
ns_gui_rep::need_update () {
  if (updating) needing_update = true;
  else if (updatetimer)
    [updatetimer setFireDate: [NSDate dateWithTimeIntervalSinceNow: 0.0]];

  //updatetimer->start (0);
  // 0 ms - call immediately when all other events have been processed
}

void needs_update () {
  the_gui->need_update();
}


void ns_gui_rep::event_loop ()
{
  update ();
  [NSApp run];
}

/*! Called upon change of output language.
 
 We currently emit a signal which forces every QTMAction to change his text
 according to the new language, but the preferred Qt way seems to use
 LanguageChange events (these are triggered upon installation of QTranslators)
 */
void
ns_gui_rep::refresh_language() {
//  gui_helper->doRefresh();
}




void
ns_gui_rep::show_wait_indicator (widget w, string message, string arg) {
}


/***************************************************************************/
/***************************************************************************/
/***************************************************************************/



/* interface ******************************************************************/
#pragma mark GUI interface

//static display cur_display= NULL;

static NSAutoreleasePool *pool = nil;
//static NSApplication *app = nil;



/******************************************************************************
* Main routines
******************************************************************************/

void gui_open (int& argc2, char** argv2)
  // start the gui
{
  if (!NSApp) {
    // initialize app
    [NSApplication sharedApplication];
    [NSBundle loadNibNamed:@"MainMenu" owner:NSApp];
  }
  if (!pool) {
    // create autorelease pool 
    pool = [[NSAutoreleasePool alloc] init];
  } else [pool retain];
  
  the_gui = tm_new <ns_gui_rep> (argc2, argv2);
}

void gui_start_loop ()
  // start the main loop
{
  the_gui->event_loop ();
}

void gui_close ()
  // cleanly close the gui
{
  ASSERT (the_gui != NULL, "gui not yet open");
  [pool release];
  tm_delete (the_gui);
  the_gui=NULL;
}
void
gui_root_extents (SI& width, SI& height) {   
	// get the screen size
  the_gui->get_extents (width, height);
}

void
gui_maximal_extents (SI& width, SI& height) {
  // get the maximal size of a window (can be larger than the screen size)
  the_gui->get_max_size (width, height);
}

void gui_refresh ()
{
  // update and redraw all windows (e.g. on change of output language)
  // FIXME: add suitable code
}



/******************************************************************************
* Font support
******************************************************************************/

void
set_default_font (string name) {
	(void) name;
  // set the name of the default font
  // this is ignored since Qt handles fonts for the widgets
}

font
get_default_font (bool tt, bool mini, bool bold) {
  (void) tt; (void) mini;
  // get the default font or monospaced font (if tt is true)
	
  // return a null font since this function is not called in the Qt port.
  if (DEBUG_EVENTS) debug_events << "get_default_font(): SHOULD NOT BE CALLED\n";
  return NULL;
  //return tex_font (this, "ecrm", 10, 300, 0);
}

// load the metric and glyphs of a system font
// you are not obliged to provide any system fonts

void
load_system_font (string family, int size, int dpi,
                  font_metric& fnm, font_glyphs& fng)
{
	(void) family; (void) size; (void) dpi; (void) fnm; (void) fng;
	if (DEBUG_EVENTS) debug_events << "load_system_font(): SHOULD NOT BE CALLED\n";
}

/******************************************************************************
* Clipboard support
******************************************************************************/

  // Copy a selection 't' with string equivalent 's' to the clipboard 'cb'
  // Returns true on success
bool
set_selection (string key, tree t,
               string s, string sv, string sh, string format) {
  (void) format;
  return the_gui->set_selection (key, t, s);
}

  // Retrieve the selection 't' with string equivalent 's' from clipboard 'cb'
  // Returns true on success; sets t to (extern s) for external selections
bool
get_selection (string key, tree& t, string& s, string format) { 
  (void) format;
  return the_gui->get_selection (key, t, s);
}

  // Clear the selection on clipboard 'cb'
void
clear_selection (string key) {
  the_gui->clear_selection (key);
}


/******************************************************************************
* Miscellaneous
******************************************************************************/
int char_clip=0;

void 
beep () {
  // Issue a beep
  NSBeep();
}


bool check_event (int type)
  // Check whether an event of one of the above types has occurred;
  // we check for keyboard events while repainting windows
{ return the_gui->check_event(type); }

void
show_help_balloon (widget balloon, SI x, SI y) { 
  // Display a help balloon at position (x, y); the help balloon should
  // disappear as soon as the user presses a key or moves the mouse
  (void) balloon; (void) x; (void) y;
}

void
show_wait_indicator (widget base, string message, string argument) {
  // Display a wait indicator with a message and an optional argument
  // The indicator might for instance be displayed at the center of
  // the base widget which triggered the lengthy operation;
  // the indicator should be removed if the message is empty
  the_gui->show_wait_indicator(base,message,argument); 
}

void
external_event (string type, time_t t) {
  // External events, such as pushing a button of a remote infrared commander
#if 0
  QTMWidget *tm_focus = qobject_cast<QTMWidget*>(qApp->focusWidget());
  if (tm_focus) {
    simple_widget_rep *wid = tm_focus->tm_widget();
    if (wid) the_gui -> process_keypress (wid, type, t);
  }
#endif
}



/******************************************************************************
 * Delayed commands interface
 ******************************************************************************/

void exec_delayed (object cmd) {
  the_gui->delayed_commands.exec(cmd);
}
void exec_delayed_pause (object cmd) {
  the_gui->delayed_commands.exec_pause(cmd);
}
void clear_pending_commands () {
  the_gui->delayed_commands.clear_pending();
}



