# $Id: GNUmakefile,v 1.11 2004/12/08 21:20:43 marcel Exp $


OBJC_RUNTIME_LIB=ng

#include $(GNUSTEP_MAKEFILES)/common.make

FRAMEWORK_NAME = ObjectiveHTTPD

GNUSTEP_LOCAL_ADDITIONAL_MAKEFILES=base.make
GNUSTEP_BUILD_DIR = ~/Build

include $(GNUSTEP_MAKEFILES)/common.make


LIBRARY_NAME = libObjectiveHTTPD
CC = clang


OBJCFLAGS += -Wno-import -fobjc-runtime=gnustep-2


ObjectiveHTTPD_HEADER_FILES = \


ObjectiveHTTPD_HEADER_FILES_INSTALL_DIR = /ObjectiveHTTPD


libObjectiveHTTPD_OBJC_FILES = \
    MPWTemplater.m \
    MPWHTTPServer.m \
    MPWSiteMap.m \
    MPWSiteServer.m \
    MPWHTMLRenderScheme.m \
    WAHtmlRenderer.m \
    MPWHtmlPage.m \
    MPWPlainHtmlContent.m \
    MPWPlainCSSContent.m \
    MPWSchemeHttpServer.m \
    MPWPOSTProcessor.m \


libObjectiveHTTPD_C_FILES = \




LIBRARIES_DEPEND_UPON +=  -lMPWFoundation -lgnustep-base

LDFLAGS += -L /home/gnustep/Build/obj 


libObjectiveHTTPD_INCLUDE_DIRS += -I.headers -I. -I../MPWFoundation/.headers/   -I../ObjectiveSmalltalk/.headers/

-include GNUmakefile.preamble
include $(GNUSTEP_MAKEFILES)/library.make
-include GNUmakefile.postamble

before-all ::
	
#	@$(MKDIRS) $(libMPWFoundation_HEADER_FILES_DIR)
#	cp *.h $(libMPWFoundation_HEADER_FILES_DIR)
#	cp Collections.subproj/*.h $(libMPWFoundation_HEADER_FILES_DIR)
#	cp Comm.subproj/*.h        $(libMPWFoundation_HEADER_FILES_DIR)
#	cp Streams.subproj/*.h     $(libMPWFoundation_HEADER_FILES_DIR)
#	cp Threading.subproj/*.h   $(libMPWFoundation_HEADER_FILES_DIR)

after-clean ::
	rm -rf .headers


test    : libObjectiveHTTPD tester
	LD_LIBRARY_PATH=/home/gnustep/GNUstep/Library/Libraries:/usr/local/lib:/home/gnustep/Build/obj/  ./TestObjectiveSmalltalk/testobjectivesmalltalk

tester  :
	clang -fobjc-runtime=gnustep-2 -I../MPWFoundation/.headers/ -I.headers -o testobjectivehttpd testobjectivehttpd.m -L/home/gnustep/Build/obj -lObjectiveHTTPD -lMPWFoundation -lgnustep-base -L/usr/local/lib/ -lobjc
