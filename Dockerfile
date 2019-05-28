# Copyright 2019 Nextdoor.com, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License"); 
# you may not use this file except in compliance with the License. 
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software 
# distributed under the License is distributed on an "AS IS" BASIS, 
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
# See the License for the specific language governing permissions and 
# limitations under the License.

# Ubuntu:18.04 on 19 April 2019
FROM ubuntu@sha256:017eef0b616011647b269b5c65826e2e2ebddbe5d1f8c1e56b3599fb14fabec8

# create a non-privileged user for installing tools
RUN groupadd -g 7001 tool && \
    useradd -u 7001 -g tool -m -s /bin/bash tool

# create a non-privileged user for using tools
RUN groupadd -g 1000 user && \
    useradd -u 1000 -g user -m -s /bin/bash user && \
    usermod -a -G tool user

# entrypoint script to fix permissions for user user
COPY entrypoint.sh /usr/bin/entrypoint.sh
RUN chmod 755 /usr/bin/entrypoint.sh

# frequently required tools
RUN apt-get update && apt-get install -y \
    git=1:2.17.1-1ubuntu0.4 \
    gosu=1.10-1 \
    make=4.1-9.1ubuntu1 \
    wget=1.19.4-1ubuntu2.2

# tools are installed here
RUN mkdir -p /tool/bin /tool/lib /tool/etc && chown -R tool:tool /tool
RUN mkdir -p /work/target && chown -R user:user /work

# workspace files are mounted here
VOLUME [ "/work/target" ]
WORKDIR /work/target

# /tool/bin is on the path
ENV PATH "$PATH:/tool/bin"
ENV TOOLS_PATH_WORK "/work"
ENV TOOLS_PATH_TARGET "/work/target"

# entrypoint adjusts user to match uid:gid of /work and drops root
ENTRYPOINT ["/usr/bin/entrypoint.sh"]
