
/******************************************************************************
* MODULE     : tm_data.hpp
* DESCRIPTION: Buffer management for TeXmacs server
* COPYRIGHT  : (C) 1999  Joris van der Hoeven
*******************************************************************************
* This software falls under the GNU general public license version 3 or later.
* It comes WITHOUT ANY WARRANTY WHATSOEVER. For details, see the file LICENSE
* in the root directory or <http://www.gnu.org/licenses/gpl-3.0.html>.
******************************************************************************/

#ifndef TM_DATA_H
#define TM_DATA_H

#include "tm_server.hpp"
#include "tm_window.hpp"
#include "Data/new_view.hpp"
#include "Data/new_window.hpp"
#include "Data/new_project.hpp"
#include "Data/new_buffer.hpp"


extern array<tm_buffer> bufs;

#endif // defined TM_DATA_H
