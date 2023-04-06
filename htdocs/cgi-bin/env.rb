#!/usr/bin/env ruby
# -*- coding: None -*-

require 'cgi'       //cgi file to create a simple cgi object.
  cgi = CGI.new      //instantiating a cgi object.
  puts cgi.header   //thats telling the server about the type(html).
  puts "hello"      // thats the output on the browser.
