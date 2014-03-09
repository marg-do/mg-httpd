#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require "socket"

port = 8001
VERSION = "mg-httpd 0.0.1"
WWW_ROOT_PATH = "/var/www"
ERROR_404 = "404 Error!"
PAGE_ROOT = "index.html"

header = <<EOS
HTTP/1.1 200 OK
Content-Type: text/html; charset=UTF-8
Server: #{VERSION}
Connection: close

EOS

def log(l)
  p l
end

def request_path(req)
  path = req.scan(/GET (.*) HTTP/)[0][0]
  path = "/" + PAGE_ROOT if path == "/"
  WWW_ROOT_PATH + path
end

def read_content(path)
  content = File.read(path)
  if content[0..1] =="#!"
    exe = content.scan(/#!(.*)\n/)[0][0]
    content = `#{exe} #{path}`
    log "#{exe} #{path}"
  end

  content
rescue
  ERROR_404
end

server = TCPServer.open(port)

while true
  Thread.start(server.accept) do |socket|
    log socket.peeraddr

    request = socket.gets
    log request

    if request.include? "GET"
      socket.write header + read_content(request_path(request))
      log request_path(request)
    end

    socket.close
  end
end

server.close
