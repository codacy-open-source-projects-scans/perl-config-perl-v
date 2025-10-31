#!/usr/bin/sh

# put this file in the perl source tree and run 'Configure -ds'

man1dir=/pro/local/man/man1
man3dir=/pro/local/man/man3

case "$versiononly" in
    '') versiononly=$undef ;;
    esac
case "$cc" in
    clang*) ;;
    '')     cc="ccache cc"  ;;
    *)      cc="ccache $cc" ;;
    esac
case "$cc" in
    *g++*|*gcc*) case "$cc" in
		    *64*)	prefix=/opt/perl64	;;
		    *)		prefix=/opt/perl	;;
		    esac
		man1dir=$prefix"/man/man1"
		man3dir=$prefix"/man/man3"
		perladmin='root@localhost'
		cf_email='root@localhost'
		versiononly=$undef
		;;
    *)		prefix=/pro
		cc=cc
		if [ -x /pro/bin/perl ]; then
		    if [ `/pro/bin/perl -e '$v="5";while(<>){m/#define\s+PERL_(?:SUB)?VERSION\s+(\d+)/ and$v.=".$1"}$v=~s/\.(.)\./.00\1/;print STDERR "$v <=> $]\n";$]<$v?1:0' $src/patchlevel.h` ]; then
			versiononly=$define
			installusrbinperl='undef'
			fi
		    fi
		perladmin='h.m.brand@procura.nl'
		cf_email='h.m.brand@procura.nl'
		;;
    esac
perladmin='hmbrand@cpan.org'
cf_email='hmbrand@cpan.org'

[ "X$OSTYPE" = "X" ] && OSTYPE="$osname"
echo "===== PROCURA Policy for $OSTYPE/$cc ========================">&2

ccflags='-fPIC '
#ccflags=''
#ccflags=''
#ccflags='--coverage -fprofile-arcs -ftest-coverage'

extras='none'
inc_version_list='none'

libsdirs=' /lib /pro/local/lib'
libdirs=' /lib /pro/local/lib'
ldflags='-L/pro/local/lib'
#ldflags='-L/pro/local/lib --coverage -lgcov -fprofile-arcs'

locincpth='/pro/local/include'
loclibpth='/pro/local/lib'

#awk='gawk'
#_awk='/pro/local/bin/gawk'
#full_awk='/pro/local/bin/gawk'
csh='tcsh'
#_csh='/pro/bin/tcsh'
#full_csh='/pro/bin/tcsh'

case "$cc" in
    clang*)
	ccflags="$ccflags -fsanitize=address"
	ldflags="$ccflags -fsanitize=address"
	lddlflags="$ccflags -shared -fsanitize=address"
	;;
    esac

case "$OSTYPE" in
    aix)
	case "$cc" in
	    *gcc*)  if [ `uname -r` = 2 ]; then
			: AIX 4.2 does not support these options
		    else
			if [ "X$use64bitall" = "X" ]; then
			    ccflags="-maix32 $ccflags"
			else
			    ccflags="-maix64 $ccflags"
			    fi
			fi
		    ;;
	    *)	    if [ "$useithreads" = "define" ]; then
			cc=xlc_r
		    else
			cc=xlc
			fi
		    #optimize='-O2'
		    ;;
	    esac
	;;

    hpux)
	case "$cc" in
	    *gcc*)  if [ "X$use64bitint" = "X" -a "X$use64bitall" = "X" ]; then
			true
		    else
			cc=gcc64
			ldflags=''
			fi
		    case `uname -r` in
			B.10.20)	ccflags="-mpa-risc-1-1 $ccflags" ;;
			*)		ccflags="-mpa-risc-2-0 $ccflags" ;;
			esac
		    echo "      Using" `which $cc` >&4
		    echo 'int main(){long l;printf("%d\\n",sizeof(l));}'>try.c
		    $cc -o try $ccflags $ldflags try.c
		    if [ "`try`" = "8" ]; then
			echo "Your C compiler ($cc) is 64 bit native!" >&4
			PATH=/usr/local/pa20_64/bin:$PATH
			locincpth=' /usr/local/pa20_64/include'
			libsdirs=' /usr/local/pa20_64/lib /usr/lib/pa20_64'
			libdirs=' /usr/local/pa20_64/lib /usr/lib/pa20_64'
			loclibpth='/usr/local/pa20_64/lib'
			ldflags=''
			fi
		    rm -f try try.c
		    ;;
	    *)      case `uname -r` in
			B.10.20) ccflags="$ccflags +DAportable"	;;
			esac
		    # -fast = +O3 +Onolooptransform +Olibcalls +FPD +Oentrysched +Ofastaccess'
		    # optimize='+O2 +Onolooptransform +Olibcalls +FPD +Onolimit'

		    # For Oracle, will fail without perlio in threads
		    # 5.8.0 and up have useperlio in default
		    ;;
	    esac
	# For Oracle
	libswanted="cl pthread $libswanted"
	;;

    osf1)
	ccflags="$ccflags -std -D_INTRINSICS -D_INLINE_INTRINSICS"
	optimize='-O2'
	useshrplib='false'
	;;

    linux)
	awk='awk'
	_awk='/usr/bin/awk'
	full_awk='/usr/bin/awk'
	csh='tcsh'
	_csh='/usr/bin/tcsh'
	full_csh='/usr/bin/tcsh'
	;;

    cygwin)
	optimize=' '
	ccflags='-O'

	awk='awk'
	_awk='/usr/bin/awk'
	full_awk='/usr/bin/awk'
	csh='tcsh'
	_csh='/usr/bin/tcsh'
	full_csh='/usr/bin/tcsh'
	;;

    esac
