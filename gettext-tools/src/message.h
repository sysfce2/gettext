/* GNU gettext - internationalization aids
   Copyright (C) 1995-2025 Free Software Foundation, Inc.

   This file was written by Peter Miller <millerp@canb.auug.org.au>

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <https://www.gnu.org/licenses/>.  */

#ifndef _MESSAGE_H
#define _MESSAGE_H

#include "str-list.h"
#include "pos.h"
#include "mem-hash-map.h"

#include <stdbool.h>


#ifdef __cplusplus
extern "C" {
#endif


/* According to Sun's Uniforum proposal the default message domain is
   named 'messages'.  */
#define MESSAGE_DOMAIN_DEFAULT "messages"


/* Separator between msgctxt and msgid in .mo files.  */
#define MSGCTXT_SEPARATOR '\004'  /* EOT */


/* Kinds of format strings.  */
enum format_type
{
  format_c,
  format_objc,
  format_cplusplus_brace,
  format_python,
  format_python_brace,
  format_java,
  format_java_printf,
  format_csharp,
  format_javascript,
  format_scheme,
  format_lisp,
  format_elisp,
  format_librep,
  format_rust,
  format_go,
  format_ruby,
  format_sh,
  format_sh_printf,
  format_awk,
  format_lua,
  format_pascal,
  format_modula2,
  format_d,
  format_ocaml,
  format_smalltalk,
  format_qt,
  format_qt_plural,
  format_kde,
  format_kde_kuit,
  format_boost,
  format_tcl,
  format_perl,
  format_perl_brace,
  format_php,
  format_gcc_internal,
  format_gfc_internal,
  format_ycp
};
#define NFORMATS 37     /* Number of format_type enum values.  */
extern LIBGETTEXTSRC_DLL_VARIABLE const char *const format_language[NFORMATS];
extern LIBGETTEXTSRC_DLL_VARIABLE const char *const format_language_pretty[NFORMATS];

/* Is current msgid a format string?  */
enum is_format
{
  undecided,
  yes,
  no,
  yes_according_to_context,
  possible,
  impossible
};

extern bool
       possible_format_p (enum is_format);


/* Range of an unsigned integer argument.  */
struct argument_range
{
  int min;
  int max;
};

/* Tests whether a range is present.  */
#define has_range_p(range)  ((range).min >= 0 && (range).max >= 0)


/* Is current msgid wrappable?  */
#if 0
enum is_wrap
{
  undecided,
  yes,
  no
};
#else /* HACK - C's enum concept is so stupid */
#define is_wrap is_format
#endif


/* Kinds of syntax checks which apply to an msgid.  */
enum syntax_check_type
{
  sc_ellipsis_unicode,
  sc_space_ellipsis,
  sc_quote_unicode,
  sc_bullet_unicode
};
#define NSYNTAXCHECKS 4
extern LIBGETTEXTSRC_DLL_VARIABLE const char *const syntax_check_name[NSYNTAXCHECKS];

/* Is current msgid subject to a syntax check?  */
#if 0
enum is_syntax_check
{
  undecided,
  yes,
  no
};
#else /* HACK - C's enum concept is so stupid */
#define is_syntax_check is_format
#endif


struct altstr
{
  const char *msgstr;
  size_t msgstr_len;
  const char *msgstr_end;
  string_list_ty *comment;
  string_list_ty *comment_dot;
  char *id;
};


typedef struct message_ty message_ty;
struct message_ty
{
  /* The msgctxt string, if present.  */
  const char *msgctxt;

  /* The msgid string.  */
  const char *msgid;

  /* The msgid's plural, if present.  */
  const char *msgid_plural;

  /* The msgstr strings.  */
  const char *msgstr;
  /* The number of bytes in msgstr, including the terminating NUL.  */
  size_t msgstr_len;

  /* Position in the source PO file.  */
  lex_pos_ty pos;

  /* Plain comments (#) appearing before the message.  */
  string_list_ty *comment;

  /* Extracted comments (#.) appearing before the message.  */
  string_list_ty *comment_dot;

  /* File position comments (#:) appearing before the message, one for
     each unique file position instance, sorted by file name and then
     by line.  */
  size_t filepos_count;
  lex_pos_ty *filepos;

  /* Informations from special comments (#,).
     Some of them come from extracted comments.  They are manipulated by
     the tools, e.g. msgmerge.  */

  /* Fuzzy means "needs translator review".  */
  bool is_fuzzy;

  /* Designation of format string syntax requirements for specific
     programming languages.  */
  enum is_format is_format[NFORMATS];

  /* Lower and upper bound for the argument whose format directive can be
     omitted in specific cases of singular or plural.  */
  struct argument_range range;

  /* Do we want the string to be wrapped in the emitted PO file?  */
  enum is_wrap do_wrap;

  /* Do we want to apply or inhibit extra syntax checks on the string?
     This is only relevant within xgettext.  */
  enum is_syntax_check do_syntax_check[NSYNTAXCHECKS];

  /* The prev_msgctxt, prev_msgid and prev_msgid_plural strings appearing
     before the message, if present.  Generated by msgmerge.  */
  const char *prev_msgctxt;
  const char *prev_msgid;
  const char *prev_msgid_plural;

  /* If set the message is obsolete and while writing out it should be
     commented out.  */
  bool obsolete;

  /* Used for checking that messages have been used, in the msgcmp,
     msgmerge, msgcomm and msgcat programs.  */
  int used;

  /* Used for looking up the target message, in the msgcat program.  */
  message_ty *tmp;

  /* Used for combining alternative translations, in the msgcat program.  */
  int alternative_count;
  struct altstr *alternative;
};

extern message_ty *
       message_alloc (const char *msgctxt,
                      const char *msgid, const char *msgid_plural,
                      const char *msgstr, size_t msgstr_len,
                      const lex_pos_ty *pp);
#define is_header(mp) ((mp)->msgctxt == NULL && (mp)->msgid[0] == '\0')
extern void
       message_free (message_ty *mp);
extern void
       message_comment_append (message_ty *mp, const char *comment);
extern void
       message_comment_dot_append (message_ty *mp, const char *comment);
extern void
       message_comment_filepos (message_ty *mp,
                                const char *file_name, size_t line_number);
extern message_ty *
       message_copy (message_ty *mp);


typedef struct message_list_ty message_list_ty;
struct message_list_ty
{
  message_ty **item;
  size_t nitems;
  size_t nitems_max;
  bool use_hashtable;
  hash_table htable;    /* Table mapping msgid to 'message_ty *'.  */
};

/* Create a fresh message list.
   If USE_HASHTABLE is true, a hash table will be used to speed up
   message_list_search().  USE_HASHTABLE can only be set to true if it is
   known that the message list will not contain duplicate msgids.  */
extern message_list_ty *
       message_list_alloc (bool use_hashtable);
/* Free a message list.
   If keep_messages = 0, also free the messages.  If keep_messages = 1, don't
   free the messages.  */
extern void
       message_list_free (message_list_ty *mlp, int keep_messages);
extern void
       message_list_append (message_list_ty *mlp, message_ty *mp);
extern void
       message_list_prepend (message_list_ty *mlp, message_ty *mp);
extern void
       message_list_insert_at (message_list_ty *mlp, size_t n, message_ty *mp);
extern void
       message_list_delete_nth (message_list_ty *mlp, size_t n);
typedef bool message_predicate_ty (const message_ty *mp);
extern void
       message_list_remove_if_not (message_list_ty *mlp,
                                   message_predicate_ty *predicate);
/* Recompute the hash table of a message list after the msgids or msgctxts
   changed.  */
extern bool
       message_list_msgids_changed (message_list_ty *mlp);
/* Copy a message list.
   If copy_level = 0, also copy the messages.  If copy_level = 1, share the
   messages.  */
extern message_list_ty *
       message_list_copy (message_list_ty *mlp, int copy_level);
extern message_ty *
       message_list_search (const message_list_ty *mlp,
                            const char *msgctxt, const char *msgid);
/* Return the message in MLP which maximizes the fuzzy_search_goal_function.
   Only messages with a fuzzy_search_goal_function > FUZZY_THRESHOLD are
   considered.  In case of several messages with the same goal function value,
   the one with the smaller index is returned.  */
extern message_ty *
       message_list_search_fuzzy (message_list_ty *mlp,
                                  const char *msgctxt, const char *msgid);


typedef struct message_list_list_ty message_list_list_ty;
struct message_list_list_ty
{
  message_list_ty **item;
  size_t nitems;
  size_t nitems_max;
};

extern message_list_list_ty *
       message_list_list_alloc (void);
/* Free a list of message lists.
   If keep_level = 0, also free the messages.  If keep_level = 1, don't free
   the messages but free the lists.  If keep_level = 2, don't free the
   the messages and the lists.  */
extern void
       message_list_list_free (message_list_list_ty *mllp, int keep_level);
extern void
       message_list_list_append (message_list_list_ty *mllp,
                                 message_list_ty *mlp);
extern void
       message_list_list_append_list (message_list_list_ty *mllp,
                                      message_list_list_ty *mllp2);
extern message_ty *
       message_list_list_search (message_list_list_ty *mllp,
                                 const char *msgctxt, const char *msgid);
extern message_ty *
       message_list_list_search_fuzzy (message_list_list_ty *mllp,
                                       const char *msgctxt, const char *msgid);


typedef struct msgdomain_ty msgdomain_ty;
struct msgdomain_ty
{
  const char *domain;
  message_list_ty *messages;
};

extern msgdomain_ty *
       msgdomain_alloc (const char *domain, bool use_hashtable);
extern void
       msgdomain_free (msgdomain_ty *mdp);


typedef struct msgdomain_list_ty msgdomain_list_ty;
struct msgdomain_list_ty
{
  msgdomain_ty **item;
  size_t nitems;
  size_t nitems_max;
  bool use_hashtable;
  const char *encoding;         /* canonicalized encoding or NULL if unknown */
};

extern msgdomain_list_ty *
       msgdomain_list_alloc (bool use_hashtable);
extern void
       msgdomain_list_free (msgdomain_list_ty *mdlp);
extern void
       msgdomain_list_append (msgdomain_list_ty *mdlp, msgdomain_ty *mdp);
extern void
       msgdomain_list_append_list (msgdomain_list_ty *mdlp,
                                   msgdomain_list_ty *mdlp2);
extern message_list_ty *
       msgdomain_list_sublist (msgdomain_list_ty *mdlp, const char *domain,
                               bool create);
/* Copy a message domain list.
   If copy_level = 0, also copy the messages.  If copy_level = 1, share the
   messages but copy the domains.  If copy_level = 2, share the domains.  */
extern msgdomain_list_ty *
       msgdomain_list_copy (msgdomain_list_ty *mdlp, int copy_level);
extern message_ty *
       msgdomain_list_search (msgdomain_list_ty *mdlp,
                              const char *msgctxt, const char *msgid);
extern message_ty *
       msgdomain_list_search_fuzzy (msgdomain_list_ty *mdlp,
                                    const char *msgctxt, const char *msgid);


/* The goal function used in fuzzy search.
   Higher values indicate a closer match.
   If the result is < LOWER_BOUND, an arbitrary other value < LOWER_BOUND can
   be returned.  */
extern double
       fuzzy_search_goal_function (const message_ty *mp,
                                   const char *msgctxt, const char *msgid,
                                   double lower_bound);

/* The threshold for fuzzy-searching.
   A message is considered only if
   fuzzy_search_goal_function (mp, given, 0.0) > FUZZY_THRESHOLD.  */
#define FUZZY_THRESHOLD 0.6


#ifdef __cplusplus
}
#endif


#endif /* message.h */
