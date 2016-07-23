
/******************************************************************************
*
* This file has been generated automatically using build-glue.scm
* from build-glue-server.scm. Please do not edit its contents.
* Copyright (C) 2000 Joris van der Hoeven
*
* This software falls under the GNU general public license version 3 or later.
* It comes WITHOUT ANY WARRANTY WHATSOEVER. For details, see the file LICENSE
* in the root directory or <http://www.gnu.org/licenses/gpl-3.0.html>.
*
******************************************************************************/

tmscm
tmg_insert_kbd_wildcard (tmscm arg1, tmscm arg2, tmscm arg3, tmscm arg4, tmscm arg5) {
  TMSCM_ASSERT_STRING (arg1, TMSCM_ARG1, "insert-kbd-wildcard");
  TMSCM_ASSERT_STRING (arg2, TMSCM_ARG2, "insert-kbd-wildcard");
  TMSCM_ASSERT_BOOL (arg3, TMSCM_ARG3, "insert-kbd-wildcard");
  TMSCM_ASSERT_BOOL (arg4, TMSCM_ARG4, "insert-kbd-wildcard");
  TMSCM_ASSERT_BOOL (arg5, TMSCM_ARG5, "insert-kbd-wildcard");

  string in1= tmscm_to_string (arg1);
  string in2= tmscm_to_string (arg2);
  bool in3= tmscm_to_bool (arg3);
  bool in4= tmscm_to_bool (arg4);
  bool in5= tmscm_to_bool (arg5);

  // TMSCM_DEFER_INTS;
  get_server()->insert_kbd_wildcard (in1, in2, in3, in4, in5);
  // TMSCM_ALLOW_INTS;

  return TMSCM_UNSPECIFIED;
}

tmscm
tmg_set_variant_keys (tmscm arg1, tmscm arg2) {
  TMSCM_ASSERT_STRING (arg1, TMSCM_ARG1, "set-variant-keys");
  TMSCM_ASSERT_STRING (arg2, TMSCM_ARG2, "set-variant-keys");

  string in1= tmscm_to_string (arg1);
  string in2= tmscm_to_string (arg2);

  // TMSCM_DEFER_INTS;
  get_server()->set_variant_keys (in1, in2);
  // TMSCM_ALLOW_INTS;

  return TMSCM_UNSPECIFIED;
}

tmscm
tmg_kbd_pre_rewrite (tmscm arg1) {
  TMSCM_ASSERT_STRING (arg1, TMSCM_ARG1, "kbd-pre-rewrite");

  string in1= tmscm_to_string (arg1);

  // TMSCM_DEFER_INTS;
  string out= get_server()->kbd_pre_rewrite (in1);
  // TMSCM_ALLOW_INTS;

  return string_to_tmscm (out);
}

tmscm
tmg_kbd_post_rewrite (tmscm arg1, tmscm arg2) {
  TMSCM_ASSERT_STRING (arg1, TMSCM_ARG1, "kbd-post-rewrite");
  TMSCM_ASSERT_BOOL (arg2, TMSCM_ARG2, "kbd-post-rewrite");

  string in1= tmscm_to_string (arg1);
  bool in2= tmscm_to_bool (arg2);

  // TMSCM_DEFER_INTS;
  string out= get_server()->kbd_post_rewrite (in1, in2);
  // TMSCM_ALLOW_INTS;

  return string_to_tmscm (out);
}

tmscm
tmg_kbd_system_rewrite (tmscm arg1) {
  TMSCM_ASSERT_STRING (arg1, TMSCM_ARG1, "kbd-system-rewrite");

  string in1= tmscm_to_string (arg1);

  // TMSCM_DEFER_INTS;
  tree out= get_server()->kbd_system_rewrite (in1);
  // TMSCM_ALLOW_INTS;

  return tree_to_tmscm (out);
}

tmscm
tmg_set_font_rules (tmscm arg1) {
  TMSCM_ASSERT_SCHEME_TREE (arg1, TMSCM_ARG1, "set-font-rules");

  scheme_tree in1= tmscm_to_scheme_tree (arg1);

  // TMSCM_DEFER_INTS;
  get_server()->set_font_rules (in1);
  // TMSCM_ALLOW_INTS;

  return TMSCM_UNSPECIFIED;
}

tmscm
tmg_window_get_serial () {
  // TMSCM_DEFER_INTS;
  int out= get_server()->get_window_serial ();
  // TMSCM_ALLOW_INTS;

  return int_to_tmscm (out);
}

tmscm
tmg_window_set_property (tmscm arg1, tmscm arg2) {
  TMSCM_ASSERT_SCHEME_TREE (arg1, TMSCM_ARG1, "window-set-property");
  TMSCM_ASSERT_SCHEME_TREE (arg2, TMSCM_ARG2, "window-set-property");

  scheme_tree in1= tmscm_to_scheme_tree (arg1);
  scheme_tree in2= tmscm_to_scheme_tree (arg2);

  // TMSCM_DEFER_INTS;
  get_server()->set_window_property (in1, in2);
  // TMSCM_ALLOW_INTS;

  return TMSCM_UNSPECIFIED;
}

tmscm
tmg_window_get_property (tmscm arg1) {
  TMSCM_ASSERT_SCHEME_TREE (arg1, TMSCM_ARG1, "window-get-property");

  scheme_tree in1= tmscm_to_scheme_tree (arg1);

  // TMSCM_DEFER_INTS;
  scheme_tree out= get_server()->get_window_property (in1);
  // TMSCM_ALLOW_INTS;

  return scheme_tree_to_tmscm (out);
}

tmscm
tmg_show_header (tmscm arg1) {
  TMSCM_ASSERT_BOOL (arg1, TMSCM_ARG1, "show-header");

  bool in1= tmscm_to_bool (arg1);

  // TMSCM_DEFER_INTS;
  get_server()->show_header (in1);
  // TMSCM_ALLOW_INTS;

  return TMSCM_UNSPECIFIED;
}

tmscm
tmg_show_icon_bar (tmscm arg1, tmscm arg2) {
  TMSCM_ASSERT_INT (arg1, TMSCM_ARG1, "show-icon-bar");
  TMSCM_ASSERT_BOOL (arg2, TMSCM_ARG2, "show-icon-bar");

  int in1= tmscm_to_int (arg1);
  bool in2= tmscm_to_bool (arg2);

  // TMSCM_DEFER_INTS;
  get_server()->show_icon_bar (in1, in2);
  // TMSCM_ALLOW_INTS;

  return TMSCM_UNSPECIFIED;
}

tmscm
tmg_show_side_tools (tmscm arg1, tmscm arg2) {
  TMSCM_ASSERT_INT (arg1, TMSCM_ARG1, "show-side-tools");
  TMSCM_ASSERT_BOOL (arg2, TMSCM_ARG2, "show-side-tools");

  int in1= tmscm_to_int (arg1);
  bool in2= tmscm_to_bool (arg2);

  // TMSCM_DEFER_INTS;
  get_server()->show_side_tools (in1, in2);
  // TMSCM_ALLOW_INTS;

  return TMSCM_UNSPECIFIED;
}

tmscm
tmg_show_bottom_tools (tmscm arg1, tmscm arg2) {
  TMSCM_ASSERT_INT (arg1, TMSCM_ARG1, "show-bottom-tools");
  TMSCM_ASSERT_BOOL (arg2, TMSCM_ARG2, "show-bottom-tools");

  int in1= tmscm_to_int (arg1);
  bool in2= tmscm_to_bool (arg2);

  // TMSCM_DEFER_INTS;
  get_server()->show_bottom_tools (in1, in2);
  // TMSCM_ALLOW_INTS;

  return TMSCM_UNSPECIFIED;
}

tmscm
tmg_show_footer (tmscm arg1) {
  TMSCM_ASSERT_BOOL (arg1, TMSCM_ARG1, "show-footer");

  bool in1= tmscm_to_bool (arg1);

  // TMSCM_DEFER_INTS;
  get_server()->show_footer (in1);
  // TMSCM_ALLOW_INTS;

  return TMSCM_UNSPECIFIED;
}

tmscm
tmg_visible_headerP () {
  // TMSCM_DEFER_INTS;
  bool out= get_server()->visible_header ();
  // TMSCM_ALLOW_INTS;

  return bool_to_tmscm (out);
}

tmscm
tmg_visible_icon_barP (tmscm arg1) {
  TMSCM_ASSERT_INT (arg1, TMSCM_ARG1, "visible-icon-bar?");

  int in1= tmscm_to_int (arg1);

  // TMSCM_DEFER_INTS;
  bool out= get_server()->visible_icon_bar (in1);
  // TMSCM_ALLOW_INTS;

  return bool_to_tmscm (out);
}

tmscm
tmg_visible_side_toolsP (tmscm arg1) {
  TMSCM_ASSERT_INT (arg1, TMSCM_ARG1, "visible-side-tools?");

  int in1= tmscm_to_int (arg1);

  // TMSCM_DEFER_INTS;
  bool out= get_server()->visible_side_tools (in1);
  // TMSCM_ALLOW_INTS;

  return bool_to_tmscm (out);
}

tmscm
tmg_visible_bottom_toolsP (tmscm arg1) {
  TMSCM_ASSERT_INT (arg1, TMSCM_ARG1, "visible-bottom-tools?");

  int in1= tmscm_to_int (arg1);

  // TMSCM_DEFER_INTS;
  bool out= get_server()->visible_bottom_tools (in1);
  // TMSCM_ALLOW_INTS;

  return bool_to_tmscm (out);
}

tmscm
tmg_visible_footerP () {
  // TMSCM_DEFER_INTS;
  bool out= get_server()->visible_footer ();
  // TMSCM_ALLOW_INTS;

  return bool_to_tmscm (out);
}

tmscm
tmg_full_screen_mode (tmscm arg1, tmscm arg2) {
  TMSCM_ASSERT_BOOL (arg1, TMSCM_ARG1, "full-screen-mode");
  TMSCM_ASSERT_BOOL (arg2, TMSCM_ARG2, "full-screen-mode");

  bool in1= tmscm_to_bool (arg1);
  bool in2= tmscm_to_bool (arg2);

  // TMSCM_DEFER_INTS;
  get_server()->full_screen_mode (in1, in2);
  // TMSCM_ALLOW_INTS;

  return TMSCM_UNSPECIFIED;
}

tmscm
tmg_full_screenP () {
  // TMSCM_DEFER_INTS;
  bool out= get_server()->in_full_screen_mode ();
  // TMSCM_ALLOW_INTS;

  return bool_to_tmscm (out);
}

tmscm
tmg_full_screen_editP () {
  // TMSCM_DEFER_INTS;
  bool out= get_server()->in_full_screen_edit_mode ();
  // TMSCM_ALLOW_INTS;

  return bool_to_tmscm (out);
}

tmscm
tmg_set_window_zoom_factor (tmscm arg1) {
  TMSCM_ASSERT_DOUBLE (arg1, TMSCM_ARG1, "set-window-zoom-factor");

  double in1= tmscm_to_double (arg1);

  // TMSCM_DEFER_INTS;
  get_server()->set_window_zoom_factor (in1);
  // TMSCM_ALLOW_INTS;

  return TMSCM_UNSPECIFIED;
}

tmscm
tmg_get_window_zoom_factor () {
  // TMSCM_DEFER_INTS;
  double out= get_server()->get_window_zoom_factor ();
  // TMSCM_ALLOW_INTS;

  return double_to_tmscm (out);
}

tmscm
tmg_shell (tmscm arg1) {
  TMSCM_ASSERT_STRING (arg1, TMSCM_ARG1, "shell");

  string in1= tmscm_to_string (arg1);

  // TMSCM_DEFER_INTS;
  get_server()->shell (in1);
  // TMSCM_ALLOW_INTS;

  return TMSCM_UNSPECIFIED;
}

tmscm
tmg_dialogue_end () {
  // TMSCM_DEFER_INTS;
  get_server()->dialogue_end ();
  // TMSCM_ALLOW_INTS;

  return TMSCM_UNSPECIFIED;
}

tmscm
tmg_cpp_choose_file (tmscm arg1, tmscm arg2, tmscm arg3, tmscm arg4, tmscm arg5) {
  TMSCM_ASSERT_OBJECT (arg1, TMSCM_ARG1, "cpp-choose-file");
  TMSCM_ASSERT_STRING (arg2, TMSCM_ARG2, "cpp-choose-file");
  TMSCM_ASSERT_STRING (arg3, TMSCM_ARG3, "cpp-choose-file");
  TMSCM_ASSERT_STRING (arg4, TMSCM_ARG4, "cpp-choose-file");
  TMSCM_ASSERT_URL (arg5, TMSCM_ARG5, "cpp-choose-file");

  object in1= tmscm_to_object (arg1);
  string in2= tmscm_to_string (arg2);
  string in3= tmscm_to_string (arg3);
  string in4= tmscm_to_string (arg4);
  url in5= tmscm_to_url (arg5);

  // TMSCM_DEFER_INTS;
  get_server()->choose_file (in1, in2, in3, in4, in5);
  // TMSCM_ALLOW_INTS;

  return TMSCM_UNSPECIFIED;
}

tmscm
tmg_tm_interactive (tmscm arg1, tmscm arg2) {
  TMSCM_ASSERT_OBJECT (arg1, TMSCM_ARG1, "tm-interactive");
  TMSCM_ASSERT_SCHEME_TREE (arg2, TMSCM_ARG2, "tm-interactive");

  object in1= tmscm_to_object (arg1);
  scheme_tree in2= tmscm_to_scheme_tree (arg2);

  // TMSCM_DEFER_INTS;
  get_server()->interactive (in1, in2);
  // TMSCM_ALLOW_INTS;

  return TMSCM_UNSPECIFIED;
}

tmscm
tmg_keyboard_focus_on (tmscm arg1) {
  TMSCM_ASSERT_STRING (arg1, TMSCM_ARG1, "keyboard-focus-on");

  string in1= tmscm_to_string (arg1);

  // TMSCM_DEFER_INTS;
  get_server()->keyboard_focus_on (in1);
  // TMSCM_ALLOW_INTS;

  return TMSCM_UNSPECIFIED;
}

tmscm
tmg_style_clear_cache () {
  // TMSCM_DEFER_INTS;
  get_server()->style_clear_cache ();
  // TMSCM_ALLOW_INTS;

  return TMSCM_UNSPECIFIED;
}

tmscm
tmg_set_script_status (tmscm arg1) {
  TMSCM_ASSERT_INT (arg1, TMSCM_ARG1, "set-script-status");

  int in1= tmscm_to_int (arg1);

  // TMSCM_DEFER_INTS;
  get_server()->set_script_status (in1);
  // TMSCM_ALLOW_INTS;

  return TMSCM_UNSPECIFIED;
}

tmscm
tmg_set_printing_command (tmscm arg1) {
  TMSCM_ASSERT_STRING (arg1, TMSCM_ARG1, "set-printing-command");

  string in1= tmscm_to_string (arg1);

  // TMSCM_DEFER_INTS;
  get_server()->set_printing_command (in1);
  // TMSCM_ALLOW_INTS;

  return TMSCM_UNSPECIFIED;
}

tmscm
tmg_set_printer_paper_type (tmscm arg1) {
  TMSCM_ASSERT_STRING (arg1, TMSCM_ARG1, "set-printer-paper-type");

  string in1= tmscm_to_string (arg1);

  // TMSCM_DEFER_INTS;
  get_server()->set_printer_page_type (in1);
  // TMSCM_ALLOW_INTS;

  return TMSCM_UNSPECIFIED;
}

tmscm
tmg_get_printer_paper_type () {
  // TMSCM_DEFER_INTS;
  string out= get_server()->get_printer_page_type ();
  // TMSCM_ALLOW_INTS;

  return string_to_tmscm (out);
}

tmscm
tmg_set_printer_dpi (tmscm arg1) {
  TMSCM_ASSERT_STRING (arg1, TMSCM_ARG1, "set-printer-dpi");

  string in1= tmscm_to_string (arg1);

  // TMSCM_DEFER_INTS;
  get_server()->set_printer_dpi (in1);
  // TMSCM_ALLOW_INTS;

  return TMSCM_UNSPECIFIED;
}

tmscm
tmg_set_default_zoom_factor (tmscm arg1) {
  TMSCM_ASSERT_DOUBLE (arg1, TMSCM_ARG1, "set-default-zoom-factor");

  double in1= tmscm_to_double (arg1);

  // TMSCM_DEFER_INTS;
  get_server()->set_default_zoom_factor (in1);
  // TMSCM_ALLOW_INTS;

  return TMSCM_UNSPECIFIED;
}

tmscm
tmg_get_default_zoom_factor () {
  // TMSCM_DEFER_INTS;
  double out= get_server()->get_default_zoom_factor ();
  // TMSCM_ALLOW_INTS;

  return double_to_tmscm (out);
}

tmscm
tmg_inclusions_gc () {
  // TMSCM_DEFER_INTS;
  get_server()->inclusions_gc ();
  // TMSCM_ALLOW_INTS;

  return TMSCM_UNSPECIFIED;
}

tmscm
tmg_update_all_path (tmscm arg1) {
  TMSCM_ASSERT_PATH (arg1, TMSCM_ARG1, "update-all-path");

  path in1= tmscm_to_path (arg1);

  // TMSCM_DEFER_INTS;
  get_server()->typeset_update (in1);
  // TMSCM_ALLOW_INTS;

  return TMSCM_UNSPECIFIED;
}

tmscm
tmg_update_all_buffers () {
  // TMSCM_DEFER_INTS;
  get_server()->typeset_update_all ();
  // TMSCM_ALLOW_INTS;

  return TMSCM_UNSPECIFIED;
}

tmscm
tmg_set_message (tmscm arg1, tmscm arg2) {
  TMSCM_ASSERT_CONTENT (arg1, TMSCM_ARG1, "set-message");
  TMSCM_ASSERT_CONTENT (arg2, TMSCM_ARG2, "set-message");

  content in1= tmscm_to_content (arg1);
  content in2= tmscm_to_content (arg2);

  // TMSCM_DEFER_INTS;
  get_server()->set_message (in1, in2);
  // TMSCM_ALLOW_INTS;

  return TMSCM_UNSPECIFIED;
}

tmscm
tmg_set_message_temp (tmscm arg1, tmscm arg2, tmscm arg3) {
  TMSCM_ASSERT_CONTENT (arg1, TMSCM_ARG1, "set-message-temp");
  TMSCM_ASSERT_CONTENT (arg2, TMSCM_ARG2, "set-message-temp");
  TMSCM_ASSERT_BOOL (arg3, TMSCM_ARG3, "set-message-temp");

  content in1= tmscm_to_content (arg1);
  content in2= tmscm_to_content (arg2);
  bool in3= tmscm_to_bool (arg3);

  // TMSCM_DEFER_INTS;
  get_server()->set_message (in1, in2, in3);
  // TMSCM_ALLOW_INTS;

  return TMSCM_UNSPECIFIED;
}

tmscm
tmg_recall_message () {
  // TMSCM_DEFER_INTS;
  get_server()->recall_message ();
  // TMSCM_ALLOW_INTS;

  return TMSCM_UNSPECIFIED;
}

tmscm
tmg_yesP (tmscm arg1) {
  TMSCM_ASSERT_STRING (arg1, TMSCM_ARG1, "yes?");

  string in1= tmscm_to_string (arg1);

  // TMSCM_DEFER_INTS;
  bool out= get_server()->is_yes (in1);
  // TMSCM_ALLOW_INTS;

  return bool_to_tmscm (out);
}

tmscm
tmg_quit_TeXmacs () {
  // TMSCM_DEFER_INTS;
  get_server()->quit ();
  // TMSCM_ALLOW_INTS;

  return TMSCM_UNSPECIFIED;
}

tmscm
tmg_buffer_list () {
  // TMSCM_DEFER_INTS;
  array_url out= get_server()->get_all_buffers ();
  // TMSCM_ALLOW_INTS;

  return array_url_to_tmscm (out);
}

tmscm
tmg_current_buffer_url () {
  // TMSCM_DEFER_INTS;
  url out= get_server()->get_current_buffer_safe ();
  // TMSCM_ALLOW_INTS;

  return url_to_tmscm (out);
}

tmscm
tmg_path_to_buffer (tmscm arg1) {
  TMSCM_ASSERT_PATH (arg1, TMSCM_ARG1, "path-to-buffer");

  path in1= tmscm_to_path (arg1);

  // TMSCM_DEFER_INTS;
  url out= get_server()->path_to_buffer (in1);
  // TMSCM_ALLOW_INTS;

  return url_to_tmscm (out);
}

tmscm
tmg_buffer_new () {
  // TMSCM_DEFER_INTS;
  url out= get_server()->make_new_buffer ();
  // TMSCM_ALLOW_INTS;

  return url_to_tmscm (out);
}

tmscm
tmg_buffer_rename (tmscm arg1, tmscm arg2) {
  TMSCM_ASSERT_URL (arg1, TMSCM_ARG1, "buffer-rename");
  TMSCM_ASSERT_URL (arg2, TMSCM_ARG2, "buffer-rename");

  url in1= tmscm_to_url (arg1);
  url in2= tmscm_to_url (arg2);

  // TMSCM_DEFER_INTS;
  get_server()->rename_buffer (in1, in2);
  // TMSCM_ALLOW_INTS;

  return TMSCM_UNSPECIFIED;
}

tmscm
tmg_buffer_set (tmscm arg1, tmscm arg2) {
  TMSCM_ASSERT_URL (arg1, TMSCM_ARG1, "buffer-set");
  TMSCM_ASSERT_CONTENT (arg2, TMSCM_ARG2, "buffer-set");

  url in1= tmscm_to_url (arg1);
  content in2= tmscm_to_content (arg2);

  // TMSCM_DEFER_INTS;
  get_server()->set_buffer_tree (in1, in2);
  // TMSCM_ALLOW_INTS;

  return TMSCM_UNSPECIFIED;
}

tmscm
tmg_buffer_get (tmscm arg1) {
  TMSCM_ASSERT_URL (arg1, TMSCM_ARG1, "buffer-get");

  url in1= tmscm_to_url (arg1);

  // TMSCM_DEFER_INTS;
  tree out= get_server()->get_buffer_tree (in1);
  // TMSCM_ALLOW_INTS;

  return tree_to_tmscm (out);
}

tmscm
tmg_buffer_set_body (tmscm arg1, tmscm arg2) {
  TMSCM_ASSERT_URL (arg1, TMSCM_ARG1, "buffer-set-body");
  TMSCM_ASSERT_CONTENT (arg2, TMSCM_ARG2, "buffer-set-body");

  url in1= tmscm_to_url (arg1);
  content in2= tmscm_to_content (arg2);

  // TMSCM_DEFER_INTS;
  get_server()->set_buffer_body (in1, in2);
  // TMSCM_ALLOW_INTS;

  return TMSCM_UNSPECIFIED;
}

tmscm
tmg_buffer_get_body (tmscm arg1) {
  TMSCM_ASSERT_URL (arg1, TMSCM_ARG1, "buffer-get-body");

  url in1= tmscm_to_url (arg1);

  // TMSCM_DEFER_INTS;
  tree out= get_server()->get_buffer_body (in1);
  // TMSCM_ALLOW_INTS;

  return tree_to_tmscm (out);
}

tmscm
tmg_buffer_set_master (tmscm arg1, tmscm arg2) {
  TMSCM_ASSERT_URL (arg1, TMSCM_ARG1, "buffer-set-master");
  TMSCM_ASSERT_URL (arg2, TMSCM_ARG2, "buffer-set-master");

  url in1= tmscm_to_url (arg1);
  url in2= tmscm_to_url (arg2);

  // TMSCM_DEFER_INTS;
  get_server()->set_master_buffer (in1, in2);
  // TMSCM_ALLOW_INTS;

  return TMSCM_UNSPECIFIED;
}

tmscm
tmg_buffer_get_master (tmscm arg1) {
  TMSCM_ASSERT_URL (arg1, TMSCM_ARG1, "buffer-get-master");

  url in1= tmscm_to_url (arg1);

  // TMSCM_DEFER_INTS;
  url out= get_server()->get_master_buffer (in1);
  // TMSCM_ALLOW_INTS;

  return url_to_tmscm (out);
}

tmscm
tmg_buffer_set_title (tmscm arg1, tmscm arg2) {
  TMSCM_ASSERT_URL (arg1, TMSCM_ARG1, "buffer-set-title");
  TMSCM_ASSERT_STRING (arg2, TMSCM_ARG2, "buffer-set-title");

  url in1= tmscm_to_url (arg1);
  string in2= tmscm_to_string (arg2);

  // TMSCM_DEFER_INTS;
  get_server()->set_title_buffer (in1, in2);
  // TMSCM_ALLOW_INTS;

  return TMSCM_UNSPECIFIED;
}

tmscm
tmg_buffer_get_title (tmscm arg1) {
  TMSCM_ASSERT_URL (arg1, TMSCM_ARG1, "buffer-get-title");

  url in1= tmscm_to_url (arg1);

  // TMSCM_DEFER_INTS;
  string out= get_server()->get_title_buffer (in1);
  // TMSCM_ALLOW_INTS;

  return string_to_tmscm (out);
}

tmscm
tmg_buffer_last_save (tmscm arg1) {
  TMSCM_ASSERT_URL (arg1, TMSCM_ARG1, "buffer-last-save");

  url in1= tmscm_to_url (arg1);

  // TMSCM_DEFER_INTS;
  int out= get_server()->get_last_save_buffer (in1);
  // TMSCM_ALLOW_INTS;

  return int_to_tmscm (out);
}

tmscm
tmg_buffer_last_visited (tmscm arg1) {
  TMSCM_ASSERT_URL (arg1, TMSCM_ARG1, "buffer-last-visited");

  url in1= tmscm_to_url (arg1);

  // TMSCM_DEFER_INTS;
  double out= get_server()->last_visited (in1);
  // TMSCM_ALLOW_INTS;

  return double_to_tmscm (out);
}

tmscm
tmg_buffer_modifiedP (tmscm arg1) {
  TMSCM_ASSERT_URL (arg1, TMSCM_ARG1, "buffer-modified?");

  url in1= tmscm_to_url (arg1);

  // TMSCM_DEFER_INTS;
  bool out= get_server()->buffer_modified (in1);
  // TMSCM_ALLOW_INTS;

  return bool_to_tmscm (out);
}

tmscm
tmg_buffer_modified_since_autosaveP (tmscm arg1) {
  TMSCM_ASSERT_URL (arg1, TMSCM_ARG1, "buffer-modified-since-autosave?");

  url in1= tmscm_to_url (arg1);

  // TMSCM_DEFER_INTS;
  bool out= get_server()->buffer_modified_since_autosave (in1);
  // TMSCM_ALLOW_INTS;

  return bool_to_tmscm (out);
}

tmscm
tmg_buffer_pretend_modified (tmscm arg1) {
  TMSCM_ASSERT_URL (arg1, TMSCM_ARG1, "buffer-pretend-modified");

  url in1= tmscm_to_url (arg1);

  // TMSCM_DEFER_INTS;
  get_server()->pretend_buffer_modified (in1);
  // TMSCM_ALLOW_INTS;

  return TMSCM_UNSPECIFIED;
}

tmscm
tmg_buffer_pretend_saved (tmscm arg1) {
  TMSCM_ASSERT_URL (arg1, TMSCM_ARG1, "buffer-pretend-saved");

  url in1= tmscm_to_url (arg1);

  // TMSCM_DEFER_INTS;
  get_server()->pretend_buffer_saved (in1);
  // TMSCM_ALLOW_INTS;

  return TMSCM_UNSPECIFIED;
}

tmscm
tmg_buffer_pretend_autosaved (tmscm arg1) {
  TMSCM_ASSERT_URL (arg1, TMSCM_ARG1, "buffer-pretend-autosaved");

  url in1= tmscm_to_url (arg1);

  // TMSCM_DEFER_INTS;
  get_server()->pretend_buffer_autosaved (in1);
  // TMSCM_ALLOW_INTS;

  return TMSCM_UNSPECIFIED;
}

tmscm
tmg_buffer_attach_notifier (tmscm arg1) {
  TMSCM_ASSERT_URL (arg1, TMSCM_ARG1, "buffer-attach-notifier");

  url in1= tmscm_to_url (arg1);

  // TMSCM_DEFER_INTS;
  get_server()->attach_buffer_notifier (in1);
  // TMSCM_ALLOW_INTS;

  return TMSCM_UNSPECIFIED;
}

tmscm
tmg_buffer_has_nameP (tmscm arg1) {
  TMSCM_ASSERT_URL (arg1, TMSCM_ARG1, "buffer-has-name?");

  url in1= tmscm_to_url (arg1);

  // TMSCM_DEFER_INTS;
  bool out= get_server()->buffer_has_name (in1);
  // TMSCM_ALLOW_INTS;

  return bool_to_tmscm (out);
}

tmscm
tmg_buffer_auxP (tmscm arg1) {
  TMSCM_ASSERT_URL (arg1, TMSCM_ARG1, "buffer-aux?");

  url in1= tmscm_to_url (arg1);

  // TMSCM_DEFER_INTS;
  bool out= get_server()->is_aux_buffer (in1);
  // TMSCM_ALLOW_INTS;

  return bool_to_tmscm (out);
}

tmscm
tmg_buffer_import (tmscm arg1, tmscm arg2, tmscm arg3) {
  TMSCM_ASSERT_URL (arg1, TMSCM_ARG1, "buffer-import");
  TMSCM_ASSERT_URL (arg2, TMSCM_ARG2, "buffer-import");
  TMSCM_ASSERT_STRING (arg3, TMSCM_ARG3, "buffer-import");

  url in1= tmscm_to_url (arg1);
  url in2= tmscm_to_url (arg2);
  string in3= tmscm_to_string (arg3);

  // TMSCM_DEFER_INTS;
  bool out= get_server()->buffer_import (in1, in2, in3);
  // TMSCM_ALLOW_INTS;

  return bool_to_tmscm (out);
}

tmscm
tmg_buffer_load (tmscm arg1) {
  TMSCM_ASSERT_URL (arg1, TMSCM_ARG1, "buffer-load");

  url in1= tmscm_to_url (arg1);

  // TMSCM_DEFER_INTS;
  bool out= get_server()->buffer_load (in1);
  // TMSCM_ALLOW_INTS;

  return bool_to_tmscm (out);
}

tmscm
tmg_buffer_export (tmscm arg1, tmscm arg2, tmscm arg3) {
  TMSCM_ASSERT_URL (arg1, TMSCM_ARG1, "buffer-export");
  TMSCM_ASSERT_URL (arg2, TMSCM_ARG2, "buffer-export");
  TMSCM_ASSERT_STRING (arg3, TMSCM_ARG3, "buffer-export");

  url in1= tmscm_to_url (arg1);
  url in2= tmscm_to_url (arg2);
  string in3= tmscm_to_string (arg3);

  // TMSCM_DEFER_INTS;
  bool out= get_server()->buffer_export (in1, in2, in3);
  // TMSCM_ALLOW_INTS;

  return bool_to_tmscm (out);
}

tmscm
tmg_buffer_save (tmscm arg1) {
  TMSCM_ASSERT_URL (arg1, TMSCM_ARG1, "buffer-save");

  url in1= tmscm_to_url (arg1);

  // TMSCM_DEFER_INTS;
  bool out= get_server()->buffer_save (in1);
  // TMSCM_ALLOW_INTS;

  return bool_to_tmscm (out);
}

tmscm
tmg_tree_import_loaded (tmscm arg1, tmscm arg2, tmscm arg3) {
  TMSCM_ASSERT_STRING (arg1, TMSCM_ARG1, "tree-import-loaded");
  TMSCM_ASSERT_URL (arg2, TMSCM_ARG2, "tree-import-loaded");
  TMSCM_ASSERT_STRING (arg3, TMSCM_ARG3, "tree-import-loaded");

  string in1= tmscm_to_string (arg1);
  url in2= tmscm_to_url (arg2);
  string in3= tmscm_to_string (arg3);

  // TMSCM_DEFER_INTS;
  tree out= get_server()->import_loaded_tree (in1, in2, in3);
  // TMSCM_ALLOW_INTS;

  return tree_to_tmscm (out);
}

tmscm
tmg_tree_import (tmscm arg1, tmscm arg2) {
  TMSCM_ASSERT_URL (arg1, TMSCM_ARG1, "tree-import");
  TMSCM_ASSERT_STRING (arg2, TMSCM_ARG2, "tree-import");

  url in1= tmscm_to_url (arg1);
  string in2= tmscm_to_string (arg2);

  // TMSCM_DEFER_INTS;
  tree out= get_server()->import_tree (in1, in2);
  // TMSCM_ALLOW_INTS;

  return tree_to_tmscm (out);
}

tmscm
tmg_tree_export (tmscm arg1, tmscm arg2, tmscm arg3) {
  TMSCM_ASSERT_TREE (arg1, TMSCM_ARG1, "tree-export");
  TMSCM_ASSERT_URL (arg2, TMSCM_ARG2, "tree-export");
  TMSCM_ASSERT_STRING (arg3, TMSCM_ARG3, "tree-export");

  tree in1= tmscm_to_tree (arg1);
  url in2= tmscm_to_url (arg2);
  string in3= tmscm_to_string (arg3);

  // TMSCM_DEFER_INTS;
  bool out= get_server()->export_tree (in1, in2, in3);
  // TMSCM_ALLOW_INTS;

  return bool_to_tmscm (out);
}

tmscm
tmg_tree_load_style (tmscm arg1) {
  TMSCM_ASSERT_STRING (arg1, TMSCM_ARG1, "tree-load-style");

  string in1= tmscm_to_string (arg1);

  // TMSCM_DEFER_INTS;
  tree out= get_server()->load_style_tree (in1);
  // TMSCM_ALLOW_INTS;

  return tree_to_tmscm (out);
}

tmscm
tmg_buffer_focus (tmscm arg1) {
  TMSCM_ASSERT_URL (arg1, TMSCM_ARG1, "buffer-focus");

  url in1= tmscm_to_url (arg1);

  // TMSCM_DEFER_INTS;
  bool out= get_server()->focus_on_buffer (in1);
  // TMSCM_ALLOW_INTS;

  return bool_to_tmscm (out);
}

tmscm
tmg_view_list () {
  // TMSCM_DEFER_INTS;
  array_url out= get_server()->get_all_views ();
  // TMSCM_ALLOW_INTS;

  return array_url_to_tmscm (out);
}

tmscm
tmg_buffer_2views (tmscm arg1) {
  TMSCM_ASSERT_URL (arg1, TMSCM_ARG1, "buffer->views");

  url in1= tmscm_to_url (arg1);

  // TMSCM_DEFER_INTS;
  array_url out= get_server()->buffer_to_views (in1);
  // TMSCM_ALLOW_INTS;

  return array_url_to_tmscm (out);
}

tmscm
tmg_current_view_url () {
  // TMSCM_DEFER_INTS;
  url out= get_server()->get_current_view_safe ();
  // TMSCM_ALLOW_INTS;

  return url_to_tmscm (out);
}

tmscm
tmg_window_2view (tmscm arg1) {
  TMSCM_ASSERT_URL (arg1, TMSCM_ARG1, "window->view");

  url in1= tmscm_to_url (arg1);

  // TMSCM_DEFER_INTS;
  url out= get_server()->window_to_view (in1);
  // TMSCM_ALLOW_INTS;

  return url_to_tmscm (out);
}

tmscm
tmg_view_2buffer (tmscm arg1) {
  TMSCM_ASSERT_URL (arg1, TMSCM_ARG1, "view->buffer");

  url in1= tmscm_to_url (arg1);

  // TMSCM_DEFER_INTS;
  url out= get_server()->view_to_buffer (in1);
  // TMSCM_ALLOW_INTS;

  return url_to_tmscm (out);
}

tmscm
tmg_view_2window_url (tmscm arg1) {
  TMSCM_ASSERT_URL (arg1, TMSCM_ARG1, "view->window-url");

  url in1= tmscm_to_url (arg1);

  // TMSCM_DEFER_INTS;
  url out= get_server()->view_to_window (in1);
  // TMSCM_ALLOW_INTS;

  return url_to_tmscm (out);
}

tmscm
tmg_view_new (tmscm arg1) {
  TMSCM_ASSERT_URL (arg1, TMSCM_ARG1, "view-new");

  url in1= tmscm_to_url (arg1);

  // TMSCM_DEFER_INTS;
  url out= get_server()->get_new_view (in1);
  // TMSCM_ALLOW_INTS;

  return url_to_tmscm (out);
}

tmscm
tmg_view_passive (tmscm arg1) {
  TMSCM_ASSERT_URL (arg1, TMSCM_ARG1, "view-passive");

  url in1= tmscm_to_url (arg1);

  // TMSCM_DEFER_INTS;
  url out= get_server()->get_passive_view (in1);
  // TMSCM_ALLOW_INTS;

  return url_to_tmscm (out);
}

tmscm
tmg_view_recent (tmscm arg1) {
  TMSCM_ASSERT_URL (arg1, TMSCM_ARG1, "view-recent");

  url in1= tmscm_to_url (arg1);

  // TMSCM_DEFER_INTS;
  url out= get_server()->get_recent_view (in1);
  // TMSCM_ALLOW_INTS;

  return url_to_tmscm (out);
}

tmscm
tmg_view_delete (tmscm arg1) {
  TMSCM_ASSERT_URL (arg1, TMSCM_ARG1, "view-delete");

  url in1= tmscm_to_url (arg1);

  // TMSCM_DEFER_INTS;
  get_server()->delete_view (in1);
  // TMSCM_ALLOW_INTS;

  return TMSCM_UNSPECIFIED;
}

tmscm
tmg_window_set_view (tmscm arg1, tmscm arg2, tmscm arg3) {
  TMSCM_ASSERT_URL (arg1, TMSCM_ARG1, "window-set-view");
  TMSCM_ASSERT_URL (arg2, TMSCM_ARG2, "window-set-view");
  TMSCM_ASSERT_BOOL (arg3, TMSCM_ARG3, "window-set-view");

  url in1= tmscm_to_url (arg1);
  url in2= tmscm_to_url (arg2);
  bool in3= tmscm_to_bool (arg3);

  // TMSCM_DEFER_INTS;
  get_server()->window_set_view (in1, in2, in3);
  // TMSCM_ALLOW_INTS;

  return TMSCM_UNSPECIFIED;
}

tmscm
tmg_switch_to_buffer (tmscm arg1) {
  TMSCM_ASSERT_URL (arg1, TMSCM_ARG1, "switch-to-buffer");

  url in1= tmscm_to_url (arg1);

  // TMSCM_DEFER_INTS;
  get_server()->switch_to_buffer (in1);
  // TMSCM_ALLOW_INTS;

  return TMSCM_UNSPECIFIED;
}

tmscm
tmg_window_list () {
  // TMSCM_DEFER_INTS;
  array_url out= get_server()->windows_list ();
  // TMSCM_ALLOW_INTS;

  return array_url_to_tmscm (out);
}

tmscm
tmg_windows_number () {
  // TMSCM_DEFER_INTS;
  int out= get_server()->get_nr_windows ();
  // TMSCM_ALLOW_INTS;

  return int_to_tmscm (out);
}

tmscm
tmg_current_window () {
  // TMSCM_DEFER_INTS;
  url out= get_server()->get_current_window ();
  // TMSCM_ALLOW_INTS;

  return url_to_tmscm (out);
}

tmscm
tmg_buffer_2windows (tmscm arg1) {
  TMSCM_ASSERT_URL (arg1, TMSCM_ARG1, "buffer->windows");

  url in1= tmscm_to_url (arg1);

  // TMSCM_DEFER_INTS;
  array_url out= get_server()->buffer_to_windows (in1);
  // TMSCM_ALLOW_INTS;

  return array_url_to_tmscm (out);
}

tmscm
tmg_window_to_buffer (tmscm arg1) {
  TMSCM_ASSERT_URL (arg1, TMSCM_ARG1, "window-to-buffer");

  url in1= tmscm_to_url (arg1);

  // TMSCM_DEFER_INTS;
  url out= get_server()->window_to_buffer (in1);
  // TMSCM_ALLOW_INTS;

  return url_to_tmscm (out);
}

tmscm
tmg_window_set_buffer (tmscm arg1, tmscm arg2) {
  TMSCM_ASSERT_URL (arg1, TMSCM_ARG1, "window-set-buffer");
  TMSCM_ASSERT_URL (arg2, TMSCM_ARG2, "window-set-buffer");

  url in1= tmscm_to_url (arg1);
  url in2= tmscm_to_url (arg2);

  // TMSCM_DEFER_INTS;
  get_server()->window_set_buffer (in1, in2);
  // TMSCM_ALLOW_INTS;

  return TMSCM_UNSPECIFIED;
}

tmscm
tmg_window_focus (tmscm arg1) {
  TMSCM_ASSERT_URL (arg1, TMSCM_ARG1, "window-focus");

  url in1= tmscm_to_url (arg1);

  // TMSCM_DEFER_INTS;
  get_server()->window_focus (in1);
  // TMSCM_ALLOW_INTS;

  return TMSCM_UNSPECIFIED;
}

tmscm
tmg_new_buffer () {
  // TMSCM_DEFER_INTS;
  url out= get_server()->create_buffer ();
  // TMSCM_ALLOW_INTS;

  return url_to_tmscm (out);
}

tmscm
tmg_open_buffer_in_window (tmscm arg1, tmscm arg2, tmscm arg3) {
  TMSCM_ASSERT_URL (arg1, TMSCM_ARG1, "open-buffer-in-window");
  TMSCM_ASSERT_CONTENT (arg2, TMSCM_ARG2, "open-buffer-in-window");
  TMSCM_ASSERT_CONTENT (arg3, TMSCM_ARG3, "open-buffer-in-window");

  url in1= tmscm_to_url (arg1);
  content in2= tmscm_to_content (arg2);
  content in3= tmscm_to_content (arg3);

  // TMSCM_DEFER_INTS;
  url out= get_server()->new_buffer_in_new_window (in1, in2, in3);
  // TMSCM_ALLOW_INTS;

  return url_to_tmscm (out);
}

tmscm
tmg_open_window () {
  // TMSCM_DEFER_INTS;
  url out= get_server()->open_window ();
  // TMSCM_ALLOW_INTS;

  return url_to_tmscm (out);
}

tmscm
tmg_open_window_geometry (tmscm arg1) {
  TMSCM_ASSERT_CONTENT (arg1, TMSCM_ARG1, "open-window-geometry");

  content in1= tmscm_to_content (arg1);

  // TMSCM_DEFER_INTS;
  url out= get_server()->open_window (in1);
  // TMSCM_ALLOW_INTS;

  return url_to_tmscm (out);
}

tmscm
tmg_clone_window () {
  // TMSCM_DEFER_INTS;
  get_server()->clone_window ();
  // TMSCM_ALLOW_INTS;

  return TMSCM_UNSPECIFIED;
}

tmscm
tmg_buffer_close (tmscm arg1) {
  TMSCM_ASSERT_URL (arg1, TMSCM_ARG1, "buffer-close");

  url in1= tmscm_to_url (arg1);

  // TMSCM_DEFER_INTS;
  get_server()->kill_buffer (in1);
  // TMSCM_ALLOW_INTS;

  return TMSCM_UNSPECIFIED;
}

tmscm
tmg_kill_window (tmscm arg1) {
  TMSCM_ASSERT_URL (arg1, TMSCM_ARG1, "kill-window");

  url in1= tmscm_to_url (arg1);

  // TMSCM_DEFER_INTS;
  get_server()->kill_window (in1);
  // TMSCM_ALLOW_INTS;

  return TMSCM_UNSPECIFIED;
}

tmscm
tmg_kill_current_window_and_buffer () {
  // TMSCM_DEFER_INTS;
  get_server()->kill_current_window_and_buffer ();
  // TMSCM_ALLOW_INTS;

  return TMSCM_UNSPECIFIED;
}

tmscm
tmg_project_attach (tmscm arg1) {
  TMSCM_ASSERT_STRING (arg1, TMSCM_ARG1, "project-attach");

  string in1= tmscm_to_string (arg1);

  // TMSCM_DEFER_INTS;
  get_server()->project_attach (in1);
  // TMSCM_ALLOW_INTS;

  return TMSCM_UNSPECIFIED;
}

tmscm
tmg_project_detach () {
  // TMSCM_DEFER_INTS;
  get_server()->project_attach ();
  // TMSCM_ALLOW_INTS;

  return TMSCM_UNSPECIFIED;
}

tmscm
tmg_project_attachedP () {
  // TMSCM_DEFER_INTS;
  bool out= get_server()->project_attached ();
  // TMSCM_ALLOW_INTS;

  return bool_to_tmscm (out);
}

tmscm
tmg_project_get () {
  // TMSCM_DEFER_INTS;
  url out= get_server()->project_get ();
  // TMSCM_ALLOW_INTS;

  return url_to_tmscm (out);
}

tmscm
tmg_tree_load_inclusion (tmscm arg1) {
  TMSCM_ASSERT_URL (arg1, TMSCM_ARG1, "tree-load-inclusion");

  url in1= tmscm_to_url (arg1);

  // TMSCM_DEFER_INTS;
  tree out= get_server()->load_inclusion (in1);
  // TMSCM_ALLOW_INTS;

  return tree_to_tmscm (out);
}

tmscm
tmg_widget_texmacs_input (tmscm arg1, tmscm arg2, tmscm arg3) {
  TMSCM_ASSERT_CONTENT (arg1, TMSCM_ARG1, "widget-texmacs-input");
  TMSCM_ASSERT_CONTENT (arg2, TMSCM_ARG2, "widget-texmacs-input");
  TMSCM_ASSERT_URL (arg3, TMSCM_ARG3, "widget-texmacs-input");

  content in1= tmscm_to_content (arg1);
  content in2= tmscm_to_content (arg2);
  url in3= tmscm_to_url (arg3);

  // TMSCM_DEFER_INTS;
  widget out= get_server()->texmacs_input_widget (in1, in2, in3);
  // TMSCM_ALLOW_INTS;

  return widget_to_tmscm (out);
}

void
initialize_glue_server () {
  tmscm_install_procedure ("insert-kbd-wildcard",  tmg_insert_kbd_wildcard, 5, 0, 0);
  tmscm_install_procedure ("set-variant-keys",  tmg_set_variant_keys, 2, 0, 0);
  tmscm_install_procedure ("kbd-pre-rewrite",  tmg_kbd_pre_rewrite, 1, 0, 0);
  tmscm_install_procedure ("kbd-post-rewrite",  tmg_kbd_post_rewrite, 2, 0, 0);
  tmscm_install_procedure ("kbd-system-rewrite",  tmg_kbd_system_rewrite, 1, 0, 0);
  tmscm_install_procedure ("set-font-rules",  tmg_set_font_rules, 1, 0, 0);
  tmscm_install_procedure ("window-get-serial",  tmg_window_get_serial, 0, 0, 0);
  tmscm_install_procedure ("window-set-property",  tmg_window_set_property, 2, 0, 0);
  tmscm_install_procedure ("window-get-property",  tmg_window_get_property, 1, 0, 0);
  tmscm_install_procedure ("show-header",  tmg_show_header, 1, 0, 0);
  tmscm_install_procedure ("show-icon-bar",  tmg_show_icon_bar, 2, 0, 0);
  tmscm_install_procedure ("show-side-tools",  tmg_show_side_tools, 2, 0, 0);
  tmscm_install_procedure ("show-bottom-tools",  tmg_show_bottom_tools, 2, 0, 0);
  tmscm_install_procedure ("show-footer",  tmg_show_footer, 1, 0, 0);
  tmscm_install_procedure ("visible-header?",  tmg_visible_headerP, 0, 0, 0);
  tmscm_install_procedure ("visible-icon-bar?",  tmg_visible_icon_barP, 1, 0, 0);
  tmscm_install_procedure ("visible-side-tools?",  tmg_visible_side_toolsP, 1, 0, 0);
  tmscm_install_procedure ("visible-bottom-tools?",  tmg_visible_bottom_toolsP, 1, 0, 0);
  tmscm_install_procedure ("visible-footer?",  tmg_visible_footerP, 0, 0, 0);
  tmscm_install_procedure ("full-screen-mode",  tmg_full_screen_mode, 2, 0, 0);
  tmscm_install_procedure ("full-screen?",  tmg_full_screenP, 0, 0, 0);
  tmscm_install_procedure ("full-screen-edit?",  tmg_full_screen_editP, 0, 0, 0);
  tmscm_install_procedure ("set-window-zoom-factor",  tmg_set_window_zoom_factor, 1, 0, 0);
  tmscm_install_procedure ("get-window-zoom-factor",  tmg_get_window_zoom_factor, 0, 0, 0);
  tmscm_install_procedure ("shell",  tmg_shell, 1, 0, 0);
  tmscm_install_procedure ("dialogue-end",  tmg_dialogue_end, 0, 0, 0);
  tmscm_install_procedure ("cpp-choose-file",  tmg_cpp_choose_file, 5, 0, 0);
  tmscm_install_procedure ("tm-interactive",  tmg_tm_interactive, 2, 0, 0);
  tmscm_install_procedure ("keyboard-focus-on",  tmg_keyboard_focus_on, 1, 0, 0);
  tmscm_install_procedure ("style-clear-cache",  tmg_style_clear_cache, 0, 0, 0);
  tmscm_install_procedure ("set-script-status",  tmg_set_script_status, 1, 0, 0);
  tmscm_install_procedure ("set-printing-command",  tmg_set_printing_command, 1, 0, 0);
  tmscm_install_procedure ("set-printer-paper-type",  tmg_set_printer_paper_type, 1, 0, 0);
  tmscm_install_procedure ("get-printer-paper-type",  tmg_get_printer_paper_type, 0, 0, 0);
  tmscm_install_procedure ("set-printer-dpi",  tmg_set_printer_dpi, 1, 0, 0);
  tmscm_install_procedure ("set-default-zoom-factor",  tmg_set_default_zoom_factor, 1, 0, 0);
  tmscm_install_procedure ("get-default-zoom-factor",  tmg_get_default_zoom_factor, 0, 0, 0);
  tmscm_install_procedure ("inclusions-gc",  tmg_inclusions_gc, 0, 0, 0);
  tmscm_install_procedure ("update-all-path",  tmg_update_all_path, 1, 0, 0);
  tmscm_install_procedure ("update-all-buffers",  tmg_update_all_buffers, 0, 0, 0);
  tmscm_install_procedure ("set-message",  tmg_set_message, 2, 0, 0);
  tmscm_install_procedure ("set-message-temp",  tmg_set_message_temp, 3, 0, 0);
  tmscm_install_procedure ("recall-message",  tmg_recall_message, 0, 0, 0);
  tmscm_install_procedure ("yes?",  tmg_yesP, 1, 0, 0);
  tmscm_install_procedure ("quit-TeXmacs",  tmg_quit_TeXmacs, 0, 0, 0);
  tmscm_install_procedure ("buffer-list",  tmg_buffer_list, 0, 0, 0);
  tmscm_install_procedure ("current-buffer-url",  tmg_current_buffer_url, 0, 0, 0);
  tmscm_install_procedure ("path-to-buffer",  tmg_path_to_buffer, 1, 0, 0);
  tmscm_install_procedure ("buffer-new",  tmg_buffer_new, 0, 0, 0);
  tmscm_install_procedure ("buffer-rename",  tmg_buffer_rename, 2, 0, 0);
  tmscm_install_procedure ("buffer-set",  tmg_buffer_set, 2, 0, 0);
  tmscm_install_procedure ("buffer-get",  tmg_buffer_get, 1, 0, 0);
  tmscm_install_procedure ("buffer-set-body",  tmg_buffer_set_body, 2, 0, 0);
  tmscm_install_procedure ("buffer-get-body",  tmg_buffer_get_body, 1, 0, 0);
  tmscm_install_procedure ("buffer-set-master",  tmg_buffer_set_master, 2, 0, 0);
  tmscm_install_procedure ("buffer-get-master",  tmg_buffer_get_master, 1, 0, 0);
  tmscm_install_procedure ("buffer-set-title",  tmg_buffer_set_title, 2, 0, 0);
  tmscm_install_procedure ("buffer-get-title",  tmg_buffer_get_title, 1, 0, 0);
  tmscm_install_procedure ("buffer-last-save",  tmg_buffer_last_save, 1, 0, 0);
  tmscm_install_procedure ("buffer-last-visited",  tmg_buffer_last_visited, 1, 0, 0);
  tmscm_install_procedure ("buffer-modified?",  tmg_buffer_modifiedP, 1, 0, 0);
  tmscm_install_procedure ("buffer-modified-since-autosave?",  tmg_buffer_modified_since_autosaveP, 1, 0, 0);
  tmscm_install_procedure ("buffer-pretend-modified",  tmg_buffer_pretend_modified, 1, 0, 0);
  tmscm_install_procedure ("buffer-pretend-saved",  tmg_buffer_pretend_saved, 1, 0, 0);
  tmscm_install_procedure ("buffer-pretend-autosaved",  tmg_buffer_pretend_autosaved, 1, 0, 0);
  tmscm_install_procedure ("buffer-attach-notifier",  tmg_buffer_attach_notifier, 1, 0, 0);
  tmscm_install_procedure ("buffer-has-name?",  tmg_buffer_has_nameP, 1, 0, 0);
  tmscm_install_procedure ("buffer-aux?",  tmg_buffer_auxP, 1, 0, 0);
  tmscm_install_procedure ("buffer-import",  tmg_buffer_import, 3, 0, 0);
  tmscm_install_procedure ("buffer-load",  tmg_buffer_load, 1, 0, 0);
  tmscm_install_procedure ("buffer-export",  tmg_buffer_export, 3, 0, 0);
  tmscm_install_procedure ("buffer-save",  tmg_buffer_save, 1, 0, 0);
  tmscm_install_procedure ("tree-import-loaded",  tmg_tree_import_loaded, 3, 0, 0);
  tmscm_install_procedure ("tree-import",  tmg_tree_import, 2, 0, 0);
  tmscm_install_procedure ("tree-export",  tmg_tree_export, 3, 0, 0);
  tmscm_install_procedure ("tree-load-style",  tmg_tree_load_style, 1, 0, 0);
  tmscm_install_procedure ("buffer-focus",  tmg_buffer_focus, 1, 0, 0);
  tmscm_install_procedure ("view-list",  tmg_view_list, 0, 0, 0);
  tmscm_install_procedure ("buffer->views",  tmg_buffer_2views, 1, 0, 0);
  tmscm_install_procedure ("current-view-url",  tmg_current_view_url, 0, 0, 0);
  tmscm_install_procedure ("window->view",  tmg_window_2view, 1, 0, 0);
  tmscm_install_procedure ("view->buffer",  tmg_view_2buffer, 1, 0, 0);
  tmscm_install_procedure ("view->window-url",  tmg_view_2window_url, 1, 0, 0);
  tmscm_install_procedure ("view-new",  tmg_view_new, 1, 0, 0);
  tmscm_install_procedure ("view-passive",  tmg_view_passive, 1, 0, 0);
  tmscm_install_procedure ("view-recent",  tmg_view_recent, 1, 0, 0);
  tmscm_install_procedure ("view-delete",  tmg_view_delete, 1, 0, 0);
  tmscm_install_procedure ("window-set-view",  tmg_window_set_view, 3, 0, 0);
  tmscm_install_procedure ("switch-to-buffer",  tmg_switch_to_buffer, 1, 0, 0);
  tmscm_install_procedure ("window-list",  tmg_window_list, 0, 0, 0);
  tmscm_install_procedure ("windows-number",  tmg_windows_number, 0, 0, 0);
  tmscm_install_procedure ("current-window",  tmg_current_window, 0, 0, 0);
  tmscm_install_procedure ("buffer->windows",  tmg_buffer_2windows, 1, 0, 0);
  tmscm_install_procedure ("window-to-buffer",  tmg_window_to_buffer, 1, 0, 0);
  tmscm_install_procedure ("window-set-buffer",  tmg_window_set_buffer, 2, 0, 0);
  tmscm_install_procedure ("window-focus",  tmg_window_focus, 1, 0, 0);
  tmscm_install_procedure ("new-buffer",  tmg_new_buffer, 0, 0, 0);
  tmscm_install_procedure ("open-buffer-in-window",  tmg_open_buffer_in_window, 3, 0, 0);
  tmscm_install_procedure ("open-window",  tmg_open_window, 0, 0, 0);
  tmscm_install_procedure ("open-window-geometry",  tmg_open_window_geometry, 1, 0, 0);
  tmscm_install_procedure ("clone-window",  tmg_clone_window, 0, 0, 0);
  tmscm_install_procedure ("buffer-close",  tmg_buffer_close, 1, 0, 0);
  tmscm_install_procedure ("kill-window",  tmg_kill_window, 1, 0, 0);
  tmscm_install_procedure ("kill-current-window-and-buffer",  tmg_kill_current_window_and_buffer, 0, 0, 0);
  tmscm_install_procedure ("project-attach",  tmg_project_attach, 1, 0, 0);
  tmscm_install_procedure ("project-detach",  tmg_project_detach, 0, 0, 0);
  tmscm_install_procedure ("project-attached?",  tmg_project_attachedP, 0, 0, 0);
  tmscm_install_procedure ("project-get",  tmg_project_get, 0, 0, 0);
  tmscm_install_procedure ("tree-load-inclusion",  tmg_tree_load_inclusion, 1, 0, 0);
  tmscm_install_procedure ("widget-texmacs-input",  tmg_widget_texmacs_input, 3, 0, 0);
}
