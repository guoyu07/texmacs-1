//
//  ns_ui_element.m
//  TeXmacs
//
//  Created by Massimiliano Gubinelli on 15/07/16.
//  Copyright © 2016 TeXmacs.org. All rights reserved.
//

#include "ns_ui_element.h"
#include "ns_utilities.h"
#include "ns_renderer.h"

#include "promise.hpp"

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
      float spacing = 0.0;
      for (int i = 0; i < N(arr); i++) {
        if (is_nil (arr[i])) break;
        NSView* item = concrete (arr[i])->as_view ();
        [v addSubview: item];
        [[item topAnchor] constraintEqualToAnchor: yanchor constant: spacing];
        [[item leadingAnchor] constraintEqualToAnchor:lanchor];
        [[item trailingAnchor] constraintEqualToAnchor:ranchor];
        yanchor = [item bottomAnchor];
      }
      [yanchor constraintEqualToAnchor: [v bottomAnchor]];
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
      float spacing = 0.0;
      for (int i = 0; i < N(arr); i++) {
        if (is_nil (arr[i])) break;
        NSView* item = concrete (arr[i])->as_view ();
        [v addSubview: item];
        [[item leadingAnchor] constraintEqualToAnchor: xanchor constant: spacing];
        [[item topAnchor] constraintEqualToAnchor:tanchor];
        [[item bottomAnchor] constraintEqualToAnchor:banchor];
        xanchor = [item trailingAnchor];
      }
      [xanchor constraintEqualToAnchor: [v trailingAnchor]];
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
      NSLayoutXAxisAnchor *lanchor = [v leadingAnchor];
      NSLayoutYAxisAnchor *tanchor = [v topAnchor];
      NSLayoutDimension *wanchor = nil;
      NSLayoutDimension *hanchor = nil;
      
      int row= 0, col= 0;
      for (int i=0; i < N(a); i++) {
        NSView* item = concrete(a[i])->as_view ();
        [v addSubview: item];
        if (!wanchor)
          wanchor = [item widthAnchor];
        else
          [[item widthAnchor] constraintEqualToAnchor: wanchor];
        if (!hanchor)
          wanchor = [item widthAnchor];
        else
          [[item heightAnchor] constraintEqualToAnchor: hanchor];
        [[item topAnchor] constraintEqualToAnchor:tanchor];
        [[item leadingAnchor] constraintEqualToAnchor:lanchor];
        lanchor = [item trailingAnchor];
        col++;
        if (col >= cols) {
          col = 0; row++;
          tanchor = [item bottomAnchor];
          lanchor = [v leadingAnchor];
        }
      }
    }
      
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
//      qt_apply_tm_style (qwid, style);
      
      QSize minSize = qt_decode_length (widths.x1, heights.x1,
                                        qwid->minimumSizeHint(),
                                        qwid->fontMetrics());
      QSize defSize = qt_decode_length (widths.x2, heights.x2,
                                        qwid->minimumSizeHint(),
                                        qwid->fontMetrics());
      QSize maxSize = qt_decode_length (widths.x3, heights.x3,
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
        TMLazyMenu* menu = [[[TMLazyMenu alloc] init] autorelease];
        [menu setPromise: pw.rep];
        [b setMenu: menu];
        [b setImage: the_ns_renderer()->xpm_image(image)];
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
        // qt_apply_tm_style (b, y.x2, y.x3);
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
      
      ns_ui_element_rep *w = dynamic_cast<ns_ui_element_rep*>(_w.rep);

      if (w->type == xpm_widget) {  // Toolbar button
        QAction*     a = as_qaction();        // Create key shortcuts and actions
        QToolButton* b = new QToolButton ();
        b->setIcon (a->icon());
        b->setPopupMode (QToolButton::InstantPopup);
        b->setAutoRaise (true);
        b->setDefaultAction (a);
        a->setParent (b);
        qwid = b;
      } else { // text_widget
        QPushButton*     b = new QPushButton();
        QTMCommand* qtmcmd = new QTMCommand (b, cmd);
        QObject::connect (b, SIGNAL (clicked ()), qtmcmd, SLOT (apply ()));
        if (qtw->type == text_widget) {
          typedef quartet<string, int, color, bool> T1;
          b->setText (to_qstring (open_box<T1> (get_payload (qtw)).x1));
        }
        b->setFlat (! (style & WIDGET_STYLE_BUTTON));
        qwid = b;
      }
      qwid->setStyle (qtmstyle());
      qt_apply_tm_style (qwid, style);
      qwid->setEnabled (! (style & WIDGET_STYLE_INERT));
    }
      break;
      
      // given a button widget w, specify a help balloon which should be displayed
      // when the user leaves the mouse pointer on the button for a small while
    case balloon_widget:
    {
      typedef pair<widget, widget> T;
      T            x = open_box<T>(load);
      qt_widget  qtw = concrete (x.x1);
      qt_widget help = concrete (x.x2);
      
      typedef quartet<string, int, color, bool> T1;
      T1 y = open_box<T1>(get_payload (help, text_widget));
      QWidget* w = qtw->as_qwidget();
      w->setToolTip (to_qstring (y.x1));
      qwid = w;
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
      
      QLabel* w = new QLabel();
      /*
       //FIXME: implement refresh when changing language
       QTMAction* a= new QTMAction (NULL);
       a->set_text (str);
       */
      w->setText (to_qstring (str));
      w->setSizePolicy (QSizePolicy::Fixed, QSizePolicy::Fixed);
      // Workaround too small sizeHint() when the text has letters with descent:
      w->setMinimumHeight (w->fontMetrics().height());
      w->setFocusPolicy (Qt::NoFocus);
      
      qt_apply_tm_style (w, style, c);
      qwid = w;
    }
      break;
      
      // a widget with an X pixmap icon
    case xpm_widget:
    {
      url image = open_box<url>(load);
      QLabel* l = new QLabel (NULL);
      l->setPixmap (as_pixmap (*xpm_image (image)));
      qwid = l;
    }
      break;
      
    case toggle_widget:
    {
      typedef triple<command, bool, int > T;
      T         x = open_box<T>(load);
      command cmd = x.x1;
      bool  check = x.x2;
      int   style = x.x3;
      
      QCheckBox* w  = new QCheckBox (NULL);
      w->setCheckState (check ? Qt::Checked : Qt::Unchecked);
      qt_apply_tm_style (w, style);
      
      command tcmd = tm_new<qt_toggle_command_rep> (w, cmd);
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
      
      qt_apply_tm_style (w, style);
      
      command  ecmd = tm_new<qt_enum_command_rep> (w, cmd);
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
      qt_widget wid = concrete (x.x1);
      int     style = x.x2;
      
      QTMScrollArea* w = new QTMScrollArea();
      w->setWidgetAndConnect (wid->as_qwidget());
      w->setWidgetResizable (true);
      
      qt_apply_tm_style (w, style);
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
      qt_widget w1 = concrete(x.x1);
      qt_widget w2 = concrete(x.x2);
      
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
      
    default:
      qwid = NULL;
  }
  
  //qwid->setFocusPolicy (Qt::StrongFocus); // Bad idea: containers get focus
  if (qwid->objectName().isEmpty())
    qwid->setObjectName (to_qstring (type_as_string()));
  return qwid;
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
      // an horizontal list made up of the widgets in arr
    {
      typedef array<widget> T;
      array<widget> arr = open_box<T> (load);
      //FIXME: horizontal_list
      debug_aqua << "horizontal_list\n";
      //act = new QTMMinibarAction (arr);
    }
      break;
      
    case aligned_widget:
      //  a table with two columns FIXME!!!!
    {
      typedef triple<array<widget>, array<widget>, coord4 > T;
      T x = open_box<T>(load);
      array<widget> lhs = x.x1;
      array<widget> rhs = x.x2;
      
      if (N(lhs) != N(rhs)) FAILED("aligned_widget: N(lhs) != N(rhs) ");
      
      array<widget> wids(N(lhs)*3);
      for (int i=0; i < N(lhs); ++i) {
        wids[3*i]   = lhs[i];
        wids[3*i+1] = rhs[i];
        wids[3*i+2] = ::glue_widget(false, true, 1, 1);
      }
      //FIXME: aligned_widget
      debug_aqua << "aligned_widget\n";
      //act = new QTMMinibarAction (wids);
    }
      break;
      
    case tile_menu:
      // a menu rendered as a table of "cols" columns & made up of the widgets
      // in array a
    {
      typedef pair<array<widget>, int> T;
      T             x = open_box<T>(load);
      array<widget> a = x.x1;
      int        cols = x.x2;
      //FIXME: tile_menu
      debug_aqua << "tile_menu\n";
      //act = new QTMTileAction (a, cols);
    }
      break;
      
    case minibar_menu:
    {
      typedef array<widget> T;
      array<widget> arr = open_box<T> (load);
      
      //FIXME: minibar_menu
      debug_aqua << "minibar_menu\n";
//      act = new QTMMinibarAction (arr);
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
      [mi setEnabled: NO];
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
      [mi setTitle: to_nsstring(name)];
      [mi setEnabled: NO];
      //FIXME: set font
      //act->setFont (to_qfont (style, act->font()));
    }
      break;
      
    case pulldown_button:
    case pullright_button:
      // a button w with a lazy pulldown menu pw
    {
      typedef pair<widget, promise<widget> > T;
      T                x = open_box<T> (load);
      ns_widget      qtw = concrete (x.x1);
      promise<widget> pw = x.x2;
      
      mi = qtw->as_menuitem ();
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

      if (typeid(*(w.rep)) == typeid(simple_widget_rep)) {
        mi = [[[TMMenuItem alloc] init] autorelease];
        [mi setWidget:(ns_simple_widget_rep*)(((simple_widget_rep*)w.rep)->get_impl().rep)];
      } else  {
        mi = ((ns_widget_rep*)w.rep)->as_menuitem();
      }
    
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
      ns_widget  qtw = concrete (x.x1);
      ns_widget help = concrete (x.x2);
    
      mi = qtw->as_menuitem ();
      {
        typedef quartet<string, int, color, bool> T1;
        T1 y = open_box<T1> (load);
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
      [mi setTitle: to_nsstring(str)];
      //FIXME: set font
//      a->setFont (to_qfont (style, a->font()));
    }
      break;
      
    case xpm_widget:
      // a widget with an X pixmap icon
    {
      url    image = open_box<url>(load);
      mi = [[[TMMenuItem alloc] init] autorelease];
      [mi setImage: the_ns_renderer()->xpm_image(image)];
    }
      break;
      
    default:
      debug_aqua << "failed ns_ui_element_rep::as_menuitem, using an empty object.\n";
      mi = [[[TMMenuItem alloc] init] autorelease];
  }
  
  return mi;
}
