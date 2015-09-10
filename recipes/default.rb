#
# Cookbook Name:: odi-cert-deployer
# Recipe:: default
#
# Copyright 2013, The Open Data Institute
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#

cert_for = node['cert']['name']
outfile  = node['cert']['file']

temp_file  = '/tmp/cert'
target_dir = "/etc/certs/%s" % [
    cert_for
]

directory target_dir do
  action :create
  recursive true
end

dbi = data_bag_item('certs', cert_for)

if dbi['cert'][0..30] == '-----BEGIN RSA PRIVATE KEY-----'
  file "#{target_dir}/#{outfile}" do
    action :create
    content dbi['cert']
  end
else
  file temp_file do
    action :create
    content dbi['cert']
  end

  script 'base64 (how low can you go?)' do
    interpreter 'bash'
    code <<-EOF
        openssl base64 -d -in #{temp_file} -out #{target_dir}/#{outfile}
    EOF
  end

  file temp_file do
    action :delete
  end
end
