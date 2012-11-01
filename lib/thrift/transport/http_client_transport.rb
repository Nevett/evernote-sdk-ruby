# encoding: ascii-8bit
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements. See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership. The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License. You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied. See the License for the
# specific language governing permissions and limitations
# under the License.
#

require 'net/http'
require 'net/https'
require 'uri'
require 'stringio'

module Thrift
  class HTTPClientTransport < BaseTransport

    def initialize(url, proxy_addr = nil, proxy_port = nil)
      @url = URI url
      @headers = default_headers
      @outbuf = ""
      @proxy_addr = proxy_addr
      @proxy_port = proxy_port
    end

    def open?; true end
    def read(sz); @inbuf.read sz end
    def write(buf); @outbuf << buf end

    def add_headers(headers)
      @headers = @headers.merge(headers)
    end

    def flush
      http = Net::HTTP.new @url.host, @url.port, @proxy_addr, @proxy_port
      http.use_ssl = @url.scheme == "https"
      resp = http.post(@url.request_uri, @outbuf, @headers)
      @inbuf = StringIO.new resp.body
      @outbuf = ""
    end

    private
    def default_headers
      sdk_version = "#{Evernote::EDAM::UserStore::EDAM_VERSION_MAJOR}.#{Evernote::EDAM::UserStore::EDAM_VERSION_MINOR}" rescue 'NA'
      {'Content-Type' => 'application/x-thrift',
        'User-Agent' => "Evernote SDK Ruby / #{sdk_version}; Ruby / #{RUBY_VERSION};"}
    end

  end
end
