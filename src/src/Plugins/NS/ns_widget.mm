
/******************************************************************************
* MODULE     : ns_widget.mm
* DESCRIPTION: Aqua widget class
* COPYRIGHT  : (C) 2007  Massimiliano Gubinelli
*******************************************************************************
* This software falls under the GNU general public license version 3 or later.
* It comes WITHOUT ANY WARRANTY WHATSOEVER. For details, see the file LICENSE
* in the root directory or <http://www.gnu.org/licenses/gpl-3.0.html>.
******************************************************************************/

#include "scheme.hpp"
#include "mac_cocoa.h" 

#include "ns_widget.h"
#include "ns_simple_widget.h"
#include "ns_other_widgets.h"
#include "ns_renderer.h"
#include "ns_utilities.h"

#include "gui.hpp"
#include "widget.hpp" 
#include "message.hpp"
#include "promise.hpp"
#include "analyze.hpp"

#include "ns_basic_widgets.h"

#import "TMView.h"
#import "TMButtonsController.h"

#define TYPE_CHECK(b) ASSERT (b, "type mismatch")
#define NOT_IMPLEMENTED \
  { if (DEBUG_EVENTS) debug_events << "STILL NOT IMPLEMENTED\n"; }

widget the_keyboard_focus(NULL);

@interface TMWindowController : NSWindowController
{
	ns_window_widget_rep *wid;
}
- (void) setWidget:(widget_rep*) w;
- (widget_rep*) widget;
@end


widget
ns_widget_rep::plain_window_widget (string s)
// creates a decorated window with name s and contents w
{
  NSRect screen_frame = [[NSScreen mainScreen] visibleFrame];
  
  NSWindow *nsw = [[[NSWindow alloc] initWithContentRect:NSMakeRect(0,0,100,100)
                                               styleMask:NSTitledWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask | NSResizableWindowMask
                                                 backing:NSBackingStoreBuffered
                                                   defer:NO] autorelease];
  // NSView *view = ((ns_view_widget_rep*)w.rep)->get_nsview();
  //	NSRect frame = [[nsw contentView] frame];
  //	[view setFrame:frame];
  [nsw setContentView: as_view ()];
  [nsw setTitle:to_nsstring(s)];
  [nsw setAcceptsMouseMovedEvents:YES];
  //	[[nsw contentView] addSubview:view];
  //	[nsw setToolbar:((ns_tm_widget_rep*)w.rep)->toolbar];
  widget wid =  tm_new <ns_window_widget_rep> (nsw);
  return wid; 
}

widget
ns_widget_rep::make_popup_widget () {
  return this;
}

widget 
ns_widget_rep::popup_window_widget (string s) {
  (void) s;
  return widget();
}



TMMenuItem *
ns_widget_rep::as_menuitem() { 
  return [[[TMMenuItem alloc] init] autorelease];
}

NSView*
ns_widget_rep::as_view () {
  return [[[NSView alloc] init] autorelease];
}

/******************************************************************************
* ns_view_widget_rep
******************************************************************************/

#pragma mark ns_view_widget_rep

ns_view_widget_rep::ns_view_widget_rep(NSView *v) : 
  ns_widget_rep(), view(v) { 
  [v retain]; 
}

ns_view_widget_rep::~ns_view_widget_rep()  {
  [view release]; 
}

NSView*
ns_view_widget_rep::as_view () {
  return view;
}

void
ns_view_widget_rep::send (slot s, blackbox val) {
  switch (s) {
    case SLOT_NAME:
    {
      check_type<string> (val, s);
      string name = open_box<string> (val);
      NSWindow *win = [view window];
      if (win) {
        [win setTitle:to_nsstring(name)];
      }
    }
      break;
    case SLOT_INVALIDATE:
    {
      TYPE_CHECK (type_box (val) == type_helper<coord4>::id);
      coord4 p= open_box<coord4> (val);
      NSRect rect = to_nsrect(p);
      [view setNeedsDisplayInRect: rect];
#if 0
      if (DEBUG_AQUA)
        debug_aqua << "Invalidating rect " << rectangle(p.x1,p.x2,p.x3,p.x4) << LF;
      ns_renderer_rep* ren = the_ns_renderer ();
      ren->set_origin(0,0);
      SI x1 = p.x1, y1 = p.x2, x2 = p.x3, y2 = p.x4;
      ren->outer_round (x1, y1, x2, y2);
      ren->decode (x1, y1);
      ren->decode (x2, y2);
      [view setNeedsDisplayInRect: NSMakeRect(x1, y2, x2-x1, y1-y2)];
#endif
    }
      break;
      
    case SLOT_INVALIDATE_ALL:
    {
      ASSERT (is_nil (val), "type mismatch");
      [view setNeedsDisplay:YES];
    }
      break;
      
    case SLOT_MOUSE_GRAB:
      NOT_IMPLEMENTED;
      //			send_mouse_grab (THIS, val);
      break;
      
    case SLOT_MOUSE_POINTER:
      NOT_IMPLEMENTED;
      //			send_mouse_pointer (THIS, val);
      break;
      
    case SLOT_KEYBOARD_FOCUS:
      //			send_keyboard_focus (THIS, val);
    {
      check_type<bool> (val, s);
      bool focus = open_box<bool> (val);
      if (focus) {
        the_keyboard_focus = this;
        //FIXME: implement SLOT_KEYBOARD_FOCUS
      }
    }
      break;
      
    case SLOT_KEYBOARD_FOCUS_ON:
    {
      string field = open_box<string>(val);
      //FIXME: implement SLOT_KEYBOARD_FOCUS_ON
    }
      break;
      
    case SLOT_MODIFIED:
    {
      check_type<bool> (val, s);
      bool flag = open_box<bool> (val);
      NSWindow *win = [view window];
      if (win) {
        [win setDocumentEdited:flag];
      }
    }
      break;
      
    case SLOT_SCROLL_POSITION:
    {
      //check_type<coord2>(val, s);
      coord2  p = open_box<coord2> (val);
      NSPoint qp = to_nspoint (p);
      //QSize  sz = canvas()->surface()->size();
      //qp -= QPoint (sz.width() / 2, sz.height() / 2);
      // NOTE: adjust because child is centered
      [view scrollPoint: qp];
    }
      break;
      
    default:
      if (DEBUG_AQUA_WIDGETS)
        debug_widgets << "slot type= " << slot_name (s) << "\n";
      FAILED ("cannot handle slot type");
  }
}

/******************************************************************************
* Querying
******************************************************************************/
blackbox
ns_view_widget_rep::query (slot s, int type_id) {
  switch (s) {
    case SLOT_IDENTIFIER:
      check_type_id<int> (type_id, s);
      return close_box<int> ([view window] ? 1 : 0);
      
    case SLOT_POSITION:
    {
      check_type_id<coord2> (type_id, s);
      NSPoint pos = [view frame].origin;
      return close_box<coord2> (from_nspoint(pos));
    }
      
    default:
      FAILED ("cannot handle slot type");
      return blackbox ();
  }
}
/******************************************************************************
 * Notification of state changes
 ******************************************************************************/

void
ns_view_widget_rep::notify (slot s, blackbox new_val) {
  ns_widget_rep::notify (s, new_val);
}

/******************************************************************************
 * Read and write access of subwidgets
 ******************************************************************************/

widget
ns_view_widget_rep::read (slot s, blackbox index) {
  switch (s) {
  case SLOT_WINDOW:
    check_type_void (index, s);
    return [(TMWindowController*)[[view window] windowController] widget];
  default:
    FAILED ("cannot handle slot type");
    return widget();
  }
}

void
ns_view_widget_rep::write (slot s, blackbox index, widget w) {
  switch (s) {
  default:
    FAILED ("cannot handle slot type");
  }
}

#pragma mark ns_tm_widget_rep

NSString *TMToolbarIdentifier = @"TMToolbarIdentifier";
NSString *TMButtonsIdentifier = @"TMButtonsIdentifier";

@interface TMToolbarItem : NSToolbarItem
@end
@implementation TMToolbarItem
- (void)validate
{
#if 1
  NSSize s = [[self view] frame].size;
  s = [[self view] fittingSize];
  NSSize s2 = [self minSize];
  if ((s.width != s2.width)||(s.height!=s2.height)) {
    [self setMinSize:s];
    [self setMaxSize:s];
  }
  //	NSLog(@"validate\n");
#endif
}
@end



@interface TMWidgetHelper : NSObject<NSToolbarDelegate>
{
@public
  ns_tm_widget_rep *wid;
  NSToolbarItem *ti;
}
- (void)notify:(NSNotification*)obj;
@end

@implementation TMWidgetHelper
-(void)dealloc
{
  [ti release]; [super dealloc];
}
- (void)notify:(NSNotification*)n
{
  wid->layout();
}
- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag
{
  if (itemIdentifier == TMButtonsIdentifier) {
    if (!ti) {
      ti = [[TMToolbarItem alloc] initWithItemIdentifier:TMButtonsIdentifier];
      [ti setView:[wid->bc bar]];
      NSRect f = [[wid->bc bar] frame];
      //	NSSize s = NSMakeSize(900,70);
      NSSize s = f.size;
      //[ti setMinSize:s];
      //[ti setMaxSize:s];
      
    }
    return ti;
  }
  return nil;
}
- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar
{
  return [NSArray arrayWithObjects:TMButtonsIdentifier,nil];
}
- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar
{
  return [NSArray arrayWithObjects:TMButtonsIdentifier,nil];
}
@end


ns_tm_widget_rep::ns_tm_widget_rep(int mask) : ns_view_widget_rep([[[NSView alloc] initWithFrame:NSMakeRect(0,0,100,100)] autorelease]), 
  sv(nil), leftField(nil), rightField(nil), bc(nil), toolbar(nil) 
{
  // decode mask
  visibility[0] = (mask & 1)  == 1;  // header
  visibility[1] = (mask & 2)  == 2;  // main
  visibility[2] = (mask & 4)  == 4;  // context
  visibility[3] = (mask & 8)  == 8;  // user
  visibility[4] = (mask & 16) == 16; // footer
  
  
  NSSize s = NSMakeSize(100,20); // size of the right footer;
  NSRect r = [view bounds];
  NSRect r0 = r;
  //	r.size.height -= 100;
  //	r0.origin.y =+ r.size.height; r0.size.height = 100;
  NSRect r1 = r; r1.origin.y += s.height; r1.size.height -= s.height;
  NSRect r2 = r; r2.size.height = s.height;
  NSRect r3 = r2; 
  r2.size.width -= s.width; r3.origin.x += r2.size.width;
  
  sv = [[[NSScrollView alloc] initWithFrame:r1] autorelease];
  [sv setHasVerticalScroller:YES];
  [sv setHasHorizontalScroller:YES];
  [sv setBorderType:NSNoBorder];
  //  [sv setBackgroundColor:[NSColor redColor]];
  [sv setBackgroundColor:[NSColor grayColor]];
  
  [sv setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
  id newClipView = [[[TMCenteringClipView alloc] initWithFrame:[[sv contentView] frame]] autorelease];
  [newClipView setBackgroundColor:[NSColor windowBackgroundColor]];
  [sv setContentView:(NSClipView *)newClipView];
  
  [sv setDocumentView:[[[NSView alloc] initWithFrame: NSMakeRect(0,0,100,100)] autorelease]];
  [view addSubview:sv];
  
  leftField = [[[NSTextField alloc] initWithFrame:r2] autorelease];
  rightField = [[[NSTextField alloc] initWithFrame:r3] autorelease];
  [leftField setAutoresizingMask:NSViewWidthSizable|NSViewMaxYMargin];
  [rightField setAutoresizingMask:NSViewMinXMargin|NSViewMaxYMargin];
  [leftField setEditable: NO];
  [rightField setEditable: NO];
  [leftField setBackgroundColor:[NSColor windowFrameColor]];
  [rightField setBackgroundColor:[NSColor windowFrameColor]];
  [leftField setBezeled:NO];
  [rightField setBezeled:NO];
  [rightField setAlignment:NSRightTextAlignment];
  [view addSubview:leftField];
  [view addSubview:rightField];
  
  bc = [[TMToolbarController alloc] init];
  //NSView *mt = [bc bar];
  //[mt setFrame:r0];
  //[mt setAutoresizingMask:NSViewMaxXMargin|NSViewMinYMargin];
  //[view addSubview:mt];
  //	[mt setPostsFrameChangedNotifications:YES];
  wh = [[TMWidgetHelper alloc] init];
  wh->wid = this;
#if 0
  [(NSNotificationCenter*)[NSNotificationCenter defaultCenter] addObserver:wh
			  selector:@selector(notify:)
			  name:NSViewFrameDidChangeNotification 
			  object:mt];
#endif
	
  toolbar = [[NSToolbar alloc] initWithIdentifier:TMToolbarIdentifier ];
  [toolbar setDelegate:wh];
  
  update_visibility ();
  
}

ns_tm_widget_rep::~ns_tm_widget_rep() 
{ 
  //	[(NSNotificationCenter*)[NSNotificationCenter defaultCenter] removeObserver:wh];
  [wh release];	
  [bc release]; 
}


void
ns_tm_widget_rep::layout()
{
  NSSize s = NSMakeSize(100,20); // size of the right footer;
  NSRect r = [view bounds];
  NSRect r0 = r;
  //	NSRect rh = [[bc bar] frame];
  NSRect rh = NSMakeRect(0,0,0,0);
  r.size.height -= rh.size.height;
  r0.origin.y += r.size.height; r0.size.height = rh.size.height;
  NSRect r1 = r; r1.origin.y += s.height; r1.size.height -= s.height;
  NSRect r2 = r; r2.size.height = s.height;
  NSRect r3 = r2; 
  r2.size.width -= s.width;
  r3.origin.x += r2.size.width;
//  r3.size.width -= r2.size.width + 15.0;
  r3.size.width -= r2.size.width;
  [sv setFrame:r1];
  [leftField setFrame:r2];
  [rightField setFrame:r3];
  //[[bc bar] setFrame:r0];
  [NSApp setWindowsNeedUpdate:YES];
}

void
ns_tm_widget_rep::update_visibility ()
{
  //FIXME: this implementation is from the Qt port. to be adapted.
#if 0
  mainToolBar->setVisible (visibility[1] && visibility[0]);
  contextToolBar->setVisible (visibility[2] && visibility[0]);
  userToolBar->setVisible (visibility[3] && visibility[0]);
  tm_mainwindow()->statusBar()->setVisible (visibility[4]);
#ifndef Q_WS_MAC
  tm_mainwindow()->menuBar()->setVisible (visibility[0]);
#endif
#endif
}

void
ns_tm_widget_rep::send (slot s, blackbox val) {
  switch (s) {
    case SLOT_INVALIDATE:
    case SLOT_INVALIDATE_ALL:
    case SLOT_EXTENTS:
    case SLOT_SCROLL_POSITION:
    case SLOT_ZOOM_FACTOR:
    case SLOT_MOUSE_GRAB:
    case SLOT_KEYBOARD_FOCUS:
    case SLOT_SCROLLBARS_VISIBILITY:
       main_widget->send(s, val);
        return;
      
    case SLOT_HEADER_VISIBILITY:
    {
      check_type<bool>(val, s);
      visibility[0] = open_box<bool> (val);
      update_visibility();
    }
      break;
    case SLOT_MAIN_ICONS_VISIBILITY:
    {
      check_type<bool>(val, s);
      visibility[1] = open_box<bool> (val);
      update_visibility();
    }
      break;
    case SLOT_MODE_ICONS_VISIBILITY:
    {
      check_type<bool>(val, s);
      visibility[2] = open_box<bool> (val);
      update_visibility();
    }
      break;
    case SLOT_FOCUS_ICONS_VISIBILITY:
    {
      check_type<bool>(val, s);
      visibility[3] = open_box<bool> (val);
      update_visibility();
    }
      break;
    case SLOT_USER_ICONS_VISIBILITY:
    {
      check_type<bool>(val, s);
      visibility[4] = open_box<bool> (val);
      update_visibility();
    }
      break;
      
    case SLOT_FOOTER_VISIBILITY:
    {
      check_type<bool>(val, s);
      visibility[5] = open_box<bool> (val);
      update_visibility();
    }
      break;

    case SLOT_SIDE_TOOLS_VISIBILITY:
    {
      check_type<bool>(val, s);
      visibility[6] = open_box<bool> (val);
      update_visibility();
    }
      break;

    case SLOT_BOTTOM_TOOLS_VISIBILITY:
    {
      check_type<bool>(val, s);
      visibility[7] = open_box<bool> (val);
      update_visibility();
    }
      break;

    case SLOT_LEFT_FOOTER:
    {
      TYPE_CHECK (type_box (val) == type_helper<string>::id);
      string msg = open_box<string> (val);
      [leftField setStringValue:to_nsstring_utf8 (tm_var_encode (msg))];
      [leftField displayIfNeeded];
    }
      break;
      
    case SLOT_RIGHT_FOOTER:
    {
      TYPE_CHECK (type_box (val) == type_helper<string>::id);
      string msg = open_box<string> (val);
      [rightField setStringValue:to_nsstring_utf8 (tm_var_encode (msg))];
      [rightField displayIfNeeded];
    }
      break;
      
    case SLOT_INTERACTIVE_MODE:
    {
      TYPE_CHECK (type_box (val) == type_helper<bool>::id);
      if (open_box<bool>(val) == true) {
        //FIXME: to postpone once we return to the runloop
        do_interactive_prompt();
      }
    }
      break;
      
    case SLOT_FILE:
    {
      TYPE_CHECK (type_box (val) == type_helper<string>::id);
      string file = open_box<string> (val);
      if (DEBUG_EVENTS) debug_events << "File: " << file << LF;
      //      view->window()->setWindowFilePath(to_qstring(file));
    }
      break;
    
    default:
      ns_view_widget_rep::send(s,val);
  }
}

blackbox
ns_tm_widget_rep::query (slot s, int type_id) {
  switch (s) {
      case SLOT_SCROLL_POSITION:
      case SLOT_EXTENTS:
      case SLOT_VISIBLE_PART:
      case SLOT_ZOOM_FACTOR:
          return main_widget->query(s, type_id);

    case SLOT_HEADER_VISIBILITY:
      check_type_id<bool> (type_id, s);
      return close_box<bool> (visibility[0]);
      
    case SLOT_MAIN_ICONS_VISIBILITY:
      check_type_id<bool> (type_id, s);
      return close_box<bool> (visibility[1]);
      
    case SLOT_MODE_ICONS_VISIBILITY:
      check_type_id<bool> (type_id, s);
      return close_box<bool> (visibility[2]);
      
    case SLOT_FOCUS_ICONS_VISIBILITY:
      check_type_id<bool> (type_id, s);
      return close_box<bool> (visibility[3]);
      
    case SLOT_USER_ICONS_VISIBILITY:
      check_type_id<bool> (type_id, s);
      return close_box<bool> (visibility[4]);
      
    case SLOT_FOOTER_VISIBILITY:
      check_type_id<bool> (type_id, s);
      return close_box<bool> (visibility[5]);
      
    case SLOT_SIDE_TOOLS_VISIBILITY:
      check_type_id<bool> (type_id, s);
      return close_box<bool> (visibility[6]);
      
    case SLOT_BOTTOM_TOOLS_VISIBILITY:
      check_type_id<bool> (type_id, s);
      return close_box<bool> (visibility[7]);
      
    
  case SLOT_INTERACTIVE_INPUT:
    {
      TYPE_CHECK (type_id == type_helper<string>::id);
      return close_box<string> ( ((ns_input_text_widget_rep*) int_input.rep)->text );
      
    }
  case SLOT_INTERACTIVE_MODE:
    {
      TYPE_CHECK (type_id == type_helper<bool>::id);
      return close_box<bool> (false);  // FIXME: who needs this info?
    }
    
    
  default:
    return ns_view_widget_rep::query(s,type_id);
  }
}

widget
ns_tm_widget_rep::read (slot s, blackbox index) {
  widget ret;
  switch (s) {
    case SLOT_CANVAS:
      check_type_void (index, s);
      ret = abstract (main_widget);
      break;
      
  default:
    return ns_view_widget_rep::read(s,index);
  }
  if (DEBUG_QT_WIDGETS)
    debug_widgets << "qt_tm_widget_rep::read " << slot_name (s) << LF;
  return ret;
}






@interface TMMenuHelper : NSObject
{
@public
  NSMenuItem *mi;
  NSMenu *menu;
}
+ (TMMenuHelper *)sharedHelper;
- init;
- (void)setMenu:(NSMenu *)_mi;
@end


@implementation TMMenuHelper
- init { 
  [super init]; mi = nil; menu = nil;
  //[NSApp  setMainMenu: [[[NSMenu alloc] init] autorelease]];
#if 0
  mi = [[NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:@"Menu" action:NULL keyEquivalent:@""];
  NSMenu *sm = [[[NSMenu allocWithZone:[NSMenu menuZone]] initWithTitle:@"Menu"] autorelease];
  [mi  setSubmenu:sm];
  //[[NSApp mainMenu] removeItem: [[NSApp mainMenu] itemWithTitle:@"Help"]]; //FIXME: Help menu causes problems (crash)
  
  [[NSApp mainMenu] insertItem: mi atIndex:1];	
  //	[sm setDelegate: self];
#endif
  return self;
}

- (void) setMenu: (NSMenu *)_m
{
  [menu release];  menu = _m; [menu retain];
  [menu setTitle:@"Main TeXmacs menu"];
  NSMenu* menubar = [NSApp mainMenu];
  for (int i = [menubar numberOfItems]-1; i > 0 ; i--)
    [menubar removeItemAtIndex: i];
  for (NSMenuItem* eachItem in [menu itemArray]) {
    NSMenu* submenu = [eachItem submenu];
    [submenu setTitle: [eachItem title]];
    [menu removeItem: eachItem];
    [menubar addItem: eachItem];
  }
  [menubar update];
};

- (void) dealloc {
  [mi release]; [menu release]; [super dealloc];
}

+ (TMMenuHelper *)sharedHelper
{
  static TMMenuHelper *the_menu_helper = nil;

  if (!the_menu_helper) 
    {
      the_menu_helper = [[TMMenuHelper alloc] init];
    }
  return the_menu_helper; 
}

#if 0
- (BOOL)menu:(NSMenu *)menu updateItem:(NSMenuItem *)item atIndex:(int)index shouldCancel:(BOOL)shouldCancel
{
  return NO;
}
#endif
@end

void
ns_tm_widget_rep::write (slot s, blackbox index, widget w) {
  switch (s) {
      
  case SLOT_SCROLLABLE: 
    {
      check_type_void (index, s);
      main_widget = concrete(w);
      NSView *v = main_widget->as_view();
      [sv setDocumentView: v];
      [[sv window] makeFirstResponder:v];
    }
    break;
      
  case SLOT_MAIN_MENU:
    check_type_void (index, s);
    [[TMMenuHelper sharedHelper] setMenu:to_nsmenu(w)];
    break;
      
  case SLOT_MAIN_ICONS:
    check_type_void (index, s);
//    [bc setMenu:to_nsmenu(w) forRow:0];
      [bc setView: concrete(w)->as_view() forRow:0];
    layout();
    break;
      
  case SLOT_MODE_ICONS:
    check_type_void (index, s);
//    [bc setMenu:to_nsmenu(w) forRow:1];
      [bc setView: concrete(w)->as_view() forRow:1];

    layout();
    break;
      
  case SLOT_FOCUS_ICONS:
    check_type_void (index, s);
//    [bc setMenu:to_nsmenu(w) forRow:2];
      [bc setView: concrete(w)->as_view() forRow:2];

    layout();
    break;
      
  case SLOT_USER_ICONS:
    check_type_void (index, s);
//    [bc setMenu:to_nsmenu(w) forRow:3];
      [bc setView: concrete(w)->as_view() forRow:3];
    layout();
    break;
      
  case SLOT_BOTTOM_TOOLS:
    check_type_void (index, s);
    //FIXME: implement this
    break;
      
  case SLOT_INTERACTIVE_PROMPT:
    check_type_void (index, s);
    int_prompt = concrete(w);
    //			THIS << set_widget ("interactive prompt", concrete (w));
    break;
      
  case SLOT_INTERACTIVE_INPUT:
    check_type_void (index, s);
    int_input = concrete(w);
    //			THIS << set_widget ("interactive input", concrete (w));
    break;
      
  default:
    ns_view_widget_rep::write(s,index,w);
  }
}

widget
ns_tm_widget_rep::plain_window_widget (string s) {
  // creates a decorated window with name s and contents w
  widget w = ns_view_widget_rep::plain_window_widget(s);
  // to manage correctly retain counts
  ns_window_widget_rep * wid = (ns_window_widget_rep *)(w.rep);
  [[wid->get_windowcontroller() window] setToolbar:toolbar];
  return wid;
}

#pragma mark ns_window_widget_rep

@implementation TMWindowController

- (void) setWidget: (widget_rep*) w
{
  wid = (ns_window_widget_rep*)w;
}

- (widget_rep*) widget
{
  return (ns_widget_rep*)wid;
}

@end

ns_window_widget_rep::ns_window_widget_rep(NSWindow *win) 
: widget_rep(), wc([[[TMWindowController alloc] initWithWindow:win] autorelease]) 
{ [wc retain]; [wc setWidget:this]; }

ns_window_widget_rep::~ns_window_widget_rep()  { [wc release]; }

TMWindowController *ns_window_widget_rep::get_windowcontroller() { return wc; }

void
ns_window_widget_rep::send (slot s, blackbox val) {
  switch (s) {
      
    case SLOT_SIZE:
    {
      TYPE_CHECK (type_box (val) == type_helper<coord2>::id);
      coord2 p= open_box<coord2> (val);
      NSWindow *win = [wc window];
      if (win) {
        NSSize size = to_nssize(p);
        [win setContentSize:size];
      }
    }
      break;
      
    case SLOT_POSITION:
    {
      TYPE_CHECK (type_box (val) == type_helper<coord2>::id);
      coord2 p= open_box<coord2> (val);
      NSWindow *win = [wc window];
      if (win) {
        [win setFrameOrigin:to_nspoint(p)];
      }
    }
      break;
      
    case SLOT_VISIBILITY:
    {
      check_type<bool> (val, s);
      bool flag = open_box<bool> (val);
      NSWindow *win = [wc window];
      if (win) {
        if (flag) [win makeKeyAndOrderFront:nil] ;
        else [win orderOut:nil]  ;
      }
    }
      break;
      
    case SLOT_MOUSE_GRAB:
    {
      //check_type<bool> (val, s);
      bool flag = open_box<bool> (val);  // true= get grab, false= release grab
      NSWindow *win = [wc window];
      if (flag && win) [win makeKeyAndOrderFront:nil];
#if 0
      if (flag && qwid) {
        qwid->setWindowFlags (Qt::Window);  // ok?
        qwid->setWindowModality (Qt::WindowModal); //ok?
        qwid->show();
      }
#endif
    }
      break;
      
    case SLOT_NAME:
    {
      check_type<string> (val, s);
      string name = open_box<string> (val);
      NSWindow *win = [wc window];
      if (win) {
        NSString *title = to_nsstring(name);
        [win setTitle:title];
      }
    }
      break;
      
    case SLOT_MODIFIED:
    {
      check_type<bool> (val, s);
      bool flag = open_box<bool> (val);
      NSWindow *win = [wc window];
      if (win) [win setDocumentEdited:flag];
    }
      break;
    case SLOT_REFRESH:
      NOT_IMPLEMENTED ;
      // send_refresh (THIS, val);
      break;
      
    default:
      FAILED ("cannot handle slot type");
  }
}


blackbox
ns_window_widget_rep::query (slot s, int type_id) {
  switch (s) {
      
    case SLOT_IDENTIFIER:
      TYPE_CHECK (type_id == type_helper<int>::id);
      return close_box<int> ((intptr_t) [wc window] ? 1 : 0);
      
    case SLOT_POSITION:
    {
      typedef pair<SI,SI> coord2;
      TYPE_CHECK (type_id == type_helper<coord2>::id);
      NSRect frame = [[wc window] frame];
      return close_box<coord2> (from_nspoint(frame.origin));
    }
      
    case SLOT_SIZE:
    {
      typedef pair<SI,SI> coord2;
      TYPE_CHECK (type_id == type_helper<coord2>::id);
      NSRect frame = [[wc window] frame];
      return close_box<coord2> (from_nssize(frame.size));
    }
      
    default:
      FAILED ("cannot handle slot type");
      return blackbox ();
  }
}

/******************************************************************************
 * Notification of state changes
 ******************************************************************************/

void
ns_window_widget_rep::notify (slot s, blackbox new_val) {
  widget_rep::notify (s, new_val);
}

widget
ns_window_widget_rep::read (slot s, blackbox index) {
  switch (s) {
      
  default:
    FAILED ("cannot handle slot type");
    return widget();
      
  }
}

void
ns_window_widget_rep::write (slot s, blackbox index, widget w) {
  switch (s) {
      
  default:
    FAILED ("cannot handle slot type");
      
  }
}


/******************************************************************************
* ns_simple_widget_rep
******************************************************************************/
#pragma mark ns_simple_widget_rep

ns_simple_widget_rep::ns_simple_widget_rep (simple_widget_rep *w)
: ns_view_widget_rep ([[[TMView alloc] initWithFrame:NSMakeRect(0,0,1000,1000)] autorelease]) 
{
  setCounterpart(w);
  [(TMView*)view setWidget:this];
}

void
ns_simple_widget_rep::send (slot s, blackbox val) {
  if (DEBUG_AQUA) debug_aqua << "ns_ns_simple_widget_rep::send " << slot_name(s) << LF;
  switch (s) {
      
    case SLOT_CURSOR:
    {
      TYPE_CHECK (type_box (val) == type_helper<coord2>::id);
      coord2 p= open_box<coord2> (val);
      NSPoint pt = to_nspoint(p);
      
      //FIXME: implement this!!!
      //      debug_aqua << "ns_simple_widget_rep::send SLOT_POSITION - TO BE IMPLEMENTED (" << pt.x << "," << pt.y << ")\n";
      // [view scrollPoint:to_nspoint(p)];
      
      //QPoint pt = to_qpoint(p);
      //tm_canvas() -> setCursorPos(pt);
    }
      break;
      
    case SLOT_SCROLL_POSITION:
    {
      TYPE_CHECK (type_box (val) == type_helper<coord2>::id);
      coord2 p= open_box<coord2> (val);
      NSPoint pt = to_nspoint(p);
      NSSize sz = [view bounds].size;
      sz = [[view enclosingScrollView] documentVisibleRect].size;
      if (DEBUG_EVENTS)
        debug_events << "Scroll position :" << pt.x << "," << pt.y << LF;
      pt.y -= sz.height/2;
      pt.x -= sz.width/2;
      [view scrollPoint:pt];
    }
      break;
      
    case SLOT_EXTENTS:
    {
      TYPE_CHECK (type_box (val) == type_helper<coord4>::id);
      coord4 p= open_box<coord4> (val);
      NSRect rect = to_nsrect(p);
      //          NSSize ws = [sv contentSize];
      NSSize sz = rect.size;
      //         sz.height = max (sz.height, ws.height );
      //			[[view window] setContentSize:rect.size];
      [view setFrameSize: sz];
    }
      break;
      
    case SLOT_ZOOM_FACTOR:
    {
      TYPE_CHECK (type_box (val) == type_helper<double>::id);
      double new_zoom = open_box<double> (val);
      if (DEBUG_EVENTS) debug_events << "New zoom factor :" << new_zoom << LF;
      counterpart()->handle_set_zoom_factor (new_zoom);
      break;
    }
      
    case SLOT_SCROLLBARS_VISIBILITY:
    {
      check_type<int>(val, s);
      int flag= open_box<int> (val);
      if (DEBUG_QT)
        debug_qt << "scrollbars visibility :" << flag << LF;
      //FIXME: scrollbars
//      canvas()->setHorizontalScrollBarPolicy(flag ? Qt::ScrollBarAsNeeded : Qt::ScrollBarAlwaysOff);
//      canvas()->setVerticalScrollBarPolicy(flag ? Qt::ScrollBarAsNeeded : Qt::ScrollBarAlwaysOff);
    }
      break;
      
    default:
      if (DEBUG_AQUA) debug_aqua << "[ns_ns_simple_widget_rep] ";
      ns_view_widget_rep::send (s, val);
      //      FAILED ("unhandled slot type");
  }
}

blackbox
ns_simple_widget_rep::query (slot s, int type_id) {
  switch (s) {
      
    case SLOT_INVALID:
    {
      return close_box<bool> (view ? [view needsDisplay] : false);
    }
      
    case SLOT_SIZE:
    {
      typedef pair<SI,SI> coord2;
      TYPE_CHECK (type_id == type_helper<coord2>::id);
      NSRect frame = [view  frame];
      return close_box<coord2> (from_nssize(frame.size));
    }
      
    case SLOT_SCROLL_POSITION:
    {
      TYPE_CHECK (type_id == type_helper<coord2>::id);
      NSPoint pt = [view frame].origin;
      if (DEBUG_EVENTS)
        debug_events << "Position (" << pt.x << "," << pt.y << ")\n";
      return close_box<coord2> (from_nspoint(pt));
    }
      
    case SLOT_EXTENTS:
    {
      TYPE_CHECK (type_id == type_helper<coord4>::id);
      NSRect rect= [view frame];
      coord4 c= from_nsrect (rect);
      if (DEBUG_EVENTS) debug_events << "Canvas geometry (" << rect.origin.x
        << "," << rect.origin.y
        << "," << rect.size.width
        << "," << rect.size.height
        << ")" << LF;
      return close_box<coord4> (c);
    }
      
    case SLOT_VISIBLE_PART:
    {
      TYPE_CHECK (type_id == type_helper<coord4>::id);
      NSRect rect= [view visibleRect];
      NSPoint pt = [view frame].origin;
      rect = NSOffsetRect(rect, pt.x, pt.y);
      coord4 c= from_nsrect (rect);
      if (DEBUG_EVENTS) debug_events << "Visible region (" << rect.origin.x
        << "," << rect.origin.y
        << "," << rect.size.width
        << "," << rect.size.height
        << ")" << LF;
      return close_box<coord4> (c);
    }
      
    default:
      return ns_view_widget_rep::query(s, type_id);
  }
  
  return ns_view_widget_rep::query(s,type_id);
}

void
ns_simple_widget_rep::notify (slot s, blackbox new_val) {
  ns_view_widget_rep::notify (s, new_val);
}

widget
ns_simple_widget_rep::read (slot s, blackbox index) {
  return ns_view_widget_rep::read(s,index);
}

void
ns_simple_widget_rep::write (slot s, blackbox index, widget w) {
  ns_view_widget_rep::write(s,index,w);
}

// forwarding

void
ns_simple_widget_rep::handle_get_size_hint (SI& w, SI& h) {
  counterpart()->handle_get_size_hint(w, h);
}

void
ns_simple_widget_rep::handle_notify_resize (SI w, SI h) {
  counterpart()->handle_notify_resize(w, h);
}

void
ns_simple_widget_rep::handle_keypress (string key, time_t t) {
  counterpart()->handle_keypress(key, t);
}

void
ns_simple_widget_rep::handle_keyboard_focus (bool has_focus, time_t t) {
  counterpart()->handle_keyboard_focus(has_focus, t);
}

void
ns_simple_widget_rep::handle_mouse (string kind, SI x, SI y, int mods, time_t t) {
  counterpart()->handle_mouse(kind, x, y, mods, t);
}

void
ns_simple_widget_rep::handle_set_zoom_factor (double zoom) {
  counterpart()->handle_set_zoom_factor(zoom);
}

void
ns_simple_widget_rep::handle_clear (renderer ren, SI x1, SI y1, SI x2, SI y2) {
  counterpart()->handle_clear(ren, x1, y1, x2, y2);
}

void
ns_simple_widget_rep::handle_repaint (renderer ren, SI x1, SI y1, SI x2, SI y2) {
  counterpart()->handle_repaint(ren, x1, y1, x2, y2);
}


/******************************************************************************
* Window widgets
******************************************************************************/

#pragma mark Widget interface


widget plain_window_widget (widget w, string s, command c)
// creates a decorated window with name s and contents w
{
  return concrete(w)->plain_window_widget(s);
}

widget popup_window_widget (widget w, string s) 
// creates an undecorated window with name s and contents w
{
  return concrete(w)->popup_window_widget(s);
}

void   destroy_window_widget (widget w) {  
// destroys a window as created by the above routines
  (void) w;
}

/******************************************************************************
 * Top-level widgets, typically given as an argument to plain_window_widget
 * See also message.hpp for specific messages for these widgets
 ******************************************************************************/

widget texmacs_widget (int mask, command quit) 
// the main TeXmacs widget and a command which is called on exit
// the mask variable indicates whether the menu, icon bars, status bar, etc.
// are visible or not
{
  (void) mask; (void) quit; // FIXME: handle correctly mask and quit

  widget w = tm_new <ns_tm_widget_rep> (mask);
  return w; 
}





widget popup_widget (widget w) 
// a widget container which results w to be unmapped as soon as
// the pointer quits the widget
// used in edit_mouse.cpp to implement a contextual menu in the canvas
{
  return concrete(w)->make_popup_widget();
}


