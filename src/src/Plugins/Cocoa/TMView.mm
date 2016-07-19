
/******************************************************************************
* MODULE     : TMView.mm
* DESCRIPTION: Main TeXmacs view
* COPYRIGHT  : (C) 2007  Massimiliano Gubinelli
*******************************************************************************
* This software falls under the GNU general public license version 3 or later.
* It comes WITHOUT ANY WARRANTY WHATSOEVER. For details, see the file LICENSE
* in the root directory or <http://www.gnu.org/licenses/gpl-3.0.html>.
******************************************************************************/

#import "TMView.h"
#include "converter.hpp"
#include "message.hpp"
#include "ns_renderer.h"
#include "ns_gui.h"

extern bool ns_update_flag;
extern int time_credit;
extern int timeout_time;

hashmap<int,string> nskeymap("");

inline void scale (NSPoint &point)
{	
	point.x *= PIXEL; point.y *= -PIXEL;
}

inline void scaleSize (NSSize &point)
{	
	point.width *= PIXEL; point.height *= PIXEL;
}

inline void unscaleSize (NSSize &point)
{
	point.width /= PIXEL; point.height /= PIXEL;
}



@interface TMRect : NSObject
{
	NSRect rect;
}
- initWithRect:(NSRect)_rect;
- (NSRect)rect;
@end

@implementation TMRect
- initWithRect:(NSRect)_rect
{
	[super init];
	rect = _rect;
	return self;
}
- (NSRect)rect { return rect; }
@end


@interface TMView (Private)
- (void) delayedUpdate;
- (void) focusIn;
- (void) focusOut;
@end



@implementation TMView


inline void map(int code, string name)
{
  nskeymap(code) = name;
}

void initkeymap()
{
  map(0x0d,"return");
  map(0x09,"tab");
  map(0xf728,"backspace");
  map(0xf003,"enter");
  map(0x1b,"escape");
  map(0x0003,"K-enter");
  map(0x7f,"backspace");
  
  map( NSUpArrowFunctionKey       ,"up" );
  map( NSDownArrowFunctionKey     ,"down" );
  map( NSLeftArrowFunctionKey     ,"left" );
  map( NSRightArrowFunctionKey    ,"right" );
  map( NSF1FunctionKey    ,"F1" );
  map( NSF2FunctionKey    ,"F2" );
  map( NSF3FunctionKey    ,"F3" );
  map( NSF4FunctionKey    ,"F4" );
  map( NSF5FunctionKey    ,"F5" );
  map( NSF6FunctionKey    ,"F6" );
  map( NSF7FunctionKey    ,"F7" );
  map( NSF8FunctionKey    ,"F8" );
  map( NSF9FunctionKey    ,"F9" );
  map( NSF10FunctionKey   ,"F10" );
  map( NSF11FunctionKey   ,"F11" );
  map( NSF12FunctionKey   ,"F12" );
  map( NSF13FunctionKey   ,"F13" );
  map( NSF14FunctionKey   ,"F14" );
  map( NSF15FunctionKey   ,"F15" );
  map( NSF16FunctionKey   ,"F16" );
  map( NSF17FunctionKey   ,"F17" );
  map( NSF18FunctionKey   ,"F18" );
  map( NSF19FunctionKey   ,"F19" );
  map( NSF20FunctionKey   ,"F20" );
  map( NSF21FunctionKey   ,"F21" );
  map( NSF22FunctionKey   ,"F22" );
  map( NSF23FunctionKey   ,"F23" );
  map( NSF24FunctionKey   ,"F24" );
  map( NSF25FunctionKey   ,"F25" );
  map( NSF26FunctionKey   ,"F26" );
  map( NSF27FunctionKey   ,"F27" );
  map( NSF28FunctionKey   ,"F28" );
  map( NSF29FunctionKey   ,"F29" );
  map( NSF30FunctionKey   ,"F30" );
  map( NSF31FunctionKey   ,"F31" );
  map( NSF32FunctionKey   ,"F32" );
  map( NSF33FunctionKey   ,"F33" );
  map( NSF34FunctionKey   ,"F34" );
  map( NSF35FunctionKey   ,"F35" );
  map( NSInsertFunctionKey        ,"insert" );
  map( NSDeleteFunctionKey        ,"delete" );
  map( NSHomeFunctionKey  ,"home" );
  map( NSBeginFunctionKey         ,"begin" );
  map( NSEndFunctionKey   ,"end" );
  map( NSPageUpFunctionKey        ,"pageup" );
  map( NSPageDownFunctionKey      ,"pagedown" );
  map( NSPrintScreenFunctionKey   ,"printscreen" );
  map( NSScrollLockFunctionKey    ,"scrolllock" );
  map( NSPauseFunctionKey         ,"pause" );
  map( NSSysReqFunctionKey        ,"sysreq" );
  map( NSBreakFunctionKey         ,"break" );
  map( NSResetFunctionKey         ,"reset" );
  map( NSStopFunctionKey  ,"stop" );
  map( NSMenuFunctionKey  ,"menu" );
  map( NSUserFunctionKey  ,"user" );
  map( NSSystemFunctionKey        ,"system" );
  map( NSPrintFunctionKey         ,"print" );
  map( NSClearLineFunctionKey     ,"clear" );
  map( NSClearDisplayFunctionKey  ,"cleardisplay" );
  map( NSInsertLineFunctionKey    ,"insertline" );
  map( NSDeleteLineFunctionKey    ,"deleteline" );
  map( NSInsertCharFunctionKey    ,"insert" );
  map( NSDeleteCharFunctionKey    ,"delete" );
  map( NSPrevFunctionKey  ,"prev" );
  map( NSNextFunctionKey  ,"next" );
  map( NSSelectFunctionKey        ,"select" );
  map( NSExecuteFunctionKey       ,"execute" );
  map( NSUndoFunctionKey  ,"undo" );
  map( NSRedoFunctionKey  ,"redo" );
  map( NSFindFunctionKey  ,"find" );
  map( NSHelpFunctionKey  ,"help" );
  map( NSModeSwitchFunctionKey    ,"modeswitch" );  
}


- (id)initWithFrame:(NSRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    // Initialization code here.
    wid = NULL;
    processingCompose = NO;
    workingText = nil;
    delayed_rects = [[NSMutableArray arrayWithCapacity:100] retain];
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(delayedUpdate)
                                                 name: @"TeXmacsUpdateWindows"
                                               object: nil];

  }
  return self;
}

-(void) dealloc
{
  [delayed_rects release];
  [self deleteWorkingText];
  [[NSNotificationCenter defaultCenter] removeObserver: self
                                                  name: @"NSWindowDidBecomeKeyNotification"
                                                object: nil];
  [[NSNotificationCenter defaultCenter] removeObserver: self
                                                  name: @"NSWindowDidBecomeKeyNotification"
                                                object: nil];
  [[NSNotificationCenter defaultCenter] removeObserver: self
                                               name: @"TeXmacsUpdateWindows"
                                             object: nil];

  
  [super dealloc];
}

- (void) setWidget:(ns_simple_widget_rep*) w
{
	wid = w;
}

- (ns_simple_widget_rep*)widget
{
	return  wid;
}

- (void)viewWillMoveToWindow:(NSWindow *)newWindow
{
  // query widget preferred size
  SI w,h;
  wid->handle_get_size_hint (w,h);
  NSSize s = NSMakeSize(w,h);
  unscaleSize(s);
  [self setFrameSize:s];
  
  // register to receive focus in/out notifications  
  [[NSNotificationCenter defaultCenter] removeObserver: self
                                                  name: @"NSWindowDidBecomeKeyNotification"
                                                object: nil];
  [[NSNotificationCenter defaultCenter] removeObserver: self
                                                  name: @"NSWindowDidBecomeKeyNotification"
                                                object: nil];
  
  [[NSNotificationCenter defaultCenter] addObserver: self
                                           selector: @selector(focusIn)
                                               name: @"NSWindowDidBecomeKeyNotification"
                                             object: newWindow];
  
  [[NSNotificationCenter defaultCenter] addObserver: self
                                           selector: @selector(focusOut)
                                               name: @"NSWindowDidResignKeyNotification"
                                             object: newWindow];
  
}


- (void) focusIn
{
  if (DEBUG_EVENTS) debug_events << "FOCUSIN" << LF;
  if (wid) {
    wid->handle_keyboard_focus (true, texmacs_time ());
  }
}

- (void) focusOut
{
  if (DEBUG_EVENTS)   debug_events << "FOCUSOUT" << LF;
  if (wid) {
    wid->handle_keyboard_focus (false, texmacs_time ());
  }
}

- (void) delayedUpdate
{
  inWindowUpdate = YES;
  NSMutableArray *arr = delayed_rects;
  delayed_rects = [[NSMutableArray arrayWithCapacity:10] retain];
  for (TMRect *anObject in arr)
    [self setNeedsDisplayInRect: [anObject rect]];
  [arr release];
  [self display];
  inWindowUpdate = NO;
}

- (void)drawRect:(NSRect)rect 
{
  BOOL beenInterrupted = NO;
  if (inWindowUpdate) {
	// Drawing code here.
	if ([self inLiveResize])
	{
		NSRect bounds = [self bounds];
		[[NSColor blackColor] set];
		[NSBezierPath strokeRect: NSInsetRect(bounds,1,1)];
		//    return;
	}
//	debug_events << "DRAWING : " << rect.origin.x << ","<< rect.origin.x << ","<< rect.size.width<< "," << rect.size.height <<  "\n";
//	NSRect bounds = [self bounds];
	
  {
    ns_renderer_rep* r = the_ns_renderer ();
    int x1 = rect.origin.x;
    int y1 = rect.origin.y+rect.size.height;
    int x2 = rect.origin.x+rect.size.width;
    int y2 = rect.origin.y;
    
    r -> begin ([NSGraphicsContext currentContext]);
    r -> view = self;
    r -> set_origin (0,0);
    r -> encode (x1,y1);
    r -> encode (x2,y2);
 //    debug_events << "DRAWING RECT " << x1 << "," << y1 << "," << x2 << "," << y2 << LF;
    r -> set_clipping (x1, y1, x2, y2);
    wid->handle_repaint (r, x1, y1, x2, y2);
    r -> end ();
    if (gui_interrupted ()) beenInterrupted = YES;
  }
  }
  if (beenInterrupted || !inWindowUpdate)
    [delayed_rects addObject: [[[TMRect alloc] initWithRect:rect] autorelease]];
//	debug_events << "END DRAWING" << "\n";
}

#if 0
- (void)keyDown:(NSEvent *)theEvent
{
  if (!wid) return;
  
  {
    char str[256];
    string r;
    NSString *nss = [theEvent charactersIgnoringModifiers];
    unsigned int mods = [theEvent modifierFlags];
    
    
    
    if (([nss length]==1)&& (!processingCompose))
      
    {
      int key = [nss characterAtIndex:0];
      if (nskeymap->contains(key)) {
        r = nskeymap[key];
        r = ((mods & NSShiftKeyMask)? "S-" * r: r);
      }
      else
      {
        [nss getCString:str maxLength:256 encoding:NSUTF8StringEncoding];
        string rr (str, strlen(str));
        r= utf8_to_cork (rr);          
      } 
      
      
      string s (r);
      if (! contains_unicode_char (s))     
      {
        //      string s= ((mods & NSShiftKeyMask)? "S-" * r: r);
        /* other keyboard modifiers */
        if (N(s)!=0) {
          if (mods & NSControlKeyMask ) s= "C-" * s;
          if (mods & NSAlternateKeyMask) s= "A-" * s;
          if (mods & NSCommandKeyMask) s= "M-" * s;
          // if (mods & NSNumericPadKeyMask) s= "K-" * s;
	  // if (mods & NSHelpKeyMask) s= "H-" * s;
          // if (mods & NSFunctionKeyMask) s= "F-" * s;
        }
        if (DEBUG_EVENT)
          debug_events << "key press: " << s << LF;
        wid -> handle_keypress (s, texmacs_time());    
      }
    }
    else {
      processingCompose = YES;
      static NSMutableArray *nsEvArray = nil;
      if (nsEvArray == nil)
        nsEvArray = [[NSMutableArray alloc] initWithCapacity: 1];
      
      [nsEvArray addObject: theEvent];
      [self interpretKeyEvents: nsEvArray];
      [nsEvArray removeObject: theEvent];
    }
  }	
  
  
}
#else
- (void)keyDown:(NSEvent *)theEvent
{
  if (!wid) return;

  time_credit= 25;
  timeout_time= texmacs_time () + time_credit;
  static bool fInit = false;
  if (!fInit) {
    if (DEBUG_EVENTS)
      debug_events << "Initializing keymap\n";
    initkeymap ();
    fInit = true;
  }
  
  {
    // char str[256];
    string r;
    NSString *nss = [theEvent charactersIgnoringModifiers];
    unsigned int mods = [theEvent modifierFlags];
    
    string modstr;
    
    if (mods & NSControlKeyMask ) modstr= "C-" * modstr;
    if (mods & NSAlternateKeyMask) modstr= "A-" * modstr;
    if (mods & NSCommandKeyMask) modstr= "M-" * modstr;
    // if (mods & NSNumericPadKeyMask) modstr= "K-" * modstr;
    // if (mods & NSHelpKeyMask) modstr= "H-" * modstr;
    // if (mods & NSFunctionKeyMask) modstr= "F-" * modstr;
    
    //    if (!processingCompose)
    {
      if ([nss length]>0) {
        int key = [nss characterAtIndex:0];
        if (nskeymap->contains(key)) {
          r = nskeymap[key];
          r = ((mods & NSShiftKeyMask)? "S-" * modstr: modstr) * r;
          if (DEBUG_EVENTS)
            debug_events << "function key press: " << r << LF;
          [self deleteWorkingText];
          wid->handle_keypress (r, texmacs_time());
          return;
        } else if (mods & (NSControlKeyMask  | NSCommandKeyMask | NSHelpKeyMask))
        {
          static char str[256];
          [nss getCString:str maxLength:256 encoding:NSUTF8StringEncoding];
          string rr (str, strlen(str));
          r= utf8_to_cork (rr);          
          
          string s ( modstr * r);
          if (DEBUG_EVENTS)
            debug_events << "modified  key press: " << s << LF;
          [self deleteWorkingText];
          wid->handle_keypress (s, texmacs_time());
          the_gui->update (); // FIXME: remove this line when
          // edit_typeset_rep::get_env_value will be faster

          return;
        }
      }
    }
    
    processingCompose = YES;
    static NSMutableArray *nsEvArray = nil;
    if (nsEvArray == nil)
      nsEvArray = [[NSMutableArray alloc] initWithCapacity: 1];
    
    [nsEvArray addObject: theEvent];
    [self interpretKeyEvents: nsEvArray];
    [nsEvArray removeObject: theEvent];
  }
}

#endif

static unsigned int
mouse_state (NSEvent* event, bool flag) {
  unsigned int i= 0;
  i += 1 << min([event buttonNumber],4);
  unsigned int mods = [event modifierFlags];
  if (mods & NSAlternateKeyMask) i = 2;  
  if (mods & NSCommandKeyMask) i = 4;  
  if (mods & NSShiftKeyMask) i += 256;  
  if (mods & NSControlKeyMask) i += 2048;  
  return i;
}

static string
mouse_decode (unsigned int mstate) {
  if      (mstate & 1 ) return "left";
  else if (mstate & 2 ) return "middle";
  else if (mstate & 4 ) return "right";
  else if (mstate & 8 ) return "up";
  else if (mstate & 16) return "down";
  return "unknown";
}

- (void)mouseDown:(NSEvent *)theEvent
{
  if (wid) {
    NSPoint point = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	scale(point);
    unsigned int mstate= mouse_state (theEvent, false);
    string s= "press-" * mouse_decode (mstate);
    wid->handle_mouse (s, point.x , point.y , mstate, texmacs_time ());
    if (DEBUG_EVENTS)
      debug_events << "mouse event: " << s << " at "
      << point.x << ", " << point.y  << LF;
  }
}

- (void)mouseUp:(NSEvent *)theEvent
{
  if (wid) {
    NSPoint point = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	scale(point);
    unsigned int mstate= mouse_state (theEvent, true);
    string s= "release-" * mouse_decode (mstate);
    wid->handle_mouse (s, point.x , point.y , mstate, texmacs_time ());
    if (DEBUG_EVENTS)
      debug_events << "mouse event: " << s << " at "
      << point.x  << ", " << point.y  << LF;
  }
}

- (void)mouseDragged:(NSEvent *)theEvent
{
  if (wid) {
    NSPoint point = [self convertPoint:[theEvent locationInWindow] fromView:nil];
		scale(point);
    unsigned int mstate= mouse_state (theEvent, false);
    string s= "move";
    wid->handle_mouse (s, point.x , point.y , mstate, texmacs_time ());
    if (DEBUG_EVENTS)
      debug_events << "mouse event: " << s << " at "
      << point.x  << ", " << point.y  << LF;
  }  
}

- (void)mouseMoved:(NSEvent *)theEvent
{
  if (wid) {
    NSPoint point = [self convertPoint:[theEvent locationInWindow] fromView:nil];
		scale(point);
    unsigned int mstate= mouse_state (theEvent, false);
    string s= "move";
    wid->handle_mouse (s, point.x , point.y , mstate, texmacs_time ());
    if (DEBUG_EVENTS)
      debug_events << "mouse event: " << s << " at "
      << point.x  << ", " << point.y  << LF;
  }  
}

- (BOOL)isFlipped
{
  return YES;
}

- (BOOL)isOpaque
{
  return YES;
}

- (void)resizeWithOldSuperviewSize:(NSSize)oldBoundsSize
{
  [super resizeWithOldSuperviewSize:oldBoundsSize];
  if (wid)  {
    NSSize size = [self bounds].size;
    scaleSize (size);
    wid->handle_notify_resize (size.width, size.height);
  }
}

- (BOOL)acceptsFirstResponder
{
	return YES;
}

- (void) deleteWorkingText
{ 
  if (workingText == nil) return;
  [workingText release];
  workingText = nil;
  processingCompose = NO;
}

#pragma mark NSTextInput protocol implementation

- (void) insertText:(id)aString
// instead of keyDown: aString can be NSString or NSAttributedString
{
  processingCompose = NO;
//  NSLog(@"insertText: <%@>",aString);
  
  NSString *str = [aString respondsToSelector: @selector(string)] ?
  [aString string] : aString;
  
  static char buf[256];
  for(unsigned int i=0; i<[str length]; i++) {
    [[str substringWithRange:NSMakeRange(i, 1)] getCString:buf maxLength:256 encoding:NSUTF8StringEncoding];
    string rr (buf, strlen(buf));
    string s= utf8_to_cork (rr);
    if (DEBUG_EVENTS)
      debug_events << "key press: " << s << LF;
    wid->handle_keypress (s, texmacs_time());        
  }
}

- (void) doCommandBySelector:(SEL)aSelector
{
}

// setMarkedText: cannot take a nil first argument. aString can be NSString or NSAttributedString
- (void) setMarkedText:(id)aString selectedRange:(NSRange)selRange
{
  NSString *str = [aString respondsToSelector: @selector(string)] ?
  [aString string] : aString;
  
  if (workingText != nil)
    [self deleteWorkingText];
  if ([str length] == 0)
    return;
  workingText = [str copy];
  processingCompose = YES;
  NSLog(@"setMarkedText: <%@>",workingText);
  
}

- (void) unmarkText
{
  [self deleteWorkingText];  
}

- (BOOL) hasMarkedText
{
  return workingText != nil;
  
}

- (NSInteger) conversationIdentifier
{
  return (NSInteger)self;
}

/* Returns attributed string at the range.  This allows input mangers to query any range in backing-store.  May return nil.
 */
- (NSAttributedString *) attributedSubstringFromRange:(NSRange)theRange
{
  static NSAttributedString *str = nil;
  if (str == nil) str = [NSAttributedString new];
  return str;
}

/* This method returns the range for marked region.  If hasMarkedText == false, it'll return NSNotFound location & 0 length range.
 */
- (NSRange) markedRange
{
  NSRange rng = workingText != nil
  ? NSMakeRange(0, [workingText length]) : NSMakeRange(NSNotFound, 0);
  return rng;
  
}

/* This method returns the range for selected region.  Just like markedRange method, its location field contains char index from the text beginning.
 */
- (NSRange) selectedRange
{
  return NSMakeRange(NSNotFound, 0);
}
/* This method returns the first frame of rects for theRange in screen coordindate system.
 */
- (NSRect) firstRectForCharacterRange:(NSRange)theRange
{
  return NSMakeRect(0,0,50,50);
}

/* This method returns the index for character that is nearest to thePoint.  thePoint is in screen coordinate system.
 */
- (NSUInteger)characterIndexForPoint:(NSPoint)thePoint
{
  return 0;
}

/* This method is the key to attribute extension.  We could add new attributes through this method. NSInputServer examines the return value of this method & constructs appropriate attributed string.
 */
- (NSArray*) validAttributesForMarkedText
{
  static NSArray *arr = nil;
  if (arr == nil) arr = [NSArray new];
  return arr;
}


@end


#pragma mark TMCenteringClipView


@implementation TMCenteringClipView

// ----------------------------------------

-(void)centerDocument
{
  NSRect docRect = [[self documentView] frame];
  NSRect clipRect = [self bounds];
  
  // The origin point should have integral values or drawing anomalies will occur.
  // We'll leave it to the constrainScrollPoint: method to do it for us.
  if( docRect.size.width < clipRect.size.width )
    clipRect.origin.x = ( docRect.size.width - clipRect.size.width ) / 2.0;
  else
    clipRect.origin.x = _lookingAt.x * docRect.size.width - ( clipRect.size.width / 2.0 );
  
  if( docRect.size.height < clipRect.size.height )
    clipRect.origin.y = ( docRect.size.height - clipRect.size.height ) / 2.0;
  else
    clipRect.origin.y = _lookingAt.y * docRect.size.height - ( clipRect.size.height / 2.0 );
  
  // Probably the best way to move the bounds origin.
  // Make sure that the scrollToPoint contains integer values
  // or the NSView will smear the drawing under certain circumstances.
  
  [self scrollToPoint:[self constrainScrollPoint:clipRect.origin]];
  [[self superview] reflectScrolledClipView:self];
  
  // We could use this instead since it allows a scroll view
  // to coordinate scrolling between multiple clip views.
  // [[self superview] scrollClipView:self toPoint:[self constrainScrollPoint:clipRect.origin]];
}

// ----------------------------------------
// We need to override this so that the superclass doesn't override our new origin point.

-(NSPoint)constrainScrollPoint:(NSPoint)proposedNewOrigin
{
  NSRect docRect = [[self documentView] frame];
  NSRect clipRect = [self bounds];
  float maxX = docRect.size.width - clipRect.size.width;
  float maxY = docRect.size.height - clipRect.size.height;
  
  clipRect.origin = proposedNewOrigin; // shift origin to proposed location
  
  // If the clip view is wider than the doc, we can't scroll horizontally
  if( docRect.size.width < clipRect.size.width )
    clipRect.origin.x = round( maxX / 2.0 );
  else
    clipRect.origin.x = round( MAX(0,MIN(clipRect.origin.x,maxX)) );
  
  // If the clip view is taller than the doc, we can't scroll vertically
  if( docRect.size.height < clipRect.size.height )
    clipRect.origin.y = round( maxY / 2.0 );
  else
    clipRect.origin.y = round( MAX(0,MIN(clipRect.origin.y,maxY)) );
  
  // Save center of view as proportions so we can later tell where the user was focused.
  _lookingAt.x = NSMidX(clipRect) / docRect.size.width;
  _lookingAt.y = NSMidY(clipRect) / docRect.size.height;
  
  return clipRect.origin;
}

// ----------------------------------------
// These two methods get called whenever the NSClipView's subview changes.
// We save the old center of interest, call the superclass to let it do its work,
// then move the scroll point to try and put the old center of interest
// back in the center of the view if possible.

-(void)viewBoundsChanged:(NSNotification *)notification
{
  NSPoint savedPoint = _lookingAt;
  [super viewBoundsChanged:notification];
  _lookingAt = savedPoint;
  [self centerDocument];
}

-(void)viewFrameChanged:(NSNotification *)notification
{
  NSPoint savedPoint = _lookingAt;
  [super viewFrameChanged:notification];
  _lookingAt = savedPoint;
  [self centerDocument];
}

// ----------------------------------------
// These NSClipView superclass methods change the bounds rect
// directly without sending any notifications,
// so we're not sure what other work they silently do for us.
// As a result, we let them do their
// work and then swoop in behind to change the bounds origin ourselves.
// This appears to work just fine without us having to
// reinvent the methods from scratch.
// ---
// Even though an NSView posts an NSViewFrameDidChangeNotification to the default notification center
// if it's configured to do so, NSClipViews appear to be configured not to. The methods
// setPostsFrameChangedNotifications: and setPostsBoundsChangedNotifications: appear
// to be configured not to send notifications.
// ---
// We have some redundancy in the fact that setFrame: appears to call/send setFrameOrigin:
// and setFrameSize: to do its work, but we need to override these individual methods in case
// either one gets called independently. Because none of them explicitly cause a screen update,
// it's ok to do a little extra work behind the scenes because it wastes very little time.
// It's probably the result of a single UI action anyway so it's not like it's slowing
// down a huge iteration by being called thousands of times.

-(void)setFrame:(NSRect)frameRect
{
  [super setFrame:frameRect];
  [self centerDocument];
}

-(void)setFrameOrigin:(NSPoint)newOrigin
{
  [super setFrameOrigin:newOrigin];
  [self centerDocument];
}

-(void)setFrameSize:(NSSize)newSize
{
  [super setFrameSize:newSize];
  [self centerDocument];
}

-(void)setFrameRotation:(float)angle
{
  [super setFrameRotation:angle];
  [self centerDocument];
}

@end

