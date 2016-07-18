//
//  ns_ui_element.m
//  TeXmacs
//
//  Created by Massimiliano Gubinelli on 15/07/16.
//  Copyright © 2016 TeXmacs.org. All rights reserved.
//


#define NEW_MENUS

#include "mac_cocoa.h"

#include "ns_ui_element.h"
#include "ns_utilities.h"
#include "ns_renderer.h"
#include "ns_picture.h"

#include "ns_simple_widget.h"
#include "ns_basic_widgets.h"
#include "ns_gui.h"

#include "widget.hpp"
#include "message.hpp"
#include "analyze.hpp"

#include "promise.hpp"
#include "scheme.hpp"
#include <typeinfo>

//#import "TMView.h"

NSMenu* to_nsmenu(widget w);
NSMenuItem* to_nsmenuitem(widget w);


@interface TMCommand : NSObject
{
  command_rep *cmd;
  NSView *object; // not retained
}
- (void) setCommand: (command_rep *)_c;
- (void) setObject: (NSView*)_v;
- (void) doit;
@end



@implementation TMCommand

- (void) setCommand:(command_rep *)_c
{
  if (cmd) { DEC_COUNT_NULL(cmd); } cmd = _c;
  if (cmd) { INC_COUNT_NULL(cmd); }
}

- (void) setObject: (NSView*)_v
{
  object = _v;
}

- (void) dealloc {
  [self setCommand: NULL]; [self setObject: nil];
  [super dealloc];
}

- (void) doit {
  if (cmd) {
    cmd->apply();
    cout << command(cmd) << LF;
  }
  id m = [object enclosingMenuItem];
  id mm = [m menu];
  [mm cancelTracking];
}

@end // TMCommand

@interface TMMenuItem : NSMenuItem
{
  command_rep *cmd;
  ns_simple_widget_rep* wid;// an eventual box widget (see tm_button.cpp)
}
- (void) setCommand: (command_rep *)_c;
- (void) setWidget: (ns_simple_widget_rep *)_w;
- (void) doit;
@end

@interface TMLazyMenu : NSMenu <NSMenuDelegate>
{
  promise_rep<widget> *pm;
  BOOL forced;
}
- (void) setPromise: (promise_rep<widget> *)p;
@end


NSMenu *alloc_menu() { return [NSMenu alloc]; }
NSMenuItem *alloc_menuitem() { return [NSMenuItem alloc]; }

class ns_menu_rep : public ns_widget_rep  {
public:
  NSMenuItem *item;
  ns_menu_rep(NSMenuItem* _item) : item(_item) { [item retain]; }
  ~ns_menu_rep()  { [item release]; }
  
  virtual void send (slot s, blackbox val);
  virtual widget make_popup_widget ();
  virtual widget popup_window_widget (string s);
  
  virtual TMMenuItem *as_menuitem() { return (TMMenuItem *)item; }
  
};

widget ns_menu_rep::make_popup_widget ()
{
  return this;
}

widget ns_menu_rep::popup_window_widget (string s)
{
  [item setTitle: to_nsstring(s)];
  return this;
}


void ns_menu_rep::send (slot s, blackbox val) {
  switch (s) {
      
    case SLOT_POSITION:
    {
      ASSERT (type_box (val) == type_helper<coord2>::id, "type mismatch");
    }
      break;
      
    case SLOT_VISIBILITY:
    {
      check_type<bool> (val, s);
      bool flag = open_box<bool> (val);
      (void) flag;
    }
      break;
      
    case SLOT_MOUSE_GRAB:
    {
      check_type<bool> (val, s);
      bool flag = open_box<bool> (val);
      (void) flag;
      [NSMenu popUpContextMenu: [item submenu] withEvent: [NSApp currentEvent]
                       forView: ((ns_view_widget_rep*)(the_keyboard_focus.rep))->view ];
    }
      //			send_mouse_grab (THIS, val);
      break;
      
    default:
      FAILED ("cannot handle slot type");
  }
}

#if 0
class ns_menu_text_rep : public ns_basic_widget_rep {
public:
  NSString *text;
  ns_menu_text_rep(NSString* _text) : text(_text) { [text retain]; }
  ~ns_menu_text_rep()  { [text release]; }
};

#endif


@implementation TMMenuItem

- (void) setCommand: (command_rep *)_c
{
  if (cmd) { DEC_COUNT_NULL(cmd); } cmd = _c;
  if (cmd) {
    INC_COUNT_NULL(cmd);
    [self setAction: @selector(doit)];
    [self setTarget: self];
  }
}

- (void) setWidget: (ns_simple_widget_rep *)_w
{
  if (wid) { DEC_COUNT_NULL(wid); } wid = _w;
  if (wid) {
    INC_COUNT_NULL(wid);
  }
}

- (void) dealloc {
  [self setCommand:NULL];  [self setWidget:NULL];  [super dealloc];
}

- (void) doit {
  if (cmd) cmd->apply();
  [[self menu] cancelTracking];
}

- (NSImage*) image
{
  NSImage *img = [super image];
  if ((!img) && (wid))
  {
    SI width, height;
    wid->handle_get_size_hint (width,height);
    NSSize s = NSMakeSize (width/PIXEL,height/PIXEL);
    
    img = [[[NSImage alloc] initWithSize: s] autorelease];
    [img lockFocusFlipped:YES];
    
    basic_renderer r = the_ns_renderer();
    int x1 = 0;
    int y1 = s.height;
    int x2 = s.width;
    int y2 = 0;
    
    r -> begin([NSGraphicsContext currentContext]);
    
    r -> encode (x1,y1);
    r -> encode (x2,y2);
    r -> set_clipping (x1,y1,x2,y2);
    wid-> handle_repaint (r,x1,y1,x2,y2);
    r->end();
    [img unlockFocus];
    //[img setFlipped:YES];
    [super setImage:img];
    [self setWidget:NULL];
  }
  return img;
}

@end // TMMenuItem


@implementation TMLazyMenu

- (void) setPromise:(promise_rep<widget> *)p
{
  if (pm) { DEC_COUNT_NULL(pm); }
  pm = p;
  if (pm) {
    forced = NO;
    INC_COUNT_NULL(pm);
    [self setDelegate: self];
  } else {
    [self setDelegate: nil];
  }
}

- (void) dealloc {
  if (pm) { DEC_COUNT_NULL(pm); pm = NULL; }
  [super dealloc];
}

- (void) menuNeedsUpdate:(NSMenu *)menu
{
  if (!forced) {
    widget w = pm->eval();
    NSMenu *menu2 = to_nsmenu(w);
    unsigned count = [menu2 numberOfItems];
    for (unsigned j=0; j<count; j++)
    {
      NSMenuItem *itm = [[[menu2 itemAtIndex:0] retain] autorelease];
      [menu2 removeItem:itm];
      [menu insertItem:itm atIndex:j];
    }
    [self setPromise: NULL];
    forced = YES;
  }
}

- (BOOL)menuHasKeyEquivalent:(NSMenu *)menu forEvent:(NSEvent *)event target:(id *)target action:(SEL *)action
{
  return NO;
  // disable keyboard handling for lazy menus
}

@end // TMLazyMenu

@interface TMTileView : NSMatrix
{
  int cols;
}
- (id) initWithObjects:(NSArray*)objs cols:(int)_cols;
- (void) click:(TMTileView*)tile;
@end


@implementation TMTileView

- (void) dealloc
{
  [super dealloc];
}

- (id) initWithObjects:(NSArray*)objs cols:(int)_cols
{
  self = [super init];
  if (self != nil) {
    int current_col;
    int current_row;
    cols = _cols;
    current_col = cols;
    current_row = -1;
    [self setCellSize:NSMakeSize(20,20)];
    [self renewRows:0 columns:cols];
    NSEnumerator *en = [objs objectEnumerator];
    NSMenuItem *mi;
    while ((mi = [en nextObject])) {
      if (current_col == cols) {
        current_col=0; current_row++;
        [self addRow];
      }
      NSImageCell *cell = [[[NSImageCell alloc] initImageCell:[mi image]] autorelease];
      //		[cell setImage:[mi image]];
      [cell setRepresentedObject:mi];
      [self putCell:cell atRow:current_row column:current_col];
      current_col++;
    }
    
    [self setTarget:self];
    [self setAction:@selector(click:)];
    [self sizeToCells];
  }
  return self;
}

- (void) click:(TMTileView*)tile
{
  // on mouse up, we want to dismiss the menu being tracked
  NSMenuItem* mi = [self enclosingMenuItem];
  //[[mi menu] performSelector:@selector(cancelTracking) withObject:nil afterDelay:0.0];
  [[mi menu] cancelTracking];
  TMMenuItem* item =  [(NSCell*)[self selectedCell]  representedObject];
  //	[item performSelector:@selector(doit) withObject:nil afterDelay:0.0];
  [item doit];
}

#if 0
- (void)mouseDown:(NSEvent*)event
{
  [super mouseDown:event];
  // on mouse up, we want to dismiss the menu being tracked
  NSMenu* menu = [[self enclosingMenuItem] menu];
  [menu cancelTracking];
  
}
#endif
@end // TMTileView


TMMenuItem * ns_text_widget_rep::as_menuitem()
{
  return [[[TMMenuItem alloc] initWithTitle:to_nsstring_utf8(str)
                                     action:NULL keyEquivalent:@""] autorelease];
}

TMMenuItem * ns_image_widget_rep::as_menuitem()
{
  NSImage *img = xpm_image (image);
  //	TMMenuItem *mi = [[[TMMenuItem alloc] initWithTitle:to_nsstring(as_string(file_name)) action:NULL keyEquivalent:@""] autorelease];
  TMMenuItem *mi = [[[TMMenuItem alloc] initWithTitle:@"" action:NULL
                                        keyEquivalent:@""] autorelease];
  [mi setRepresentedObject:img];
  [mi setImage:img];
  
  return  mi;
}

TMMenuItem * ns_balloon_widget_rep::as_menuitem()
{
  TMMenuItem *mi = concrete (text)->as_menuitem ();
  ns_text_widget_rep* h = dynamic_cast<ns_text_widget_rep*>(hint.rep);
  if (h)
    [mi setToolTip: to_nsstring(h->str)];
  return mi;
}

@implementation NSView (DEBUG_AmbiguityTests)

// Debug only. Do not ship with this code
- (void) testAmbiguity
{
  NSLog(@"<%@:0x%0x>: %@",
        self.class.description, (int)self,
        self.hasAmbiguousLayout ? @"Ambiguous" : @"Unambiguous");
  
  for (NSView *view in self.subviews)
    [view testAmbiguity];
}

// Return all constraints from self and subviews
- (NSArray *) allConstraints
{
  NSMutableArray *array = [NSMutableArray array];
  [array addObjectsFromArray:self.constraints];
  for (NSView *view in self.subviews)
    [array addObjectsFromArray: [view allConstraints]];
  return array;
}
@end


/******************************************************************************
 * utilities
 ******************************************************************************/
#if 0
void
qt_apply_tm_style (QWidget* qwid, int style, color c) {
  int r,g,b,a;
  get_rgb_color (c, r, g, b, a);
  a = a*100/255;
  QString sheet = "* {" + parse_tm_style (style)
  + QString("color: rgba(%1, %2, %3, %4%);").arg(r).arg(g).arg(b).arg(a)
  + "} ";
  
#ifdef Q_WS_MAC
  /* Disabled QLabels are not greyed out (at least in MacOS, since Qt 4.7.2),
   see: https://bugreports.qt-project.org/browse/QTBUG-19008
   For consistency we set the disabled color for all widgets.
   */
  sheet += " :disabled { color: #7F7F7F; }";
#endif
  qwid->setEnabled (! (style & WIDGET_STYLE_INERT));
  qwid->setStyleSheet (sheet);
}

#endif


NSAttributedString*
add_style (NSString *str, int style) {
  
  NSDictionary* dict = [[[NSDictionary alloc] init] autorelease];
   //	NSAttributedString *str = [mi attributedTitle];
  NSMutableParagraphStyle *pstyle = nil;
  //	NSMutableParagraphStyle *style = [(NSParagraphStyle*)[str attribute:NSParagraphStyleAttributeName atIndex:0 effectiveRange:NULL] mutableCopy];
  NSFont* font = nil;
  NSColor* color = nil;
//  int fs = [NSFont systemFontSize];
  if (style & WIDGET_STYLE_MINI) {  // Use smaller text font
    //FIXME: remove hard coded size
    int fs = as_int (get_preference ("gui:mini-fontsize", "8"));
    if (fs <= 0) fs = 8;
    font = [NSFont systemFontOfSize: fs];
//    [dict insertValue: font inPropertyWithKey: NSFontAttributeName];
//    sheet += QString("font-size: %1pt;").arg (fs > 0 ? fs : QTM_MINI_FONTSIZE);
 //   sheet += QString("padding: 1px;");
  }
  if (style & WIDGET_STYLE_MONOSPACED) {  // Use monospaced font
    NSFont* f = [[NSFontManager sharedFontManager] convertFont: font toHaveTrait: NSFixedPitchFontMask];
    font = f;
  }
  if (style & WIDGET_STYLE_GREY)  {    // Use grey text font
    color = [NSColor grayColor];
    //    sheet += "color: #414141;";
  }
  if (style & WIDGET_STYLE_PRESSED)  { // Button is currently pressed
  }
  if (style & WIDGET_STYLE_INERT)  {   // Only render, don't associate any action
  }
  if (style & WIDGET_STYLE_BUTTON)  {  // Render button as standard button
  }
  if (style & WIDGET_STYLE_CENTERED) { // Use centered text
    pstyle = [[[NSParagraphStyle defaultParagraphStyle] mutableCopy] autorelease];
    [pstyle setAlignment: NSCenterTextAlignment];
  }
  if (style & WIDGET_STYLE_BOLD) {
    NSFont* f = [[NSFontManager sharedFontManager] convertFont: font toHaveTrait: NSBoldFontMask];
    font = f;
  }
  
  if (pstyle) [dict insertValue: pstyle inPropertyWithKey: NSParagraphStyleAttributeName];
  if (font) [dict insertValue: font inPropertyWithKey: NSFontAttributeName];
  if (color) [dict insertValue: color inPropertyWithKey: NSForegroundColorAttributeName];
  
  return [[[NSAttributedString alloc] initWithString: str attributes: dict] autorelease];
}


/******************************************************************************
 * ns_ui_element_rep
 ******************************************************************************/

ns_ui_element_rep::ns_ui_element_rep (types _type, blackbox _load)
: ns_widget_rep (), load (_load), type(_type) {}

ns_ui_element_rep::~ns_ui_element_rep() {}


NSView*
ns_ui_element_rep::as_view () {
  NSView *v = nil;
  switch (type) {
    case vertical_menu:
    case vertical_list:
    case aligned_widget:
    {
      typedef array<widget> T;
      T arr = open_box<T> (load);

      v = [[[NSView alloc] init] autorelease];
      NSLayoutYAxisAnchor *yanchor = [v topAnchor];
      NSLayoutXAxisAnchor *lanchor = [v leftAnchor];
      NSLayoutXAxisAnchor *ranchor = [v rightAnchor];
      float hspacing = 2.0, vspacing = 2.0, hborder = 2.0, vborder = 2.0;
      for (int i = 0; i < N(arr); i++) {
        if (is_nil (arr[i])) break;
        NSView* item = concrete (arr[i])->as_view ();
        [item setTranslatesAutoresizingMaskIntoConstraints: NO];
        [v addSubview: item];
        [[[item topAnchor] constraintEqualToAnchor: yanchor constant: (i == 0 ? vborder : vspacing)] setActive: YES];
        [[[item leadingAnchor] constraintEqualToAnchor: lanchor constant: hborder] setActive: YES];
        [[[item trailingAnchor] constraintEqualToAnchor: ranchor constant: -hborder] setActive: YES];
        yanchor = [item bottomAnchor];
      }
      [[yanchor constraintEqualToAnchor: [v bottomAnchor] constant: -vborder] setActive: YES];
    }
      break;
      
    case horizontal_menu:
    case horizontal_list:
    case minibar_menu:
    {
      typedef array<widget> T;
      T arr = open_box<T> (load);
      
      v = [[[NSView alloc] init] autorelease];
      NSLayoutXAxisAnchor *xanchor = [v leadingAnchor];
      NSLayoutYAxisAnchor *tanchor = [v topAnchor];
      NSLayoutYAxisAnchor *banchor = [v bottomAnchor];
      float hspacing = 2.0, vspacing = 2.0, hborder = 2.0, vborder = 2.0;
      for (int i = 0; i < N(arr); i++) {
        if (is_nil (arr[i])) break;
        NSView* item = concrete (arr[i])->as_view ();
        [item setTranslatesAutoresizingMaskIntoConstraints: NO];
        [v addSubview: item];
        [[[item leadingAnchor] constraintEqualToAnchor: xanchor constant: (i==0 ? hborder : hspacing)] setActive: YES];
        [[[item topAnchor] constraintEqualToAnchor: tanchor constant: vborder] setActive: YES];
        [[[item bottomAnchor] constraintEqualToAnchor: banchor constant: -vborder] setActive: YES];
        xanchor = [item trailingAnchor];
      }
      [[xanchor constraintEqualToAnchor: [v trailingAnchor] constant: -hspacing] setActive: YES];
    }
      break;
      
      
    case tile_menu:
    {
      typedef array<widget> T1;
      typedef pair<T1, int> T;
      T  x     = open_box<T> (load);
      T1 a     = x.x1;
      int cols = x.x2;
      
      v = [[[NSView alloc] init] autorelease];
//      [v setTranslatesAutoresizingMaskIntoConstraints: NO];
      
      NSLayoutXAxisAnchor *lanchor = [v leadingAnchor];
      NSLayoutYAxisAnchor *tanchor = [v topAnchor];
      NSLayoutDimension *wanchor = nil;
      NSLayoutDimension *hanchor = nil;
      float hspacing = 2.0, vspacing = 2.0, hborder = 2.0, vborder = 2.0;
      int row= 0, col= 0;
      for (int i=0; i < N(a); i++) {
        NSView* item = concrete(a[i])->as_view ();
        [item setTranslatesAutoresizingMaskIntoConstraints: NO];
        [v addSubview: item];
        if (!wanchor)
          wanchor = [item widthAnchor];
        else
          [[[item widthAnchor] constraintEqualToAnchor: wanchor] setActive: YES];
        if (!hanchor)
          wanchor = [item widthAnchor];
        else
          [[[item heightAnchor] constraintEqualToAnchor: hanchor] setActive: YES];
        [[[item topAnchor] constraintEqualToAnchor: tanchor constant: (row == 0 ? vborder : vspacing)] setActive: YES];
        [[[item leadingAnchor] constraintEqualToAnchor: lanchor constant: (col == 0? hborder : hspacing)] setActive: YES];
        lanchor = [item trailingAnchor];
        col++;
        if (col >= cols) {
          col = 0; row++;
          [[lanchor constraintLessThanOrEqualToAnchor: [v trailingAnchor] constant: -hborder] setActive: YES];
          tanchor = [item bottomAnchor];
          lanchor = [v leadingAnchor];
        }
      }
      [[tanchor constraintLessThanOrEqualToAnchor: [v bottomAnchor] constant:-vborder] setActive: YES];
      NSSize naturalSize = [v fittingSize];
      [v setFrameSize: naturalSize];
    }
      break;
      
    case resize_widget:
    {
      typedef triple <string, string, string> T1;
      typedef quartet <widget, int, T1, T1 > T;
      T x = open_box<T>(load);
      
      ns_widget wid = concrete(x.x1);
      int     style = x.x2;
      T1     widths = x.x3;
      T1    heights = x.x4;
      
      v = wid->as_view ();
      debug_aqua << "resize_widget not implemented.\n";
      //FIXME : implement resize_widget
#if 0
//      ns_apply_tm_style (qwid, style);
      
      QSize minSize = ns_decode_length (widths.x1, heights.x1,
                                        qwid->minimumSizeHint(),
                                        qwid->fontMetrics());
      QSize defSize = ns_decode_length (widths.x2, heights.x2,
                                        qwid->minimumSizeHint(),
                                        qwid->fontMetrics());
      QSize maxSize = ns_decode_length (widths.x3, heights.x3,
                                        qwid->minimumSizeHint(),
                                        qwid->fontMetrics());
      
      if (minSize == defSize && defSize == maxSize) {
        qwid->setFixedSize (defSize);
        qwid->setSizePolicy (QSizePolicy::Fixed, QSizePolicy::Fixed);
      } else {
        qwid->setSizePolicy (QSizePolicy::Ignored, QSizePolicy::Ignored);
        qwid->setMinimumSize (minSize);
        qwid->setMaximumSize (maxSize);
        qwid->resize (defSize);
      }
#endif
    }
      break;
      
    case menu_separator:
    case menu_group:
    case glue_widget:
    {
      //debug_aqua << "(ns_ui_element_rep::as_view) I'm not sure we are doing the right thing here \n";
      v = [[[NSView alloc] init] autorelease];
    }
      break;
      
    case pulldown_button:
    case pullright_button:
    {
      typedef pair<widget, promise<widget> > T;
      T                x = open_box<T> (load);
      ns_widget      _w = concrete (x.x1);
      promise<widget> pw = x.x2;
      
      ns_ui_element_rep *w = dynamic_cast<ns_ui_element_rep*>(_w.rep);
      if (!w) {
        v = [[[NSView alloc] init] autorelease];
      } else if (w->type == xpm_widget) {
        url image = open_box<url> (w->load);
        NSButton* b = [[[NSButton alloc] init] autorelease];
        [b setTranslatesAutoresizingMaskIntoConstraints: NO];
        TMLazyMenu* menu = [[[TMLazyMenu alloc] init] autorelease];
        [menu setPromise: pw.rep];
        [b setMenu: menu];
        [b setImage: xpm_image (image)];
        [b setButtonType: NSMomentaryPushInButton];
        v = b;
      } else if (w->type == text_widget) {
        typedef quartet<string, int, color, bool> T1;
        T1 y = open_box<T1> (w->load);
        NSButton* b = [[[NSButton alloc] init] autorelease];
        TMLazyMenu* menu = [[[TMLazyMenu alloc] init] autorelease];
        [menu setPromise: pw.rep];
        [b setMenu: menu];
        [b setButtonType: NSMomentaryPushInButton];
        [b setTitle: to_nsstring(y.x1)];
        [b setEnabled:(y.x2 & WIDGET_STYLE_INERT) ? NO : YES];
        // ns_apply_tm_style (b, y.x2, y.x3);
        v = b;
      }
    }
      break;
      
      // a command button with an optional prefix (o, * or v) and (sometimes)
      // keyboard shortcut
    case menu_button:
    {
      typedef quintuple<widget, command, string, string, int> T;
      T x = open_box<T>(load);
      ns_widget _w = concrete(x.x1); // contents: xpm_widget, text_widget, ...?
      command   cmd = x.x2;
      string    pre = x.x3;
      string     ks = x.x4;
      int     style = x.x5;
    
      NSButton* b = nil;
      
      v = _w->as_view ();
      if ([[v class] isSubclassOfClass: [NSButton class]]) {
        b = (NSButton*)v;
      } else {
        // can be a ns_simple_widget_rep, take a snapshot
        TMMenuItem* mi = _w->as_menuitem ();
        b = [[[NSButton alloc] init] autorelease];
        [b setImage: [mi image]];
      }
      [b setButtonType: NSMomentaryPushInButton];
      [b setBezelStyle: NSShadowlessSquareBezelStyle];
      [b setBordered: NO];
      [b setTranslatesAutoresizingMaskIntoConstraints: NO];
      [b setEnabled: NO];
      NSImage *img = [b image];
      if (img) {
        NSSize sz = [img size];
        [[[b widthAnchor] constraintGreaterThanOrEqualToConstant: sz.width] setActive: YES];
        [[[b heightAnchor] constraintGreaterThanOrEqualToConstant: sz.height] setActive: YES];
      }
      TMCommand* command = [[[TMCommand alloc] init] autorelease];
      [command setCommand: cmd.rep];
      [command setObject: b];
      [[b cell] setRepresentedObject: command];
      [b setTarget: command];
      [b setAction: @selector(doit)];
      [b setEnabled: !(style & WIDGET_STYLE_INERT)];
      v = b;
      //FIXME: respect  (style & WIDGET_STYLE_BUTTON)
//      qwid->setStyle (qtmstyle());
//      ns_apply_tm_style (qwid, style);
//      qwid->setEnabled (! (style & WIDGET_STYLE_INERT));
    }
      break;
      
      // given a button widget w, specify a help balloon which should be displayed
      // when the user leaves the mouse pointer on the button for a small while
    case balloon_widget:
    {
      typedef pair<widget, widget> T;
      T            x = open_box<T>(load);
      ns_widget    w = concrete (x.x1);
      ns_widget _help = concrete (x.x2);
      
      typedef quartet<string, int, color, bool> T1;
      
      ns_ui_element_rep* help = dynamic_cast<ns_ui_element_rep*>(_help.rep);
      
      v = w->as_view ();
      if (help && help->type == text_widget) {
        T1 y = open_box<T1>(help->load);
        [v setToolTip: to_nsstring (y.x1)];
      }
    }
      break;

      // a text widget with a given color and transparency
    case text_widget:
    {
      typedef quartet<string, int, color, bool> T;
      T        x = open_box<T>(load);
      string str = x.x1;
      int  style = x.x2;
      color    c = x.x3;
      //bool      tsp = x.x4;  // FIXME: add transparency support
      
      NSButton* b = [[[NSButton alloc] init] autorelease];
      [b setTitle: to_nsstring (str)];
      [b setEnabled: NO];
      //FIXME: implement style and color
      v = b;
    }
      break;

      // a widget with an X pixmap icon
    case xpm_widget:
    {
      url image = open_box<url>(load);
      NSButton* b = [[[NSButton alloc] init] autorelease];
      NSImage* img = xpm_image (image);
      [b setImagePosition: NSImageOnly];
      [b setImage: img];
      [b setEnabled: NO];
      
      v = b;
    }
      break;

#if 0

      

    case toggle_widget:
    {
      typedef triple<command, bool, int > T;
      T         x = open_box<T>(load);
      command cmd = x.x1;
      bool  check = x.x2;
      int   style = x.x3;
      
      QCheckBox* w  = new QCheckBox (NULL);
      w->setCheckState (check ? Qt::Checked : Qt::Unchecked);
      ns_apply_tm_style (w, style);
      
      command tcmd = tm_new<ns_toggle_command_rep> (w, cmd);
      QTMCommand* c = new QTMCommand (w, tcmd);
      QObject::connect (w, SIGNAL (stateChanged(int)), c, SLOT (apply()));
      
      qwid = w;
    }
      break;
      
    case enum_widget:
    {
      typedef quintuple<command, array<string>, string, int, string> T;
      T                x = open_box<T>(load);
      command        cmd = x.x1;
      QStringList values = to_qstringlist (x.x2);
      QString      value = to_qstring (x.x3);
      int          style = x.x4;
      
      QTMComboBox* w = new QTMComboBox (NULL);
      if (values.isEmpty())
        values << QString("");  // safeguard
      
      w->setEditable (value.isEmpty() || values.last().isEmpty());  // weird convention?!
      if (values.last().isEmpty())
        values.removeLast();
      
      w->addItemsAndResize (values, x.x5, "");
      int index = w->findText (value, Qt::MatchFixedString | Qt::MatchCaseSensitive);
      if (index != -1)
        w->setCurrentIndex (index);
      
      ns_apply_tm_style (w, style);
      
      command  ecmd = tm_new<ns_enum_command_rep> (w, cmd);
      QTMCommand* c = new QTMCommand (w, ecmd);
      // NOTE: with QueuedConnections, the slots are sometimes not invoked.
      QObject::connect (w, SIGNAL (currentIndexChanged(int)), c, SLOT (apply()));
      
      qwid = w;
    }
      break;
      
      // select one or multiple values from a list
    case choice_widget:
    {
      typedef quartet<command, array<string>, array<string>, bool> T;
      T  x = open_box<T>(load);
      qwid = new QTMListView (x.x1, to_qstringlist(x.x2), to_qstringlist(x.x3),
                              x.x4);
    }
      break;
      
    case filtered_choice_widget:
    {
      typedef quartet<command, array<string>, string, string> T;
      T           x = open_box<T>(load);
      string filter = x.x4;
      QTMListView* choiceWidget = new QTMListView (x.x1, to_qstringlist (x.x2),
                                                   QStringList (to_qstring (x.x3)),
                                                   false, true, true);
      
      QTMLineEdit* lineEdit = new QTMLineEdit (0, "string", "1w");
      QObject::connect (lineEdit, SIGNAL (textChanged (const QString&)),
                        choiceWidget->filter(), SLOT (setFilterRegExp (const QString&)));
      lineEdit->setText (to_qstring (filter));
      lineEdit->setFocusPolicy (Qt::StrongFocus);
      
      QVBoxLayout* layout = new QVBoxLayout ();
      layout->addWidget (lineEdit);
      layout->addWidget (choiceWidget);
      layout->setSpacing (0);
      layout->setContentsMargins (0, 0, 0, 0);
      
      qwid = new QWidget();
      qwid->setLayout (layout);
    }
      break;
      
    case tree_view_widget:
    {
      typedef triple<command, tree, tree> T;
      T  x = open_box<T>(load);
      qwid = new QTMTreeView (x.x1, x.x2, x.x3);  // command, data, roles
    }
      break;
      
    case scrollable_widget:
    {
      typedef pair<widget, int> T;
      T           x = open_box<T> (load);
      ns_widget wid = concrete (x.x1);
      int     style = x.x2;
      
      QTMScrollArea* w = new QTMScrollArea();
      w->setWidgetAndConnect (wid->as_qwidget());
      w->setWidgetResizable (true);
      
      ns_apply_tm_style (w, style);
      // FIXME????
      // "Note that You must add the layout of widget before you call this function;
      //  if you add it later, the widget will not be visible - regardless of when
      //  you show() the scroll area. In this case, you can also not show() the widget
      //  later."
      qwid = w;
      
    }
      break;
      
    case hsplit_widget:
    case vsplit_widget:
    {
      typedef pair<widget, widget> T;
      T          x = open_box<T>(load);
      ns_widget w1 = concrete(x.x1);
      ns_widget w2 = concrete(x.x2);
      
      QWidget* qw1 = w1->as_qwidget();
      QWidget* qw2 = w2->as_qwidget();
      QSplitter* split = new QSplitter();
      split->setOrientation(type == hsplit_widget ? Qt::Horizontal
                            : Qt::Vertical);
      split->addWidget (qw1);
      split->addWidget (qw2);
      
      qwid = split;
    }
      break;
      
    case tabs_widget:
    {
      typedef array<widget> T1;
      typedef pair<T1, T1> T;
      T       x = open_box<T>(load);
      T1   tabs = x.x1;
      T1 bodies = x.x2;
      
      QTMTabWidget* tw = new QTMTabWidget ();
      
      int i;
      for (i = 0; i < N(tabs); i++) {
        if (is_nil (tabs[i])) break;
        QWidget* prelabel = concrete (tabs[i])->as_qwidget();
        QLabel*     label = qobject_cast<QLabel*> (prelabel);
        QWidget*     body = concrete (bodies[i])->as_qwidget();
        tw->addTab (body, label ? label->text() : "");
        delete prelabel;
      }
      
      if (i>0) tw->resizeOthers(0);   // Force the automatic resizing
      
      qwid = tw;
    }
      break;
      
    case icon_tabs_widget:
    {
      typedef array<url> U1;
      typedef array<widget> T1;
      typedef triple<U1, T1, T1> T;
      T       x = open_box<T>(load);
      U1  icons = x.x1;
      T1   tabs = x.x2;
      T1 bodies = x.x3;
      
      QTMTabWidget* tw = new QTMTabWidget ();
      int i;
      for (i = 0; i < N(tabs); i++) {
        if (is_nil (tabs[i])) break;
        QImage*       img = xpm_image (icons[i]);
        QWidget* prelabel = concrete (tabs[i])->as_qwidget();
        QLabel*     label = qobject_cast<QLabel*> (prelabel);
        QWidget*     body = concrete (bodies[i])->as_qwidget();
        tw->addTab (body, QIcon (as_pixmap (*img)), label ? label->text() : "");
        delete prelabel;
      }
      
      if (i>0) tw->resizeOthers(0);   // Force the automatic resizing
      
      qwid = tw;
    }
      break;
      
    case refresh_widget:
    {
      typedef pair<string, string> T;
      T  x = open_box<T> (load);
      qwid = new QTMRefreshWidget (this, x.x1, x.x2);
    }
      break;
      
    case refreshable_widget:
    {
      typedef pair<object, string> T;
      T  x = open_box<T> (load);
      qwid = new QTMRefreshableWidget (this, x.x1, x.x2);
    }
      break;
#endif
      
    default:
      ;
  }
  
  if (!v) {
    debug_aqua << "as_view(): not implemented\n";
    v = [[[NSView alloc] init] autorelease];
  }
  
  return v;
}

TMMenuItem*
ns_ui_element_rep::as_menuitem () {
  TMMenuItem* mi = nil;
  switch (type) {
    case vertical_menu:
    case horizontal_menu:
    case vertical_list:
      // a vertical menu made up of the widgets in arr
    {
      typedef array<widget> T;
      array<widget> arr = open_box<T> (load);
      
      mi = [[[TMMenuItem alloc] init] autorelease];
      [mi setTitle: to_nsstring (ns_translate ("Menu"))];
      NSMenu* menu = [[[NSMenu alloc] init] autorelease];
      for (int i = 0; i < N(arr); i++) {
        if (is_nil (arr[i])) break;
        NSMenuItem* mii = concrete (arr[i])->as_menuitem ();
        [menu addItem: mii];
      }
      [mi setSubmenu: menu];
    }
      break;
      
    case horizontal_list:
    case aligned_widget:
    case tile_menu:
    case minibar_menu:
    {
      mi = [[[TMMenuItem alloc] init] autorelease];
      NSView *v = as_view ();
      [mi setView: v];
    }
      break;
      
    case menu_separator:
      // a horizontal or vertical menu separator
    {
      mi = [NSMenuItem separatorItem];
    }
      break;
      
    case glue_widget:
    {
      mi = [[[TMMenuItem alloc] init] autorelease];
      [mi setTitle:@""]; // remove default title
      [mi setEnabled: NO];
      {
        typedef quintuple<tree, bool, bool, SI, SI> T;
        T x = open_box<T> (load);
        tree col = x.x1;
        bool hx = x.x2; bool vx = x.x3;
        SI w = x.x4; SI h = x.x5;
        if (col == "") {
          NSSize s = NSMakeSize(w,h);
          NSImage *img = [[[NSImage alloc] initWithSize: s] autorelease];
          [mi setImage: img];
          // transparent glue
        } else {
          // rendering colored glue
          NSSize s = NSMakeSize(w,h);
          NSImage *img = [[[NSImage alloc] initWithSize: s] autorelease];
          [img lockFocus];
          {
            basic_renderer ren = the_ns_renderer();
            ren -> begin([NSGraphicsContext currentContext]);
            rectangle r = rectangle (0, 0, s.width, s.height);
            ren->set_origin (0, 0);
            ren->encode (r->x1, r->y1);
            ren->encode (r->x2, r->y2);
            ren->set_clipping (r->x1, r->y2, r->x2, r->y1);
        
            if (is_atomic (col)) {
              color c = named_color (col->label);
              ren->set_background (c);
              ren->set_pencil (c);
              ren->fill (r->x1, r->y2, r->x2, r->y1);
            } else {
              ren->set_shrinking_factor (std_shrinkf);
              brush old_b = ren->get_background ();
              ren->set_background (col);
              ren->clear_pattern (5*r->x1, 5*r->y2, 5*r->x2, 5*r->y1);
              ren->set_background (old_b);
              ren->set_shrinking_factor (1);
            }
            ren->end();
            [img unlockFocus];
            [mi setImage: img];
          }
        }
      }
    }
      break;
      
    case menu_group:
      // a menu group; the name should be greyed and centered
    {
      typedef pair<string, int> T;
      T         x = open_box<T> (load);
      string name = x.x1;
      int   style = x.x2;  //FIXME: ignored. Use a QWidgeAction to use it?
      
      mi = [[[TMMenuItem alloc] init] autorelease];
      [mi setTitle: to_nsstring_utf8 (name)];
      [mi setEnabled: NO];

      //FIXME: set font properly
      //act->setFont (to_qfont (style, act->font()));

      //	NSAttributedString *str = [mi attributedTitle];
      NSMutableParagraphStyle *pstyle = [[[NSParagraphStyle defaultParagraphStyle] mutableCopy] autorelease];
      //	NSMutableParagraphStyle *style = [(NSParagraphStyle*)[str attribute:NSParagraphStyleAttributeName atIndex:0 effectiveRange:NULL] mutableCopy];
      [pstyle setAlignment: NSCenterTextAlignment];
      [mi setAttributedTitle: add_style ([mi title], style)];
    }
      break;
      
    case pulldown_button:
    case pullright_button:
      // a button w with a lazy pulldown menu pw
    {
      typedef pair<widget, promise<widget> > T;
      T                x = open_box<T> (load);
      ns_widget        w = concrete (x.x1);
      promise<widget> pw = x.x2;
      
      mi = w->as_menuitem ();
      TMLazyMenu* lm = [[[TMLazyMenu alloc] init] autorelease];
      [lm setPromise: pw.rep];
      [mi setSubmenu: lm];
      [mi setEnabled: YES];
    }
      break;
      
    case menu_button:
      // a command button with an optional prefix (o, * or v) and
      // keyboard shortcut; if ok does not hold, then the button is greyed
    {
      typedef quintuple<widget, command, string, string, int> T;
      T x = open_box<T> (load);
      
      ns_widget   w = concrete (x.x1);
      command   cmd = x.x2;
      string   pre  = x.x3;
      string   ks   = x.x4;
      int   style   = x.x5;
    
      mi = w->as_menuitem ();
      [mi setCommand: cmd.rep];

      //FIXME: implement shortcuts
      
      bool ok = (style & WIDGET_STYLE_INERT) == 0;
      [mi setEnabled: ok ? YES : NO];
      
      // FIXME: implement complete prefix handling
      bool check = (pre != "") || (style & WIDGET_STYLE_PRESSED);
      [mi setState: (check ? NSOnState : NSOffState)];
      if (pre == "v") {}
      else if (pre == "*") {}
      // [mi setOnStateImage:[NSImage imageNamed:@"TMStarMenuBullet"]];
      else if (pre == "o") {}
    }
      break;
      
    case balloon_widget:
      // Given a button widget w, specify a help balloon which should be
      // displayed when the user leaves the mouse pointer on the button for a
      // small while
    {
      typedef pair<widget, widget> T;
      T            x = open_box<T> (load);
      ns_widget    w = concrete (x.x1);
      ns_widget help = concrete (x.x2);
    
      mi = w->as_menuitem ();
      ns_ui_element_rep* ww = dynamic_cast<ns_ui_element_rep*>(help.rep);
      if (ww) {
        typedef quartet<string, int, color, bool> T1;
        T1 y = open_box<T1> (ww->load);
        [mi setToolTip: to_nsstring (y.x1)];
      }
    }
      break;
      
    case text_widget:
      // A text widget with a given color and transparency
    {
      typedef quartet<string, int, color, bool> T;
      T x = open_box<T>(load);
      string str = x.x1;
      int style  = x.x2;
      //color col  = x.x3;
      //bool tsp   = x.x4;
      
      mi = [[[TMMenuItem alloc] init] autorelease];
      [mi setTitle: to_nsstring_utf8 (tm_var_encode (str))];
      //FIXME: set font
//      a->setFont (to_qfont (style, a->font()));
    }
      break;
      
    case xpm_widget:
      // a widget with an X pixmap icon
    {
      url    image = open_box<url>(load);
      mi = [[[TMMenuItem alloc] init] autorelease];
      NSImage* img = xpm_image (image);
      [mi setImage: img];
      [mi setRepresentedObject: img];
    }
      break;
      
      
    default:
      debug_aqua << "failed ns_ui_element_rep::as_menuitem, using an empty object.\n";
      mi = [[[TMMenuItem alloc] init] autorelease];
  }
  
  return mi;
}


widget
ns_ui_element_rep::make_popup_widget () {
  if (type == vertical_menu) {
    TMMenuItem *mi = as_menuitem ();
    return tm_new<ns_menu_rep> (mi);
  }
  else
    return ns_widget_rep::make_popup_widget();
}



NSMenu*
to_nsmenu (widget w)
{
  return [concrete(w)->as_menuitem() submenu];
}

NSMenuItem*
to_nsmenuitem (widget w)
{
  return concrete(w)->as_menuitem();
}

TMMenuItem*
ns_simple_widget_rep::as_menuitem () {
  TMMenuItem *mi = [[[TMMenuItem alloc] init] autorelease];
  [mi setWidget: this];
  return mi;
}

#if 0
NSView*
ns_simple_widget_rep::as_view () {
  TMMenuItem *mi = as_menuitem ();
  NSButton* b = [[[NSButton alloc] init] autorelease];
  NSImage* img = [mi image];
  [b setImagePosition: NSImageOnly];
  [b setImage: img];
  [b setEnabled: NO];
  return b;
}
#endif

#pragma mark abstract UI widget interface

#ifdef NEW_MENUS

/******************************************************************************
 * TeXmacs interface for the creation of widgets.
 * See Graphics/Gui/widget.hpp for comments.
 ******************************************************************************/

widget horizontal_menu (array<widget> a) {
  ns_widget wid = ns_ui_element_rep::create (ns_ui_element_rep::horizontal_menu, a);
  wid->add_children (a);
  return abstract (wid);
}

widget vertical_menu (array<widget> a)  {
  ns_widget wid = ns_ui_element_rep::create (ns_ui_element_rep::vertical_menu, a);
  wid->add_children (a);
  return abstract (wid);
}

widget horizontal_list (array<widget> a) {
  ns_widget wid = ns_ui_element_rep::create (ns_ui_element_rep::horizontal_list, a);
  wid->add_children (a);
  return abstract (wid);
}

widget vertical_list (array<widget> a) {
  ns_widget wid = ns_ui_element_rep::create (ns_ui_element_rep::vertical_list, a);
  wid->add_children (a);
  return abstract (wid);
}

widget aligned_widget (array<widget> lhs, array<widget> rhs, SI hsep, SI vsep,
                       SI lpad, SI rpad) {
  ns_widget wid = ns_ui_element_rep::create (ns_ui_element_rep::aligned_widget,
                                             lhs, rhs, coord4 (hsep, vsep, lpad, rpad));
  wid->add_children (lhs);
  wid->add_children (rhs);
  return abstract (wid);
}

widget tabs_widget (array<widget> tabs, array<widget> bodies) {
  ns_widget wid = ns_ui_element_rep::create (ns_ui_element_rep::tabs_widget,
                                             tabs, bodies);
  wid->add_children (tabs);
  wid->add_children (bodies);
  return abstract (wid);
}

widget icon_tabs_widget (array<url> us, array<widget> ts, array<widget> bs) {
  ns_widget wid = ns_ui_element_rep::create (ns_ui_element_rep::icon_tabs_widget,
                                             us, ts, bs);
  wid->add_children (ts);
  wid->add_children (bs);
  return abstract (wid);
}

widget wrapped_widget (widget w, command cmd) {
  return widget();
//  return tm_new<ns_wrapped_widget_rep> (w, cmd);
}

widget tile_menu (array<widget> a, int cols) {
  ns_widget wid = ns_ui_element_rep::create (ns_ui_element_rep::tile_menu, a, cols);
  wid->add_children (a);
  return abstract (wid);
}

widget minibar_menu (array<widget> a) {
  ns_widget wid = ns_ui_element_rep::create (ns_ui_element_rep::minibar_menu, a);
  wid->add_children (a);
  return abstract (wid);
}

widget menu_separator (bool vertical) {
  ns_widget wid = ns_ui_element_rep::create (ns_ui_element_rep::menu_separator,
                                             vertical);
  return abstract (wid);
}

widget menu_group (string name, int style) {
  ns_widget wid = ns_ui_element_rep::create (ns_ui_element_rep::menu_group,
                                             name, style);
  return abstract (wid);
}

widget pulldown_button (widget w, promise<widget> pw) {
  ns_widget wid = ns_ui_element_rep::create (ns_ui_element_rep::pulldown_button,
                                             w, pw);
  // FIXME: the promise widget isn't added to the children when it's evaluated
  //  wid->add_child (??);
  return abstract(wid);
}

widget pullright_button (widget w, promise<widget> pw) {
  ns_widget wid = ns_ui_element_rep::create (ns_ui_element_rep::pullright_button,
                                             w, pw);
  // FIXME: the promise widget isn't added to the children when it's evaluated
  //  wid->add_child (??);
  return abstract(wid);
}

widget menu_button (widget w, command cmd, string pre, string ks, int style) {
  ns_widget wid = ns_ui_element_rep::create (ns_ui_element_rep::menu_button,
                                             w, cmd, pre, ks, style);
  wid->add_child (w);
  return abstract (wid);
}

widget balloon_widget (widget w, widget help) {
  ns_widget wid = ns_ui_element_rep::create (ns_ui_element_rep::balloon_widget,
                                             w, help);
  wid->add_child (w);
  return abstract (wid);
}

widget text_widget (string s, int style, color col, bool tsp) {
  ns_widget wid = ns_ui_element_rep::create (ns_ui_element_rep::text_widget,
                                             s, style, col, tsp);
  return abstract (wid);
}

widget xpm_widget (url file_name) {
  ns_widget wid = ns_ui_element_rep::create (ns_ui_element_rep::xpm_widget,
                                             file_name);
  return abstract (wid);
}

widget toggle_widget (command cmd, bool on, int style) {
  ns_widget wid = ns_ui_element_rep::create (ns_ui_element_rep::toggle_widget,
                                             cmd, on, style);
  return abstract (wid);
}

widget enum_widget (command cmd, array<string> vals, string val, int style,
                    string width) {
  ns_widget wid = ns_ui_element_rep::create (ns_ui_element_rep::enum_widget,
                                             cmd, vals, val, style, width);
  return abstract (wid);
}

widget choice_widget (command cmd, array<string> vals, array<string> chosen) {
  ns_widget wid = ns_ui_element_rep::create (ns_ui_element_rep::choice_widget,
                                             cmd, vals, chosen, true);
  return abstract (wid);
}

widget choice_widget (command cmd, array<string> vals, string cur) {
  array<string> chosen (1);
  chosen[0]= cur;
  ns_widget wid = ns_ui_element_rep::create (ns_ui_element_rep::choice_widget,
                                             cmd, vals, chosen, false);
  return abstract (wid);
}

widget choice_widget (command cmd, array<string> vals, string cur, string filter) {
  ns_widget wid = ns_ui_element_rep::create (ns_ui_element_rep::filtered_choice_widget,
                                             cmd, vals, cur, filter);
  return abstract (wid);
}

widget user_canvas_widget (widget w, int style) {
  ns_widget wid = ns_ui_element_rep::create (ns_ui_element_rep::scrollable_widget,
                                             w, style);
  wid->add_child (w);
  return abstract (wid);
}

widget resize_widget (widget w, int style, string w1, string h1,
                      string w2, string h2, string w3, string h3,
                      string hpos, string vpos) {
  typedef triple<string, string, string> T1;
  (void) hpos; (void) vpos;
  ns_widget wid = ns_ui_element_rep::create (ns_ui_element_rep::resize_widget,
                                             w, style, T1(w1, w2, w3),
                                             T1(h1, h2, h3));
  wid->add_child (w);
  return abstract (wid);
}

widget hsplit_widget (widget l, widget r) {
  ns_widget wid = ns_ui_element_rep::create (ns_ui_element_rep::hsplit_widget, l, r);
  wid->add_children (array<widget> (l, r));
  return abstract (wid);
}

widget vsplit_widget (widget t, widget b) {
  ns_widget wid = ns_ui_element_rep::create (ns_ui_element_rep::vsplit_widget, t, b);
  wid->add_children (array<widget> (t, b));
  return abstract (wid);
}

widget refresh_widget (string tmwid, string kind) {
  ns_widget wid = ns_ui_element_rep::create (ns_ui_element_rep::refresh_widget,
                                             tmwid, kind);
  // FIXME: decide what to do with children in QTMRefresh::recompute()
  return abstract (wid);
}

widget refreshable_widget (object promise, string kind) {
  ns_widget wid = ns_ui_element_rep::create (ns_ui_element_rep::refreshable_widget,
                                             promise, kind);
  // FIXME: decide what to do with children in QTMRefreshable::recompute()
  return abstract (wid);
}

widget glue_widget (bool hx, bool vx, SI w, SI h) {
  ns_widget wid = ns_ui_element_rep::create (ns_ui_element_rep::glue_widget,
                                             tree(""), hx, vx, w/PIXEL, h/PIXEL);
  return abstract (wid);
}

widget glue_widget (tree col, bool hx, bool vx, SI w, SI h) {
  ns_widget wid = ns_ui_element_rep::create (ns_ui_element_rep::glue_widget,
                                             col, hx, vx, w/PIXEL, h/PIXEL);
//  return tm_new<ns_glue_widget_rep> (col, hx, vx, w, h);
 // debug_aqua << "glue_widget\n";
  return abstract (wid);
}

#if 0
widget inputs_list_widget (command call_back, array<string> prompts) {
//  return tm_new<ns_inputs_list_widget_rep> (call_back, prompts);
  debug_aqua << "inputs_list_widget\n";
  return widget();
}

widget input_text_widget (command call_back, string type, array<string> def,
                          int style, string width) {
  //FIXME: handle style
  return tm_new<ns_input_text_widget_rep> (call_back, type, def);
  //, style, width);
}

widget color_picker_widget (command call_back, bool bg, array<tree> proposals) {
//  return tm_new<ns_color_picker_widget_rep> (call_back, bg, proposals);
  debug_aqua << "color_picker_widget\n";
  return widget();
}

widget file_chooser_widget (command cmd, string type, string prompt) {
//  return tm_new<ns_chooser_widget_rep> (cmd, type, prompt);
  debug_aqua << "file_chooser_widget\n";
  return widget();
}

widget printer_widget (command cmd, url ps_pdf_file) {
//  return tm_new<ns_printer_widget_rep> (cmd, ps_pdf_file);
  debug_aqua << "printer_widget\n";
  return widget();
}

widget texmacs_widget (int mask, command quit) {
  if (mask) return tm_new<ns_tm_widget_rep> (mask, quit);
  else      return tm_new<ns_tm_embedded_widget_rep> (quit);
}
#endif

widget ink_widget (command cb) {
  (void) cb;
  debug_aqua << "ink_widget\n";
  return widget();
}

widget tree_view_widget (command cmd, tree data, tree actions) {
  ns_widget wid = ns_ui_element_rep::create (ns_ui_element_rep::tree_view_widget,
                                             cmd, data, actions);
  return abstract (wid);
  
}
//// Widgets which are not strictly required by TeXmacs have void implementations

widget empty_widget () {
  //NOT_IMPLEMENTED("empty_widget");
  debug_aqua << "empty_widget\n";
  return widget();
}

widget extend (widget w, array<widget> a) {
  (void) a;
  debug_aqua << "extend\n";
  return w;
}

widget wait_widget (SI width, SI height, string message) {
  (void) width; (void) height; (void) message;
  debug_aqua << "wait_widget\n";
  return widget();
}
#endif
