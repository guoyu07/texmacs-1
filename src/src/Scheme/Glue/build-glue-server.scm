
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; MODULE      : build-glue-server.scm
;; DESCRIPTION : Building basic glue for the server
;; COPYRIGHT   : (C) 1999  Joris van der Hoeven
;;
;; This software falls under the GNU general public license version 3 or later.
;; It comes WITHOUT ANY WARRANTY WHATSOEVER. For details, see the file LICENSE
;; in the root directory or <http://www.gnu.org/licenses/gpl-3.0.html>.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(output-copyright "build-glue-server.scm")

(build
  "get_server()->"
  "initialize_glue_server"

  (insert-kbd-wildcard insert_kbd_wildcard (void string string bool bool bool))
  (set-variant-keys set_variant_keys (void string string))
  (kbd-pre-rewrite kbd_pre_rewrite (string string))
  (kbd-post-rewrite kbd_post_rewrite (string string bool))
  (kbd-system-rewrite kbd_system_rewrite (tree string))
  (set-font-rules set_font_rules (void scheme_tree))

  (window-get-serial get_window_serial (int))
  (window-set-property set_window_property (void scheme_tree scheme_tree))
  (window-get-property get_window_property (scheme_tree scheme_tree))
  (show-header show_header (void bool))
  (show-icon-bar show_icon_bar (void int bool))
  (show-side-tools show_side_tools (void int bool))
  (show-bottom-tools show_bottom_tools (void int bool))
  (show-footer show_footer (void bool))
  (visible-header? visible_header (bool))
  (visible-icon-bar? visible_icon_bar (bool int))
  (visible-side-tools? visible_side_tools (bool int))
  (visible-bottom-tools? visible_bottom_tools (bool int))
  (visible-footer? visible_footer (bool))
  (full-screen-mode full_screen_mode (void bool bool))
  (full-screen? in_full_screen_mode (bool))
  (full-screen-edit? in_full_screen_edit_mode (bool))
  (set-window-zoom-factor set_window_zoom_factor (void double))
  (get-window-zoom-factor get_window_zoom_factor (double))

  (shell shell (void string))
  (dialogue-end dialogue_end (void))
  (cpp-choose-file choose_file (void object string string string url))
  (tm-interactive interactive (void object scheme_tree))
  (keyboard-focus-on keyboard_focus_on (void string))

  (style-clear-cache style_clear_cache (void))
  (set-script-status set_script_status (void int))
  (set-printing-command set_printing_command (void string))
  (set-printer-paper-type set_printer_page_type (void string))
  (get-printer-paper-type get_printer_page_type (string))
  (set-printer-dpi set_printer_dpi (void string))
  (set-default-zoom-factor set_default_zoom_factor (void double))
  (get-default-zoom-factor get_default_zoom_factor (double))
  (inclusions-gc inclusions_gc (void))
  (update-all-path typeset_update (void path))
  (update-all-buffers typeset_update_all (void))
  (set-message set_message (void content content))
  (set-message-temp set_message (void content content bool))
  (recall-message recall_message (void))
  (yes? is_yes (bool string))
  (quit-TeXmacs quit (void))

  ;; buffers
  (buffer-list get_all_buffers (array_url))
  (current-buffer-url get_current_buffer_safe (url))
  (path-to-buffer path_to_buffer (url path))
  (buffer-new make_new_buffer (url))
  (buffer-rename rename_buffer (void url url))
  (buffer-set set_buffer_tree (void url content))
  (buffer-get get_buffer_tree (tree url))
  (buffer-set-body set_buffer_body (void url content))
  (buffer-get-body get_buffer_body (tree url))
  (buffer-set-master set_master_buffer (void url url))
  (buffer-get-master get_master_buffer (url url))
  (buffer-set-title set_title_buffer (void url string))
  (buffer-get-title get_title_buffer (string url))
  (buffer-last-save get_last_save_buffer (int url))
  (buffer-last-visited last_visited (double url))
  (buffer-modified? buffer_modified (bool url))
  (buffer-modified-since-autosave? buffer_modified_since_autosave (bool url))
  (buffer-pretend-modified pretend_buffer_modified (void url))
  (buffer-pretend-saved pretend_buffer_saved (void url))
  (buffer-pretend-autosaved pretend_buffer_autosaved (void url))
  (buffer-attach-notifier attach_buffer_notifier (void url))
  (buffer-has-name? buffer_has_name (bool url))
  (buffer-aux? is_aux_buffer (bool url))
  (buffer-import buffer_import (bool url url string))
  (buffer-load buffer_load (bool url))
  (buffer-export buffer_export (bool url url string))
  (buffer-save buffer_save (bool url))
  (tree-import-loaded import_loaded_tree (tree string url string))
  (tree-import import_tree (tree url string))
  (tree-export export_tree (bool tree url string))
  (tree-load-style load_style_tree (tree string))
  (buffer-focus focus_on_buffer (bool url))
  
  (view-list get_all_views (array_url))
  (buffer->views buffer_to_views (array_url url))
  (current-view-url get_current_view_safe (url))
  (window->view window_to_view (url url))
  (view->buffer view_to_buffer (url url))
  (view->window-url view_to_window (url url))
  (view-new get_new_view (url url))
  (view-passive get_passive_view (url url))
  (view-recent get_recent_view (url url))
  (view-delete delete_view (void url))
  (window-set-view window_set_view (void url url bool))
  (switch-to-buffer switch_to_buffer (void url))
  
  (window-list windows_list (array_url))
  (windows-number get_nr_windows (int))
  (current-window get_current_window (url))
  (buffer->windows buffer_to_windows (array_url url))
  (window-to-buffer window_to_buffer (url url))
  (window-set-buffer window_set_buffer (void url url))
  (window-focus window_focus (void url))
  
  (new-buffer create_buffer (url))
  (open-buffer-in-window new_buffer_in_new_window (url url content content))
  (open-window open_window (url))
  (open-window-geometry open_window (url content))
  (clone-window clone_window (void))
  (buffer-close kill_buffer (void url))
  (kill-window kill_window (void url))
  (kill-current-window-and-buffer kill_current_window_and_buffer (void))
  
  (project-attach project_attach (void string))
  (project-detach project_attach (void))
  (project-attached? project_attached (bool))
  (project-get project_get (url))

  (tree-load-inclusion load_inclusion (tree url))
  (widget-texmacs-input texmacs_input_widget (widget content content url))
)
