ObjectiveHTTPD
==============

Providing a simple and fast bridge between HTTP and Objective-Smalltalk (and Objective-C)



libmicrohttpd
---------------

Based on libmicrohttpd for the actual HTTP serving.  It assumes a pre-built library in /usr/local/lib.

Note:  

Use the following to configure libmicorhttpd fat for ARM64 + x86_64

 `CFLAGS='-no-cpp-precomp -fno-common -g -O2 -fno-strict-aliasing -arch x86_64 -arch arm64 '  ./configure`


Stores 
--------

Stores (also called scheme-handlers, or schemes for short) are an in-process analog to an HTTP server.  
So what _ObjectiveHTTPD_ does is map from actual HTTP requests to the store-API and back.


