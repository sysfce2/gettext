# gettext.m4
# serial 84 (gettext-0.27)
dnl Copyright (C) 1995-2025 Free Software Foundation, Inc.
dnl This file is free software; the Free Software Foundation
dnl gives unlimited permission to copy and/or distribute it,
dnl with or without modifications, as long as this notice is preserved.
dnl This file is offered as-is, without any warranty.
dnl
dnl This file can be used in projects which are not available under
dnl the GNU General Public License or the GNU Lesser General Public
dnl License but which still want to provide support for the GNU gettext
dnl functionality.
dnl Please note that the actual code of the GNU gettext library is covered
dnl by the GNU Lesser General Public License, and the rest of the GNU
dnl gettext package is covered by the GNU General Public License.
dnl They are *not* in the public domain.

dnl Authors:
dnl   Ulrich Drepper <drepper@cygnus.com>, 1995-2000.
dnl   Bruno Haible <bruno@clisp.org>, 2000-2025.

dnl Macro to add for using GNU gettext.

dnl Usage: AM_GNU_GETTEXT([INTLSYMBOL], [NEEDSYMBOL], [INTLDIR]).
dnl INTLSYMBOL must be one of 'external', 'use-libtool', 'here'.
dnl    INTLSYMBOL should be 'external' for packages other than GNU gettext.
dnl    It should be 'use-libtool' for the packages 'gettext-runtime' and
dnl    'gettext-tools'.
dnl    It should be 'here' for the package 'gettext-runtime/intl'.
dnl    If INTLSYMBOL is 'here', then a libtool library
dnl    $(top_builddir)/libintl.la will be created (shared and/or static,
dnl    depending on --{enable,disable}-{shared,static} and on the presence of
dnl    AM-DISABLE-SHARED).
dnl If NEEDSYMBOL is specified and is 'need-ngettext', then GNU gettext
dnl    implementations (in libc or libintl) without the ngettext() function
dnl    will be ignored.  If NEEDSYMBOL is specified and is
dnl    'need-formatstring-macros', then GNU gettext implementations that don't
dnl    support the ISO C 99 <inttypes.h> formatstring macros will be ignored.
dnl INTLDIR is used to find the intl libraries.  If empty,
dnl    the value '$(top_builddir)/intl/' is used.
dnl
dnl The result of the configuration is one of three cases:
dnl 1) GNU gettext, as included in the intl subdirectory, will be compiled
dnl    and used.
dnl    Catalog format: GNU --> install in $(datadir)
dnl    Catalog extension: .mo after installation, .gmo in source tree
dnl 2) GNU gettext has been found in the system's C library.
dnl    Catalog format: GNU --> install in $(datadir)
dnl    Catalog extension: .mo after installation, .gmo in source tree
dnl 3) No internationalization, always use English msgid.
dnl    Catalog format: none
dnl    Catalog extension: none
dnl If INTLSYMBOL is 'external', only cases 2 and 3 can occur.
dnl The use of .gmo is historical (it was needed to avoid overwriting the
dnl GNU format catalogs when building on a platform with an X/Open gettext),
dnl but we keep it in order not to force irrelevant filename changes on the
dnl maintainers.
dnl
AC_DEFUN([AM_GNU_GETTEXT],
[
  dnl Argument checking.
  m4_if([$1], [], , [m4_if([$1], [external], , [m4_if([$1], [use-libtool], , [m4_if([$1], [here], ,
    [errprint([ERROR: invalid first argument to AM_GNU_GETTEXT
])])])])])
  m4_if(m4_if([$1], [], [old])[]m4_if([$1], [no-libtool], [old]), [old],
    [errprint([ERROR: Use of AM_GNU_GETTEXT without [external] argument is no longer supported.
])])
  m4_if([$2], [], , [m4_if([$2], [need-ngettext], , [m4_if([$2], [need-formatstring-macros], ,
    [errprint([ERROR: invalid second argument to AM_GNU_GETTEXT
])])])])
  define([gt_building_libintl_in_same_build_tree],
    m4_if([$1], [use-libtool], [yes], [m4_if([$1], [here], [yes], [no])]))
  gt_NEEDS_INIT
  AM_GNU_GETTEXT_NEED([$2])

  AC_REQUIRE([AM_PO_SUBDIRS])dnl

  dnl Prerequisites of AC_LIB_LINKFLAGS_BODY.
  AC_REQUIRE([AC_LIB_PREPARE_PREFIX])
  AC_REQUIRE([AC_LIB_RPATH])

  dnl Sometimes libintl requires libiconv, so first search for libiconv.
  dnl Ideally we would do this search only after the
  dnl      if test "$USE_NLS" = "yes"; then
  dnl        if { eval "gt_val=\$$gt_func_gnugettext_libc"; test "$gt_val" != "yes"; }; then
  dnl tests. But if configure.ac invokes AM_ICONV after AM_GNU_GETTEXT
  dnl the configure script would need to contain the same shell code
  dnl again, outside any 'if'. There are two solutions:
  dnl - Invoke AM_ICONV_LINKFLAGS_BODY here, outside any 'if'.
  dnl - Control the expansions in more detail using AC_PROVIDE_IFELSE.
  dnl Since AC_PROVIDE_IFELSE is not documented, we avoid it.
  m4_if(gt_building_libintl_in_same_build_tree, yes, , [
    AC_REQUIRE([AM_ICONV_LINKFLAGS_BODY])
  ])

  dnl Sometimes, on Mac OS X, libintl requires linking with CoreFoundation.
  gt_INTL_MACOSX

  dnl Set USE_NLS.
  AC_REQUIRE([AM_NLS])

  m4_if(gt_building_libintl_in_same_build_tree, yes, [
    USE_INCLUDED_LIBINTL=no
  ])
  LIBINTL=
  LTLIBINTL=
  POSUB=

  dnl Add a version number to the cache macros.
  case " $gt_needs " in
    *" need-formatstring-macros "*) gt_api_version=3 ;;
    *" need-ngettext "*) gt_api_version=2 ;;
    *) gt_api_version=1 ;;
  esac
  gt_func_gnugettext_libc="gt_cv_func_gnugettext${gt_api_version}_libc"
  gt_func_gnugettext_libintl="gt_cv_func_gnugettext${gt_api_version}_libintl"

  dnl If we use NLS figure out what method
  if test "$USE_NLS" = "yes"; then
    gt_use_preinstalled_gnugettext=no
    m4_if(gt_building_libintl_in_same_build_tree, yes, [
      AC_MSG_CHECKING([whether included libintl is requested])
      AC_ARG_WITH([included-libintl],
        [  --with-included-libintl use the GNU libintl library included here],
        gt_cv_force_use_gnu_libintl=$withval,
        gt_cv_force_use_gnu_libintl=no)
      AC_MSG_RESULT([$gt_cv_force_use_gnu_libintl])

      gt_cv_use_gnu_libintl="$gt_cv_force_use_gnu_libintl"
      if test "$gt_cv_force_use_gnu_libintl" != "yes"; then
    ])
        dnl User does not insist on using GNU NLS library.  Figure out what
        dnl to use.  If GNU gettext is available we use this.  Else we have
        dnl to fall back to GNU NLS library.

        if test $gt_api_version -ge 3; then
          gt_revision_test_code='
#ifndef __GNU_GETTEXT_SUPPORTED_REVISION
#define __GNU_GETTEXT_SUPPORTED_REVISION(major) ((major) == 0 ? 0 : -1)
#endif
changequote(,)dnl
typedef int array [2 * (__GNU_GETTEXT_SUPPORTED_REVISION(0) >= 1) - 1];
changequote([,])dnl
'
        else
          gt_revision_test_code=
        fi
        if test $gt_api_version -ge 2; then
          gt_expression_test_code=' + * ngettext ("", "", 0)'
        else
          gt_expression_test_code=
        fi

        dnl In the test code below:
        dnl * We test for the presence of _nl_msg_cat_cntr because GNU libc and
        dnl   libintl define this variable, whereas Solaris 10 libc/libintl
        dnl   (which we don't want to use, as it does not support GNU .mo files)
        dnl   does not define it.
        dnl * We don't test for _nl_msg_cat_cntr on MSVC, because the use of a
        dnl   variable under MSVC depends on whether it is exported by a shared
        dnl   library or a static library: If libintl is a shared library, we
        dnl   would have to declare it with __declspec(dllimport), whereas if it
        dnl   is a static library, we would have to declare it without such a
        dnl   __declspec. But libintl comes with just one header file,
        dnl   <libintl.h>, that does not declare _nl_msg_cat_cntr and that does
        dnl   not tell us whether the library was built shared or static.
        dnl * We test for the presence of _nl_domain_bindings because GNU libc
        dnl   defines this variable, whereas NetBSD libc (which we don't want to
        dnl   use, as it was broken at least in 2002) does not define it.
        dnl * We test for the presence of _nl_expand_alias because GNU libintl
        dnl   defines this function, whereas NetBSD libintl (which we don't want
        dnl   to use, as it was broken at least in 2002) does not define it.

        AC_CACHE_CHECK([for GNU gettext in libc], [$gt_func_gnugettext_libc],
         [AC_LINK_IFELSE(
            [AC_LANG_PROGRAM(
               [[
#include <libintl.h>
#ifndef __GNU_GETTEXT_SUPPORTED_REVISION
#if defined _MSC_VER
#define _nl_msg_cat_cntr 0
#else
extern int _nl_msg_cat_cntr;
#endif
extern int *_nl_domain_bindings;
#define __GNU_GETTEXT_SYMBOL_EXPRESSION (_nl_msg_cat_cntr + *_nl_domain_bindings)
#else
#define __GNU_GETTEXT_SYMBOL_EXPRESSION 0
#endif
$gt_revision_test_code
               ]],
               [[
bindtextdomain ("", "");
return * gettext ("")$gt_expression_test_code + __GNU_GETTEXT_SYMBOL_EXPRESSION
               ]])],
            [dnl Solaris 11.[0-3] doesn't strip the CODESET part from the locale name,
             dnl when looking for a message catalog. E.g. when the locale is fr_FR.UTF-8,
             dnl on Solaris 11.[0-3] it looks for
             dnl   <LOCALEDIR>/fr_FR.UTF-8/LC_MESSAGES/<domain>.mo
             dnl   <LOCALEDIR>/fr.UTF-8/LC_MESSAGES/<domain>.mo
             dnl Similarly, on Solaris 11 OpenIndiana and Solaris 11 OmniOS it looks only for
             dnl   <LOCALEDIR>/fr_FR.UTF-8/LC_MESSAGES/<domain>.mo
             dnl Reported at <https://www.illumos.org/issues/13423>.
             dnl On Solaris 11.4 this is fixed: it looks for
             dnl   <LOCALEDIR>/fr_FR.UTF-8/LC_MESSAGES/<domain>.mo
             dnl   <LOCALEDIR>/fr.UTF-8/LC_MESSAGES/<domain>.mo
             dnl   <LOCALEDIR>/fr_FR/LC_MESSAGES/<domain>.mo
             dnl   <LOCALEDIR>/fr/LC_MESSAGES/<domain>.mo
             if test "`uname -sr`" = 'SunOS 5.11'; then
               case `uname -v` in
                 11.4 | 11.4.*) eval "$gt_func_gnugettext_libc=yes" ;;
                 *)             eval "$gt_func_gnugettext_libc=no" ;;
               esac
             else
               eval "$gt_func_gnugettext_libc=yes"
             fi
            ],
            [eval "$gt_func_gnugettext_libc=no"])])

        if { eval "gt_val=\$$gt_func_gnugettext_libc"; test "$gt_val" != "yes"; }; then
          dnl Sometimes libintl requires libiconv, so first search for libiconv.
          m4_if(gt_building_libintl_in_same_build_tree, yes, , [
            AM_ICONV_LINK
          ])
          dnl Search for libintl and define LIBINTL, LTLIBINTL and INCINTL
          dnl accordingly. Don't use AC_LIB_LINKFLAGS_BODY([intl],[iconv])
          dnl because that would add "-liconv" to LIBINTL and LTLIBINTL
          dnl even if libiconv doesn't exist.
          AC_LIB_LINKFLAGS_BODY([intl])
          AC_CACHE_CHECK([for GNU gettext in libintl],
            [$gt_func_gnugettext_libintl],
           [gt_saved_CPPFLAGS="$CPPFLAGS"
            CPPFLAGS="$CPPFLAGS $INCINTL"
            gt_saved_LIBS="$LIBS"
            LIBS="$LIBS $LIBINTL"
            dnl Now see whether libintl exists and does not depend on libiconv.
            AC_LINK_IFELSE(
              [AC_LANG_PROGRAM(
                 [[
#include <libintl.h>
#ifndef __GNU_GETTEXT_SUPPORTED_REVISION
#if defined _MSC_VER
#define _nl_msg_cat_cntr 0
#else
extern int _nl_msg_cat_cntr;
#endif
extern
#ifdef __cplusplus
"C"
#endif
const char *_nl_expand_alias (const char *);
#define __GNU_GETTEXT_SYMBOL_EXPRESSION (_nl_msg_cat_cntr + *_nl_expand_alias (""))
#else
#define __GNU_GETTEXT_SYMBOL_EXPRESSION 0
#endif
$gt_revision_test_code
                 ]],
                 [[
bindtextdomain ("", "");
return * gettext ("")$gt_expression_test_code + __GNU_GETTEXT_SYMBOL_EXPRESSION
                 ]])],
              [eval "$gt_func_gnugettext_libintl=yes"],
              [eval "$gt_func_gnugettext_libintl=no"])
            dnl Now see whether libintl exists and depends on libiconv or other
            dnl OS dependent libraries, specifically on macOS and AIX.
            gt_LIBINTL_EXTRA="$INTL_MACOSX_LIBS"
            AC_REQUIRE([AC_CANONICAL_HOST])
            case "$host_os" in
              aix*) gt_LIBINTL_EXTRA="-lpthread" ;;
            esac
            if { eval "gt_val=\$$gt_func_gnugettext_libintl"; test "$gt_val" != yes; } \
               && { test -n "$LIBICONV" || test -n "$gt_LIBINTL_EXTRA"; }; then
              LIBS="$LIBS $LIBICONV $gt_LIBINTL_EXTRA"
              AC_LINK_IFELSE(
                [AC_LANG_PROGRAM(
                   [[
#include <libintl.h>
#ifndef __GNU_GETTEXT_SUPPORTED_REVISION
#if defined _MSC_VER
#define _nl_msg_cat_cntr 0
#else
extern int _nl_msg_cat_cntr;
#endif
extern
#ifdef __cplusplus
"C"
#endif
const char *_nl_expand_alias (const char *);
#define __GNU_GETTEXT_SYMBOL_EXPRESSION (_nl_msg_cat_cntr + *_nl_expand_alias (""))
#else
#define __GNU_GETTEXT_SYMBOL_EXPRESSION 0
#endif
$gt_revision_test_code
                   ]],
                   [[
bindtextdomain ("", "");
return * gettext ("")$gt_expression_test_code + __GNU_GETTEXT_SYMBOL_EXPRESSION
                   ]])],
                [LIBINTL="$LIBINTL $LIBICONV $gt_LIBINTL_EXTRA"
                 LTLIBINTL="$LTLIBINTL $LTLIBICONV $gt_LIBINTL_EXTRA"
                 eval "$gt_func_gnugettext_libintl=yes"
                ])
            fi
            CPPFLAGS="$gt_saved_CPPFLAGS"
            LIBS="$gt_saved_LIBS"])
        fi

        dnl If an already present or preinstalled GNU gettext() is found,
        dnl use it.  But if this macro is used in GNU gettext, and GNU
        dnl gettext is already preinstalled in libintl, we update this
        dnl libintl.  (Cf. the install rule in intl/Makefile.in.)
        if { eval "gt_val=\$$gt_func_gnugettext_libc"; test "$gt_val" = "yes"; } \
           || { { eval "gt_val=\$$gt_func_gnugettext_libintl"; test "$gt_val" = "yes"; } \
                && test "$PACKAGE" != gettext-runtime \
                && test "$PACKAGE" != gettext-tools \
                && test "$PACKAGE" != libintl; }; then
          gt_use_preinstalled_gnugettext=yes
        else
          dnl Reset the values set by searching for libintl.
          LIBINTL=
          LTLIBINTL=
          INCINTL=
        fi

    m4_if(gt_building_libintl_in_same_build_tree, yes, [
        if test "$gt_use_preinstalled_gnugettext" != "yes"; then
          dnl GNU gettext is not found in the C library.
          dnl Fall back on included GNU gettext library.
          gt_cv_use_gnu_libintl=yes
        fi
      fi

      AC_REQUIRE([AC_CANONICAL_HOST])
      if test "$gt_cv_use_gnu_libintl" = "yes" \
         || case "$host_os" in cygwin*) true;; *) false;; esac; then
        dnl GNU gettext is not found in the C library or is,
        dnl like on Cygwin, a component of the C library.
        dnl Mark actions used to generate GNU NLS library.
        USE_INCLUDED_LIBINTL=yes
        LIBINTL="m4_if([$3],[],\${top_builddir}/intl,[$3])/libintl.la $LIBICONV $LIBTHREAD"
        LTLIBINTL="m4_if([$3],[],\${top_builddir}/intl,[$3])/libintl.la $LTLIBICONV $LTLIBTHREAD"
        LIBS=`echo " $LIBS " | sed -e 's/ -lintl / /' -e 's/^ //' -e 's/ $//'`
      fi

      CATOBJEXT=
      if test "$gt_use_preinstalled_gnugettext" = "yes" \
         || test "$gt_cv_use_gnu_libintl" = "yes"; then
        dnl Mark actions to use GNU gettext tools.
        CATOBJEXT=.gmo
      fi
    ])

    if test -n "$INTL_MACOSX_LIBS"; then
      if test "$gt_use_preinstalled_gnugettext" = "yes" \
         || test "$gt_cv_use_gnu_libintl" = "yes"; then
        dnl Some extra flags are needed during linking.
        LIBINTL="$LIBINTL $INTL_MACOSX_LIBS"
        LTLIBINTL="$LTLIBINTL $INTL_MACOSX_LIBS"
      fi
    fi

    if test "$gt_use_preinstalled_gnugettext" = "yes" \
       || test "$gt_cv_use_gnu_libintl" = "yes"; then
      AC_DEFINE([ENABLE_NLS], [1],
        [Define to 1 if translation of program messages to the user's native language
   is requested.])
    else
      USE_NLS=no
    fi
  fi

  AC_MSG_CHECKING([whether to use NLS])
  AC_MSG_RESULT([$USE_NLS])
  if test "$USE_NLS" = "yes"; then
    AC_MSG_CHECKING([where the gettext function comes from])
    if test "$gt_use_preinstalled_gnugettext" = "yes"; then
      if { eval "gt_val=\$$gt_func_gnugettext_libintl"; test "$gt_val" = "yes"; }; then
        gt_source="external libintl"
      else
        gt_source="libc"
      fi
    else
      gt_source="included intl directory"
    fi
    AC_MSG_RESULT([$gt_source])
  fi

  if test "$USE_NLS" = "yes"; then

    if test "$gt_use_preinstalled_gnugettext" = "yes"; then
      if { eval "gt_val=\$$gt_func_gnugettext_libintl"; test "$gt_val" = "yes"; }; then
        AC_MSG_CHECKING([how to link with libintl])
        AC_MSG_RESULT([$LIBINTL])
        AC_LIB_APPENDTOVAR([CPPFLAGS], [$INCINTL])
      fi

      dnl For backward compatibility. Some packages may be using this.
      AC_DEFINE([HAVE_GETTEXT], [1],
       [Define if the GNU gettext() function is already present or preinstalled.])
      AC_DEFINE([HAVE_DCGETTEXT], [1],
       [Define if the GNU dcgettext() function is already present or preinstalled.])
    fi

    dnl We need to process the po/ directory.
    POSUB=po
  fi

  m4_if(gt_building_libintl_in_same_build_tree, yes, [
    dnl Make all variables we use known to autoconf.
    AC_SUBST([USE_INCLUDED_LIBINTL])
    AC_SUBST([CATOBJEXT])
  ])

  m4_if(gt_building_libintl_in_same_build_tree, yes, [], [
    dnl For backward compatibility. Some Makefiles may be using this.
    INTLLIBS="$LIBINTL"
    AC_SUBST([INTLLIBS])
  ])

  dnl Make all documented variables known to autoconf.
  AC_SUBST([LIBINTL])
  AC_SUBST([LTLIBINTL])
  AC_SUBST([POSUB])

  dnl Define localedir_c and localedir_c_make.
  gl_BUILD_TO_HOST_LOCALEDIR
])


dnl gt_NEEDS_INIT ensures that the gt_needs variable is initialized.
m4_define([gt_NEEDS_INIT],
[
  m4_divert_text([DEFAULTS], [gt_needs=])
  m4_define([gt_NEEDS_INIT], [])
])


dnl Usage: AM_GNU_GETTEXT_NEED([NEEDSYMBOL])
AC_DEFUN([AM_GNU_GETTEXT_NEED],
[
  m4_divert_text([INIT_PREPARE], [gt_needs="$gt_needs $1"])
])


dnl Usage: AM_GNU_GETTEXT_VERSION([gettext-version])
AC_DEFUN([AM_GNU_GETTEXT_VERSION], [])


dnl Usage: AM_GNU_GETTEXT_REQUIRE_VERSION([gettext-version])
AC_DEFUN([AM_GNU_GETTEXT_REQUIRE_VERSION], [])
